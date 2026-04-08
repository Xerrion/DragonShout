-------------------------------------------------------------------------------
-- AuraListener.lua
-- Secondary CC-on-player detection via UNIT_AURA for redundancy
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local GetTime = GetTime
local math_floor = math.floor
local UnitDebuff = UnitDebuff
local C_UnitAuras = C_UnitAuras  -- nil on Classic, guarded below

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

local DEBOUNCE_WINDOW = 0.5

-------------------------------------------------------------------------------
-- Module
-------------------------------------------------------------------------------

ns.AuraListener = {}

-------------------------------------------------------------------------------
-- Debounce check
-- If the CLEU-based CCListener already announced this spell within
-- DEBOUNCE_WINDOW seconds, skip to avoid double-announce.
-------------------------------------------------------------------------------

local function IsRecentlyAnnounced(spellId)
    local lastTime = ns.Announcer.GetLastAnnounceTime(spellId, "ccOnYou")
    return (GetTime() - lastTime) < DEBOUNCE_WINDOW
end

-------------------------------------------------------------------------------
-- Announce CC on player (shared logic)
-------------------------------------------------------------------------------

local function AnnounceIfCC(spellId, spellName, duration)
    if not spellId then return end

    local IS_CC_SPELL = ns.CCListener.IS_CC_SPELL
    if not IS_CC_SPELL[spellId] then return end
    if IsRecentlyAnnounced(spellId) then return end

    local db = ns.Addon.db
    if not db then return end

    local ccType = ns.CCListener.CC_TYPE[spellId]
    if not ccType then return end
    local categoryConfig = db.profile.ccOnYou

    -- Check sub-toggle for specific CC type
    if categoryConfig[ccType] == false then return end

    local typeLabel = ns.CCListener.CC_TYPE_LABEL[ccType] or ""
    local durationStr = (duration and duration > 0) and tostring(math_floor(duration)) or nil

    ns.Announcer.Announce("ccOnYou", spellId, {
        spell = spellName or "Unknown",
        type = typeLabel,
        duration = durationStr,
    })
end

-------------------------------------------------------------------------------
-- Retail UNIT_AURA handler (with updateInfo)
-------------------------------------------------------------------------------

local function HandleRetailAura(_event, unitTarget, updateInfo)
    if unitTarget ~= "player" then return end
    if not updateInfo then return end

    if updateInfo.isFullUpdate then
        if not C_UnitAuras then return end
        local index = 1
        while true do
            local aura = C_UnitAuras.GetAuraDataByIndex("player", index, "HARMFUL")
            if not aura then break end
            AnnounceIfCC(aura.spellId, aura.name, aura.duration)
            index = index + 1
        end
        return
    end

    if updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
            if aura.isHarmful then
                AnnounceIfCC(aura.spellId, aura.name, aura.duration)
            end
        end
    end
end

-------------------------------------------------------------------------------
-- Classic UNIT_AURA handler (no updateInfo)
-- Tracks active CCs to only announce absent-to-present transitions.
-------------------------------------------------------------------------------

local announcedCCs = {}  -- spellId -> true: guards against re-announcing same CC before expiry

local function HandleClassicAura(_event, unitTarget)
    if unitTarget ~= "player" then return end

    -- Build current debuff set
    local currentCCs = {}
    local index = 1
    while true do
        local name, _, _, _, duration, _, _, _, _, spellId = UnitDebuff("player", index)
        if not name then break end
        if ns.CCListener.IS_CC_SPELL[spellId] then
            currentCCs[spellId] = { name = name, duration = duration }
        end
        index = index + 1
    end

    -- Announce newly applied CCs (present now, not previously tracked)
    for spellId, auraInfo in pairs(currentCCs) do
        if not announcedCCs[spellId] then
            announcedCCs[spellId] = true
            AnnounceIfCC(spellId, auraInfo.name, auraInfo.duration)
        end
    end

    -- Clear expired CCs (tracked but no longer present)
    for spellId in pairs(announcedCCs) do
        if not currentCCs[spellId] then
            announcedCCs[spellId] = nil
        end
    end
end

-------------------------------------------------------------------------------
-- Lifecycle
-------------------------------------------------------------------------------

function ns.AuraListener.Initialize(addon)
    if ns.IS_RETAIL then
        addon:RegisterEvent("UNIT_AURA", HandleRetailAura)
    else
        addon:RegisterEvent("UNIT_AURA", HandleClassicAura)
    end
    ns.DebugPrint("AuraListener initialized (retail=" .. tostring(ns.IS_RETAIL) .. ")")
end

function ns.AuraListener.Shutdown()
    ns.Addon:UnregisterEvent("UNIT_AURA")
    wipe(announcedCCs)
    ns.DebugPrint("AuraListener shut down")
end

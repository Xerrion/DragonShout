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
local UnitDebuff = UnitDebuff

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

local function AnnounceIfCC(spellId, spellName)
    if not spellId then return end

    local IS_CC_SPELL = ns.CCListener.IS_CC_SPELL
    if not IS_CC_SPELL[spellId] then return end
    if IsRecentlyAnnounced(spellId) then return end

    local db = ns.Addon.db
    if not db then return end

    local ccType = ns.CCListener.CC_TYPE[spellId]
    local categoryConfig = db.profile.ccOnYou

    -- Check sub-toggle for specific CC type
    if ccType and categoryConfig[ccType] == false then return end

    ns.Announcer.Announce("ccOnYou", spellId, {
        spell = spellName or "Unknown",
    })
end

-------------------------------------------------------------------------------
-- Retail UNIT_AURA handler (with updateInfo)
-------------------------------------------------------------------------------

local function HandleRetailAura(_event, unitTarget, updateInfo)
    if unitTarget ~= "player" then return end
    if not updateInfo then return end

    if updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
            if aura.isHarmful then
                AnnounceIfCC(aura.spellId, aura.name)
            end
        end
    end
end

-------------------------------------------------------------------------------
-- Classic UNIT_AURA handler (no updateInfo)
-------------------------------------------------------------------------------

local function HandleClassicAura(_event, unitTarget)
    if unitTarget ~= "player" then return end

    local index = 1
    while true do
        local name, _, _, _, _, _, _, _, _, spellId = UnitDebuff("player", index)
        if not name then break end
        AnnounceIfCC(spellId, name)
        index = index + 1
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
    ns.DebugPrint("AuraListener shut down")
end

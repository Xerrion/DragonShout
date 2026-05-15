-------------------------------------------------------------------------------
-- AuraListener.lua
-- Handles CC detection from SPELL_AURA_APPLIED sub-events
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local math_floor = math.floor
local select = select
local string_format = string.format
local tostring = tostring
local UnitDebuff = UnitDebuff
local C_UnitAuras = C_UnitAuras  -- nil on Classic; nil-safe
local L = ns.L

-------------------------------------------------------------------------------
-- CC type classification
--
-- Spell ID -> CC type tables live in Data/CC_{Retail,MoP,TBC,Era}.lua and are
-- loaded into ns.Data before this file. At load, MergeTable copies the
-- appropriate table into CC_TYPE based on WOW_PROJECT_ID. Unknown project IDs
-- fall back to ERA_CC as the safest baseline (1.x player abilities only).
--
-- WOW_PROJECT_MISTS_CLASSIC may not be defined on older clients; the numeric
-- fallback `or 14` matches the constant's documented value so the comparison
-- still works on clients that lack the symbol.
-------------------------------------------------------------------------------

local function MergeTable(target, source)
    for k, v in pairs(source) do
        target[k] = v
    end
end

local CC_TYPE = {}
if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    MergeTable(CC_TYPE, ns.Data.RETAIL_CC)
elseif WOW_PROJECT_ID == (WOW_PROJECT_MISTS_CLASSIC or 14) then
    MergeTable(CC_TYPE, ns.Data.MOP_CC)
elseif WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
    MergeTable(CC_TYPE, ns.Data.TBC_CC)
else
    MergeTable(CC_TYPE, ns.Data.ERA_CC)
end

-------------------------------------------------------------------------------
-- Display labels for CC types (used as {type} token value)
-------------------------------------------------------------------------------

local CC_TYPE_LABEL = {
    silence   = L["Silenced"],
    stun      = L["Stunned"],
    polymorph = L["Polymorphed"],
    disorient = L["Disoriented"],
    fear      = L["Feared"],
    root      = L["Rooted"],
}

-------------------------------------------------------------------------------
-- Duration lookup helper
-------------------------------------------------------------------------------

local function GetPlayerCCDuration(spellId)
    if ns.IS_RETAIL then
        if not C_UnitAuras then return nil end
        local index = 1
        while true do
            local aura = C_UnitAuras.GetAuraDataByIndex("player", index, "HARMFUL")
            if not aura then break end
            if aura.spellId == spellId then
                return aura.duration
            end
            index = index + 1
        end
    else
        local index = 1
        while true do
            local name, _, _, _, duration, _, _, _, _, sid = UnitDebuff("player", index)
            if not name then break end
            if sid == spellId then
                return duration
            end
            index = index + 1
        end
    end
    return nil
end

-------------------------------------------------------------------------------
-- Handler
-------------------------------------------------------------------------------

ns.AuraListener = {}

-- Exposed so UnitEventListener (retail Midnight UNIT_AURA path) can filter
-- updateInfo.addedAuras to CC spells before paying the cost of a full
-- OnAuraApplied call. The handler still re-checks membership; this is a
-- pre-filter, not a load-bearing gate.
ns.AuraListener.CC_TYPE = CC_TYPE

function ns.AuraListener.OnAuraApplied(sourceGUID, sourceName, _, _, destGUID, destName, _, _, extras)
    -- `extras` is the post-PR-#28 minimal signature extension: when present
    -- (UnitEventListener on retail Midnight) spell info travels through it.
    -- When nil (CombatLogListener on Classic), fall back to CLEU positional
    -- arguments at index 12+.
    local spellId, spellName, auraType
    if extras then
        spellId = extras.spellId
        spellName = extras.spellName
        auraType = extras.auraType
    else
        spellId, spellName, _, auraType = select(12, CombatLogGetCurrentEventInfo())
    end

    ns.DebugPrintCLEU(sourceGUID, destGUID,
        string_format("AuraListener: auraType=%s spellId=%s", tostring(auraType), tostring(spellId)))

    if auraType ~= "DEBUFF" then return end

    if not CC_TYPE[spellId] then
        ns.DebugPrintCLEU(sourceGUID, destGUID,
            string_format("AuraListener: spellId=%s not in CC_TYPE", tostring(spellId)))
        return
    end

    if not ns.playerGUID then
        ns.DebugPrint("AuraListener: playerGUID is nil, skipping")
        return
    end

    local db = ns.Addon and ns.Addon.db
    if not db then return end

    local ccType = CC_TYPE[spellId]

    if destGUID == ns.playerGUID then
        ns.DebugPrintCLEU(sourceGUID, destGUID, string_format("AuraListener: CC on player - spellId=%s type=%s",
            tostring(spellId), tostring(ccType)))
        local categoryConfig = db.profile.ccOnYou
        if categoryConfig[ccType] ~= false then
            local typeLabel = CC_TYPE_LABEL[ccType] or ""
            local rawDuration = GetPlayerCCDuration(spellId)
            local durationStr = (rawDuration and rawDuration > 0)
                and tostring(math_floor(rawDuration)) or nil

            ns.Announcer.Announce("ccOnYou", spellId, {
                spell = spellName,
                source = sourceName,
                type = typeLabel,
                duration = durationStr,
            }, ccType)
        end
    end

    if sourceGUID == ns.playerGUID then
        ns.DebugPrintCLEU(sourceGUID, destGUID,
            string_format("AuraListener: CC applied by player - spellId=%s target=%s",
                tostring(spellId), tostring(destName)))
        ns.Announcer.Announce("ccApplied", spellId, {
            spell = spellName,
            target = destName,
            type = CC_TYPE_LABEL[ccType] or "",
        })
    end

    -- Only fire custom announce if the player was involved (source or dest)
    if destGUID == ns.playerGUID or sourceGUID == ns.playerGUID then
        ns.Announcer.AnnounceCustom(spellId, {
            spell = spellName,
            target = destName,
            source = sourceName,
        })
    end
end

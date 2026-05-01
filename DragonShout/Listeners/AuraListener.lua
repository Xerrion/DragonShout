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
-------------------------------------------------------------------------------

local CC_TYPE = {
    -- Polymorph
    [118]    = "polymorph",
    [12824]  = "polymorph",
    [12825]  = "polymorph",
    [12826]  = "polymorph",
    [28271]  = "polymorph",
    [28272]  = "polymorph",
    [61025]  = "polymorph",
    [61305]  = "polymorph",
    [126819] = "polymorph",
    [161353] = "polymorph",
    [161354] = "polymorph",
    [161355] = "polymorph",
    [161372] = "polymorph",
    [277787] = "polymorph",
    [277792] = "polymorph",
    [51514]  = "polymorph",

    -- Silences
    [2139]   = "silence",
    [6552]   = "silence",
    [47528]  = "silence",
    [1766]   = "silence",
    [93985]  = "silence",
    [47476]  = "silence",
    [15487]  = "silence",
    [28730]  = "silence",
    [25046]  = "silence",
    [50613]  = "silence",
    [69179]  = "silence",
    [80483]  = "silence",
    [129597] = "silence",
    [155145] = "silence",
    [202719] = "silence",
    [18498]  = "silence",

    -- Stuns
    [1833]   = "stun",
    [408]    = "stun",
    [853]    = "stun",
    [20252]  = "stun",
    [20549]  = "stun",
    [5211]   = "stun",
    [7922]   = "stun",

    -- Disorient
    [31661]  = "disorient",
    [19503]  = "disorient",

    -- Fear
    [5782]   = "fear",
    [8122]   = "fear",
    [10326]  = "fear",
    [5484]   = "fear",

    -- Root
    [44572]  = "root",
    [122]    = "root",
    [339]    = "root",
}

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

function ns.AuraListener.OnAuraApplied(sourceGUID, sourceName, _, _, destGUID, destName, _, _)
    local spellId, spellName, _, auraType = select(12, CombatLogGetCurrentEventInfo())

    ns.DebugPrint(string_format("AuraListener: auraType=%s spellId=%s", tostring(auraType), tostring(spellId)))

    if auraType ~= "DEBUFF" then return end

    if not CC_TYPE[spellId] then
        ns.DebugPrint(string_format("AuraListener: spellId=%s not in CC_TYPE", tostring(spellId)))
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
        ns.DebugPrint(string_format("AuraListener: CC on player - spellId=%s type=%s",
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
        ns.DebugPrint(string_format("AuraListener: CC applied by player - spellId=%s target=%s",
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

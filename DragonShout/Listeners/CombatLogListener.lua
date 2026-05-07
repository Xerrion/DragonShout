-------------------------------------------------------------------------------
-- CombatLogListener.lua
-- COMBAT_LOG_EVENT_UNFILTERED dispatcher (CLEU-capable flavors only)
--
-- Supported versions: Retail (<12.0), MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ... -- luacheck: ignore 211/ADDON_NAME

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local select = select
local string_format = string.format

-------------------------------------------------------------------------------
-- Sub-event handlers (build payload tables, dispatch to listener modules)
-------------------------------------------------------------------------------

local function HandleInterrupt(sourceGUID, sourceName, destGUID, destName)
    local spellId, spellName, _, extraSpellId, extraSpellName = select(12, CombatLogGetCurrentEventInfo())
    ns.InterruptListener.OnInterrupt({
        sourceGUID = sourceGUID,
        sourceName = sourceName,
        destGUID = destGUID,
        destName = destName,
        spellId = spellId,
        spellName = spellName,
        extraSpellId = extraSpellId,
        extraSpellName = extraSpellName,
    })
end

local function HandleAuraApplied(sourceGUID, sourceName, destGUID, destName)
    local spellId, spellName, _, auraType = select(12, CombatLogGetCurrentEventInfo())
    ns.AuraListener.OnAuraApplied({
        sourceGUID = sourceGUID,
        sourceName = sourceName,
        destGUID = destGUID,
        destName = destName,
        spellId = spellId,
        spellName = spellName,
        auraType = auraType,
        auraInstanceID = nil,
    })
end

local function HandleDispel(sourceGUID, sourceName, destGUID, destName)
    local spellId, spellName, _, extraSpellId, extraSpellName = select(12, CombatLogGetCurrentEventInfo())
    ns.DispelListener.OnDispel({
        sourceGUID = sourceGUID,
        sourceName = sourceName,
        destGUID = destGUID,
        destName = destName,
        spellId = spellId,
        spellName = spellName,
        extraSpellId = extraSpellId,
        extraSpellName = extraSpellName,
    })
end

local DISPATCH = {
    SPELL_INTERRUPT    = HandleInterrupt,
    SPELL_AURA_APPLIED = HandleAuraApplied,
    SPELL_DISPEL       = HandleDispel,
}

-------------------------------------------------------------------------------
-- Module state
-------------------------------------------------------------------------------

local registered = false

-------------------------------------------------------------------------------
-- Module
-------------------------------------------------------------------------------

ns.CombatLogListener = {}

local function OnCombatLogEvent()
    local _, subevent, _,
        sourceGUID, sourceName, _, _,
        destGUID, destName = CombatLogGetCurrentEventInfo()

    local handler = DISPATCH[subevent]
    if not handler then return end

    ns.DebugPrint(string_format("CombatLogListener: dispatching %s", subevent))
    handler(sourceGUID, sourceName, destGUID, destName)
end

function ns.CombatLogListener.Initialize(addon)
    if not (ns.capabilities and ns.capabilities.combatLog) then
        ns.DebugPrint("CombatLogListener: skipping registration; capability disabled")
        return
    end
    addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", OnCombatLogEvent)
    registered = true
    ns.DebugPrint("CombatLogListener initialized")
end

function ns.CombatLogListener.Shutdown()
    if registered then
        ns.Addon:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        registered = false
    end
    ns.DebugPrint("CombatLogListener shut down")
end

function ns.CombatLogListener.IsActive()
    return registered
end

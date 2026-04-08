-------------------------------------------------------------------------------
-- CombatLogListener.lua
-- Central COMBAT_LOG_EVENT_UNFILTERED dispatcher
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo

-------------------------------------------------------------------------------
-- Sub-event dispatch table
-------------------------------------------------------------------------------

local DISPATCH = {
    SPELL_INTERRUPT = function(...)
        ns.InterruptListener.OnInterrupt(...)
    end,
    SPELL_AURA_APPLIED = function(...)
        ns.CCListener.OnAuraApplied(...)
    end,
    SPELL_DISPEL = function(...)
        ns.DispelListener.OnDispel(...)
    end,
}

-------------------------------------------------------------------------------
-- Module
-------------------------------------------------------------------------------

ns.CombatLogListener = {}

local function OnCombatLogEvent()
    local _, subevent, _,
        sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
        destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()

    local handler = DISPATCH[subevent]
    if not handler then return end

    handler(sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
            destGUID, destName, destFlags, destRaidFlags)
end

function ns.CombatLogListener.Initialize(addon)
    addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", OnCombatLogEvent)
    ns.DebugPrint("CombatLogListener initialized")
end

function ns.CombatLogListener.Shutdown()
    ns.Addon:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    ns.DebugPrint("CombatLogListener shut down")
end

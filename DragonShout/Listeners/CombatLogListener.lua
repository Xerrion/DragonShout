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

local CreateFrame = CreateFrame
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local string_format = string.format

-------------------------------------------------------------------------------
-- Sub-event dispatch table
-------------------------------------------------------------------------------

local DISPATCH = {
    SPELL_INTERRUPT = function(...)
        ns.InterruptListener.OnInterrupt(...)
    end,
    SPELL_AURA_APPLIED = function(...)
        ns.AuraListener.OnAuraApplied(...)
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

    ns.DebugPrintCLEU(sourceGUID, destGUID, string_format("CombatLogListener: dispatching %s", subevent))

    handler(sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
            destGUID, destName, destFlags, destRaidFlags)
end

-------------------------------------------------------------------------------
-- Private event frame
--
-- Retail 12.0 (Midnight) marks COMBAT_LOG_EVENT_UNFILTERED with
-- HasRestrictions = true, which makes AceEvent's shared dispatcher emit
-- ADDON_ACTION_FORBIDDEN. Owning a private, unnamed frame keeps the CLEU
-- registration off the shared global event bus and contains the blast radius.
-- The frame MUST be unnamed - a named frame would re-introduce the same
-- shared-global exposure we are escaping.
-------------------------------------------------------------------------------

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", OnCombatLogEvent)

function ns.CombatLogListener.Initialize(_addon)
    if ns.capabilities and ns.capabilities.cleuRestricted then
        ns.DebugPrint("CombatLogListener: CLEU restricted on this client; standing down")
        return
    end
    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    ns.DebugPrint("CombatLogListener initialized")
end

function ns.CombatLogListener.Shutdown()
    if ns.capabilities and ns.capabilities.cleuRestricted then
        return
    end
    frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    ns.DebugPrint("CombatLogListener shut down")
end

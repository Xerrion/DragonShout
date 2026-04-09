-------------------------------------------------------------------------------
-- DispelListener.lua
-- Handles SPELL_DISPEL sub-events from the combat log
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local select = select
local string_format = string.format
local tostring = tostring

-------------------------------------------------------------------------------
-- Module
-------------------------------------------------------------------------------

ns.DispelListener = {}

function ns.DispelListener.OnDispel(sourceGUID, sourceName, _, _, _, destName, _, _)
    if not ns.playerGUID then
        ns.DebugPrint("DispelListener: playerGUID is nil, skipping")
        return
    end
    if sourceGUID ~= ns.playerGUID then
        ns.DebugPrint(string_format("DispelListener: sourceGUID %s != playerGUID %s",
            tostring(sourceGUID), tostring(ns.playerGUID)))
        return
    end

    local spellId, spellName, _, _, extraSpellName = select(12, CombatLogGetCurrentEventInfo())

    ns.Announcer.Announce("dispels", spellId, {
        spell = spellName,
        target = destName,
        source = sourceName,
        extraSpell = extraSpellName,
    })

    ns.DebugPrint(string_format("DispelListener: dispel detected spellId=%s target=%s",
        tostring(spellId), tostring(destName)))
end

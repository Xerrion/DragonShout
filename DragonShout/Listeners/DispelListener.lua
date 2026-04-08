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

-------------------------------------------------------------------------------
-- Module
-------------------------------------------------------------------------------

ns.DispelListener = {}

function ns.DispelListener.OnDispel(sourceGUID, sourceName, _, _, _, destName, _, _)
    if not ns.playerGUID then return end
    if sourceGUID ~= ns.playerGUID then return end

    local spellId, spellName, _, _, extraSpellName = select(12, CombatLogGetCurrentEventInfo())

    ns.Announcer.Announce("dispels", spellId, {
        spell = spellName,
        target = destName,
        source = sourceName,
        extraSpell = extraSpellName,
    })
end

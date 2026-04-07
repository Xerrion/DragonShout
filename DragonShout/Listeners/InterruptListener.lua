-------------------------------------------------------------------------------
-- InterruptListener.lua
-- Handles SPELL_INTERRUPT sub-events from the combat log
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Module
-------------------------------------------------------------------------------

ns.InterruptListener = {}

function ns.InterruptListener.OnInterrupt(
    _timestamp, _subevent, _hideCaster,
    sourceGUID, sourceName, _sourceFlags, _sourceRaidFlags,
    _destGUID, destName, _destFlags, _destRaidFlags,
    spellId, spellName, _spellSchool,
    _extraSpellId, extraSpellName, _extraSchool,
    _auraType
)
    -- Guard: only announce interrupts performed by the player
    if not ns.playerGUID then return end
    if sourceGUID ~= ns.playerGUID then return end

    ns.Announcer.Announce("interrupts", spellId, {
        spell = spellName,
        target = destName,
        source = sourceName,
        extraSpell = extraSpellName,
    })
end

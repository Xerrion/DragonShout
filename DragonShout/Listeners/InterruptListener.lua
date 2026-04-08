-------------------------------------------------------------------------------
-- InterruptListener.lua
-- Handles SPELL_INTERRUPT sub-events from the combat log
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local select = select
local GetSpellInfo = GetSpellInfo
local C_Spell = C_Spell

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

--- Resolve a spell name from its ID, supporting both Retail and Classic APIs.
local function GetSpellName(spellId)
    if C_Spell and C_Spell.GetSpellName then
        return C_Spell.GetSpellName(spellId)
    end
    if GetSpellInfo then
        return GetSpellInfo(spellId)
    end
    return tostring(spellId)
end

-------------------------------------------------------------------------------
-- Module
-------------------------------------------------------------------------------

ns.InterruptListener = {}

function ns.InterruptListener.OnInterrupt(sourceGUID, sourceName, _, _, _, destName, _, _)
    if not ns.playerGUID then return end
    if sourceGUID ~= ns.playerGUID then return end

    -- SPELL_INTERRUPT suffix: [12]=spellId [13]=spellName [14]=spellSchool [15]=extraSpellId [16]=extraSpellSchool
    local spellId, spellName, _, extraSpellId = select(12, CombatLogGetCurrentEventInfo())
    local extraSpellName = GetSpellName(extraSpellId)

    ns.Announcer.Announce("interrupts", spellId, {
        spell = spellName,
        target = destName,
        source = sourceName,
        extraSpell = extraSpellName,
    })
end

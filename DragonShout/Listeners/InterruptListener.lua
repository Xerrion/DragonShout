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
local string_format = string.format
local tostring = tostring
local GetSpellInfo = GetSpellInfo
local C_Spell = C_Spell

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

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

function ns.InterruptListener.OnInterrupt(sourceGUID, sourceName, _, _, _, destName, _, _, extras)
    if not ns.playerGUID then
        ns.DebugPrint("InterruptListener: playerGUID is nil, skipping")
        return
    end
    if sourceGUID ~= ns.playerGUID then
        ns.DebugPrint(string_format("InterruptListener: sourceGUID %s != playerGUID %s",
            tostring(sourceGUID), tostring(ns.playerGUID)))
        return
    end

    -- `extras` is the post-PR-#28 minimal signature extension: when present
    -- (UnitEventListener on retail Midnight), spell info travels through it
    -- because CombatLogGetCurrentEventInfo() is not the source of truth.
    -- When nil (CombatLogListener on Classic), fall back to CLEU positional
    -- arguments at index 12+.
    local spellId, spellName, extraSpellName
    if extras then
        spellId = extras.spellId
        spellName = extras.spellName
        extraSpellName = extras.extraSpellName
    else
        local extraSpellId
        spellId, spellName, _, extraSpellId = select(12, CombatLogGetCurrentEventInfo())
        extraSpellName = GetSpellName(extraSpellId)
    end

    ns.Announcer.Announce("interrupts", spellId, {
        spell = spellName,
        target = destName,
        source = sourceName,
        extraSpell = extraSpellName,
    })

    ns.DebugPrint(string_format("InterruptListener: interrupt detected spellId=%s target=%s",
        tostring(spellId), tostring(destName)))
end

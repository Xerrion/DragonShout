-------------------------------------------------------------------------------
-- InterruptListener.lua
-- Handles interrupt events (player as the interrupter)
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ... -- luacheck: ignore 211/ADDON_NAME

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local string_format = string.format
local tostring = tostring
local GetSpellInfo = GetSpellInfo
local C_Spell = C_Spell

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function GetSpellName(spellId)
    if not spellId then return nil end
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

-- payload = { sourceGUID, sourceName, destGUID, destName,
--             spellId, spellName,             -- interrupter's spell (nil on retail 12.0+)
--             extraSpellId, extraSpellName }  -- interrupted spell
function ns.InterruptListener.OnInterrupt(payload)
    if not ns.playerGUID then
        ns.DebugPrint("InterruptListener: playerGUID is nil, skipping")
        return
    end
    if payload.sourceGUID ~= ns.playerGUID then
        ns.DebugPrint(string_format("InterruptListener: sourceGUID %s != playerGUID %s",
            tostring(payload.sourceGUID), tostring(ns.playerGUID)))
        return
    end

    local extraSpellName = payload.extraSpellName or GetSpellName(payload.extraSpellId)

    ns.Announcer.Announce("interrupts", payload.spellId, {
        spell = payload.spellName,
        target = payload.destName,
        source = payload.sourceName,
        extraSpell = extraSpellName,
    })

    ns.DebugPrint(string_format("InterruptListener: interrupt detected spellId=%s target=%s",
        tostring(payload.spellId), tostring(payload.destName)))
end

-------------------------------------------------------------------------------
-- DispelListener.lua
-- Handles dispel events (player as the dispeller)
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ... -- luacheck: ignore 211/ADDON_NAME

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local string_format = string.format
local tostring = tostring

-------------------------------------------------------------------------------
-- Module
-------------------------------------------------------------------------------

ns.DispelListener = {}

-- payload = { sourceGUID, sourceName, destGUID, destName,
--             spellId, spellName,             -- the dispel spell
--             extraSpellId, extraSpellName }  -- the removed aura (may be nil on retail 12.0+ cache miss)
function ns.DispelListener.OnDispel(payload)
    if not ns.playerGUID then
        ns.DebugPrint("DispelListener: playerGUID is nil, skipping")
        return
    end
    if payload.sourceGUID ~= ns.playerGUID then
        ns.DebugPrint(string_format("DispelListener: sourceGUID %s != playerGUID %s",
            tostring(payload.sourceGUID), tostring(ns.playerGUID)))
        return
    end

    ns.Announcer.Announce("dispels", payload.spellId, {
        spell = payload.spellName,
        target = payload.destName,
        source = payload.sourceName,
        extraSpell = payload.extraSpellName,
    })

    ns.DebugPrint(string_format("DispelListener: dispel detected spellId=%s target=%s",
        tostring(payload.spellId), tostring(payload.destName)))
end

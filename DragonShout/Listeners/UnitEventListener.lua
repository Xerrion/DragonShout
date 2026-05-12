-------------------------------------------------------------------------------
-- UnitEventListener.lua
-- Retail Midnight (Interface 120000+) CLEU replacement via UNIT_* events
--
-- Acts as an Anti-Corrupt Layer: translates UNIT_SPELLCAST_INTERRUPTED and
-- UNIT_AURA payloads into the CLEU-shaped positional tuple the existing
-- handlers (InterruptListener, AuraListener) consume, plus a trailing
-- `extras` table carrying spell info that would normally come from
-- select(12, CombatLogGetCurrentEventInfo()).
--
-- Active only when ns.capabilities.cleuRestricted is true; no-ops on Classic.
--
-- Supported versions: Retail (12.0+). Inert on MoP Classic, TBC Anniversary.
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local UnitGUID = UnitGUID
local UnitName = UnitName
local GetSpellInfo = GetSpellInfo
local C_Spell = C_Spell
local string_format = string.format
local tostring = tostring

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function GetSpellName(spellId)
    if not spellId then return nil end
    local name
    if C_Spell and C_Spell.GetSpellName then
        name = C_Spell.GetSpellName(spellId)
    elseif GetSpellInfo then
        name = GetSpellInfo(spellId)
    end
    return name or tostring(spellId)
end

-------------------------------------------------------------------------------
-- Module
-------------------------------------------------------------------------------

ns.UnitEventListener = {}

-------------------------------------------------------------------------------
-- Event handlers
-------------------------------------------------------------------------------

-- UNIT_SPELLCAST_INTERRUPTED(unitTarget, castGUID, spellID, interruptedBy, castBarID)
--
-- We only announce the player's own interrupts (matches InterruptListener's
-- existing sourceGUID == playerGUID filter). `interruptedBy` is a unit token
-- ("player", "pet", "party1", ...), not a GUID - filter on the token directly.
-- The ADR explicitly defers group interrupt attribution; we keep srcGUID as
-- ns.playerGUID since the token resolves to the player.
--
-- Spell semantics on retail Midnight: UNIT_SPELLCAST_INTERRUPTED carries the
-- *interrupted* spell ID, not the interrupter's. We pass spellId/spellName as
-- nil and put the interrupted spell into extraSpellId/extraSpellName. The
-- announcer template substitutes empty for the interrupter spell and shows the
-- interrupted spell as {extraSpell}.
local function OnUnitSpellcastInterrupted(unitTarget, _castGUID, spellID, interruptedBy)
    if not ns.playerGUID then
        ns.DebugPrint("UnitEventListener: playerGUID is nil, skipping interrupt")
        return
    end
    if interruptedBy ~= "player" then
        return
    end

    local sourceName = UnitName("player")
    local destGUID = unitTarget and UnitGUID(unitTarget) or nil
    local destName = (unitTarget and UnitName(unitTarget)) or "[Unknown]"

    ns.InterruptListener.OnInterrupt(
        ns.playerGUID, sourceName, nil, nil,
        destGUID, destName, nil, nil,
        {
            spellId = nil,
            spellName = nil,
            extraSpellId = spellID,
            extraSpellName = GetSpellName(spellID),
        }
    )

    ns.DebugPrint(string_format(
        "UnitEventListener: interrupt translated spellID=%s target=%s",
        tostring(spellID), tostring(destName)))
end

-- UNIT_AURA(unit, updateInfo)
--
-- Only react to the player's own auras. ccApplied (CC the player lands on
-- enemies) is intentionally dropped on retail Midnight: enemy unit tokens are
-- populated unreliably and sourceUnit on AuraData is often nil/secret. See
-- ADR-0002 for the decision and trade-offs.
local function OnUnitAura(unit, updateInfo)
    if unit ~= "player" then return end
    if not updateInfo then return end
    local addedAuras = updateInfo.addedAuras
    if not addedAuras then return end
    if not ns.playerGUID then return end

    local ccTypeTable = ns.AuraListener and ns.AuraListener.CC_TYPE
    if not ccTypeTable then return end

    local playerName = UnitName("player")

    for _, auraData in ipairs(addedAuras) do
        if auraData and auraData.isHarmful and ccTypeTable[auraData.spellId] then
            local sourceUnit = auraData.sourceUnit
            local sourceGUID = sourceUnit and UnitGUID(sourceUnit) or nil
            local sourceName = sourceUnit and UnitName(sourceUnit) or nil

            ns.AuraListener.OnAuraApplied(
                sourceGUID, sourceName, nil, nil,
                ns.playerGUID, playerName, nil, nil,
                {
                    spellId = auraData.spellId,
                    spellName = auraData.name,
                    auraType = "DEBUFF",
                }
            )

            ns.DebugPrint(string_format(
                "UnitEventListener: CC-on-player translated spellId=%s",
                tostring(auraData.spellId)))
        end
    end
end

-------------------------------------------------------------------------------
-- Event dispatch
-------------------------------------------------------------------------------

local DISPATCH = {
    UNIT_SPELLCAST_INTERRUPTED = OnUnitSpellcastInterrupted,
    UNIT_AURA = OnUnitAura,
}

local function OnEvent(_self, event, ...)
    local handler = DISPATCH[event]
    if not handler then return end
    handler(...)
end

-------------------------------------------------------------------------------
-- Private event frame
--
-- Unnamed CreateFrame mirrors CombatLogListener's PR #26 pattern: a private
-- frame avoids the AceEvent shared dispatcher's taint surface. The frame MUST
-- be unnamed; a name would re-introduce shared-global exposure.
-------------------------------------------------------------------------------

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", OnEvent)

function ns.UnitEventListener.Initialize(_addon)
    if not (ns.capabilities and ns.capabilities.cleuRestricted) then
        return
    end

    -- UNIT_SPELLCAST_INTERRUPTED fires with `unitTarget` = the unit whose
    -- cast was interrupted (e.g. an enemy `nameplate2`, `boss1`, `target`).
    -- We cannot filter on "player" here - that would limit to events where
    -- the *player's own* cast was interrupted. Filter on interruptedBy in
    -- the handler instead.
    frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    -- UNIT_AURA we only care about for the player (ccOnYou). Unit-filter it
    -- to avoid spurious dispatches.
    frame:RegisterUnitEvent("UNIT_AURA", "player")

    ns.DebugPrint("UnitEventListener initialized (retail Midnight CLEU replacement)")
    ns.DebugPrint(
        "UnitEventListener: dispel announcements unavailable on retail Midnight - no attribution event")
    ns.DebugPrint(
        "UnitEventListener: ccApplied (CC on others) unavailable on retail Midnight - unreliable source attribution")
end

function ns.UnitEventListener.Shutdown()
    if not (ns.capabilities and ns.capabilities.cleuRestricted) then
        return
    end
    frame:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    frame:UnregisterEvent("UNIT_AURA")
    ns.DebugPrint("UnitEventListener shut down")
end

-------------------------------------------------------------------------------
-- UnitEventListener.lua
-- Unit-event source module: replaces CLEU on retail 12.0+ (Midnight)
--
-- Supported versions: Retail 12.0+ (Midnight)
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ... -- luacheck: ignore 211/ADDON_NAME

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local C_UnitAuras = C_UnitAuras
local C_Spell = C_Spell
local AuraUtil = AuraUtil
local UnitGUID = UnitGUID
local UnitName = UnitName
local UnitIsFriend = UnitIsFriend
local UnitExists = UnitExists
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local pairs = pairs
local ipairs = ipairs
local string_format = string.format
local table_insert = table.insert
local tostring = tostring
local unpack = unpack

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

-- Allowlist of dispel spells the player may cast. Comment per spell.
local DISPEL_SPELLS = {
    [370]    = true,  -- Purge (shaman)
    [528]    = true,  -- Dispel Magic (priest)
    [4987]   = true,  -- Cleanse (paladin, classic)
    [475]    = true,  -- Remove Curse (mage)
    [32375]  = true,  -- Mass Dispel (priest)
    [527]    = true,  -- Purify (priest holy/disc)
    [88423]  = true,  -- Nature's Cure (druid restoration)
    [115450] = true,  -- Detox (monk)
    [213634] = true,  -- Purify Disease (priest)
    [213644] = true,  -- Cleanse Toxins (paladin)
    [360823] = true,  -- Naturalize (evoker preservation)
    [374251] = true,  -- Cauterizing Flame (evoker)
}

local DISPEL_WINDOW_SECONDS = 0.6
local SWEEP_INTERVAL_SECONDS = 1.0

-------------------------------------------------------------------------------
-- Module state
-------------------------------------------------------------------------------

local _frame
local _trackedUnits = {}
local _recentSuccesses = {}
local _sweepTimer

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

-- Compute the full set of unit tokens we want to track.
-- Skipped tokens (target, focus, mouseover, nameplate) accept loss-of-CLEU-global-scope.
local function ComputeTrackedTokens()
    local tokens = { "player", "pet" }
    if IsInRaid and IsInRaid() then
        for i = 1, 40 do
            table_insert(tokens, "raid" .. i)
            table_insert(tokens, "raidpet" .. i)
        end
    elseif IsInGroup and IsInGroup() then
        for i = 1, 4 do
            table_insert(tokens, "party" .. i)
            table_insert(tokens, "partypet" .. i)
        end
    end
    return tokens
end

-- Idempotent re-bind: RegisterUnitEvent replaces previous unit filters.
local function RebindUnitEvents()
    if not _frame then return end
    _trackedUnits = ComputeTrackedTokens()
    _frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unpack(_trackedUnits))
    _frame:RegisterUnitEvent("UNIT_AURA",                  unpack(_trackedUnits))
    _frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED",   unpack(_trackedUnits))
    ns.DebugPrint(string_format("UnitEventListener: rebound to %d unit tokens", #_trackedUnits))
end

-- Drop cached auras for unit tokens no longer in the tracked set.
local function PruneAuraCacheForRosterShrink(previousTokens)
    if not previousTokens then return end
    local current = {}
    for _, token in ipairs(_trackedUnits) do current[token] = true end
    for _, token in ipairs(previousTokens) do
        if not current[token] then
            ns.AuraListener.ClearUnitAuras(token)
        end
    end
end

-- Snapshot helpers
local function MakeSnapshot(unitToken, aura)
    return {
        spellId    = aura.spellId,
        spellName  = aura.name,
        auraType   = aura.isHarmful and "DEBUFF" or "BUFF",
        sourceGUID = aura.sourceUnit and UnitGUID(aura.sourceUnit) or nil,
        sourceName = aura.sourceUnit and UnitName(aura.sourceUnit) or nil,
        unitToken  = unitToken,
        unitGUID   = UnitGUID(unitToken),
        insertedAt = GetTime(),
    }
end

-- Reseed the cache for a single unit (full update or initial bind).
local function ReseedUnitAuras(unitToken)
    if not C_UnitAuras then return end
    ns.AuraListener.ClearUnitAuras(unitToken)
    if not UnitExists or not UnitExists(unitToken) then return end
    if not AuraUtil or not AuraUtil.ForEachAura then return end

    local function visit(aura)
        if aura and aura.auraInstanceID then
            ns.AuraListener.RememberAura(unitToken, aura.auraInstanceID, MakeSnapshot(unitToken, aura))
        end
        return false
    end

    AuraUtil.ForEachAura(unitToken, "HELPFUL", nil, visit, true)
    AuraUtil.ForEachAura(unitToken, "HARMFUL", nil, visit, true)
end

-------------------------------------------------------------------------------
-- Event handlers
-------------------------------------------------------------------------------

-- UNIT_SPELLCAST_INTERRUPTED(unitTarget, castGUID, spellID)
-- The interrupted unit fires the event; the interrupted spell is the spellID.
-- The interrupter's spell is unrecoverable from this event (drop on retail 12.0+).
local function OnUnitInterrupted(unitTarget, _castGUID, spellID)
    local sourceGUID = ns.playerGUID
    if not sourceGUID then return end

    -- Without an interrupter unit token we cannot prove the player did it on
    -- this event alone. The InterruptListener guards on sourceGUID == playerGUID,
    -- so we attribute to the player here and let the listener filter. This loses
    -- announcements for other party members' interrupts (acceptable; CLEU users
    -- already only saw their own interrupts due to the same downstream guard).
    ns.InterruptListener.OnInterrupt({
        sourceGUID     = sourceGUID,
        sourceName     = UnitName("player"),
        destGUID       = UnitGUID(unitTarget),
        destName       = UnitName(unitTarget),
        spellId        = nil,
        spellName      = nil,
        extraSpellId   = spellID,
        extraSpellName = GetSpellName(spellID),
    })
end

-- UNIT_AURA(unitTarget, updateInfo)
local function OnUnitAura(unitTarget, updateInfo)
    if not updateInfo then return end

    if updateInfo.isFullUpdate then
        ReseedUnitAuras(unitTarget)
        return
    end

    -- Inserts
    if updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
            if aura and aura.auraInstanceID then
                ns.AuraListener.RememberAura(unitTarget, aura.auraInstanceID, MakeSnapshot(unitTarget, aura))
            end
            -- Dispatch CC detection for harmful auras
            if aura and aura.isHarmful then
                ns.AuraListener.OnAuraApplied({
                    sourceGUID     = aura.sourceUnit and UnitGUID(aura.sourceUnit) or nil,
                    sourceName     = aura.sourceUnit and UnitName(aura.sourceUnit) or nil,
                    destGUID       = UnitGUID(unitTarget),
                    destName       = UnitName(unitTarget),
                    spellId        = aura.spellId,
                    spellName      = aura.name,
                    auraType       = "DEBUFF",
                    auraInstanceID = aura.auraInstanceID,
                })
            end
        end
    end

    -- Updates: refresh snapshot from authoritative API
    if updateInfo.updatedAuraInstanceIDs and C_UnitAuras and C_UnitAuras.GetAuraDataByAuraInstanceID then
        for _, instId in ipairs(updateInfo.updatedAuraInstanceIDs) do
            local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(unitTarget, instId)
            if aura and aura.auraInstanceID then
                ns.AuraListener.RememberAura(unitTarget, aura.auraInstanceID, MakeSnapshot(unitTarget, aura))
            end
        end
    end

    -- Removals: correlate dispel BEFORE forgetting the snapshot.
    if updateInfo.removedAuraInstanceIDs then
        local now = GetTime()
        for _, instId in ipairs(updateInfo.removedAuraInstanceIDs) do
            local snap = ns.AuraListener.LookupAuraSnapshot(unitTarget, instId)
            if snap and UnitIsFriend and UnitIsFriend("player", unitTarget) then
                local match, matchKey
                for cguid, rec in pairs(_recentSuccesses) do
                    if (now - rec.castedAt) <= DISPEL_WINDOW_SECONDS then
                        if not match or rec.castedAt > match.castedAt then
                            match, matchKey = rec, cguid
                        end
                    end
                end
                if match then
                    ns.DispelListener.OnDispel({
                        sourceGUID     = match.sourceGUID,
                        sourceName     = match.sourceName,
                        destGUID       = UnitGUID(unitTarget),
                        destName       = UnitName(unitTarget),
                        spellId        = match.dispelSpellId,
                        spellName      = match.dispelSpellName,
                        extraSpellId   = snap.spellId,
                        extraSpellName = snap.spellName,
                    })
                    _recentSuccesses[matchKey] = nil
                end
            end
            ns.AuraListener.ForgetAura(unitTarget, instId)
        end
    end
end

-- UNIT_SPELLCAST_SUCCEEDED(unitTarget, castGUID, spellID)
local function OnUnitSpellCastSucceeded(unitTarget, castGUID, spellID)
    if not DISPEL_SPELLS[spellID] then return end
    local sourceGUID = UnitGUID(unitTarget)
    if not sourceGUID or sourceGUID ~= ns.playerGUID then return end

    _recentSuccesses[castGUID] = {
        sourceGUID      = sourceGUID,
        sourceName      = UnitName(unitTarget),
        dispelSpellId   = spellID,
        dispelSpellName = GetSpellName(spellID),
        castedAt        = GetTime(),
    }
end

-------------------------------------------------------------------------------
-- Frame OnEvent dispatcher
-------------------------------------------------------------------------------

local FRAME_DISPATCH = {
    UNIT_SPELLCAST_INTERRUPTED = OnUnitInterrupted,
    UNIT_AURA                  = OnUnitAura,
    UNIT_SPELLCAST_SUCCEEDED   = OnUnitSpellCastSucceeded,
}

local function OnFrameEvent(_self, event, ...)
    local handler = FRAME_DISPATCH[event]
    if handler then handler(...) end
end

-------------------------------------------------------------------------------
-- AceEvent handlers (roster / world transitions)
-------------------------------------------------------------------------------

local function OnPlayerEnteringWorld()
    ns.DebugPrint("UnitEventListener: PLAYER_ENTERING_WORLD - rebinding")
    local previous = _trackedUnits
    RebindUnitEvents()
    PruneAuraCacheForRosterShrink(previous)
    -- Reseed for current units so the cache is non-empty after world transitions.
    for _, token in ipairs(_trackedUnits) do
        ReseedUnitAuras(token)
    end
end

local function OnGroupRosterUpdate()
    local previous = _trackedUnits
    RebindUnitEvents()
    PruneAuraCacheForRosterShrink(previous)
end

-------------------------------------------------------------------------------
-- Sweep: drop expired _recentSuccesses entries
-------------------------------------------------------------------------------

local function SweepRecentSuccesses()
    local now = GetTime()
    for castGUID, rec in pairs(_recentSuccesses) do
        if (now - rec.castedAt) > DISPEL_WINDOW_SECONDS then
            _recentSuccesses[castGUID] = nil
        end
    end
end

-------------------------------------------------------------------------------
-- Module
-------------------------------------------------------------------------------

ns.UnitEventListener = {}

local _registered = false

function ns.UnitEventListener.Initialize(addon)
    if ns.capabilities and ns.capabilities.combatLog then
        ns.DebugPrint("UnitEventListener: skipping; CLEU path is active")
        return
    end
    if not C_UnitAuras then
        ns.DebugPrint("UnitEventListener: skipping; C_UnitAuras unavailable")
        return
    end

    if not _frame then
        _frame = CreateFrame("Frame", "DragonShoutUnitEventFrame")
    end
    _frame:SetScript("OnEvent", OnFrameEvent)

    addon:RegisterEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
    addon:RegisterEvent("GROUP_ROSTER_UPDATE", OnGroupRosterUpdate)

    RebindUnitEvents()

    if addon.ScheduleRepeatingTimer then
        _sweepTimer = addon:ScheduleRepeatingTimer(SweepRecentSuccesses, SWEEP_INTERVAL_SECONDS)
    end

    _registered = true
    ns.DebugPrint("UnitEventListener initialized")
end

function ns.UnitEventListener.Shutdown()
    if not _registered then return end

    if _sweepTimer and ns.Addon and ns.Addon.CancelTimer then
        ns.Addon:CancelTimer(_sweepTimer)
    end
    _sweepTimer = nil

    if ns.Addon then
        ns.Addon:UnregisterEvent("PLAYER_ENTERING_WORLD")
        ns.Addon:UnregisterEvent("GROUP_ROSTER_UPDATE")
    end

    if _frame then
        _frame:UnregisterAllEvents()
        _frame:SetScript("OnEvent", nil)
    end

    _trackedUnits = {}
    _recentSuccesses = {}
    _registered = false
    ns.DebugPrint("UnitEventListener shut down")
end

function ns.UnitEventListener.IsActive()
    return _registered
end

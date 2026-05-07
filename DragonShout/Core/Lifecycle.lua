-------------------------------------------------------------------------------
-- Lifecycle.lua
-- Player identity cache and version detection
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local UnitGUID = UnitGUID
local GetBuildInfo = GetBuildInfo
local WOW_PROJECT_ID = WOW_PROJECT_ID
local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE

-------------------------------------------------------------------------------
-- Module state
-------------------------------------------------------------------------------

ns.playerGUID = nil
ns.IS_RETAIL = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)

local playerLoginRegistered = false

-------------------------------------------------------------------------------
-- Capability detection
-------------------------------------------------------------------------------

-- Retail 12.0+ restricts CLEU registration; selects unit-event source module.
-- When this returns true, CombatLogListener registers COMBAT_LOG_EVENT_UNFILTERED.
-- When false, UnitEventListener registers UNIT_SPELLCAST_INTERRUPTED, UNIT_AURA,
-- and UNIT_SPELLCAST_SUCCEEDED against tracked unit tokens. Both source modules
-- feed the same downstream handler payload contract.
local function detectCombatLogAvailable()
    if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then return true end
    local _, _, _, tocVersion = GetBuildInfo()
    if tocVersion and tocVersion < 120000 then return true end
    return false
end

-------------------------------------------------------------------------------
-- Lifecycle Module
-------------------------------------------------------------------------------

ns.Lifecycle = {}

function ns.Lifecycle.Initialize(addon)
    ns.capabilities = ns.capabilities or {}
    ns.capabilities.combatLog = detectCombatLogAvailable()
    ns.DebugPrint("Lifecycle: capabilities.combatLog = " .. tostring(ns.capabilities.combatLog))

    ns.playerGUID = UnitGUID("player")
    if ns.playerGUID then
        ns.DebugPrint("Player GUID cached on Initialize: " .. ns.playerGUID)
    else
        ns.DebugPrint("Player GUID not yet available - registering PLAYER_LOGIN fallback")
        addon:RegisterEvent("PLAYER_LOGIN", function()
            ns.playerGUID = UnitGUID("player")
            ns.DebugPrint("Player GUID cached on PLAYER_LOGIN: " .. tostring(ns.playerGUID))
            addon:UnregisterEvent("PLAYER_LOGIN")
            playerLoginRegistered = false
        end)
        playerLoginRegistered = true
    end
end

function ns.Lifecycle.Shutdown()
    ns.playerGUID = nil
    if playerLoginRegistered then
        ns.Addon:UnregisterEvent("PLAYER_LOGIN")
        playerLoginRegistered = false
    end
end

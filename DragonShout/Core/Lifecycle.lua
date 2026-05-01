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
local WOW_PROJECT_ID = WOW_PROJECT_ID
local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE

-------------------------------------------------------------------------------
-- Module state
-------------------------------------------------------------------------------

ns.playerGUID = nil
ns.IS_RETAIL = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)

local playerLoginRegistered = false

-------------------------------------------------------------------------------
-- Lifecycle Module
-------------------------------------------------------------------------------

ns.Lifecycle = {}

function ns.Lifecycle.Initialize(addon)
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

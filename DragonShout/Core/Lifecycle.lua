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

-------------------------------------------------------------------------------
-- Lifecycle Module
-------------------------------------------------------------------------------

ns.Lifecycle = {}

function ns.Lifecycle.Initialize(_addon)
    ns.playerGUID = UnitGUID("player")
    ns.DebugPrint("Player GUID cached: " .. tostring(ns.playerGUID))
end

function ns.Lifecycle.Shutdown()
    ns.playerGUID = nil
end

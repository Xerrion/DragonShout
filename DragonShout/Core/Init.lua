-------------------------------------------------------------------------------
-- Init.lua
-- DragonShout addon bootstrap and namespace setup
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

ns.ADDON_NAME = ADDON_NAME
ns.ADDON_TITLE = "DragonShout"
ns.VERSION = "@project-version@"

-- Color constants
ns.COLOR_GOLD = "|cffffd700"
ns.COLOR_GREEN = "|cff00ff00"
ns.COLOR_RED = "|cffff0000"
ns.COLOR_GRAY = "|cff888888"
ns.COLOR_WHITE = "|cffffffff"
ns.COLOR_RESET = "|r"

ns._debugMode = false

-------------------------------------------------------------------------------
-- Session-only debug ring buffer (never persisted)
-- Capacity is fixed; oldest entries are overwritten in place (O(1) append).
-- Each entry is { time = GetTime(), text = "HH:MM:SS <msg>" }.
-------------------------------------------------------------------------------

local DEBUG_LOG_CAPACITY = 200
ns.DebugLog = {}
local debugLogHead = 0  -- count of entries appended (mod capacity = next write slot)
local debugLogCount = 0 -- entries currently stored (caps at capacity)

-------------------------------------------------------------------------------
-- Localization
-------------------------------------------------------------------------------

ns.L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local L = ns.L

-- AceAddon Setup
-------------------------------------------------------------------------------

local Addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
ns.Addon = Addon

-------------------------------------------------------------------------------
-- Utility: Print with addon prefix
-------------------------------------------------------------------------------

function ns.Print(msg)
    print(ns.COLOR_GOLD .. "[DragonShout]|r " .. msg)
end

local function isDebugOn()
    if ns._debugMode then return true end
    local db = ns.Addon and ns.Addon.db
    return db and db.profile and db.profile.debug or false
end

function ns.DebugPrint(msg)
    if not isDebugOn() then
        return
    end

    local stamp = date("%H:%M:%S")
    local text = stamp .. " " .. msg

    debugLogHead = debugLogHead + 1
    local slot = ((debugLogHead - 1) % DEBUG_LOG_CAPACITY) + 1
    ns.DebugLog[slot] = { time = GetTime(), text = text }
    if debugLogCount < DEBUG_LOG_CAPACITY then
        debugLogCount = debugLogCount + 1
    end

    print(ns.COLOR_GRAY .. "[DragonShout Debug]|r " .. msg)
end

-- Filtered debug sink for combat-log events: drops the message unless the
-- player is either source or destination. Keeps the debug ring buffer focused
-- on events the addon could plausibly act on instead of every nearby aura.
function ns.DebugPrintCLEU(sourceGUID, destGUID, msg)
    if not isDebugOn() then return end
    if not ns.playerGUID then return end
    if sourceGUID ~= ns.playerGUID and destGUID ~= ns.playerGUID then return end
    ns.DebugPrint(msg)
end

-------------------------------------------------------------------------------
-- Debug log accessors (oldest -> newest, suitable for newline-joined display)
-------------------------------------------------------------------------------

function ns.GetDebugLog()
    local out = {}
    if debugLogCount == 0 then return out end

    local startIndex
    if debugLogCount < DEBUG_LOG_CAPACITY then
        startIndex = 1
    else
        startIndex = (debugLogHead % DEBUG_LOG_CAPACITY) + 1
    end

    for i = 0, debugLogCount - 1 do
        local slot = ((startIndex - 1 + i) % DEBUG_LOG_CAPACITY) + 1
        out[#out + 1] = ns.DebugLog[slot]
    end
    return out
end

function ns.ClearDebugLog()
    for i = 1, DEBUG_LOG_CAPACITY do
        ns.DebugLog[i] = nil
    end
    debugLogHead = 0
    debugLogCount = 0
end

-------------------------------------------------------------------------------
-- Toggle enable/disable via the public AceAddon API
-------------------------------------------------------------------------------

function ns.ToggleAddonEnabled()
    local db = ns.Addon.db.profile
    db.enabled = not db.enabled

    if db.enabled then
        ns.Addon:Enable()
        ns.Print(ns.L["Addon enabled"])
        return
    end

    ns.Addon:Disable()
    ns.Print(ns.L["Addon disabled"])
end

-------------------------------------------------------------------------------
-- Expose namespace for companion addons (e.g. DragonShout_Options)
-------------------------------------------------------------------------------

DragonShoutNS = ns

-------------------------------------------------------------------------------
-- Listener module registry (initialized/shutdown via loop in OnEnable/OnDisable)
-------------------------------------------------------------------------------

local LISTENER_MODULES = {
    "CombatLogListener",
    "UnitEventListener",
    "InterruptListener",
    "AuraListener",
    "DispelListener",
}

-------------------------------------------------------------------------------
-- AceAddon Lifecycle

function Addon:OnInitialize()
    -- AceDB setup (Config.lua defines the defaults and registers the DB)
    ns.InitializeDB(self)

    -- Register slash commands
    self:RegisterChatCommand("dragonshout", "OnSlashCommand")
    self:RegisterChatCommand("ds", "OnSlashCommand")

    -- Initialize minimap icon (after DB is ready)
    if ns.MinimapIcon.Initialize then
        ns.MinimapIcon.Initialize()
    end

    ns.Print(L["Loaded. Type /ds help for commands."])
end

function Addon:OnEnable()
    -- Initialize lifecycle (sets playerGUID, version flags)
    if ns.Lifecycle.Initialize then
        ns.Lifecycle.Initialize(self)
    end

    -- Initialize all listener modules
    for _, name in ipairs(LISTENER_MODULES) do
        local mod = ns[name]
        if mod and mod.Initialize then
            mod.Initialize(self)
        end
    end
end

function Addon:OnDisable()
    -- Shutdown all listener modules
    for _, name in ipairs(LISTENER_MODULES) do
        local mod = ns[name]
        if mod and mod.Shutdown then
            mod.Shutdown()
        end
    end

    -- Shutdown lifecycle
    if ns.Lifecycle.Shutdown then
        ns.Lifecycle.Shutdown()
    end
end

function Addon:OnSlashCommand(input)
    if ns.HandleSlashCommand then
        ns.HandleSlashCommand(input)
    end
end

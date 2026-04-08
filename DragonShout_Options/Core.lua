-------------------------------------------------------------------------------
-- Core.lua
-- DragonShout_Options bootstrap - bridges DragonWidgets for DragonShout config
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local tinsert = table.insert

-------------------------------------------------------------------------------
-- DragonWidgets bridge
-------------------------------------------------------------------------------

local DW = DragonWidgetsNS
if not DW then
    print("|cffff6600[DragonShout_Options]|r DragonWidgets is required but not found. Options UI will be unavailable.")
    ns.DW = { Widgets = {}, LayoutConstants = {} }
    ns.L = LibStub("AceLocale-3.0"):GetLocale("DragonShout")
    ns.CHANNEL_VALUES = {}
    ns.Tabs = {}
    DragonShout_Options = {
        Open = function() end,
        Close = function() end,
        Toggle = function() end,
    }
    return
end

ns.DW = DW

-------------------------------------------------------------------------------
-- Localization
-------------------------------------------------------------------------------

ns.L = LibStub("AceLocale-3.0"):GetLocale("DragonShout")
local L = ns.L

-------------------------------------------------------------------------------
-- Shared channel dropdown values (used by multiple tab files)
-------------------------------------------------------------------------------

ns.CHANNEL_VALUES = {
    { value = "AUTO",  text = L["Auto"] },
    { value = "PARTY", text = L["Party"] },
    { value = "RAID",  text = L["Raid"] },
    { value = "SAY",   text = L["Say"] },
    { value = "YELL",  text = L["Yell"] },
}

-------------------------------------------------------------------------------
-- Tab registry (populated by subsequent tab files)
-------------------------------------------------------------------------------

ns.Tabs = {}

-------------------------------------------------------------------------------
-- Panel state
-------------------------------------------------------------------------------

local panelResult

-------------------------------------------------------------------------------
-- Create the options panel (called lazily on first Open)
-------------------------------------------------------------------------------

local function CreateOptionsPanel()
    ns.dsns = _G.DragonShoutNS
    if not ns.dsns then
        print("|cffff6600[DragonShout_Options]|r DragonShout namespace not found.")
        return
    end

    local tabDefs = {}
    for i = 1, #ns.Tabs do
        tinsert(tabDefs, ns.Tabs[i])
    end

    panelResult = DW.CreateOptionsPanel({
        name = "DragonShoutOptionsFrame",
        title = "DragonShout Options",
        width = 800,
        height = 600,
        tabs = tabDefs,
    })

    ns.RefreshVisibleWidgets = panelResult.RefreshVisibleWidgets
end

-------------------------------------------------------------------------------
-- Global API
-------------------------------------------------------------------------------

DragonShout_Options = {}

function DragonShout_Options.Open()
    if not panelResult then
        CreateOptionsPanel()
    end
    if not panelResult then return end
    panelResult.Open()
end

function DragonShout_Options.Close()
    if not panelResult then return end
    panelResult.Close()
end

function DragonShout_Options.Toggle()
    if not panelResult then
        CreateOptionsPanel()
    end
    if not panelResult then return end
    panelResult.Toggle()
end

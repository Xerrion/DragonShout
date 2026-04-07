-------------------------------------------------------------------------------
-- ConfigWindow.lua
-- LoadOnDemand bridge for DragonShout_Options
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

local C_AddOns = C_AddOns
local L = LibStub("AceLocale-3.0"):GetLocale("DragonShout")

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function IsOptionsLoaded()
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded("DragonShout_Options")
    elseif _G.IsAddOnLoaded then
        return _G.IsAddOnLoaded("DragonShout_Options")
    end
    return false
end

local function LoadOptions()
    if IsOptionsLoaded() then return true end

    if C_AddOns and C_AddOns.LoadAddOn then
        C_AddOns.LoadAddOn("DragonShout_Options")
    elseif _G.LoadAddOn then
        _G.LoadAddOn("DragonShout_Options")
    end

    return IsOptionsLoaded()
end

-------------------------------------------------------------------------------
-- Config Window Management
-------------------------------------------------------------------------------

function ns.OpenOptions()
    if not LoadOptions() then
        ns.Print(L["DragonShout_Options addon not found. Please ensure it is installed."])
        return
    end

    if DragonShout_Options and DragonShout_Options.Open then
        DragonShout_Options.Open()
    end
end

function ns.CloseOptions()
    if not IsOptionsLoaded() then return end

    if DragonShout_Options and DragonShout_Options.Close then
        DragonShout_Options.Close()
    end
end

function ns.ToggleOptions()
    if not LoadOptions() then
        ns.Print(L["DragonShout_Options addon not found. Please ensure it is installed."])
        return
    end

    if DragonShout_Options and DragonShout_Options.Toggle then
        DragonShout_Options.Toggle()
    else
        ns.OpenOptions()
    end
end

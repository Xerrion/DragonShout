-------------------------------------------------------------------------------
-- MinimapIcon.lua
-- Minimap button via LibDBIcon-1.0 and LibDataBroker-1.1
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached references
-------------------------------------------------------------------------------

local LibStub = LibStub
local L = LibStub("AceLocale-3.0"):GetLocale("DragonShout")

-------------------------------------------------------------------------------
-- Minimap Icon Module
-------------------------------------------------------------------------------

ns.MinimapIcon = {}

function ns.MinimapIcon.Initialize()
    local LDB = LibStub("LibDataBroker-1.1", true)
    local LDBIcon = LibStub("LibDBIcon-1.0", true)

    if not LDB or not LDBIcon then
        ns.DebugPrint("LibDataBroker or LibDBIcon not found, minimap icon disabled")
        return
    end

    local dataObject = LDB:NewDataObject("DragonShout", {
        type = "launcher",
        icon = "Interface\\AddOns\\DragonShout\\DragonShout_Icon",
        label = "DragonShout",
        text = "DragonShout",

        OnClick = function(_, button)
            if button == "LeftButton" then
                if ns.ToggleOptions then
                    ns.ToggleOptions()
                end
            elseif button == "RightButton" then
                ns.ToggleAddonEnabled()
            end
        end,

        OnTooltipShow = function(tooltip)
            tooltip:AddDoubleLine("DragonShout", ns.VERSION or "", 1, 0.82, 0, 0.6, 0.6, 0.6)
            tooltip:AddLine(" ")

            local db = ns.Addon.db.profile
            local status = db.enabled and (ns.COLOR_GREEN .. L["Enabled"] .. ns.COLOR_RESET)
                or (ns.COLOR_RED .. L["Disabled"] .. ns.COLOR_RESET)
            tooltip:AddLine(L["Status: "] .. status)
            tooltip:AddLine(" ")

            tooltip:AddLine(ns.COLOR_WHITE .. L["Left-Click"] .. ns.COLOR_RESET .. " - " .. L["Open settings"])
            tooltip:AddLine(ns.COLOR_WHITE .. L["Right-Click"] .. ns.COLOR_RESET .. " - " .. L["Toggle on/off"])
        end,
    })

    LDBIcon:Register("DragonShout", dataObject, ns.Addon.db.profile.minimap)

    ns.DebugPrint("Minimap icon initialized")
end

function ns.MinimapIcon.SetShown(shown)
    local LDBIcon = LibStub("LibDBIcon-1.0", true)
    if not LDBIcon then return end

    local db = ns.Addon.db.profile.minimap
    db.hide = not shown
    if shown then
        LDBIcon:Show("DragonShout")
    else
        LDBIcon:Hide("DragonShout")
    end
end

function ns.MinimapIcon.Refresh()
    local LDBIcon = LibStub("LibDBIcon-1.0", true)
    if not LDBIcon then return end

    LDBIcon:Refresh("DragonShout", ns.Addon.db.profile.minimap)
end

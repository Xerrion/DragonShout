-------------------------------------------------------------------------------
-- GeneralTab.lua
-- General settings tab: enable, throttle, minimap icon, testing
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached globals
-------------------------------------------------------------------------------

local math_abs = math.abs

-------------------------------------------------------------------------------
-- DragonWidgets references
-------------------------------------------------------------------------------

local W = ns.DW.Widgets
local LC = ns.DW.LayoutConstants
local L = ns.L

-------------------------------------------------------------------------------
-- Namespace references
-------------------------------------------------------------------------------

local dsns

-------------------------------------------------------------------------------
-- Section builders
-------------------------------------------------------------------------------

local function CreateCoreSection(parent, yOffset)
    local db = dsns.Addon.db

    local header = W.CreateHeader(parent, L["Core Settings"])
    LC.AnchorWidget(header, parent, yOffset)
    yOffset = yOffset - header:GetHeight() - LC.SPACING_AFTER_HEADER

    local enableToggle = W.CreateToggle(parent, {
        label = L["Enable DragonShout"],
        tooltip = L["Enable or disable the addon"],
        get = function() return db.profile.enabled end,
        set = function(value)
            db.profile.enabled = value
            if value then
                dsns.Addon:Enable()
            else
                dsns.Addon:Disable()
            end
        end,
    })
    LC.AnchorWidget(enableToggle, parent, yOffset)
    yOffset = yOffset - enableToggle:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local throttleSlider = W.CreateSlider(parent, {
        label = L["Throttle Duration"],
        tooltip = L["Throttle Duration"],
        min = 0.5,
        max = 10.0,
        step = 0.5,
        get = function() return db.profile.throttleDuration end,
        set = function(value) db.profile.throttleDuration = value end,
    })
    LC.AnchorWidget(throttleSlider, parent, yOffset)
    yOffset = yOffset - throttleSlider:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local minimapToggle = W.CreateToggle(parent, {
        label = L["Show Minimap Icon"],
        tooltip = L["Toggle the minimap button"],
        get = function() return not db.profile.minimap.hide end,
        set = function(value)
            db.profile.minimap.hide = not value
            dsns.MinimapIcon.SetShown(value)
        end,
    })
    LC.AnchorWidget(minimapToggle, parent, yOffset)
    yOffset = yOffset - minimapToggle:GetHeight()

    return yOffset
end

local function CreateTestingSection(parent, yOffset)
    yOffset = yOffset - LC.SPACING_BETWEEN_SECTIONS

    local header = W.CreateHeader(parent, L["Testing"])
    LC.AnchorWidget(header, parent, yOffset)
    yOffset = yOffset - header:GetHeight() - LC.SPACING_AFTER_HEADER

    local testInterruptButton = W.CreateButton(parent, {
        text = L["Test Interrupt"],
        tooltip = L["Simulate an interrupt announcement"],
        onClick = function()
            dsns.Announcer.Announce("interrupts", 0, {
                spell = "Pummel",
                target = "Test Target",
                source = "You",
                extraSpell = "Fireball",
            })
        end,
    })
    LC.AnchorWidget(testInterruptButton, parent, yOffset)
    yOffset = yOffset - testInterruptButton:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local testCCButton = W.CreateButton(parent, {
        text = L["Test CC"],
        tooltip = L["Simulate a CC announcement"],
        onClick = function()
            dsns.Announcer.Announce("ccOnYou", 0, {
                spell = "Polymorph",
            })
        end,
    })
    LC.AnchorWidget(testCCButton, parent, yOffset)
    yOffset = yOffset - testCCButton:GetHeight()

    return yOffset
end

-------------------------------------------------------------------------------
-- Build the General tab content
-------------------------------------------------------------------------------

local function CreateContent(parent)
    dsns = ns.dsns
    local yOffset = LC.PADDING_TOP

    yOffset = CreateCoreSection(parent, yOffset)
    yOffset = CreateTestingSection(parent, yOffset)

    parent:SetHeight(math_abs(yOffset) + LC.PADDING_BOTTOM)
end

-------------------------------------------------------------------------------
-- Register tab
-------------------------------------------------------------------------------

ns.Tabs[#ns.Tabs + 1] = {
    id = "general",
    label = L["General"],
    order = 1,
    createFunc = CreateContent,
}

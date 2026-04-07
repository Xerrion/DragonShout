-------------------------------------------------------------------------------
-- InterruptsTab.lua
-- Interrupt announcement settings tab
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
-- Build the Interrupts tab content
-------------------------------------------------------------------------------

local function CreateContent(parent)
    dsns = ns.dsns
    local db = dsns.Addon.db
    local yOffset = LC.PADDING_TOP

    local header = W.CreateHeader(parent, L["Interrupts"])
    LC.AnchorWidget(header, parent, yOffset)
    yOffset = yOffset - header:GetHeight() - LC.SPACING_AFTER_HEADER

    local enableToggle = W.CreateToggle(parent, {
        label = L["Interrupts"],
        tooltip = L["Enable interrupt announcements"],
        get = function() return db.profile.interrupts.enabled end,
        set = function(value) db.profile.interrupts.enabled = value end,
    })
    LC.AnchorWidget(enableToggle, parent, yOffset)
    yOffset = yOffset - enableToggle:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local channelDropdown = W.CreateDropdown(parent, {
        label = L["Channel"],
        tooltip = L["Chat channel to send announcements to"],
        values = ns.CHANNEL_VALUES,
        get = function() return db.profile.interrupts.channel end,
        set = function(value) db.profile.interrupts.channel = value end,
    })
    LC.AnchorWidget(channelDropdown, parent, yOffset)
    yOffset = yOffset - channelDropdown:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local templateInput = W.CreateTextInput(parent, {
        label = L["Template"],
        tooltip = L["Announcement template. Tokens: {spell}, {target}, {extraSpell}"],
        get = function() return db.profile.interrupts.template end,
        set = function(value) db.profile.interrupts.template = value end,
    })
    LC.AnchorWidget(templateInput, parent, yOffset)
    yOffset = yOffset - templateInput:GetHeight()

    parent:SetHeight(math_abs(yOffset) + LC.PADDING_BOTTOM)
end

-------------------------------------------------------------------------------
-- Register tab
-------------------------------------------------------------------------------

ns.Tabs[#ns.Tabs + 1] = {
    id = "interrupts",
    label = L["Interrupts"],
    order = 2,
    createFunc = CreateContent,
}

-------------------------------------------------------------------------------
-- CCOnYouTab.lua
-- CC-on-you announcement settings tab
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
-- Build the CC on You tab content
-------------------------------------------------------------------------------

local function CreateContent(parent)
    dsns = ns.dsns
    local db = dsns.Addon.db
    local yOffset = LC.PADDING_TOP

    local header = W.CreateHeader(parent, L["CC on You"])
    LC.AnchorWidget(header, parent, yOffset)
    yOffset = yOffset - header:GetHeight() - LC.SPACING_AFTER_HEADER

    local enableToggle = W.CreateToggle(parent, {
        label = L["CC on You"],
        tooltip = L["Enable CC-on-you announcements"],
        get = function() return db.profile.ccOnYou.enabled end,
        set = function(value) db.profile.ccOnYou.enabled = value end,
    })
    LC.AnchorWidget(enableToggle, parent, yOffset)
    yOffset = yOffset - enableToggle:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local channelDropdown = W.CreateDropdown(parent, {
        label = L["Channel"],
        tooltip = L["Chat channel to send announcements to"],
        values = ns.CHANNEL_VALUES,
        get = function() return db.profile.ccOnYou.channel end,
        set = function(value) db.profile.ccOnYou.channel = value end,
    })
    LC.AnchorWidget(channelDropdown, parent, yOffset)
    yOffset = yOffset - channelDropdown:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local templateInput = W.CreateTextInput(parent, {
        label = L["Template"],
        tooltip = L["Announcement template. Tokens: {spell}, {type}, {duration}"],
        get = function() return db.profile.ccOnYou.template end,
        set = function(value) db.profile.ccOnYou.template = value end,
    })
    LC.AnchorWidget(templateInput, parent, yOffset)
    yOffset = yOffset - templateInput:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    -- CC Types section
    yOffset = yOffset - LC.SPACING_BETWEEN_SECTIONS

    local typesHeader = W.CreateHeader(parent, L["CC Types"])
    LC.AnchorWidget(typesHeader, parent, yOffset)
    yOffset = yOffset - typesHeader:GetHeight() - LC.SPACING_AFTER_HEADER

    local CC_TOGGLES = {
        { key = "silence",   label = L["Silence"],   tooltip = L["Announce when silenced"] },
        { key = "polymorph", label = L["Polymorph"], tooltip = L["Announce when polymorphed"] },
        { key = "stun",      label = L["Stun"],      tooltip = L["Announce when stunned"] },
        { key = "disorient", label = L["Disorient"], tooltip = L["Announce when disoriented"] },
        { key = "fear",      label = L["Fear"],      tooltip = L["Announce when feared"] },
        { key = "root",      label = L["Root"],      tooltip = L["Announce when rooted"] },
    }

    for _, ccToggle in ipairs(CC_TOGGLES) do
        local toggle = W.CreateToggle(parent, {
            label = ccToggle.label,
            tooltip = ccToggle.tooltip,
            get = function() return db.profile.ccOnYou[ccToggle.key] end,
            set = function(value) db.profile.ccOnYou[ccToggle.key] = value end,
        })
        LC.AnchorWidget(toggle, parent, yOffset)
        yOffset = yOffset - toggle:GetHeight() - LC.SPACING_BETWEEN_WIDGETS
    end

    parent:SetHeight(math_abs(yOffset) + LC.PADDING_BOTTOM)
end

-------------------------------------------------------------------------------
-- Register tab
-------------------------------------------------------------------------------

ns.Tabs[#ns.Tabs + 1] = {
    id = "cc_on_you",
    label = L["CC on You"],
    order = 3,
    createFunc = CreateContent,
}

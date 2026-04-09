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
local ipairs = ipairs

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

    -- Section 1: CC on You
    local section1 = W.CreateSection(parent, L["CC on You"])
    local content1 = section1.content
    local innerY = -LC.SECTION_PADDING_TOP

    local enableToggle = W.CreateToggle(content1, {
        label = L["CC on You"],
        tooltip = L["Enable CC-on-you announcements"],
        get = function() return db.profile.ccOnYou.enabled end,
        set = function(value) db.profile.ccOnYou.enabled = value end,
    })
    innerY = LC.AnchorWidget(enableToggle, content1, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local soloDropdown = W.CreateDropdown(content1, {
        label = L["Solo Channel"],
        tooltip = L["Channel used when not in any group (LOCAL prints only to your own chat frame)"],
        values = ns.CHANNEL_VALUES,
        get = function() return db.profile.ccOnYou.channelSolo end,
        set = function(value) db.profile.ccOnYou.channelSolo = value end,
    })
    innerY = LC.AnchorWidget(soloDropdown, content1, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local groupDropdown = W.CreateDropdown(content1, {
        label = L["Group Channel"],
        tooltip = L["Channel used when in a party"],
        values = ns.CHANNEL_VALUES,
        get = function() return db.profile.ccOnYou.channelGroup end,
        set = function(value) db.profile.ccOnYou.channelGroup = value end,
    })
    innerY = LC.AnchorWidget(groupDropdown, content1, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local raidDropdown = W.CreateDropdown(content1, {
        label = L["Raid/Instance Channel"],
        tooltip = L["Channel used when in a raid or instance group"],
        values = ns.CHANNEL_VALUES,
        get = function() return db.profile.ccOnYou.channelRaid end,
        set = function(value) db.profile.ccOnYou.channelRaid = value end,
    })
    innerY = LC.AnchorWidget(raidDropdown, content1, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local templateInput = W.CreateTextInput(content1, {
        label = L["Template"],
        tooltip = L["Announcement template. Tokens: {spell}, {type}, {duration}"],
        get = function() return db.profile.ccOnYou.template end,
        set = function(value) db.profile.ccOnYou.template = value end,
    })
    innerY = LC.AnchorWidget(templateInput, content1, innerY) - LC.SPACING_BETWEEN_WIDGETS

    section1:SetContentHeight(math_abs(innerY) + LC.SECTION_PADDING_BOTTOM)
    yOffset = LC.AnchorSection(section1, parent, yOffset) - LC.SPACING_BETWEEN_SECTIONS

    -- Section 2: CC Types
    local section2 = W.CreateSection(parent, L["CC Types"])
    local content2 = section2.content
    innerY = -LC.SECTION_PADDING_TOP

    local CC_TOGGLES = {
        { key = "silence",   label = L["Silence"],   tooltip = L["Announce when silenced"] },
        { key = "polymorph", label = L["Polymorph"], tooltip = L["Announce when polymorphed"] },
        { key = "stun",      label = L["Stun"],      tooltip = L["Announce when stunned"] },
        { key = "disorient", label = L["Disorient"], tooltip = L["Announce when disoriented"] },
        { key = "fear",      label = L["Fear"],      tooltip = L["Announce when feared"] },
        { key = "root",      label = L["Root"],      tooltip = L["Announce when rooted"] },
    }

    for _, ccToggle in ipairs(CC_TOGGLES) do
        local toggle = W.CreateToggle(content2, {
            label = ccToggle.label,
            tooltip = ccToggle.tooltip,
            get = function() return db.profile.ccOnYou[ccToggle.key] end,
            set = function(value) db.profile.ccOnYou[ccToggle.key] = value end,
        })
        innerY = LC.AnchorWidget(toggle, content2, innerY) - LC.SPACING_BETWEEN_WIDGETS
    end

    section2:SetContentHeight(math_abs(innerY) + LC.SECTION_PADDING_BOTTOM)
    yOffset = LC.AnchorSection(section2, parent, yOffset) - LC.SPACING_BETWEEN_SECTIONS

    -- Section 3: Per-Type Templates
    local section3 = W.CreateSection(parent, L["Per-Type Templates"])
    local content3 = section3.content
    innerY = -LC.SECTION_PADDING_TOP

    local perTypeDesc = W.CreateDescription(content3, L["Leave blank to use the default template above."])
    innerY = LC.AnchorWidget(perTypeDesc, content3, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local CC_TYPE_TEMPLATES = {
        { key = "silence",   label = L["Silence template"] },
        { key = "polymorph", label = L["Polymorph template"] },
        { key = "stun",      label = L["Stun template"] },
        { key = "disorient", label = L["Disorient template"] },
        { key = "fear",      label = L["Fear template"] },
        { key = "root",      label = L["Root template"] },
    }

    for _, tplEntry in ipairs(CC_TYPE_TEMPLATES) do
        local typeInput = W.CreateTextInput(content3, {
            label = tplEntry.label,
            tooltip = tplEntry.label,
            get = function() return db.profile.ccOnYou.typeTemplates[tplEntry.key] or "" end,
            set = function(value) db.profile.ccOnYou.typeTemplates[tplEntry.key] = value end,
        })
        innerY = LC.AnchorWidget(typeInput, content3, innerY) - LC.SPACING_BETWEEN_WIDGETS
    end

    section3:SetContentHeight(math_abs(innerY) + LC.SECTION_PADDING_BOTTOM)
    yOffset = LC.AnchorSection(section3, parent, yOffset) - LC.SPACING_BETWEEN_SECTIONS

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

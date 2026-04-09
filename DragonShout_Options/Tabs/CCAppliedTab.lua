-------------------------------------------------------------------------------
-- CCAppliedTab.lua
-- CC-applied announcement settings tab
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
-- Build the CC Applied tab content
-------------------------------------------------------------------------------

local function CreateContent(parent)
    dsns = ns.dsns
    local db = dsns.Addon.db
    local yOffset = LC.PADDING_TOP

    local section = W.CreateSection(parent, L["CC Applied"])
    local content = section.content
    local innerY = -LC.SECTION_PADDING_TOP

    local enableToggle = W.CreateToggle(content, {
        label = L["CC Applied"],
        tooltip = L["Enable CC-applied announcements"],
        get = function() return db.profile.ccApplied.enabled end,
        set = function(value) db.profile.ccApplied.enabled = value end,
    })
    innerY = LC.AnchorWidget(enableToggle, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local soloDropdown = W.CreateDropdown(content, {
        label = L["Solo Channel"],
        tooltip = L["Channel used when not in any group (LOCAL prints only to your own chat frame)"],
        values = ns.CHANNEL_VALUES,
        get = function() return db.profile.ccApplied.channelSolo end,
        set = function(value) db.profile.ccApplied.channelSolo = value end,
    })
    innerY = LC.AnchorWidget(soloDropdown, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local groupDropdown = W.CreateDropdown(content, {
        label = L["Group Channel"],
        tooltip = L["Channel used when in a party"],
        values = ns.CHANNEL_VALUES,
        get = function() return db.profile.ccApplied.channelGroup end,
        set = function(value) db.profile.ccApplied.channelGroup = value end,
    })
    innerY = LC.AnchorWidget(groupDropdown, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local raidDropdown = W.CreateDropdown(content, {
        label = L["Raid/Instance Channel"],
        tooltip = L["Channel used when in a raid or instance group"],
        values = ns.CHANNEL_VALUES,
        get = function() return db.profile.ccApplied.channelRaid end,
        set = function(value) db.profile.ccApplied.channelRaid = value end,
    })
    innerY = LC.AnchorWidget(raidDropdown, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local templateInput = W.CreateTextInput(content, {
        label = L["Template"],
        tooltip = L["Announcement template. Tokens: {spell}, {target}"],
        get = function() return db.profile.ccApplied.template end,
        set = function(value) db.profile.ccApplied.template = value end,
    })
    innerY = LC.AnchorWidget(templateInput, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    section:SetContentHeight(math_abs(innerY) + LC.SECTION_PADDING_BOTTOM)
    yOffset = LC.AnchorSection(section, parent, yOffset) - LC.SPACING_BETWEEN_SECTIONS

    parent:SetHeight(math_abs(yOffset) + LC.PADDING_BOTTOM)
end

-------------------------------------------------------------------------------
-- Register tab
-------------------------------------------------------------------------------

ns.Tabs[#ns.Tabs + 1] = {
    id = "cc_applied",
    label = L["CC Applied"],
    order = 4,
    createFunc = CreateContent,
}

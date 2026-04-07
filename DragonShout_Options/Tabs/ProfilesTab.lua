-------------------------------------------------------------------------------
-- ProfilesTab.lua
-- Profile management tab: switch, create, copy, reset, delete profiles
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached globals
-------------------------------------------------------------------------------

local pairs = pairs
local table_sort = table.sort
local math_abs = math.abs
local StaticPopup_Show = StaticPopup_Show
local StaticPopupDialogs = StaticPopupDialogs

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
local isCallbacksRegistered = false

-------------------------------------------------------------------------------
-- Static popup dialogs (defined at file scope)
-------------------------------------------------------------------------------

StaticPopupDialogs["DRAGONSHOUT_OPTIONS_RESET_PROFILE"] = {
    text = L["Are you sure you want to reset the current profile?"],
    button1 = L["Reset"],
    button2 = L["Cancel"],
    OnAccept = function()
        local ds = ns.dsns
        if not ds or not ds.Addon or not ds.Addon.db then return end
        ds.Addon.db:ResetProfile()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["DRAGONSHOUT_OPTIONS_DELETE_PROFILE"] = {
    text = L["Are you sure you want to delete the profile \"%s\"?"],
    button1 = L["Delete"],
    button2 = L["Cancel"],
    OnAccept = function(self)
        local profileName = self.data
        if not profileName then return end
        local ds = ns.dsns
        if not ds or not ds.Addon or not ds.Addon.db then return end
        ds.Addon.db:DeleteProfile(profileName)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function GetProfileValues()
    local db = dsns.Addon.db
    local profiles = db:GetProfiles()
    local values = {}
    for _, name in pairs(profiles) do
        values[#values + 1] = { value = name, text = name }
    end
    table_sort(values, function(a, b) return a.text < b.text end)
    return values
end

local function GetOtherProfileValues()
    local db = dsns.Addon.db
    local profiles = db:GetProfiles()
    local current = db:GetCurrentProfile()
    local values = {}
    for _, name in pairs(profiles) do
        if name ~= current then
            values[#values + 1] = { value = name, text = name }
        end
    end
    table_sort(values, function(a, b) return a.text < b.text end)
    return values
end

-------------------------------------------------------------------------------
-- Section builders
-------------------------------------------------------------------------------

local function CreateCurrentProfileSection(parent, yOffset, refreshAll)
    local db = dsns.Addon.db
    local newProfileName = ""

    local header = W.CreateHeader(parent, L["Current Profile"])
    LC.AnchorWidget(header, parent, yOffset)
    yOffset = yOffset - header:GetHeight() - LC.SPACING_AFTER_HEADER

    local desc = W.CreateDescription(parent,
        L["Profiles allow you to save different configurations for different characters."])
    LC.AnchorWidget(desc, parent, yOffset)
    yOffset = yOffset - desc:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local activeDropdown = W.CreateDropdown(parent, {
        label = L["Active Profile"],
        tooltip = L["Select the active profile"],
        values = GetProfileValues,
        get = function() return db:GetCurrentProfile() end,
        set = function(value)
            db:SetProfile(value)
            refreshAll()
        end,
    })
    LC.AnchorWidget(activeDropdown, parent, yOffset)
    yOffset = yOffset - activeDropdown:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local newProfileInput = W.CreateTextInput(parent, {
        label = L["New Profile Name"],
        tooltip = L["Enter a name for a new profile"],
        get = function() return "" end,
        set = function(value) newProfileName = value end,
    })
    LC.AnchorWidget(newProfileInput, parent, yOffset)
    yOffset = yOffset - newProfileInput:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local createButton = W.CreateButton(parent, {
        text = L["Create Profile"],
        tooltip = L["Create a new profile with the entered name"],
        onClick = function()
            if newProfileName and newProfileName ~= "" then
                db:SetProfile(newProfileName)
                newProfileName = ""
                if newProfileInput.Refresh then
                    newProfileInput:Refresh()
                end
                refreshAll()
            end
        end,
    })
    LC.AnchorWidget(createButton, parent, yOffset)
    yOffset = yOffset - createButton:GetHeight()

    return yOffset, activeDropdown
end

local function CreateActionsSection(parent, yOffset, refreshAll)
    local db = dsns.Addon.db

    yOffset = yOffset - LC.SPACING_BETWEEN_SECTIONS

    local header = W.CreateHeader(parent, L["Profile Actions"])
    LC.AnchorWidget(header, parent, yOffset)
    yOffset = yOffset - header:GetHeight() - LC.SPACING_AFTER_HEADER

    local copyDropdown = W.CreateDropdown(parent, {
        label = L["Copy From"],
        tooltip = L["Copy settings from another profile"],
        values = GetOtherProfileValues,
        get = function() return "" end,
        set = function(value)
            db:CopyProfile(value)
            refreshAll()
        end,
    })
    LC.AnchorWidget(copyDropdown, parent, yOffset)
    yOffset = yOffset - copyDropdown:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local resetButton = W.CreateButton(parent, {
        text = L["Reset Profile"],
        tooltip = L["Reset the current profile to default settings"],
        onClick = function()
            StaticPopup_Show("DRAGONSHOUT_OPTIONS_RESET_PROFILE")
        end,
    })
    LC.AnchorWidget(resetButton, parent, yOffset)
    yOffset = yOffset - resetButton:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local deleteDropdown = W.CreateDropdown(parent, {
        label = L["Delete Profile"],
        tooltip = L["Delete a profile"],
        values = GetOtherProfileValues,
        get = function() return "" end,
        set = function(value)
            StaticPopup_Show("DRAGONSHOUT_OPTIONS_DELETE_PROFILE", value)
        end,
    })
    LC.AnchorWidget(deleteDropdown, parent, yOffset)
    yOffset = yOffset - deleteDropdown:GetHeight()

    return yOffset, copyDropdown, deleteDropdown
end

-------------------------------------------------------------------------------
-- Build the Profiles tab content
-------------------------------------------------------------------------------

local function CreateContent(parent)
    dsns = ns.dsns
    local db = dsns.Addon.db
    local yOffset = LC.PADDING_TOP

    local activeDropdown, copyDropdown, deleteDropdown

    local function RefreshProfileWidgets()
        local widgets = { activeDropdown, copyDropdown, deleteDropdown }
        for _, widget in pairs(widgets) do
            if widget and widget.Refresh then
                widget:Refresh()
            end
        end
        if ns.RefreshVisibleWidgets then
            ns.RefreshVisibleWidgets()
        end
    end

    yOffset, activeDropdown = CreateCurrentProfileSection(parent, yOffset, RefreshProfileWidgets)
    yOffset, copyDropdown, deleteDropdown = CreateActionsSection(parent, yOffset, RefreshProfileWidgets)

    parent:SetHeight(math_abs(yOffset) + LC.PADDING_BOTTOM)

    if not isCallbacksRegistered then
        db:RegisterCallback("OnProfileChanged", RefreshProfileWidgets)
        db:RegisterCallback("OnProfileCopied", RefreshProfileWidgets)
        db:RegisterCallback("OnProfileReset", RefreshProfileWidgets)
        db:RegisterCallback("OnNewProfile", RefreshProfileWidgets)
        db:RegisterCallback("OnProfileDeleted", RefreshProfileWidgets)
        isCallbacksRegistered = true
    end
end

-------------------------------------------------------------------------------
-- Register tab
-------------------------------------------------------------------------------

ns.Tabs[#ns.Tabs + 1] = {
    id = "profiles",
    label = L["Profiles"],
    order = 7,
    createFunc = CreateContent,
}

-------------------------------------------------------------------------------
-- DebugTab.lua
-- Debug settings + in-memory debug log viewer
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached globals
-------------------------------------------------------------------------------

local math_abs = math.abs
local table_concat = table.concat
local CreateFrame = CreateFrame

-------------------------------------------------------------------------------
-- DragonWidgets references
-------------------------------------------------------------------------------

local W = ns.DW.Widgets
local LC = ns.DW.LayoutConstants
local L = ns.L

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

local LOG_VIEWER_HEIGHT = 320
local LOG_BUTTON_ROW_HEIGHT = 24
local LOG_HINT_HEIGHT = 16

-------------------------------------------------------------------------------
-- Namespace references
-------------------------------------------------------------------------------

local dsns

-------------------------------------------------------------------------------
-- Settings section: debug toggle + status/throttle buttons
-------------------------------------------------------------------------------

local function CreateSettingsSection(parent, yOffset)
    local db = dsns.Addon.db

    local section = W.CreateSection(parent, L["Debug Settings"])
    local content = section.content
    local innerY = -LC.SECTION_PADDING_TOP

    local debugToggle = W.CreateToggle(content, {
        label = L["Enable Debug Mode"],
        tooltip = L["Enable verbose debug logging to chat"],
        get = function() return dsns._debugMode or (db.profile.debug) end,
        set = function(value)
            dsns._debugMode = value
            db.profile.debug = value
        end,
    })
    innerY = LC.AnchorWidget(debugToggle, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local printStatusButton = W.CreateButton(content, {
        text = L["Print Status"],
        tooltip = L["Print current addon state to chat"],
        onClick = function()
            dsns.HandleSlashCommand("status")
        end,
    })
    innerY = LC.AnchorWidget(printStatusButton, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local clearThrottleButton = W.CreateButton(content, {
        text = L["Clear Throttle"],
        tooltip = L["Reset all announce throttle timers"],
        onClick = function()
            dsns.Announcer.ClearThrottle()
            dsns.Print(L["Reset all announce throttle timers"])
        end,
    })
    innerY = LC.AnchorWidget(clearThrottleButton, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    section:SetContentHeight(math_abs(innerY) + LC.SECTION_PADDING_BOTTOM)
    yOffset = LC.AnchorSection(section, parent, yOffset) - LC.SPACING_BETWEEN_SECTIONS

    return yOffset
end

-------------------------------------------------------------------------------
-- Build the scrollable, read-only log viewer (vanilla ScrollFrame + EditBox)
--
-- Returns the outer container frame and a Refresh(text) function. The container
-- is sized by the caller via SetHeight before content is populated.
-------------------------------------------------------------------------------

local function CreateLogViewer(parent)
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    container:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    container:SetBackdropColor(0, 0, 0, 0.6)
    container:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    local scroll = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", container, "TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -26, 6)

    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetMaxLetters(0)
    edit:SetWidth(1)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    scroll:SetScrollChild(edit)
    scroll:SetScript("OnSizeChanged", function(self)
        edit:SetWidth(self:GetWidth())
    end)

    local function Refresh(text)
        edit:SetText(text or "")
    end

    local function FocusAndHighlight()
        edit:SetFocus()
        edit:HighlightText()
    end

    return container, Refresh, FocusAndHighlight
end

-------------------------------------------------------------------------------
-- Format ns.GetDebugLog() output as newline-joined text
-------------------------------------------------------------------------------

local function BuildLogText()
    if not dsns.GetDebugLog then return nil end
    local entries = dsns.GetDebugLog()
    if not entries or #entries == 0 then return "" end

    local lines = {}
    for i = 1, #entries do
        lines[i] = entries[i].text or ""
    end
    return table_concat(lines, "\n")
end

-------------------------------------------------------------------------------
-- Log section: viewer + Refresh / Clear / Copy buttons + hint
-------------------------------------------------------------------------------

local function CreateLogSection(parent, yOffset)
    local section = W.CreateSection(parent, L["Debug Log"])
    local content = section.content
    local innerY = -LC.SECTION_PADDING_TOP

    -- Defensive: main addon may not yet expose the log accessors
    if not dsns.GetDebugLog then
        local hint = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        hint:SetPoint("TOPLEFT", content, "TOPLEFT", 0, innerY)
        hint:SetText("Debug log unavailable")
        innerY = innerY - 20

        section:SetContentHeight(math_abs(innerY) + LC.SECTION_PADDING_BOTTOM)
        return LC.AnchorSection(section, parent, yOffset) - LC.SPACING_BETWEEN_SECTIONS
    end

    -- Log viewer (fixed height; the outer tab is itself scrollable)
    local viewer, RefreshViewer, FocusAndHighlight = CreateLogViewer(content)
    viewer:SetHeight(LOG_VIEWER_HEIGHT)
    viewer:SetPoint("TOPLEFT", content, "TOPLEFT", 0, innerY)
    viewer:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, innerY)
    innerY = innerY - LOG_VIEWER_HEIGHT - LC.SPACING_BETWEEN_WIDGETS

    local function DoRefresh()
        RefreshViewer(BuildLogText())
    end

    -- Button row: Refresh | Clear | Copy
    local buttonRow = CreateFrame("Frame", nil, content)
    buttonRow:SetHeight(LOG_BUTTON_ROW_HEIGHT)
    buttonRow:SetPoint("TOPLEFT", content, "TOPLEFT", 0, innerY)
    buttonRow:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, innerY)

    local refreshBtn = W.CreateButton(buttonRow, {
        text = L["Refresh"],
        tooltip = L["Refresh"],
        onClick = DoRefresh,
    })
    refreshBtn:ClearAllPoints()
    refreshBtn:SetPoint("TOPLEFT", buttonRow, "TOPLEFT", 0, 0)

    local clearBtn = W.CreateButton(buttonRow, {
        text = L["Clear Log"],
        tooltip = L["Clear Log"],
        onClick = function()
            dsns.ClearDebugLog()
            DoRefresh()
        end,
    })
    clearBtn:ClearAllPoints()
    clearBtn:SetPoint("LEFT", refreshBtn, "RIGHT", 6, 0)

    local copyBtn = W.CreateButton(buttonRow, {
        text = L["Copy"],
        tooltip = L["Click in the box and press Ctrl+C to copy"],
        onClick = FocusAndHighlight,
    })
    copyBtn:ClearAllPoints()
    copyBtn:SetPoint("LEFT", clearBtn, "RIGHT", 6, 0)

    innerY = innerY - LOG_BUTTON_ROW_HEIGHT - LC.SPACING_BETWEEN_WIDGETS

    -- Copy hint label below the button row
    local hint = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", content, "TOPLEFT", 0, innerY)
    hint:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, innerY)
    hint:SetJustifyH("LEFT")
    hint:SetText(L["Click in the box and press Ctrl+C to copy"])
    innerY = innerY - LOG_HINT_HEIGHT

    -- Initial fill so the user sees existing entries on first open
    DoRefresh()

    section:SetContentHeight(math_abs(innerY) + LC.SECTION_PADDING_BOTTOM)
    yOffset = LC.AnchorSection(section, parent, yOffset) - LC.SPACING_BETWEEN_SECTIONS

    return yOffset
end

-------------------------------------------------------------------------------
-- Build the Debug tab content
-------------------------------------------------------------------------------

local function CreateContent(parent)
    dsns = ns.dsns
    local yOffset = LC.PADDING_TOP

    yOffset = CreateSettingsSection(parent, yOffset)
    yOffset = CreateLogSection(parent, yOffset)

    parent:SetHeight(math_abs(yOffset) + LC.PADDING_BOTTOM)
end

-------------------------------------------------------------------------------
-- Register tab
-------------------------------------------------------------------------------

ns.Tabs[#ns.Tabs + 1] = {
    id = "debug",
    label = L["Debug"],
    order = 99,
    createFunc = CreateContent,
}

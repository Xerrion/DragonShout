-------------------------------------------------------------------------------
-- CustomSpellsTab.lua
-- Custom spell announcement list with inline per-spell editing
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ... -- luacheck: ignore 211/ADDON_NAME

-------------------------------------------------------------------------------
-- Cached globals
-------------------------------------------------------------------------------

local math_abs = math.abs
local tonumber = tonumber
local tostring = tostring
local tinsert = table.insert
local tremove = table.remove
local ipairs = ipairs
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo

-------------------------------------------------------------------------------
-- DragonWidgets references
-------------------------------------------------------------------------------

local W = ns.DW.Widgets
local WC = ns.DW.Widgets and ns.DW.LayoutConstants and DragonWidgetsNS and DragonWidgetsNS.WidgetConstants
local LC = ns.DW.LayoutConstants
local L = ns.L

-------------------------------------------------------------------------------
-- Namespace references
-------------------------------------------------------------------------------

local dsns

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

local ICON_SIZE = 36
local ROW_HEIGHT = 40
local ROW_SPACING = 4
local FONT_PATH = WC and WC.FONT_PATH or "Fonts\\FRIZQT__.TTF"
local WHITE8x8 = WC and WC.WHITE8x8 or "Interface\\Buttons\\WHITE8x8"
local ROW_BG = { 0.10, 0.10, 0.11, 0.80 }
local ROW_BG_HOVER = { 0.18, 0.18, 0.20, 0.90 }
local ROW_BORDER = { 0.25, 0.25, 0.28, 0.60 }
local ROW_BG_EXPANDED = { 0.14, 0.14, 0.16, 0.90 }
local EDIT_BG = { 0.08, 0.08, 0.09, 0.95 }
local EDIT_BORDER = { 0.30, 0.30, 0.35, 0.70 }
local WHITE = { 1, 1, 1, 1 }
local GRAY = { 0.65, 0.65, 0.65, 1 }
local RED = { 0.9, 0.25, 0.25, 1 }
local GREEN = { 0.25, 0.9, 0.35, 1 }
local CHANNEL_LABEL_COLOR = { 0.70, 0.85, 1.0, 1 }

-------------------------------------------------------------------------------
-- Version-safe spell name resolver
-------------------------------------------------------------------------------

local function GetSpellNameSafe(spellId)
    if C_Spell and C_Spell.GetSpellName then
        return C_Spell.GetSpellName(spellId)
    end
    local name = GetSpellInfo(spellId)
    return name
end

-------------------------------------------------------------------------------
-- Version-safe spell texture resolver
-------------------------------------------------------------------------------

local function GetSpellTextureSafe(spellId)
    if C_Spell and C_Spell.GetSpellTexture then
        return C_Spell.GetSpellTexture(spellId)
    end
    return GetSpellTexture(spellId)
end

-------------------------------------------------------------------------------
-- Build a compact channel summary string for the row header
-- e.g. "Solo: LOCAL  Group: PARTY  Raid: RAID"
-------------------------------------------------------------------------------

local function BuildChannelSummary(entry)
    local solo  = entry.channelSolo  or entry.channel or "LOCAL"
    local group = entry.channelGroup or entry.channel or "PARTY"
    local raid  = entry.channelRaid  or entry.channel or "RAID"
    return (L["Solo: "] or "Solo: ") .. solo
        .. "   " .. (L["Group: "] or "Group: ") .. group
        .. "   " .. (L["Raid: "] or "Raid: ") .. raid
end

-------------------------------------------------------------------------------
-- Spell list state
-------------------------------------------------------------------------------

local expandedIndex = nil  -- which row index is currently expanded (nil = none)

-------------------------------------------------------------------------------
-- RebuildList: wipe and recreate all spell rows inside listContainer
-------------------------------------------------------------------------------

local function RebuildList(listContainer, db, newSpellIdRef, spellIdInput, section, parent, yOffsetRef)
    -- Clear all previous children
    for _, child in ipairs({ listContainer:GetChildren() }) do
        child:SetScript("OnEnter", nil)
        child:SetScript("OnLeave", nil)
        child:SetScript("OnMouseUp", nil)
        child:Hide()
        child:SetParent(nil)
    end

    local spells = db.profile.customSpells

    if #spells == 0 then
        local emptyText = listContainer:CreateFontString(nil, "OVERLAY")
        emptyText:SetFont(FONT_PATH, 12, "")
        emptyText:SetTextColor(GRAY[1], GRAY[2], GRAY[3], GRAY[4])
        emptyText:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 0, -8)
        emptyText:SetText(L["No custom spells configured."])
        listContainer:SetHeight(32)
        return
    end

    local yPos = 0

    for i, entry in ipairs(spells) do
        local isExpanded = (expandedIndex == i)

        -- Row container
        local row = CreateFrame("Frame", nil, listContainer, "BackdropTemplate")
        row:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 0, -yPos)
        row:SetPoint("RIGHT", listContainer, "RIGHT", 0, 0)
        row:SetHeight(ROW_HEIGHT)
        row:SetBackdrop({ bgFile = WHITE8x8, edgeFile = WHITE8x8, edgeSize = 1 })

        if isExpanded then
            row:SetBackdropColor(ROW_BG_EXPANDED[1], ROW_BG_EXPANDED[2], ROW_BG_EXPANDED[3], ROW_BG_EXPANDED[4])
        else
            row:SetBackdropColor(ROW_BG[1], ROW_BG[2], ROW_BG[3], ROW_BG[4])
        end
        row:SetBackdropBorderColor(ROW_BORDER[1], ROW_BORDER[2], ROW_BORDER[3], ROW_BORDER[4])
        row:EnableMouse(true)

        -- Hover highlight (captured for closure)
        local rowIndex = i
        row:SetScript("OnEnter", function(self)
            if expandedIndex ~= rowIndex then
                self:SetBackdropColor(ROW_BG_HOVER[1], ROW_BG_HOVER[2], ROW_BG_HOVER[3], ROW_BG_HOVER[4])
            end
        end)
        row:SetScript("OnLeave", function(self)
            if expandedIndex ~= rowIndex then
                self:SetBackdropColor(ROW_BG[1], ROW_BG[2], ROW_BG[3], ROW_BG[4])
            end
        end)

        -- Spell icon
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(ICON_SIZE, ICON_SIZE)
        icon:SetPoint("LEFT", row, "LEFT", 4, 0)
        local texturePath = GetSpellTextureSafe(entry.spellId) or "Interface\\Icons\\INV_Misc_QuestionMark"
        icon:SetTexture(texturePath)

        -- Spell name
        local spellName = GetSpellNameSafe(entry.spellId) or (L["Unknown Spell"] or "Unknown Spell")
        local nameText = row:CreateFontString(nil, "OVERLAY")
        nameText:SetFont(FONT_PATH, 13, "")
        nameText:SetTextColor(WHITE[1], WHITE[2], WHITE[3], WHITE[4])
        nameText:SetPoint("TOPLEFT", row, "TOPLEFT", ICON_SIZE + 10, -6)
        nameText:SetText(spellName .. " |cff888888[" .. tostring(entry.spellId) .. "]|r")

        -- Channel summary
        local channelText = row:CreateFontString(nil, "OVERLAY")
        channelText:SetFont(FONT_PATH, 10, "")
        channelText:SetTextColor(CHANNEL_LABEL_COLOR[1], CHANNEL_LABEL_COLOR[2], CHANNEL_LABEL_COLOR[3])
        channelText:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", ICON_SIZE + 10, 5)
        channelText:SetText(BuildChannelSummary(entry))

        -- Enabled indicator dot
        local dotText = row:CreateFontString(nil, "OVERLAY")
        dotText:SetFont(FONT_PATH, 14, "OUTLINE")
        dotText:SetPoint("RIGHT", row, "RIGHT", -36, 0)
        if entry.enabled ~= false then
            dotText:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
            dotText:SetText("|cff40e860o|r")
        else
            dotText:SetTextColor(RED[1], RED[2], RED[3])
            dotText:SetText("|cffe84040o|r")
        end

        -- Remove button
        local removeBtn = CreateFrame("Button", nil, row)
        removeBtn:SetSize(28, 28)
        removeBtn:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        local removeTex = removeBtn:CreateFontString(nil, "OVERLAY")
        removeTex:SetFont(FONT_PATH, 14, "OUTLINE")
        removeTex:SetAllPoints(removeBtn)
        removeTex:SetTextColor(RED[1], RED[2], RED[3])
        removeTex:SetText("x")
        removeBtn:SetScript("OnClick", function()
            if expandedIndex == rowIndex then
                expandedIndex = nil
            elseif expandedIndex and expandedIndex > rowIndex then
                expandedIndex = expandedIndex - 1
            end
            tremove(spells, rowIndex)
            RebuildList(listContainer, db, newSpellIdRef, spellIdInput, section, parent, yOffsetRef)
        end)

        -- Click-to-expand on the row body
        row:SetScript("OnMouseUp", function(_, button)
            if button == "LeftButton" then
                if expandedIndex == rowIndex then
                    expandedIndex = nil
                else
                    expandedIndex = rowIndex
                end
                RebuildList(listContainer, db, newSpellIdRef, spellIdInput, section, parent, yOffsetRef)
            end
        end)

        yPos = yPos + ROW_HEIGHT + ROW_SPACING

        -- Inline edit form (only when this row is expanded)
        if isExpanded then
            local editForm = CreateFrame("Frame", nil, listContainer, "BackdropTemplate")
            editForm:SetPoint("TOPLEFT", listContainer, "TOPLEFT", 0, -yPos)
            editForm:SetPoint("RIGHT", listContainer, "RIGHT", 0, 0)
            editForm:SetBackdrop({ bgFile = WHITE8x8, edgeFile = WHITE8x8, edgeSize = 1 })
            editForm:SetBackdropColor(EDIT_BG[1], EDIT_BG[2], EDIT_BG[3], EDIT_BG[4])
            editForm:SetBackdropBorderColor(EDIT_BORDER[1], EDIT_BORDER[2], EDIT_BORDER[3], EDIT_BORDER[4])

            -- Make sure entry has per-context channel fields (migration guard)
            if not entry.channelSolo  then entry.channelSolo  = entry.channel or "LOCAL" end
            if not entry.channelGroup then entry.channelGroup = entry.channel or "PARTY" end
            if not entry.channelRaid  then entry.channelRaid  = entry.channel or "RAID"  end

            local formInnerY = -LC.SECTION_PADDING_TOP

            local soloDropdown = W.CreateDropdown(editForm, {
                label = L["Solo Channel"],
                tooltip = L["Channel used when solo (not in any group)"],
                values = ns.CHANNEL_VALUES,
                get = function() return entry.channelSolo end,
                set = function(value)
                    entry.channelSolo = value
                    entry.channel = nil
                    RebuildList(listContainer, db, newSpellIdRef, spellIdInput, section, parent, yOffsetRef)
                end,
            })
            formInnerY = LC.AnchorWidget(soloDropdown, editForm, formInnerY) - LC.SPACING_BETWEEN_WIDGETS

            local groupDropdown = W.CreateDropdown(editForm, {
                label = L["Group Channel"],
                tooltip = L["Channel used when in a party or group"],
                values = ns.CHANNEL_VALUES,
                get = function() return entry.channelGroup end,
                set = function(value)
                    entry.channelGroup = value
                    entry.channel = nil
                    RebuildList(listContainer, db, newSpellIdRef, spellIdInput, section, parent, yOffsetRef)
                end,
            })
            formInnerY = LC.AnchorWidget(groupDropdown, editForm, formInnerY) - LC.SPACING_BETWEEN_WIDGETS

            local raidDropdown = W.CreateDropdown(editForm, {
                label = L["Raid/Instance Channel"],
                tooltip = L["Channel used when in a raid or instance"],
                values = ns.CHANNEL_VALUES,
                get = function() return entry.channelRaid end,
                set = function(value)
                    entry.channelRaid = value
                    entry.channel = nil
                    RebuildList(listContainer, db, newSpellIdRef, spellIdInput, section, parent, yOffsetRef)
                end,
            })
            formInnerY = LC.AnchorWidget(raidDropdown, editForm, formInnerY) - LC.SPACING_BETWEEN_WIDGETS

            local templateInput = W.CreateTextInput(editForm, {
                label = L["Template"],
                tooltip = L["Template tokens: {spell} (spell name), {target} (target unit), {source} (caster)"],
                get = function() return entry.template or "" end,
                set = function(value)
                    entry.template = value
                    -- no rebuild needed for template edits (no visual change on the row header)
                end,
            })
            formInnerY = LC.AnchorWidget(templateInput, editForm, formInnerY) - LC.SPACING_BETWEEN_WIDGETS

            local enableToggle = W.CreateToggle(editForm, {
                label = L["Enabled"],
                tooltip = L["Enable this spell announcement"],
                get = function() return entry.enabled ~= false end,
                set = function(value)
                    entry.enabled = value
                    RebuildList(listContainer, db, newSpellIdRef, spellIdInput, section, parent, yOffsetRef)
                end,
            })
            formInnerY = LC.AnchorWidget(enableToggle, editForm, formInnerY) - LC.SPACING_BETWEEN_WIDGETS

            local formHeight = math_abs(formInnerY) + LC.SECTION_PADDING_BOTTOM
            editForm:SetHeight(formHeight)
            yPos = yPos + formHeight + ROW_SPACING
        end
    end

    listContainer:SetHeight(yPos > 0 and yPos or 32)
end

-------------------------------------------------------------------------------
-- Build the Custom Spells tab content
-------------------------------------------------------------------------------

local function CreateContent(parent)
    dsns = ns.dsns
    local db = dsns.Addon.db
    local yOffset = LC.PADDING_TOP
    local newSpellIdRef = { value = "" }

    local section = W.CreateSection(parent, L["Custom Spells"])
    local content = section.content
    local innerY = -LC.SECTION_PADDING_TOP

    -- Description
    local desc = W.CreateDescription(content, L["Add spell IDs to announce when applied to or by you."])
    innerY = LC.AnchorWidget(desc, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local tokenDesc = W.CreateDescription(content,
        L["Template tokens: {spell} (spell name), {target} (target unit), {source} (caster)"])
    innerY = LC.AnchorWidget(tokenDesc, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    -- List container (dynamically sized)
    local listContainer = CreateFrame("Frame", nil, content)
    listContainer:SetPoint("TOPLEFT", content, "TOPLEFT", 0, innerY)
    listContainer:SetPoint("RIGHT", content, "RIGHT", 0, 0)
    listContainer:SetHeight(32)

    -- Add spell controls (below the list)
    local addButton
    local spellIdInput = W.CreateTextInput(content, {
        label = L["Spell ID"],
        tooltip = L["Spell ID"],
        get = function() return newSpellIdRef.value end,
        set = function(value) newSpellIdRef.value = value end,
    })

    addButton = W.CreateButton(content, {
        text = L["Add"],
        tooltip = L["Add"],
        onClick = function()
            local id = tonumber(newSpellIdRef.value)
            if not id then return end

            tinsert(db.profile.customSpells, {
                spellId      = id,
                channelSolo  = "LOCAL",
                channelGroup = "PARTY",
                channelRaid  = "RAID",
                template     = "{spell} on {target}!",
                enabled      = true,
            })
            newSpellIdRef.value = ""
            if spellIdInput.Refresh then spellIdInput:Refresh() end
            expandedIndex = #db.profile.customSpells  -- auto-expand new entry
            RebuildList(listContainer, db, newSpellIdRef, spellIdInput, section, content, nil)
            -- Reflow the section height
            local listH = listContainer:GetHeight()
            local inputH = spellIdInput:GetHeight()
            local btnH = addButton:GetHeight()
            local totalInner = math_abs(innerY) + listH
                + LC.SPACING_BETWEEN_WIDGETS + inputH
                + LC.SPACING_BETWEEN_WIDGETS + btnH
                + LC.SECTION_PADDING_BOTTOM
            section:SetContentHeight(totalInner)
            parent:SetHeight(math_abs(yOffset) + section:GetHeight()
                + LC.SPACING_BETWEEN_SECTIONS + LC.PADDING_BOTTOM)
        end,
    })

    -- Initial list build
    RebuildList(listContainer, db, newSpellIdRef, spellIdInput, section, content, nil)

    -- Anchor add-spell controls below the list container
    -- (list container height is dynamic; we reposition on size change)
    listContainer:SetScript("OnSizeChanged", function(self)
        local listH = self:GetHeight()
        local inputTop = innerY - listH - LC.SPACING_BETWEEN_WIDGETS
        spellIdInput:ClearAllPoints()
        spellIdInput:SetPoint("TOPLEFT", content, "TOPLEFT", 0, inputTop)
        spellIdInput:SetPoint("RIGHT", content, "RIGHT", 0, 0)

        local btnTop = inputTop - spellIdInput:GetHeight() - LC.SPACING_BETWEEN_WIDGETS
        addButton:ClearAllPoints()
        addButton:SetPoint("TOPLEFT", content, "TOPLEFT", 0, btnTop)

        local totalInner = math_abs(innerY) + listH
            + LC.SPACING_BETWEEN_WIDGETS + spellIdInput:GetHeight()
            + LC.SPACING_BETWEEN_WIDGETS + addButton:GetHeight()
            + LC.SECTION_PADDING_BOTTOM
        section:SetContentHeight(totalInner)
        parent:SetHeight(math_abs(yOffset) + section:GetHeight()
            + LC.SPACING_BETWEEN_SECTIONS + LC.PADDING_BOTTOM)
    end)

    -- Immediate initial anchor (before OnSizeChanged fires)
    local initListH = listContainer:GetHeight()
    local initInputTop = innerY - initListH - LC.SPACING_BETWEEN_WIDGETS
    spellIdInput:SetPoint("TOPLEFT", content, "TOPLEFT", 0, initInputTop)
    spellIdInput:SetPoint("RIGHT", content, "RIGHT", 0, 0)
    addButton:SetPoint("TOPLEFT", content, "TOPLEFT", 0,
        initInputTop - spellIdInput:GetHeight() - LC.SPACING_BETWEEN_WIDGETS)

    local initTotalInner = math_abs(innerY) + initListH
        + LC.SPACING_BETWEEN_WIDGETS + spellIdInput:GetHeight()
        + LC.SPACING_BETWEEN_WIDGETS + addButton:GetHeight()
        + LC.SECTION_PADDING_BOTTOM
    section:SetContentHeight(initTotalInner)
    yOffset = LC.AnchorSection(section, parent, yOffset) - LC.SPACING_BETWEEN_SECTIONS

    parent:SetHeight(math_abs(yOffset) + LC.PADDING_BOTTOM)
end

-------------------------------------------------------------------------------
-- Register tab
-------------------------------------------------------------------------------

ns.Tabs[#ns.Tabs + 1] = {
    id = "custom_spells",
    label = L["Custom Spells"],
    order = 6,
    createFunc = CreateContent,
}

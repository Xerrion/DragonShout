-------------------------------------------------------------------------------
-- CustomSpellsTab.lua
-- Custom spell announcement management tab
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached globals
-------------------------------------------------------------------------------

local math_abs = math.abs
local tonumber = tonumber
local tostring = tostring
local tinsert = table.insert
local tremove = table.remove

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
-- Build the Custom Spells tab content
-------------------------------------------------------------------------------

local function CreateContent(parent)
    dsns = ns.dsns
    local db = dsns.Addon.db
    local yOffset = LC.PADDING_TOP
    local newSpellId = ""

    local header = W.CreateHeader(parent, L["Custom Spells"])
    LC.AnchorWidget(header, parent, yOffset)
    yOffset = yOffset - header:GetHeight() - LC.SPACING_AFTER_HEADER

    local desc = W.CreateDescription(parent, L["Add spell IDs to announce when applied to or by you."])
    LC.AnchorWidget(desc, parent, yOffset)
    yOffset = yOffset - desc:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local tokenDesc = W.CreateDescription(parent,
        L["Template tokens: {spell} (spell name), {target} (target unit), {source} (caster)"])
    LC.AnchorWidget(tokenDesc, parent, yOffset)
    yOffset = yOffset - tokenDesc:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local spellIdInput = W.CreateTextInput(parent, {
        label = L["Spell ID"],
        tooltip = L["Spell ID"],
        get = function() return "" end,
        set = function(value) newSpellId = value end,
    })
    LC.AnchorWidget(spellIdInput, parent, yOffset)
    yOffset = yOffset - spellIdInput:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local addButton = W.CreateButton(parent, {
        text = L["Add"],
        tooltip = L["Add"],
        onClick = function()
            local id = tonumber(newSpellId)
            if not id then return end

            tinsert(db.profile.customSpells, {
                spellId = id,
                channel = "AUTO",
                template = "{spell} on {target}!",
            })
            newSpellId = ""
            if spellIdInput.Refresh then
                spellIdInput:Refresh()
            end
        end,
    })
    LC.AnchorWidget(addButton, parent, yOffset)
    yOffset = yOffset - addButton:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    local removeButton = W.CreateButton(parent, {
        text = L["Remove Last"],
        tooltip = L["Remove Last"],
        onClick = function()
            local spells = db.profile.customSpells
            if #spells > 0 then
                tremove(spells, #spells)
            end
        end,
    })
    LC.AnchorWidget(removeButton, parent, yOffset)
    yOffset = yOffset - removeButton:GetHeight() - LC.SPACING_BETWEEN_WIDGETS

    -- Display existing custom spells
    for i, entry in ipairs(db.profile.customSpells) do
        local entryDesc = W.CreateDescription(parent,
            tostring(i) .. ". Spell ID: " .. tostring(entry.spellId) .. " | " .. (entry.template or ""))
        LC.AnchorWidget(entryDesc, parent, yOffset)
        yOffset = yOffset - entryDesc:GetHeight() - LC.SPACING_BETWEEN_WIDGETS
    end

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

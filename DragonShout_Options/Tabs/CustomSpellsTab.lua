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
-- Build the Custom Spells tab content
-------------------------------------------------------------------------------

local function CreateContent(parent)
    dsns = ns.dsns
    local db = dsns.Addon.db
    local yOffset = LC.PADDING_TOP
    local newSpellId = ""

    local section = W.CreateSection(parent, L["Custom Spells"])
    local content = section.content
    local innerY = -LC.SECTION_PADDING_TOP

    local desc = W.CreateDescription(content, L["Add spell IDs to announce when applied to or by you."])
    innerY = LC.AnchorWidget(desc, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local tokenDesc = W.CreateDescription(content,
        L["Template tokens: {spell} (spell name), {target} (target unit), {source} (caster)"])
    innerY = LC.AnchorWidget(tokenDesc, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local spellIdInput = W.CreateTextInput(content, {
        label = L["Spell ID"],
        tooltip = L["Spell ID"],
        get = function() return "" end,
        set = function(value) newSpellId = value end,
    })
    innerY = LC.AnchorWidget(spellIdInput, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local addButton = W.CreateButton(content, {
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
    innerY = LC.AnchorWidget(addButton, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    local removeButton = W.CreateButton(content, {
        text = L["Remove Last"],
        tooltip = L["Remove Last"],
        onClick = function()
            local spells = db.profile.customSpells
            if #spells > 0 then
                tremove(spells, #spells)
            end
        end,
    })
    innerY = LC.AnchorWidget(removeButton, content, innerY) - LC.SPACING_BETWEEN_WIDGETS

    -- Display existing custom spells
    for i, entry in ipairs(db.profile.customSpells) do
        local entryDesc = W.CreateDescription(content,
            tostring(i) .. ". Spell ID: " .. tostring(entry.spellId) .. " | " .. (entry.template or ""))
        innerY = LC.AnchorWidget(entryDesc, content, innerY) - LC.SPACING_BETWEEN_WIDGETS
    end

    section:SetContentHeight(math_abs(innerY) + LC.SECTION_PADDING_BOTTOM)
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

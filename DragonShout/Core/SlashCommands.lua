-------------------------------------------------------------------------------
-- SlashCommands.lua
-- Slash command handler for DragonShout
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached references
-------------------------------------------------------------------------------

local print = print
local string_lower = string.lower
local string_match = string.match
local L = LibStub("AceLocale-3.0"):GetLocale("DragonShout")

-------------------------------------------------------------------------------
-- Status Display
-------------------------------------------------------------------------------

local function YesNo(cond)
    return cond and ns.COLOR_GREEN .. L["Yes"] or ns.COLOR_RED .. L["No"]
end

local function PrintStatus()
    local db = ns.Addon.db.profile

    print(ns.COLOR_GOLD .. L["--- DragonShout Status ---"] .. ns.COLOR_RESET)
    print("  " .. L["Enabled"] .. ": " .. YesNo(db.enabled) .. ns.COLOR_RESET)
    print("  " .. L["Throttle Duration"] .. ": " .. db.throttleDuration .. L["s"])
    print("  " .. L["Minimap Icon"] .. ": " .. YesNo(not db.minimap.hide))
    print("")
    print("  " .. L["Interrupts"] .. ": " .. YesNo(db.interrupts.enabled)
        .. ns.COLOR_RESET .. " | " .. L["Channel"] .. ": " .. db.interrupts.channel)
    print("  " .. L["CC on You"] .. ": " .. YesNo(db.ccOnYou.enabled)
        .. ns.COLOR_RESET .. " | " .. L["Channel"] .. ": " .. db.ccOnYou.channel)
    print("  " .. L["CC Applied"] .. ": " .. YesNo(db.ccApplied.enabled)
        .. ns.COLOR_RESET .. " | " .. L["Channel"] .. ": " .. db.ccApplied.channel)
    print("  " .. L["Dispels"] .. ": " .. YesNo(db.dispels.enabled)
        .. ns.COLOR_RESET .. " | " .. L["Channel"] .. ": " .. db.dispels.channel)
end

-------------------------------------------------------------------------------
-- Help Display
-------------------------------------------------------------------------------

local HELP_ENTRIES = {
    { "",          L["Show this help"] },
    { " toggle",   L["Toggle addon on/off"] },
    { " config",   L["Open settings panel"] },
    { " status",   L["Show current settings"] },
    { " help",     L["Show this help"] },
}

local function PrintHelp()
    print(ns.COLOR_GOLD .. L["--- DragonShout Commands ---"] .. ns.COLOR_RESET)
    for _, entry in ipairs(HELP_ENTRIES) do
        print("  " .. ns.COLOR_WHITE .. "/ds" .. entry[1] .. ns.COLOR_RESET .. " -- " .. entry[2])
    end
end

-------------------------------------------------------------------------------
-- Command Router
-------------------------------------------------------------------------------

local function NormalizeCommand(input)
    local trimmedInput = string_match(input or "", "^%s*(.-)%s*$")
    return string_lower(trimmedInput)
end

local function ToggleAddon()
    ns.ToggleAddonEnabled()
end

function ns.HandleSlashCommand(input)
    local cmd = NormalizeCommand(input)

    if cmd == "" then
        PrintHelp()

    elseif cmd == "toggle" then
        ToggleAddon()

    elseif cmd == "config" or cmd == "options" or cmd == "settings" then
        if ns.ToggleOptions then
            ns.ToggleOptions()
        end

    elseif cmd == "status" then
        PrintStatus()

    elseif cmd == "help" or cmd == "?" then
        PrintHelp()

    else
        ns.Print(L["Unknown command: "] .. ns.COLOR_WHITE .. cmd .. ns.COLOR_RESET)
        PrintHelp()
    end
end

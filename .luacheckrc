std = "lua51"
max_line_length = 120
codes = true
exclude_files = {
    "DragonShout/Libs/",
    ".release/",
}

files["DragonShout/Locales/"] = {
    max_line_length = false,
}

ignore = {
    "212/self",
    "211/ADDON_NAME",
    "211/ns",
    "211/_.*",  -- unused variables prefixed with underscore
    "213/_.*",  -- unused loop variables prefixed with underscore
}

read_globals = {
    -- Lua
    "table", "string", "math", "pairs", "ipairs", "type", "tostring", "tonumber",
    "select", "unpack", "wipe", "strsplit", "strmatch", "strtrim", "format",
    "pcall", "sort", "next",

    -- WoW API - General
    "CreateFrame", "GetTime", "UIParent", "GameTooltip",
    "PlaySound",
    "C_Timer",

    -- Libraries
    "LibStub",

    -- WoW Globals
    "STANDARD_TEXT_FONT",
}

-----------------------------------------------------------------------
-- DragonShout (main addon)
-----------------------------------------------------------------------
files["DragonShout/"] = {
    globals = {
        "DragonShoutDB",
        "DragonShoutNS",
        "SLASH_DRAGONSHOUT1",
        "SLASH_DRAGONSHOUT2",
        "SlashCmdList",
    },

    read_globals = {
        -- WoW API
        "IsInGroup", "IsInRaid", "IsInInstance",
        "UnitGUID", "UnitDebuff", "C_UnitAuras",
        "CombatLogGetCurrentEventInfo",
        "SendChatMessage", "C_ChatInfo",
        "InCombatLockdown", "IsShiftKeyDown",
        "InterfaceOptionsFrame_OpenToCategory", "Settings",
        "hooksecurefunc",
        "GetSpellInfo", "C_Spell",

        -- WoW Globals
        "WOW_PROJECT_ID", "WOW_PROJECT_MAINLINE",
        "WOW_PROJECT_BURNING_CRUSADE_CLASSIC", "WOW_PROJECT_MISTS_CLASSIC",
        "LE_PARTY_CATEGORY_INSTANCE",

        -- LoadOnDemand
        "_G", "C_AddOns", "DragonShout_Options",

        -- WoW API - Aura
        "AuraUtil",
    },
}

-----------------------------------------------------------------------
-- DragonShout_Options (companion addon)
-----------------------------------------------------------------------
files["DragonShout_Options/"] = {
    globals = {
        "DragonShout_Options",
        "StaticPopupDialogs",
        "ColorPickerFrame",
    },

    read_globals = {
        -- WoW API
        "SOUNDKIT", "ShowUIPanel",
        "StaticPopup_Show",
        "_G",
        "GetSpellTexture", "GetSpellInfo", "C_Spell",

        -- WoW Globals
        "UISpecialFrames",
        "GameFontNormal", "GameFontNormalSmall", "GameFontNormalLarge",
        "GameFontHighlight", "GameFontHighlightSmall",

        -- DragonShout bridge
        "DragonShoutNS",

        -- DragonWidgets shared library
        "DragonWidgetsNS",
    },
}

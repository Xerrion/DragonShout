-------------------------------------------------------------------------------
-- ptBR.lua
-- Portuguese (Brazil) locale for DragonShout
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ... -- luacheck: ignore 211/ns
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "ptBR")
if not L then return end

-- DragonShout/Core/Init.lua
L["Loaded. Type /ds help for commands."] = ""

-- DragonShout/Core/ConfigWindow.lua
L["DragonShout_Options addon not found. Please ensure it is installed."] = ""

-- DragonShout/Core/SlashCommands.lua
L["--- DragonShout Status ---"] = ""
L["--- DragonShout Commands ---"] = ""
L["Enabled"] = ""
L["Disabled"] = ""
L["Yes"] = ""
L["No"] = ""
L["Interrupts"] = ""
L["CC on You"] = ""
L["CC Applied"] = ""
L["Dispels"] = ""
L["Channel"] = ""
L["Template"] = ""
L["Throttle Duration"] = ""
L["s"] = ""
L["Minimap Icon"] = ""
L["Show this help"] = ""
L["Toggle addon on/off"] = ""
L["Open settings panel"] = ""
L["Show current settings"] = ""
L["Addon enabled"] = ""
L["Addon disabled"] = ""
L["Unknown command: "] = ""

-- DragonShout/Core/MinimapIcon.lua
L["Status: "] = ""
L["Left-Click"] = ""
L["Right-Click"] = ""
L["Open settings"] = ""
L["Toggle on/off"] = ""

-- Default template strings
L["Interrupted {target}'s {extraSpell} with {spell}!"] = ""
L["I am {spell}!"] = ""
L["CC'd {target} with {spell}!"] = ""
L["Dispelled {extraSpell} from {target}!"] = ""

-------------------------------------------------------------------------------
-- DragonShout_Options
-------------------------------------------------------------------------------

-- DragonShout_Options/Tabs/GeneralTab.lua
L["General"] = ""
L["Core Settings"] = ""
L["Enable DragonShout"] = ""
L["Enable or disable the addon"] = ""
L["Show Minimap Icon"] = ""
L["Toggle the minimap button"] = ""
L["Testing"] = ""
L["Test Interrupt"] = ""
L["Simulate an interrupt announcement"] = ""
L["Test CC"] = ""
L["Simulate a CC announcement"] = ""

-- DragonShout_Options/Tabs/InterruptsTab.lua
L["Enable interrupt announcements"] = ""
L["Chat channel to send announcements to"] = ""
L["Announcement template. Tokens: {spell}, {target}, {extraSpell}"] = ""
L["Party"] = ""
L["Raid"] = ""
L["Say"] = ""
L["Yell"] = ""

-- DragonShout_Options/Tabs/CCOnYouTab.lua
L["Enable CC-on-you announcements"] = ""
L["Announcement template. Tokens: {spell}"] = ""
L["CC Types"] = ""
L["Silence"] = ""
L["Polymorph"] = ""
L["Stun"] = ""
L["Disorient"] = ""
L["Fear"] = ""
L["Root"] = ""
L["Announce when silenced"] = ""
L["Announce when polymorphed"] = ""
L["Announce when stunned"] = ""
L["Announce when disoriented"] = ""
L["Announce when feared"] = ""
L["Announce when rooted"] = ""
L["Silenced"] = true
L["Stunned"] = true
L["Polymorphed"] = true
L["Disoriented"] = true
L["Feared"] = true
L["Rooted"] = true

-- DragonShout_Options/Tabs/CCAppliedTab.lua
L["Enable CC-applied announcements"] = ""
L["Announcement template. Tokens: {spell}, {target}"] = ""

-- DragonShout_Options/Tabs/DispelsTab.lua
L["Enable dispel announcements"] = ""
L["Announcement template. Tokens: {spell}, {target}, {extraSpell}"] = ""

-- DragonShout_Options/Tabs/CustomSpellsTab.lua
L["Custom Spells"] = ""
L["Add spell IDs to announce when applied to or by you."] = ""
L["Spell ID"] = ""
L["Add"] = ""
L["Remove Last"] = ""

-- DragonShout_Options/Tabs/ProfilesTab.lua
L["Active Profile"] = ""
L["Are you sure you want to delete the profile \"%s\"?"] = ""
L["Are you sure you want to reset the current profile?"] = ""
L["Cancel"] = ""
L["Copy From"] = ""
L["Copy settings from another profile"] = ""
L["Create Profile"] = ""
L["Create a new profile with the entered name"] = ""
L["Current Profile"] = ""
L["Delete"] = ""
L["Delete Profile"] = ""
L["Delete a profile"] = ""
L["Enter a name for a new profile"] = ""
L["New Profile Name"] = ""
L["Profile Actions"] = ""
L["Profiles"] = ""
L["Profiles allow you to save different configurations for different characters."] = ""
L["Reset"] = ""
L["Reset Profile"] = ""
L["Reset the current profile to default settings"] = ""
L["Select the active profile"] = ""

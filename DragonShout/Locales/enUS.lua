-------------------------------------------------------------------------------
-- enUS.lua
-- English (US) locale - base/default
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ... -- luacheck: ignore 211/ns
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true, true)
if not L then return end

-- DragonShout/Core/Init.lua
L["Loaded. Type /ds help for commands."] = true

-- DragonShout/Core/ConfigWindow.lua
L["DragonShout_Options addon not found. Please ensure it is installed."] = true

-- DragonShout/Core/SlashCommands.lua
L["--- DragonShout Status ---"] = true
L["--- DragonShout Commands ---"] = true
L["Enabled"] = true
L["Disabled"] = true
L["Yes"] = true
L["No"] = true
L["Interrupts"] = true
L["CC on You"] = true
L["CC Applied"] = true
L["Dispels"] = true
L["Channel"] = true
L["Template"] = true
L["Throttle Duration"] = true
L["s"] = true
L["Minimap Icon"] = true
L["Show this help"] = true
L["Toggle addon on/off"] = true
L["Open settings panel"] = true
L["Show current settings"] = true
L["Addon enabled"] = true
L["Addon disabled"] = true
L["Solo"] = true
L["Group"] = true
L["Addon not yet initialized."] = true
L["Unknown command: "] = true
L["Debug"] = true
L["Debug Mode"] = true
L["Enable verbose debug logging to chat"] = true
L["Print Status"] = true
L["Print current addon state to chat"] = true
L["Clear Throttle"] = true
L["Reset all announce throttle timers"] = true
L["Player GUID"] = true
L["Version"] = true
L["Toggle debug mode on/off"] = true
L["Debug mode: "] = true

-- DragonShout/Core/MinimapIcon.lua
L["Status: "] = true
L["Left-Click"] = true
L["Right-Click"] = true
L["Open settings"] = true
L["Toggle on/off"] = true

-- Default template strings (used as config defaults and locale keys)
L["Interrupted {target}'s {extraSpell} with {spell}!"] = true
L["I am {spell} ({type}) for {duration}s!"] = true
L["CC'd {target} with {spell}!"] = true
L["Dispelled {extraSpell} from {target}!"] = true

-------------------------------------------------------------------------------
-- DragonShout_Options
-------------------------------------------------------------------------------

-- DragonShout_Options/Tabs/GeneralTab.lua
L["General"] = true
L["Core Settings"] = true
L["Enable DragonShout"] = true
L["Enable or disable the addon"] = true
L["Show Minimap Icon"] = true
L["Toggle the minimap button"] = true
L["Testing"] = true
L["Test Interrupt"] = true
L["Simulate an interrupt announcement"] = true
L["Test CC"] = true
L["Simulate a CC announcement"] = true
L["Debug Settings"] = true
L["Enable Debug Mode"] = true

-- DragonShout_Options/Tabs/InterruptsTab.lua
L["Enable interrupt announcements"] = true
L["Chat channel to send announcements to"] = true
L["Announcement template. Tokens: {spell}, {target}, {extraSpell}"] = true
L["Auto"] = true
L["Party"] = true
L["Raid"] = true
L["Say"] = true
L["Yell"] = true
L["Local"] = true
L["Instance"] = true
L["Officer"] = true
L["Solo Channel"] = true
L["Group Channel"] = true
L["Raid/Instance Channel"] = true
L["Channel used when not in any group (LOCAL prints only to your own chat frame)"] = true
L["Channel used when in a party"] = true
L["Channel used when in a raid or instance group"] = true

-- DragonShout_Options/Tabs/CCOnYouTab.lua
L["Enable CC-on-you announcements"] = true
L["Announcement template. Tokens: {spell}, {type}, {duration}"] = true
L["CC Types"] = true
L["Silence"] = true
L["Polymorph"] = true
L["Stun"] = true
L["Disorient"] = true
L["Fear"] = true
L["Root"] = true
L["Announce when silenced"] = true
L["Announce when polymorphed"] = true
L["Announce when stunned"] = true
L["Announce when disoriented"] = true
L["Announce when feared"] = true
L["Announce when rooted"] = true
L["Silenced"] = true
L["Stunned"] = true
L["Polymorphed"] = true
L["Disoriented"] = true
L["Feared"] = true
L["Rooted"] = true
L["Per-Type Templates"] = true
L["Leave blank to use the default template above."] = true
L["Silence template"] = true
L["Stun template"] = true
L["Polymorph template"] = true
L["Disorient template"] = true
L["Fear template"] = true
L["Root template"] = true

-- DragonShout_Options/Tabs/CCAppliedTab.lua
L["Enable CC-applied announcements"] = true
L["Announcement template. Tokens: {spell}, {target}"] = true

-- DragonShout_Options/Tabs/DispelsTab.lua
L["Enable dispel announcements"] = true
L["Announcement template. Tokens: {spell}, {target}, {extraSpell}"] = true

-- DragonShout_Options/Tabs/CustomSpellsTab.lua
L["Custom Spells"] = true
L["Add spell IDs to announce when applied to or by you."] = true
L["Template tokens: {spell} (spell name), {target} (target unit), {source} (caster)"] = true
L["Spell ID"] = true
L["Add"] = true
L["Remove"] = true
L["No custom spells configured."] = true
L["Spell ID or Name"] = true
L["Enable this spell announcement"] = true
L["Unknown Spell"] = true
L["Click to edit"] = true
L["Collapse"] = true
L["Solo: "] = true
L["Group: "] = true
L["Raid: "] = true
L["Channel used when solo (not in any group)"] = true
L["Channel used when in a party or group"] = true
L["Channel used when in a raid or instance"] = true
L["Custom spell template"] = true
L["Custom spell channel"] = true

-- DragonShout_Options/Tabs/ProfilesTab.lua
L["Active Profile"] = true
L["Are you sure you want to delete the profile \"%s\"?"] = true
L["Are you sure you want to reset the current profile?"] = true
L["Cancel"] = true
L["Copy From"] = true
L["Copy settings from another profile"] = true
L["Create Profile"] = true
L["Create a new profile with the entered name"] = true
L["Current Profile"] = true
L["Delete"] = true
L["Delete Profile"] = true
L["Delete a profile"] = true
L["Enter a name for a new profile"] = true
L["New Profile Name"] = true
L["Profile Actions"] = true
L["Profiles"] = true
L["Profiles allow you to save different configurations for different characters."] = true
L["Reset"] = true
L["Reset Profile"] = true
L["Reset the current profile to default settings"] = true
L["Select the active profile"] = true

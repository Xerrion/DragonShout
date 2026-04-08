-------------------------------------------------------------------------------
-- Config.lua
-- DragonShout configuration: AceDB defaults and profile migration
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Database Defaults
-------------------------------------------------------------------------------

local defaults = {
    profile = {
        enabled = true,
        debug = false,
        throttleDuration = 3.0,

        minimap = {
            hide = false,
        },

        interrupts = {
            enabled = true,
            channel = "AUTO",
            template = "Interrupted {target}'s {extraSpell} with {spell}!",
        },

        ccOnYou = {
            enabled = true,
            channel = "AUTO",
            template = "I am {spell} ({type}) for {duration}s!",
            typeTemplates = {
                silence   = "",
                polymorph = "",
                stun      = "",
                disorient = "",
                fear      = "",
                root      = "",
            },
            silence = true,
            polymorph = true,
            stun = true,
            disorient = true,
            fear = true,
            root = false,
        },

        ccApplied = {
            enabled = true,
            channel = "AUTO",
            template = "CC'd {target} with {spell}!",
        },

        dispels = {
            enabled = true,
            channel = "AUTO",
            template = "Dispelled {extraSpell} from {target}!",
        },

        customSpells = {},
    },
}

-------------------------------------------------------------------------------
-- Schema Migration
-------------------------------------------------------------------------------

local function MigrateProfile(db)
    local profile = db.profile
    local version = profile.schemaVersion or 0

    if version < 1 then
        profile.schemaVersion = 1
    end
end

-------------------------------------------------------------------------------
-- Initialization (called from Init.lua OnInitialize)
-------------------------------------------------------------------------------

function ns.InitializeDB(addon)
    addon.db = LibStub("AceDB-3.0"):New("DragonShoutDB", defaults, true)

    -- Migrate active profile
    MigrateProfile(addon.db)

    -- Re-migrate on profile changes
    addon.db.RegisterCallback(addon, "OnProfileChanged", function() MigrateProfile(addon.db) end)
    addon.db.RegisterCallback(addon, "OnProfileCopied", function() MigrateProfile(addon.db) end)
    addon.db.RegisterCallback(addon, "OnProfileReset", function() MigrateProfile(addon.db) end)
end

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
            template = "{type} for {duration}s!",
            typeTemplates = {
                silence   = "Silenced for {duration}s!",
                polymorph = "Polymorphed for {duration}s!",
                stun      = "Stunned for {duration}s!",
                disorient = "Disoriented for {duration}s!",
                fear      = "Feared for {duration}s!",
                root      = "Rooted for {duration}s!",
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
-- Migration helpers
-------------------------------------------------------------------------------

local TYPE_TEMPLATE_DEFAULTS = {
    silence   = "Silenced for {duration}s!",
    polymorph = "Polymorphed for {duration}s!",
    stun      = "Stunned for {duration}s!",
    disorient = "Disoriented for {duration}s!",
    fear      = "Feared for {duration}s!",
    root      = "Rooted for {duration}s!",
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

    if version < 2 then
        -- Migrate ccOnYou.template from old default to new default
        if profile.ccOnYou and profile.ccOnYou.template == "I am {spell} ({type}) for {duration}s!" then
            profile.ccOnYou.template = "{type} for {duration}s!"
        end

        -- Migrate empty typeTemplates to new per-type defaults
        if profile.ccOnYou and profile.ccOnYou.typeTemplates then
            for ccType, defaultStr in pairs(TYPE_TEMPLATE_DEFAULTS) do
                if profile.ccOnYou.typeTemplates[ccType] == "" then
                    profile.ccOnYou.typeTemplates[ccType] = defaultStr
                end
            end
        end

        profile.schemaVersion = 2
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

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
            channelSolo = "LOCAL",
            channelGroup = "PARTY",
            channelRaid = "RAID",
            template = "Interrupted {target}'s {extraSpell} with {spell}!",
        },

        ccOnYou = {
            enabled = true,
            channelSolo = "LOCAL",
            channelGroup = "PARTY",
            channelRaid = "RAID",
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
            channelSolo = "LOCAL",
            channelGroup = "PARTY",
            channelRaid = "RAID",
            template = "CC'd {target} with {spell}!",
        },

        dispels = {
            enabled = true,
            channelSolo = "LOCAL",
            channelGroup = "PARTY",
            channelRaid = "RAID",
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

    if version < 3 then
        local categories = { "interrupts", "ccOnYou", "ccApplied", "dispels" }
        for _, cat in ipairs(categories) do
            local cfg = profile[cat]
            if cfg and cfg.channel then
                local old = cfg.channel
                local solo  = (old == "AUTO" or old == nil) and "LOCAL" or old
                local group = (old == "AUTO" or old == nil) and "PARTY" or old
                local raid  = (old == "AUTO" or old == nil) and "RAID"  or old
                cfg.channelSolo  = cfg.channelSolo  or solo
                cfg.channelGroup = cfg.channelGroup or group
                cfg.channelRaid  = cfg.channelRaid  or raid
                cfg.channel = nil
            end
        end
        version = 3
        profile.schemaVersion = 3
    end

    if version < 4 then
        if profile.customSpells then
            for _, entry in ipairs(profile.customSpells) do
                if entry.enabled == nil then
                    entry.enabled = true
                end
            end
        end
        version = 4 -- luacheck: ignore 311/version (future migrations will read this)
        profile.schemaVersion = 4
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

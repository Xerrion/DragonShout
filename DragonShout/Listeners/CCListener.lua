-------------------------------------------------------------------------------
-- CCListener.lua
-- Handles CC detection from SPELL_AURA_APPLIED sub-events
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local math_floor = math.floor
local select = select
local UnitDebuff = UnitDebuff
local C_UnitAuras = C_UnitAuras  -- nil on Classic; nil-safe

-------------------------------------------------------------------------------
-- CC spell ID table
-- Maps spell IDs to true for quick membership checks.
-------------------------------------------------------------------------------

local IS_CC_SPELL = {
    -- Polymorph variants
    [118]    = true,  -- Polymorph
    [12824]  = true,  -- Polymorph: Sheep
    [12825]  = true,  -- Polymorph: Sheep (rank 2)
    [12826]  = true,  -- Polymorph: Sheep (rank 3)
    [28271]  = true,  -- Polymorph: Turtle
    [28272]  = true,  -- Polymorph: Pig
    [61025]  = true,  -- Polymorph: Serpent
    [61305]  = true,  -- Polymorph: Black Cat
    [126819] = true,  -- Polymorph: Porcupine
    [161353] = true,  -- Polymorph: Polar Bear Cub
    [161354] = true,  -- Polymorph: Monkey
    [161355] = true,  -- Polymorph: Penguin
    [161372] = true,  -- Polymorph: Peacock
    [277787] = true,  -- Polymorph: Direhorn
    [277792] = true,  -- Polymorph: Bumblebee

    -- Hex
    [51514]  = true,  -- Hex

    -- Silences
    [2139]   = true,  -- Counterspell
    [6552]   = true,  -- Pummel
    [47528]  = true,  -- Mind Freeze
    [1766]   = true,  -- Kick
    [93985]  = true,  -- Skull Bash
    [47476]  = true,  -- Strangulate
    [15487]  = true,  -- Silence (Priest)
    [28730]  = true,  -- Arcane Torrent (Mana)
    [25046]  = true,  -- Arcane Torrent (Energy)
    [50613]  = true,  -- Arcane Torrent (Runic Power)
    [69179]  = true,  -- Arcane Torrent (Rage)
    [80483]  = true,  -- Arcane Torrent (Focus)
    [129597] = true,  -- Arcane Torrent (Chi)
    [155145] = true,  -- Arcane Torrent (Holy Power)
    [202719] = true,  -- Arcane Torrent (Fury)
    [18498]  = true,  -- Gag Order

    -- Stuns
    [1833]   = true,  -- Cheap Shot
    [408]    = true,  -- Kidney Shot
    [853]    = true,  -- Hammer of Justice
    [20252]  = true,  -- Intercept
    [20549]  = true,  -- War Stomp
    [5211]   = true,  -- Bash
    [7922]   = true,  -- Charge Stun

    -- Disorient / Fear
    [5782]   = true,  -- Fear
    [8122]   = true,  -- Psychic Scream
    [10326]  = true,  -- Turn Evil
    [5484]   = true,  -- Howl of Terror
    [31661]  = true,  -- Dragon's Breath
    [19503]  = true,  -- Scatter Shot

    -- Freeze / Root
    [44572]  = true,  -- Deep Freeze
    [122]    = true,  -- Frost Nova
    [339]    = true,  -- Entangling Roots
}

-------------------------------------------------------------------------------
-- CC type classification
-------------------------------------------------------------------------------

local CC_TYPE = {
    -- Polymorph
    [118]    = "polymorph",
    [12824]  = "polymorph",
    [12825]  = "polymorph",
    [12826]  = "polymorph",
    [28271]  = "polymorph",
    [28272]  = "polymorph",
    [61025]  = "polymorph",
    [61305]  = "polymorph",
    [126819] = "polymorph",
    [161353] = "polymorph",
    [161354] = "polymorph",
    [161355] = "polymorph",
    [161372] = "polymorph",
    [277787] = "polymorph",
    [277792] = "polymorph",
    [51514]  = "polymorph",

    -- Silences
    [2139]   = "silence",
    [6552]   = "silence",
    [47528]  = "silence",
    [1766]   = "silence",
    [93985]  = "silence",
    [47476]  = "silence",
    [15487]  = "silence",
    [28730]  = "silence",
    [25046]  = "silence",
    [50613]  = "silence",
    [69179]  = "silence",
    [80483]  = "silence",
    [129597] = "silence",
    [155145] = "silence",
    [202719] = "silence",
    [18498]  = "silence",

    -- Stuns
    [1833]   = "stun",
    [408]    = "stun",
    [853]    = "stun",
    [20252]  = "stun",
    [20549]  = "stun",
    [5211]   = "stun",
    [7922]   = "stun",

    -- Disorient
    [31661]  = "disorient",
    [19503]  = "disorient",

    -- Fear
    [5782]   = "fear",
    [8122]   = "fear",
    [10326]  = "fear",
    [5484]   = "fear",

    -- Root
    [44572]  = "root",
    [122]    = "root",
    [339]    = "root",
}

-------------------------------------------------------------------------------
-- Display labels for CC types (used as {type} token value)
-------------------------------------------------------------------------------

local CC_TYPE_LABEL = {
    silence   = "Silenced",
    stun      = "Stunned",
    polymorph = "Polymorphed",
    disorient = "Disoriented",
    fear      = "Feared",
    root      = "Rooted",
}

-------------------------------------------------------------------------------
-- Duration lookup helper
-- Returns the total duration (seconds) of a specific debuff on the player,
-- or nil if the aura is not found.
-- NOTE: Called immediately on SPELL_AURA_APPLIED. The aura may not yet be
-- reflected in UnitDebuff/C_UnitAuras on the same frame. If lookup returns nil,
-- AuraListener will fire on the subsequent UNIT_AURA and announce with duration.
-------------------------------------------------------------------------------

local function GetPlayerCCDuration(spellId)
    if ns.IS_RETAIL then
        if not C_UnitAuras then return nil end
        local index = 1
        while true do
            local aura = C_UnitAuras.GetAuraDataByIndex("player", index, "HARMFUL")
            if not aura then break end
            if aura.spellId == spellId then
                return aura.duration
            end
            index = index + 1
        end
    else
        local index = 1
        while true do
            local name, _, _, _, duration, _, _, _, _, sid = UnitDebuff("player", index)
            if not name then break end
            if sid == spellId then
                return duration
            end
            index = index + 1
        end
    end
    return nil
end

-------------------------------------------------------------------------------
-- Export for AuraListener
-------------------------------------------------------------------------------

ns.CCListener = {}
ns.CCListener.IS_CC_SPELL = IS_CC_SPELL
ns.CCListener.CC_TYPE = CC_TYPE
ns.CCListener.CC_TYPE_LABEL = CC_TYPE_LABEL

-------------------------------------------------------------------------------
-- Handler
-------------------------------------------------------------------------------

function ns.CCListener.OnAuraApplied(sourceGUID, sourceName, _, _, destGUID, destName, _, _)
    -- Fetch suffix fields: spellId=12, spellName=13, spellSchool=14, auraType=15
    local spellId, spellName, _, auraType = select(12, CombatLogGetCurrentEventInfo())

    -- Only process debuffs
    if auraType ~= "DEBUFF" then return end

    -- Only process known CC spells
    if not IS_CC_SPELL[spellId] then return end
    if not ns.playerGUID then return end

    local db = ns.Addon.db
    if not db then return end

    -- CC applied TO the player
    if destGUID == ns.playerGUID then
        local ccType = CC_TYPE[spellId]
        if ccType then
            local categoryConfig = db.profile.ccOnYou
            if categoryConfig[ccType] ~= false then
                local typeLabel = CC_TYPE_LABEL[ccType] or ""
                local rawDuration = GetPlayerCCDuration(spellId)
                local durationStr = (rawDuration and rawDuration > 0)
                    and tostring(math_floor(rawDuration)) or nil

                ns.Announcer.Announce("ccOnYou", spellId, {
                    spell = spellName,
                    source = sourceName,
                    type = typeLabel,
                    duration = durationStr,
                })
            end
        end
    end

    -- CC applied BY the player
    if sourceGUID == ns.playerGUID then
        local ccType = CC_TYPE[spellId]
        if ccType then
            ns.Announcer.Announce("ccApplied", spellId, {
                spell = spellName,
                target = destName,
                type = CC_TYPE_LABEL[ccType] or "",
            })
        end
    end

    -- Check custom spells (always runs, independent of CC type classification)
    ns.Announcer.AnnounceCustom(spellId, {
        spell = spellName,
        target = destName,
        source = sourceName,
    })
end

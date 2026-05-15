-------------------------------------------------------------------------------
-- CC_MoP.lua
-- Mists of Pandaria Classic (5.x) CC spell ID -> CC type.
--
-- Loaded for all clients; AuraListener selects this table when
-- WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC (or the numeric fallback when
-- the global constant is not yet defined in older clients).
--
-- Covers all 1.x/TBC player ranks plus WotLK/Cata/MoP additions: DK, Monk,
-- and modern talents/reworks introduced between 3.0 and 5.4.
-------------------------------------------------------------------------------

local _, ns = ...
ns.Data = ns.Data or {}

ns.Data.MOP_CC = {
    -- Polymorph
    [118]    = "polymorph",
    [12824]  = "polymorph",
    [12825]  = "polymorph",
    [12826]  = "polymorph",
    [28271]  = "polymorph",   -- Turtle (TBC)
    [28272]  = "polymorph",   -- Pig (TBC)
    [61025]  = "polymorph",   -- Serpent (WotLK+)
    [61305]  = "polymorph",   -- Black Cat (WotLK+)
    [126819] = "polymorph",   -- Porcupine (MoP)
    [51514]  = "polymorph",   -- Hex (Shaman, WotLK+)

    -- Silences
    [2139]   = "silence",
    [6552]   = "silence",
    [1766]   = "silence",
    [15487]  = "silence",
    [28730]  = "silence",
    [25046]  = "silence",
    [18498]  = "silence",
    [1330]   = "silence",
    [18425]  = "silence",
    [18469]  = "silence",
    [19647]  = "silence",
    [47528]  = "silence",     -- Mind Freeze (DK, WotLK+)
    [47476]  = "silence",     -- Strangulate (DK, WotLK+)
    [93985]  = "silence",     -- Skull Bash (Druid, Cata+)
    [50613]  = "silence",     -- Arcane Torrent (WotLK+ rank)
    [69179]  = "silence",     -- Arcane Torrent (WotLK+ rank)
    [80483]  = "silence",     -- Arcane Torrent (Cata+ rank)
    [129597] = "silence",     -- Arcane Torrent (MoP)
    [116709] = "silence",     -- Spear Hand Strike (Monk, MoP)

    -- Stuns
    [1833]   = "stun",
    [408]    = "stun",
    [8643]   = "stun",
    [853]    = "stun",
    [453]    = "stun",
    [10278]  = "stun",
    [10308]  = "stun",
    [20252]  = "stun",
    [20253]  = "stun",
    [20549]  = "stun",
    [5211]   = "stun",
    [6798]   = "stun",
    [8983]   = "stun",
    [7922]   = "stun",
    [5530]   = "stun",
    [30283]  = "stun",
    [108194] = "stun",        -- Asphyxiate (DK, MoP)
    [115001] = "stun",        -- Remorseless Winter (DK, MoP)
    [115078] = "stun",        -- Paralysis (Monk, MoP)
    [119381] = "stun",        -- Leg Sweep (Monk, MoP)
    [128787] = "stun",        -- Grapple Weapon stun proc (Monk, MoP)

    -- Disorient
    [31661]  = "disorient",
    [2094]   = "disorient",
    [1776]   = "disorient",
    [6770]   = "disorient",
    [2070]   = "disorient",
    [11297]  = "disorient",
    [3355]   = "disorient",
    [14308]  = "disorient",
    [14309]  = "disorient",
    [19386]  = "disorient",
    [24132]  = "disorient",
    [24133]  = "disorient",
    [19503]  = "disorient",

    -- Fear
    [5782]   = "fear",
    [6213]   = "fear",
    [6215]   = "fear",
    [8122]   = "fear",
    [8124]   = "fear",
    [10888]  = "fear",
    [10890]  = "fear",
    [10326]  = "fear",
    [5484]   = "fear",
    [17928]  = "fear",
    [5246]   = "fear",
    [1513]   = "fear",
    [14326]  = "fear",
    [14327]  = "fear",
    [17925]  = "fear",
    [17926]  = "fear",

    -- Root
    [44572]  = "root",        -- Deep Freeze (Mage, WotLK+)
    [122]    = "root",
    [865]    = "root",
    [6131]   = "root",
    [10230]  = "root",
    [339]    = "root",
    [1062]   = "root",
    [5195]   = "root",
    [5196]   = "root",
    [16689]  = "root",
    [23694]  = "root",
    [116706] = "root",        -- Disable (Monk, MoP)
}

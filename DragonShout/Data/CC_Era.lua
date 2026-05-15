-------------------------------------------------------------------------------
-- CC_Era.lua
-- Classic Era (1.x vanilla) and Season of Discovery CC spell ID -> CC type.
--
-- Loaded for all clients; AuraListener selects this table when
-- WOW_PROJECT_ID == WOW_PROJECT_CLASSIC. Also used as the safe default for
-- unknown project IDs.
--
-- Covers 1.x player ranks only - no TBC polymorph variants (Turtle/Pig), no
-- TBC NPC IDs. Includes Season of Discovery rune-granted spells in the 400k
-- ID range.
-------------------------------------------------------------------------------

local _, ns = ...
ns.Data = ns.Data or {}

ns.Data.ERA_CC = {
    -- Polymorph (player, 1.x ranks)
    [118]    = "polymorph",
    [12824]  = "polymorph",
    [12825]  = "polymorph",
    [12826]  = "polymorph",

    -- Silences (player)
    [2139]   = "silence",
    [6552]   = "silence",
    [1766]   = "silence",
    [15487]  = "silence",
    [18498]  = "silence",
    [1330]   = "silence",
    [18425]  = "silence",
    [18469]  = "silence",
    [19647]  = "silence",

    -- Stuns (player)
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

    -- Disorient (player)
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

    -- Fear (player)
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

    -- Root (player)
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

    -- Season of Discovery (rune-granted spells; 400k ID range)
    [400033] = "stun",        -- SoD rune-granted stun (placeholder example)
}

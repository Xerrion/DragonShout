-------------------------------------------------------------------------------
-- CC_TBC.lua
-- TBC Anniversary (Burning Crusade Classic) CC spell ID -> CC type.
--
-- Loaded for all clients; AuraListener selects this table when
-- WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC.
--
-- Covers all 1.x player ranks, TBC-introduced ranks/talent procs, and the
-- TBC dungeon/raid NPC variants (Karazhan, BT, etc.). Spells that also exist
-- on Retail or other Classic flavours must be duplicated into the matching
-- file - duplication is cheaper than a runtime fallback and makes per-client
-- audits easy.
-------------------------------------------------------------------------------

local _, ns = ...
ns.Data = ns.Data or {}

ns.Data.TBC_CC = {
    -- Polymorph (player)
    [118]    = "polymorph",
    [12824]  = "polymorph",
    [12825]  = "polymorph",
    [12826]  = "polymorph",
    [28271]  = "polymorph",   -- Polymorph: Turtle (TBC)
    [28272]  = "polymorph",   -- Polymorph: Pig (TBC)
    -- Polymorph (TBC NPC variants)
    [30697]  = "polymorph",   -- Blood Furnace
    [22274]  = "polymorph",   -- Underbog Sorceress
    [13323]  = "polymorph",   -- Botanica

    -- Silences (player)
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
    -- Silences (TBC NPC variants)
    [30730]  = "silence",     -- Moroes Silence
    [41410]  = "silence",     -- BT Aura

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
    [30283]  = "stun",
    -- Stuns (TBC NPC variants)
    [29511]  = "stun",        -- Maiden
    [34694]  = "stun",        -- Moroes Gouge
    [29490]  = "stun",        -- Karazhan Concubine Seduce
    [32323]  = "stun",        -- Shattered Halls
    [31415]  = "stun",        -- Steamvault
    [33685]  = "stun",        -- Mana-Tombs
    [34661]  = "stun",        -- Mechanar
    [39046]  = "stun",        -- Arcatraz
    [36178]  = "stun",        -- Arcatraz Cyclone
    [41376]  = "stun",        -- BT Spite
    [39863]  = "stun",        -- Mother Shahraz
    [23327]  = "stun",        -- Ogre Stomp
    [38595]  = "stun",        -- Naga Gouge

    -- Disorient (player)
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
    -- Disorient (TBC NPC variants)
    [31406]  = "disorient",   -- Bog Roc Dust Cloud

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
    -- Fear (TBC NPC variants)
    [29964]  = "fear",        -- Attumen
    [30533]  = "fear",        -- Karazhan
    [30752]  = "fear",        -- Nightbane
    [30689]  = "fear",        -- Ramparts
    [12739]  = "fear",        -- Blood Furnace
    [30923]  = "fear",        -- Slave Pens
    [12167]  = "fear",        -- Mana-Tombs
    [33534]  = "fear",        -- Shadow Lab
    [35265]  = "fear",        -- Murmur
    [32563]  = "fear",        -- Blackheart
    [40600]  = "fear",        -- Azgalor
    [31231]  = "fear",        -- Anetheron Sleep

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
}

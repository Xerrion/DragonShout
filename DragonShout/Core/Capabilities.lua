-------------------------------------------------------------------------------
-- Capabilities.lua
-- Client capability flags consulted by listener modules at Initialize time
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local GetBuildInfo = GetBuildInfo
local WOW_PROJECT_ID = WOW_PROJECT_ID
local WOW_PROJECT_MAINLINE = WOW_PROJECT_MAINLINE

-------------------------------------------------------------------------------
-- Detection
--
-- Retail patch 12.0 (Midnight) restricts COMBAT_LOG_EVENT_UNFILTERED for
-- addons: the event registers without error but never fires, and
-- CombatLogGetCurrentEventInfo() returns obfuscated values. C_RestrictedActions
-- is the namespace Blizzard shipped for this purpose; the build-number
-- comparison is a belt-and-braces guard. Both must hold for the restriction
-- to apply.
-------------------------------------------------------------------------------

local function DetectCleuRestricted()
    if C_RestrictedActions == nil then return false end
    if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then return false end
    if not GetBuildInfo then return false end
    local buildNumber = select(4, GetBuildInfo())
    if type(buildNumber) ~= "number" then return false end
    return buildNumber >= 120000
end

local cleuRestricted = DetectCleuRestricted()

ns.capabilities = {
    cleuRestricted = cleuRestricted,
    -- A clean dispel source+target+spell signal exists on Classic via
    -- SPELL_DISPEL; retail Midnight has no equivalent attribution event.
    dispelAttribution = not cleuRestricted,
}

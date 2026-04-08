-------------------------------------------------------------------------------
-- Announcer.lua
-- Message formatting, throttling, and channel resolution
--
-- Supported versions: Retail, MoP Classic, TBC Anniversary
-------------------------------------------------------------------------------

local ADDON_NAME, ns = ...

-------------------------------------------------------------------------------
-- Cached WoW API
-------------------------------------------------------------------------------

local GetTime = GetTime
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local SendChatMessage = SendChatMessage
local C_ChatInfo = C_ChatInfo
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local string_gsub = string.gsub

-------------------------------------------------------------------------------
-- Module state
-------------------------------------------------------------------------------

ns.Announcer = {}
local lastAnnounceTimes = {}

-------------------------------------------------------------------------------
-- Channel Resolution
-- Determines the appropriate chat channel based on category config and
-- current group state. "AUTO" smartly picks INSTANCE_CHAT, RAID, PARTY,
-- or SAY depending on group membership.
-------------------------------------------------------------------------------

local function ResolveChannel(category)
    local db = ns.Addon and ns.Addon.db
    if not db then return "SAY" end

    local channelSetting = db.profile[category] and db.profile[category].channel or "AUTO"

    if channelSetting ~= "AUTO" then
        return channelSetting
    end

    -- AUTO resolution: instance > raid > party > say
    if LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    elseif IsInRaid() then
        return "RAID"
    elseif IsInGroup() then
        return "PARTY"
    end

    return "SAY"
end

-------------------------------------------------------------------------------
-- Template Substitution
-- Replaces {spell}, {target}, {source}, {extraSpell} tokens with values
-- from the tokens table. Unreplaced tokens remain intact.
-------------------------------------------------------------------------------

local function ApplyTemplate(template, tokens)
    if not template or not tokens then return template end

    return string_gsub(template, "{(%w+)}", function(key)
        return tokens[key] or ("{" .. key .. "}")
    end)
end

-------------------------------------------------------------------------------
-- Send Message
-- Uses C_ChatInfo.SendChatMessage on Retail 11.2+, falls back to
-- SendChatMessage on Classic.
-------------------------------------------------------------------------------

local function SendMessage(channel, msg)
    if not msg or msg == "" then return end

    if C_ChatInfo and C_ChatInfo.SendChatMessage then
        C_ChatInfo.SendChatMessage(msg, channel)
    else
        SendChatMessage(msg, channel)
    end
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

function ns.Announcer.Announce(category, spellId, tokens, ccType)
    local db = ns.Addon.db
    if not db then return end
    if not db.profile.enabled then return end

    local categoryConfig = db.profile[category]
    if not categoryConfig then return end
    if not categoryConfig.enabled then return end

    -- Throttle check
    local throttleDuration = db.profile.throttleDuration or 3.0
    local throttleKey = tostring(spellId) .. "_" .. category
    local now = GetTime()
    local lastTime = lastAnnounceTimes[throttleKey] or 0

    if (now - lastTime) < throttleDuration then
        ns.DebugPrint("Throttled: " .. category .. " spellId=" .. tostring(spellId))
        return
    end

    -- Build and send message (per-type template overrides global when non-empty)
    local template = categoryConfig.template
    if ccType and categoryConfig.typeTemplates then
        local typeTemplate = categoryConfig.typeTemplates[ccType]
        if typeTemplate and typeTemplate ~= "" then
            template = typeTemplate
        end
    end
    local msg = ApplyTemplate(template, tokens)
    local channel = ResolveChannel(category)

    SendMessage(channel, msg)
    lastAnnounceTimes[throttleKey] = now

    ns.DebugPrint("Announced [" .. category .. "] -> " .. channel .. ": " .. msg)
end

function ns.Announcer.AnnounceCustom(spellId, tokens)
    local db = ns.Addon.db
    if not db then return end
    if not db.profile.enabled then return end

    local customSpells = db.profile.customSpells
    if not customSpells then return end

    local now = GetTime()
    local throttleDuration = db.profile.throttleDuration or 3.0

    for _, entry in ipairs(customSpells) do
        if tonumber(entry.spellId) == spellId then
            local throttleKey = tostring(spellId) .. "_custom"
            local lastTime = lastAnnounceTimes[throttleKey] or 0

            if (now - lastTime) >= throttleDuration then
                local channel = entry.channel or "AUTO"
                if channel == "AUTO" then
                    channel = ResolveChannel("customSpells")
                end

                local msg = ApplyTemplate(entry.template or "", tokens)
                SendMessage(channel, msg)
                lastAnnounceTimes[throttleKey] = now

                ns.DebugPrint("Custom announced spellId=" .. tostring(spellId) .. " -> " .. channel)
            end
        end
    end
end


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

local tostring = tostring
local GetTime = GetTime
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local SendChatMessage = SendChatMessage
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local string_gsub = string.gsub
local string_format = string.format
local wipe = wipe

-------------------------------------------------------------------------------
-- Module state
-------------------------------------------------------------------------------

ns.Announcer = {}
local lastAnnounceTimes = {}

-------------------------------------------------------------------------------
-- Channel Resolution
-------------------------------------------------------------------------------

local function ResolveChannel(category)
    local db = ns.Addon and ns.Addon.db
    if not db then return "SAY" end

    local channelSetting = db.profile[category] and db.profile[category].channel or "AUTO"

    if channelSetting ~= "AUTO" then
        return channelSetting
    end

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
-------------------------------------------------------------------------------

local function ApplyTemplate(template, tokens)
    if not template or not tokens then return template end

    return string_gsub(template, "{(%w+)}", function(key)
        return tokens[key] ~= nil and tostring(tokens[key]) or ""
    end)
end

-------------------------------------------------------------------------------
-- Send Message
-------------------------------------------------------------------------------

local function SendMessage(channel, msg)
    if not msg or msg == "" then return end
    SendChatMessage(msg, channel)
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

function ns.Announcer.Announce(category, spellId, tokens, ccType, noThrottle)
    local db = ns.Addon and ns.Addon.db
    if not db then
        ns.DebugPrint("Announce: no db")
        return
    end
    if not db.profile.enabled then
        ns.DebugPrint("Announce: addon disabled")
        return
    end

    local categoryConfig = db.profile[category]
    if not categoryConfig then
        ns.DebugPrint(string_format("Announce: unknown category '%s'", tostring(category)))
        return
    end
    if not categoryConfig.enabled then
        ns.DebugPrint(string_format("Announce: category '%s' disabled", category))
        return
    end

    -- Throttle check (skip when noThrottle is true)
    if not noThrottle then
        local throttleDuration = db.profile.throttleDuration or 3.0
        local throttleKey = tostring(spellId) .. "_" .. category
        local now = GetTime()
        local lastTime = lastAnnounceTimes[throttleKey] or 0

        if (now - lastTime) < throttleDuration then
            ns.DebugPrint(string_format("Announce: throttled category='%s' spellId=%s", category, tostring(spellId)))
            return
        end

        lastAnnounceTimes[throttleKey] = now
    end

    -- Build and send message
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

    ns.DebugPrint(string_format("Announce: [%s] -> %s: %s", category, channel, tostring(msg)))
end

function ns.Announcer.AnnounceCustom(spellId, tokens)
    local db = ns.Addon and ns.Addon.db
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

                ns.DebugPrint(string_format(
                    "AnnounceCustom: spellId=%s -> %s: %s", tostring(spellId), channel, tostring(msg)
                ))
            else
                ns.DebugPrint(string_format("AnnounceCustom: throttled spellId=%s", tostring(spellId)))
            end
        end
    end
end

function ns.Announcer.ClearThrottle()
    wipe(lastAnnounceTimes)
    ns.DebugPrint("Throttle table cleared")
end

-------------------------------------------------------------------------------
-- zhCN.lua
-- Chinese (Simplified) locale for DragonShout
--
-- 支持版本：正式服、熊猫人之谜经典服、燃烧的远征周年纪念服
-------------------------------------------------------------------------------
local ADDON_NAME, ns = ... -- luacheck: ignore 211/ns
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhCN")
if not L then return end

-- DragonShout/Core/Init.lua
L["Loaded. Type /ds help for commands."] = "已加载。输入 /ds help 查看命令帮助。"

-- DragonShout/Core/ConfigWindow.lua
L["DragonShout_Options addon not found. Please ensure it is installed."] = "未找到 DragonShout_Options 插件。请确保已安装该插件。"

-- DragonShout/Core/SlashCommands.lua
L["--- DragonShout Status ---"] = "--- DragonShout 状态 ---"
L["--- DragonShout Commands ---"] = "--- DragonShout 命令 ---"
L["Enabled"] = "已启用"
L["Disabled"] = "已禁用"
L["Yes"] = "是"
L["No"] = "否"
L["Interrupts"] = "打断"
L["CC on You"] = "自身被控"
L["CC Applied"] = "施放控制"
L["Dispels"] = "驱散"
L["Channel"] = "引导"
L["Template"] = "模板"
L["Throttle Duration"] = "限制间隔"
L["s"] = "秒"
L["Minimap Icon"] = "小地图图标"
L["Show this help"] = "显示此帮助信息"
L["Toggle addon on/off"] = "切换插件启用/禁用状态"
L["Open settings panel"] = "打开设置面板"
L["Show current settings"] = "显示当前设置"
L["Addon enabled"] = "插件已启用"
L["Addon disabled"] = "插件已禁用"
L["Solo"] = "单人"
L["Group"] = "小队"
L["Addon not yet initialized."] = "插件尚未初始化。"
L["Unknown command: "] = "未知命令："
L["Debug"] = "调试"
L["Debug Mode"] = "调试模式"
L["Enable verbose debug logging to chat"] = "启用详细调试日志输出到聊天框"
L["Print Status"] = "发送状态"
L["Print current addon state to chat"] = "将插件当前状态输出到聊天框"
L["Clear Throttle"] = "解除限制"
L["Reset all announce throttle timers"] = "重置所有通告限制计时器"
L["Player GUID"] = "玩家标识 GUID"
L["Version"] = "版本"
L["Toggle debug mode on/off"] = "启用/禁用调试模式"
L["Debug mode: "] = "调试模式："

-- DragonShout/Core/MinimapIcon.lua
L["Status: "] = "状态："
L["Left-Click"] = "左键点击"
L["Right-Click"] = "右键点击"
L["Open settings"] = "打开设置"
L["Toggle on/off"] = "切换启用/禁用"

-- 默认模板字符串（用作配置默认值和本地化键）
L["Interrupted {target}'s {extraSpell} with {spell}!"] = "{spell} 打断了 {target} 的 {extraSpell}！"
L["{type} for {duration}s!"] = "{type} 持续 {duration}秒！"
L["CC'd {target} with {spell}!"] = "{spell} 控制了 {target}！"
L["Dispelled {extraSpell} from {target}!"] = "驱散了 {target} 的 {extraSpell}！"

-------------------------------------------------------------------------------
-- DragonShout_Options
-------------------------------------------------------------------------------

-- DragonShout_Options/Tabs/GeneralTab.lua
L["General"] = "常规"
L["Core Settings"] = "核心设置"
L["Enable DragonShout"] = "启用 DragonShout"
L["Enable or disable the addon"] = "启用或禁用本插件"
L["Show Minimap Icon"] = "显示小地图按钮"
L["Toggle the minimap button"] = "切换小地图按钮显示状态"
L["Testing"] = "测试"
L["Test Interrupt"] = "测试打断通告"
L["Simulate an interrupt announcement"] = "模拟发送一次打断通告"
L["Test CC"] = "测试控制效果通告"
L["Simulate a CC announcement"] = "模拟发送一次控制效果通告"
L["Debug Settings"] = "调试设置"
L["Enable Debug Mode"] = "启用调试模式"

-- DragonShout_Options/Tabs/InterruptsTab.lua
L["Enable interrupt announcements"] = "启用打断通告"
L["Chat channel to send announcements to"] = "发送通告的聊天频道"
L["Announcement template. Tokens: {spell}, {target}, {extraSpell}"] = "通告模板。技能名：{spell}，目标：{target}，目标技能：{extraSpell}"
L["Party"] = "小队"
L["Raid"] = "团队"
L["Say"] = "说"
L["Yell"] = "大喊"
L["Local"] = "本地"
L["Instance"] = "副本"
L["Officer"] = "官员"
L["Solo Channel"] = "单人频道"
L["Group Channel"] = "小队频道"
L["Raid/Instance Channel"] = "团队/副本频道"
L["Channel used when not in any group (LOCAL prints only to your own chat frame)"] = "无队伍时使用的频道（本地模式仅输出到自己的聊天框）"
L["Channel used when in a party"] = "小队模式下使用的频道"
L["Channel used when in a raid or instance group"] = "团队或副本队伍模式下使用的频道"

-- DragonShout_Options/Tabs/CCOnYouTab.lua
L["Enable CC-on-you announcements"] = "启用自身被控通告"
L["Announcement template. Tokens: {spell}, {type}, {duration}"] = "通告模板。技能名：{spell}，控制类型：{type}，持续时间：{duration}"
L["CC Types"] = "控制类型"
L["Silence"] = "沉默"
L["Polymorph"] = "变形"
L["Stun"] = "晕眩"
L["Disorient"] = "迷惑"
L["Fear"] = "恐惧"
L["Root"] = "定身"
L["Announce when silenced"] = "被沉默时发送通告"
L["Announce when polymorphed"] = "被变形时发送通告"
L["Announce when stunned"] = "被晕眩时发送通告"
L["Announce when disoriented"] = "被迷惑时发送通告"
L["Announce when feared"] = "被恐惧时发送通告"
L["Announce when rooted"] = "被定身时发送通告"
L["Silenced"] = "沉默"
L["Stunned"] = "晕眩"
L["Polymorphed"] = "变形"
L["Disoriented"] = "迷惑"
L["Feared"] = "恐惧"
L["Rooted"] = "定身"
L["Per-Type Templates"] = "各类型模板"
L["Leave blank to use the default template above."] = "留空则使用上方的默认模板。"
L["Silence template"] = "沉默模板"
L["Stun template"] = "晕眩模板"
L["Polymorph template"] = "变形模板"
L["Disorient template"] = "迷惑模板"
L["Fear template"] = "恐惧模板"
L["Root template"] = "定身模板"

-- DragonShout_Options/Tabs/CCAppliedTab.lua
L["Enable CC-applied announcements"] = "启用施放控制通告"
L["Announcement template. Tokens: {spell}, {target}"] = "通告模板。技能名：{spell}，目标：{target}"

-- DragonShout_Options/Tabs/DispelsTab.lua
L["Enable dispel announcements"] = "启用驱散通告"
L["Announcement template. Tokens: {spell}, {target}, {extraSpell}"] = "通告模板。技能名：{spell}，目标：{target}，被驱散状态：{extraSpell}"

-- DragonShout_Options/Tabs/CustomSpellsTab.lua
L["Custom Spells"] = "自定义技能"
L["Add spell IDs to announce when applied to or by you."] = "添加技能ID，当该技能作用于你或由你释放时发送通告。"
L["Template tokens: {spell} (spell name), {target} (target unit), {source} (caster)"]
    = "模板参数：技能：{spell}，目标：{target}，施法者：{source}"
L["Spell ID"] = "技能ID"
L["Add"] = "添加"
L["No custom spells configured."] = "未配置任何自定义技能。"
L["Enable this spell announcement"] = "启用该技能通告"
L["Unknown Spell"] = "未知技能"
L["Solo: "] = "单人："
L["Group: "] = "小队："
L["Raid: "] = "团队："
L["Channel used when solo (not in any group)"] = "单人模式下使用的频道（无队伍时）"
L["Channel used when in a party or group"] = "小队模式下使用的频道"
L["Channel used when in a raid or instance"] = "团队/副本模式下使用的频道"

-- DragonShout_Options/Tabs/ProfilesTab.lua
L["Active Profile"] = "当前配置文件"
L["Are you sure you want to delete the profile \"%s\"?"] = "确定要删除配置文件「%s」吗？"
L["Are you sure you want to reset the current profile?"] = "确定要重置当前配置文件吗？"
L["Cancel"] = "取消"
L["Copy From"] = "从...复制"
L["Copy settings from another profile"] = "从其他配置文件复制设置"
L["Create Profile"] = "创建配置文件"
L["Create a new profile with the entered name"] = "使用输入的名称创建新配置文件"
L["Current Profile"] = "当前配置文件"
L["Delete"] = "删除"
L["Delete Profile"] = "删除配置文件"
L["Delete a profile"] = "删除一个配置文件"
L["Enter a name for a new profile"] = "输入新配置文件的名称"
L["New Profile Name"] = "新配置文件名称"
L["Profile Actions"] = "配置文件操作"
L["Profiles"] = "配置文件"
L["Profiles allow you to save different configurations for different characters."]
    = "配置文件功能允许你为不同角色保存不同的插件配置。"
L["Reset"] = "重置"
L["Reset Profile"] = "重置配置文件"
L["Reset the current profile to default settings"] = "将当前配置文件重置为默认设置"
L["Select the active profile"] = "选择当前生效的配置文件"

-- DragonShout_Options/Tabs/DebugTab.lua
L["Debug Log"] = ""
L["Refresh"] = ""
L["Clear Log"] = ""
L["Copy"] = ""
L["Click in the box and press Ctrl+C to copy"] = ""

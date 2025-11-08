-- MiracleWarrior 设置界面
local gui = Aurora.GuiBuilder:New()

-- 本地化文本表
local L = {
    zh = {
        -- Category and Tab names
        category = "MiracleWarrior设置",
        general = "常用设置",
        combat = "战斗设置",
        defensive = "减伤设置",
        interrupt = "打断设置",
        trinket = "饰品设置",
        advanced = "功能设置",

        -- General Settings
        language = "界面语言",
        language_tooltip = "选择界面显示语言，切换后请自行/reload",
        tutorial = "使用教程",
        tutorial_text = "Miracle拥有自创HyperBurst系统，让你更智能化的打出最高雷霆轰击伤害。打断依靠Aurora list managerment，减伤自动应对。有问题及时反馈，祝您战斗愉快！",

        -- Combat Settings
        basic_settings = "基础设置",
        victory_rush = "启用乘胜追击",
        victory_rush_tooltip = "自动使用乘胜追击进行治疗",
        taunt = "启用自动嘲讽",
        taunt_tooltip = "自动嘲讽攻击队友的敌人",
        shield_charge = "启用盾牌冲锋",
        shield_charge_tooltip = "启用/禁用盾牌冲锋技能",
        rage_threshold = "怒气阈值",
        rage_threshold_tooltip = "当怒气达到此值时使用无视苦痛",
        aoe_threshold = "AOE阈值",
        aoe_threshold_tooltip = "周围敌人数量达到此值时优先使用AOE技能",

        ttd_settings = "TTD设置",
        ttd_enabled = "启用TTD判断",
        ttd_enabled_tooltip = "启用时间到死亡判断，避免在目标即将死亡时使用长冷却技能",
        ttd_threshold = "TTD阈值(秒)",
        ttd_threshold_tooltip = "目标剩余存活时间低于此值时不会使用长冷却技能",

        -- Defensive Settings
        smart_defensive = "智能减伤",
        defensive_enabled = "启用智能减伤",
        defensive_enabled_tooltip = "根据血量自动使用减伤技能",
        spell_reflect = "启用法术反射",
        spell_reflect_tooltip = "自动使用法术反射",
        rallying_cry = "启用集结呐喊",
        rallying_cry_tooltip = "自动使用集结呐喊保护团队",

        health_threshold = "血量阈值设置",
        victory_rush_health = "乘胜追击血量(%)",
        victory_rush_health_tooltip = "血量低于此值时使用乘胜追击",
        rallying_cry_health = "集结呐喊血量(%)",
        rallying_cry_health_tooltip = "团队平均血量低于此值时使用集结呐喊",
        shield_wall_health = "盾墙血量(%)",
        shield_wall_health_tooltip = "血量低于此值时使用盾墙",
        last_stand_health = "破釜沉舟血量(%)",
        last_stand_health_tooltip = "血量低于此值时使用破釜沉舟",

        -- Interrupt Settings
        interrupt_function = "打断功能",
        interrupt_enabled = "启用打断",
        interrupt_enabled_tooltip = "自动使用拳击打断敌人施法",
        hard_control = "启用硬控打断",
        hard_control_tooltip = "当拳击不可用时，使用震荡波、风暴之锤、挑战怒吼进行打断",
        random_interrupt = "随机打断时间",
        random_interrupt_tooltip = "为打断添加随机延迟，避免被检测",

        interrupt_timing = "打断时机",
        min_delay = "最小延迟(秒)",
        min_delay_tooltip = "打断的最小延迟时间",
        max_delay = "最大延迟(秒)",
        max_delay_tooltip = "打断的最大延迟时间",
        interrupt_percent = "打断进度(%)",
        interrupt_percent_tooltip = "施法进度达到此百分比时进行打断",

        -- Trinket Settings
        trinket1_settings = "饰品1设置",
        trinket1_mode = "饰品1使用模式",
        trinket1_health = "饰品1血量阈值(%)",
        trinket1_health_tooltip = "血量低于此值时自动使用饰品1",

        trinket2_settings = "饰品2设置",
        trinket2_mode = "饰品2使用模式",
        trinket2_health = "饰品2血量阈值(%)",
        trinket2_health_tooltip = "血量低于此值时自动使用饰品2",

        trinket_modes = {
            cd = "卡CD使用",
            avatar = "天神下凡时使用",
            health = "血量低于设定值时使用",
            none = "不使用"
        },

        -- Advanced Settings
        potion_settings = "药水设置",
        burst_potion = "爆发药水",
        burst_potion_tooltip = "选择爆发药水的使用策略",
        heal_potion_health = "治疗药水血量(%)",
        heal_potion_health_tooltip = "血量低于此值时自动使用治疗药水",

        advanced_settings = "高级设置",
        battle_shout = "自动战斗怒吼",
        battle_shout_tooltip = "战斗外自动为队友施放战斗怒吼",
        overpower_wait = "怒意等待阈值(%)",
        overpower_wait_tooltip = "怒意迸发进度达到此百分比时等待雷霆轰击冷却(100层=100%)",
        thunder_priority = "雷霆优先级",
        thunder_priority_tooltip = "雷霆一击的释放优先级",

        priority_levels = {
            high = "高",
            medium = "中",
            low = "低"
        },

        -- Status Bar Labels (保持简洁)
        status_taunt = "嘲讽",
        status_defensive = "减伤",
        status_reflect = "反射",
        status_victory = "乘胜",
        status_rally = "集结",
        status_charge = "盾冲",
        status_hardcontrol = "硬控"
    },

    en = {
        -- Category and Tab names
        category = "MiracleWarrior Settings",
        general = "General Settings",
        combat = "Combat Settings",
        defensive = "Defensive Settings",
        interrupt = "Interrupt Settings",
        trinket = "Trinket Settings",
        advanced = "Advanced Settings",

        -- General Settings
        language = "Interface Language",
        language_tooltip = "Select interface display language",
        tutorial = "Usage Tutorial",
        tutorial_text =
        "Miracle features the innovative HyperBurst system for optimal Thunder Blast damage. Interrupts rely on Aurora list management, defensive cooldowns are automated. Please report any issues. Enjoy your battles!",

        -- Combat Settings
        basic_settings = "Basic Settings",
        victory_rush = "Enable Victory Rush",
        victory_rush_tooltip = "Automatically use Victory Rush for healing",
        taunt = "Enable Auto Taunt",
        taunt_tooltip = "Automatically taunt enemies attacking allies",
        shield_charge = "Enable Shield Charge",
        shield_charge_tooltip = "Enable/disable Shield Charge ability",
        rage_threshold = "Rage Threshold",
        rage_threshold_tooltip = "Use Ignore Pain when rage reaches this value",
        aoe_threshold = "AOE Threshold",
        aoe_threshold_tooltip = "Prioritize AOE skills when enemy count reaches this value",

        ttd_settings = "TTD Settings",
        ttd_enabled = "Enable TTD Check",
        ttd_enabled_tooltip = "Enable time-to-death checking to avoid using long cooldowns on dying targets",
        ttd_threshold = "TTD Threshold(sec)",
        ttd_threshold_tooltip = "Don't use long cooldowns if target TTD is below this value",

        -- Defensive Settings
        smart_defensive = "Smart Defensive",
        defensive_enabled = "Enable Smart Defensive",
        defensive_enabled_tooltip = "Automatically use defensive skills based on health",
        spell_reflect = "Enable Spell Reflect",
        spell_reflect_tooltip = "Automatically use Spell Reflect",
        rallying_cry = "Enable Rallying Cry",
        rallying_cry_tooltip = "Automatically use Rallying Cry to protect the team",

        health_threshold = "Health Threshold Settings",
        victory_rush_health = "Victory Rush Health(%)",
        victory_rush_health_tooltip = "Use Victory Rush when health below this value",
        rallying_cry_health = "Rallying Cry Health(%)",
        rallying_cry_health_tooltip = "Use Rallying Cry when average team health below this value",
        shield_wall_health = "Shield Wall Health(%)",
        shield_wall_health_tooltip = "Use Shield Wall when health below this value",
        last_stand_health = "Last Stand Health(%)",
        last_stand_health_tooltip = "Use Last Stand when health below this value",

        -- Interrupt Settings
        interrupt_function = "Interrupt Function",
        interrupt_enabled = "Enable Interrupt",
        interrupt_enabled_tooltip = "Automatically use Pummel to interrupt enemy casts",
        hard_control = "Enable Hard Control Interrupt",
        hard_control_tooltip = "Use Shockwave, Storm Bolt, or Demoralizing Shout when Pummel unavailable",
        random_interrupt = "Random Interrupt Time",
        random_interrupt_tooltip = "Add random delay to interrupts to avoid detection",

        interrupt_timing = "Interrupt Timing",
        min_delay = "Min Delay(sec)",
        min_delay_tooltip = "Minimum delay time for interrupts",
        max_delay = "Max Delay(sec)",
        max_delay_tooltip = "Maximum delay time for interrupts",
        interrupt_percent = "Interrupt Progress(%)",
        interrupt_percent_tooltip = "Interrupt when cast progress reaches this percentage",

        -- Trinket Settings
        trinket1_settings = "Trinket 1 Settings",
        trinket1_mode = "Trinket 1 Usage Mode",
        trinket1_health = "Trinket 1 Health Threshold(%)",
        trinket1_health_tooltip = "Automatically use Trinket 1 when health below this value",

        trinket2_settings = "Trinket 2 Settings",
        trinket2_mode = "Trinket 2 Usage Mode",
        trinket2_health = "Trinket 2 Health Threshold(%)",
        trinket2_health_tooltip = "Automatically use Trinket 2 when health below this value",

        trinket_modes = {
            cd = "Use on CD",
            avatar = "Use with Avatar",
            health = "Use on Low Health",
            none = "Don't Use"
        },

        -- Advanced Settings
        potion_settings = "Potion Settings",
        burst_potion = "Burst Potion",
        burst_potion_tooltip = "Select burst potion usage strategy",
        heal_potion_health = "Heal Potion Health(%)",
        heal_potion_health_tooltip = "Automatically use heal potion when health below this value",

        advanced_settings = "Advanced Settings",
        battle_shout = "Auto Battle Shout",
        battle_shout_tooltip = "Automatically cast Battle Shout on party members out of combat",
        overpower_wait = "Overpower Wait Threshold(%)",
        overpower_wait_tooltip =
        "Wait for Thunder Blast cooldown when Overpower progress reaches this percentage (100 stacks = 100%)",
        thunder_priority = "Thunder Priority",
        thunder_priority_tooltip = "Thunder Clap casting priority",

        priority_levels = {
            high = "High",
            medium = "Medium",
            low = "Low"
        },

        -- Status Bar Labels (保持简洁)
        status_taunt = "Taunt",
        status_defensive = "Def",
        status_reflect = "Reflect",
        status_victory = "Victory",
        status_rally = "Rally",
        status_charge = "Charge",
        status_hardcontrol = "HardCtrl"
    }
}

-- 获取当前语言文本
local function T(key)
    local language = Aurora.Config:Read("MiracleWarrior.general.language") or "zh"
    return L[language][key] or key
end

-- 获取当前语言
local function GetLanguage()
    return Aurora.Config:Read("MiracleWarrior.general.language") or "zh"
end

-- 创建界面
local function CreateInterface()
    local lang = GetLanguage()
    local T = function(key) return L[lang][key] or key end

    gui:Category(T("category"))
        :Tab(T("general"))
        :Header({ text = T("language") })
        :Dropdown({
            text = T("language"),
            key = "MiracleWarrior.general.language",
            options = {
                { text = "中文", value = "zh" },
                { text = "English", value = "en" }
            },
            default = "zh",
            tooltip = T("language_tooltip"),
            onChange = function(value)
                Aurora.alert("Language changed to " .. value .. ". Please /reload to apply changes.", 132306)
            end
        })

        :Header({ text = T("tutorial") })
        :Text({
            text = T("tutorial_text"),
            color = "normal",
            size = 10
        })

    -- 战斗设置
        :Tab(T("combat"))
        :Header({ text = T("basic_settings") })
        :Checkbox({
            text = T("victory_rush"),
            key = "MiracleWarrior.victory_rush_enabled",
            default = true,
            tooltip = T("victory_rush_tooltip")
        })
        :Checkbox({
            text = T("taunt"),
            key = "MiracleWarrior.taunt.enabled",
            default = true,
            tooltip = T("taunt_tooltip")
        })
        :Checkbox({
            text = T("shield_charge"),
            key = "MiracleWarrior.shield_charge_enabled",
            default = true,
            tooltip = T("shield_charge_tooltip")
        })
        :Slider({
            text = T("rage_threshold"),
            key = "MiracleWarrior.rage_threshold",
            min = 40,
            max = 100,
            step = 5,
            default = 60,
            tooltip = T("rage_threshold_tooltip")
        })
        :Slider({
            text = T("aoe_threshold"),
            key = "MiracleWarrior.aoe_threshold",
            min = 1,
            max = 10,
            step = 1,
            default = 3,
            tooltip = T("aoe_threshold_tooltip")
        })

        :Header({ text = T("ttd_settings") })
        :Checkbox({
            text = T("ttd_enabled"),
            key = "MiracleWarrior.ttd_enabled",
            default = true,
            tooltip = T("ttd_enabled_tooltip")
        })
        :Slider({
            text = T("ttd_threshold"),
            key = "MiracleWarrior.ttd_threshold",
            min = 5,
            max = 30,
            step = 1,
            default = 15,
            tooltip = T("ttd_threshold_tooltip")
        })

    -- 减伤设置
        :Tab(T("defensive"))
        :Header({ text = T("smart_defensive") })
        :Checkbox({
            text = T("defensive_enabled"),
            key = "MiracleWarrior.defensive.enabled",
            default = true,
            tooltip = T("defensive_enabled_tooltip")
        })
        :Checkbox({
            text = T("spell_reflect"),
            key = "MiracleWarrior.spell_reflect.enabled",
            default = true,
            tooltip = T("spell_reflect_tooltip")
        })
        :Checkbox({
            text = T("rallying_cry"),
            key = "MiracleWarrior.rallying_cry.enabled",
            default = true,
            tooltip = T("rallying_cry_tooltip")
        })

        :Header({ text = T("health_threshold") })
        :Slider({
            text = T("victory_rush_health"),
            key = "MiracleWarrior.victory_rush_health",
            min = 20,
            max = 80,
            step = 5,
            default = 60,
            tooltip = T("victory_rush_health_tooltip")
        })
        :Slider({
            text = T("rallying_cry_health"),
            key = "MiracleWarrior.rallying_cry_health",
            min = 20,
            max = 80,
            step = 5,
            default = 50,
            tooltip = T("rallying_cry_health_tooltip")
        })
        :Slider({
            text = T("shield_wall_health"),
            key = "MiracleWarrior.shield_wall_health",
            min = 10,
            max = 100,
            step = 5,
            default = 70,
            tooltip = T("shield_wall_health_tooltip")
        })
        :Slider({
            text = T("last_stand_health"),
            key = "MiracleWarrior.last_stand_health",
            min = 10,
            max = 100,
            step = 5,
            default = 40,
            tooltip = T("last_stand_health_tooltip")
        })

    -- 打断设置
        :Tab(T("interrupt"))
        :Header({ text = T("interrupt_function") })
        :Checkbox({
            text = T("interrupt_enabled"),
            key = "MiracleWarrior.interrupt_enabled",
            default = true,
            tooltip = T("interrupt_enabled_tooltip")
        })
        :Checkbox({
            text = T("hard_control"),
            key = "MiracleWarrior.hard_control_interrupt_enabled",
            default = true,
            tooltip = T("hard_control_tooltip")
        })
        :Checkbox({
            text = T("random_interrupt"),
            key = "MiracleWarrior.random_interrupt",
            default = true,
            tooltip = T("random_interrupt_tooltip")
        })

        :Header({ text = T("interrupt_timing") })
        :Slider({
            text = T("min_delay"),
            key = "MiracleWarrior.min_interrupt_delay",
            min = 0,
            max = 1,
            step = 0.1,
            default = 0,
            tooltip = T("min_delay_tooltip")
        })
        :Slider({
            text = T("max_delay"),
            key = "MiracleWarrior.max_interrupt_delay",
            min = 0.5,
            max = 1,
            step = 0.1,
            default = 0.5,
            tooltip = T("max_delay_tooltip")
        })
        :Slider({
            text = T("interrupt_percent"),
            key = "MiracleWarrior.interrupt_cast_percent",
            min = 10,
            max = 90,
            step = 5,
            default = 50,
            tooltip = T("interrupt_percent_tooltip")
        })

    -- 饰品设置
        :Tab(T("trinket"))
        :Header({ text = T("trinket1_settings") })
        :Dropdown({
            text = T("trinket1_mode"),
            key = "MiracleWarrior.trinket1_mode",
            options = {
                { text = T("trinket_modes.cd"),     value = "cd" },
                { text = T("trinket_modes.avatar"), value = "avatar" },
                { text = T("trinket_modes.health"), value = "health" },
                { text = T("trinket_modes.none"),   value = "none" }
            },
            default = "cd",
            tooltip = T("trinket1_mode")
        })
        :Slider({
            text = T("trinket1_health"),
            key = "MiracleWarrior.trinket1_health_threshold",
            min = 10,
            max = 50,
            step = 5,
            default = 30,
            tooltip = T("trinket1_health_tooltip")
        })

        :Header({ text = T("trinket2_settings") })
        :Dropdown({
            text = T("trinket2_mode"),
            key = "MiracleWarrior.trinket2_mode",
            options = {
                { text = T("trinket_modes.cd"),     value = "cd" },
                { text = T("trinket_modes.avatar"), value = "avatar" },
                { text = T("trinket_modes.health"), value = "health" },
                { text = T("trinket_modes.none"),   value = "none" }
            },
            default = "cd",
            tooltip = T("trinket2_mode")
        })
        :Slider({
            text = T("trinket2_health"),
            key = "MiracleWarrior.trinket2_health_threshold",
            min = 10,
            max = 50,
            step = 5,
            default = 30,
            tooltip = T("trinket2_health_tooltip")
        })

    -- 功能设置
        :Tab(T("advanced"))
        :Header({ text = T("potion_settings") })
        :Dropdown({
            text = T("burst_potion"),
            key = "MiracleWarrior.burst_potion_mode",
            options = {
                { text = T("trinket_modes.cd"),     value = "cd" },
                { text = T("trinket_modes.avatar"), value = "avatar" },
                { text = T("trinket_modes.none"),   value = "none" }
            },
            default = "cd",
            tooltip = T("burst_potion_tooltip")
        })
        :Slider({
            text = T("heal_potion_health"),
            key = "MiracleWarrior.heal_potion_health",
            min = 10,
            max = 50,
            step = 5,
            default = 30,
            tooltip = T("heal_potion_health_tooltip")
        })

        :Header({ text = T("advanced_settings") })
        :Checkbox({
            text = T("battle_shout"),
            key = "MiracleWarrior.battle_shout_enabled",
            default = true,
            tooltip = T("battle_shout_tooltip")
        })
        :Slider({
            text = T("overpower_wait"),
            key = "MiracleWarrior.overpower_wait",
            min = 50,
            max = 95,
            step = 5,
            default = 80,
            tooltip = T("overpower_wait_tooltip")
        })
        :Dropdown({
            text = T("thunder_priority"),
            key = "MiracleWarrior.thunder_priority",
            options = {
                { text = T("priority_levels.high"),   value = "high" },
                { text = T("priority_levels.medium"), value = "medium" },
                { text = T("priority_levels.low"),    value = "low" }
            },
            default = "medium",
            tooltip = T("thunder_priority_tooltip")
        })
end

-- 状态栏集成
local function RegisterStatusToggles()
    C_Timer.After(3, function()
        local lang = GetLanguage()
        local T = function(key) return L[lang][key] or key end

        -- 确保使用正确的配置键名
        Aurora.Rotation.TauntToggle = Aurora:AddGlobalToggle({
            label = T("status_taunt"),
            var = "MiracleWarrior.taunt.enabled",
            icon = 355,
            tooltip = T("taunt_tooltip")
        })

        Aurora.Rotation.DefensiveToggle = Aurora:AddGlobalToggle({
            label = T("status_defensive"),
            var = "MiracleWarrior.defensive.enabled",
            icon = 871,
            tooltip = T("defensive_enabled_tooltip")
        })

        Aurora.Rotation.SpellReflectToggle = Aurora:AddGlobalToggle({
            label = T("status_reflect"),
            var = "MiracleWarrior.spell_reflect.enabled",
            icon = 23920,
            tooltip = T("spell_reflect_tooltip")
        })

        Aurora.Rotation.VictoryRushToggle = Aurora:AddGlobalToggle({
            label = T("status_victory"),
            var = "MiracleWarrior.victory_rush_enabled",
            icon = 34428,
            tooltip = T("victory_rush_tooltip")
        })

        Aurora.Rotation.RallyingCryToggle = Aurora:AddGlobalToggle({
            label = T("status_rally"),
            var = "MiracleWarrior.rallying_cry.enabled",
            icon = 97462,
            tooltip = T("rallying_cry_tooltip")
        })

        Aurora.Rotation.ShieldChargeToggle = Aurora:AddGlobalToggle({
            label = T("status_charge"),
            var = "MiracleWarrior.shield_charge_enabled",
            icon = 385952,
            tooltip = T("shield_charge_tooltip")
        })

        Aurora.Rotation.HardControlInterruptToggle = Aurora:AddGlobalToggle({
            label = T("status_hardcontrol"),
            var = "MiracleWarrior.hard_control_interrupt_enabled",
            icon = 46968,
            tooltip = T("hard_control_tooltip")
        })

        local loadedMsg = lang == "zh" and "MiracleWarrior 状态栏已加载!" or "MiracleWarrior status bar loaded!"
        print(loadedMsg)
    end)
end

-- 创建界面
CreateInterface()

-- 注册状态栏
RegisterStatusToggles()

local loadedMsg = GetLanguage() == "zh" and "MiracleWarrior 界面已加载!" or "MiracleWarrior interface loaded!"
print(loadedMsg)

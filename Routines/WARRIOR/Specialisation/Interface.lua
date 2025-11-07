-- MiracleWarrior 设置界面
local gui = Aurora.GuiBuilder:New()

-- 默认天赋代码
local DEFAULT_TALENT_CODE = "BcQAAAAAAAAAAAAAAAAAAAAAAQSSJkEJpAAAAAAQiIJJFSaEJJJJBJAAAAA"

-- 获取当前语言
local function GetLanguage()
    return Aurora.Config:Read("MiracleWarrior.general.language") or "zh"
end

-- MiracleWarrior设置 - 常用设置
gui:Category("MiracleWarrior设置")
    :Tab("常用设置")
    :Header({ text = "语言设置" })
    :Dropdown({
        text = "界面语言",
        key = "MiracleWarrior.general.language",
        options = {
            { text = "中文", value = "zh" },
            { text = "English", value = "en" }
        },
        default = "zh",
        tooltip = "选择界面显示语言",
        onChange = function(value)
            -- 切换语言后自动执行重载命令
            C_Timer.After(1, function()
                RunMacroText("/reload")
            end)
        end
    })

    :Header({ text = "天赋代码" })
    :Button({
        text = "推荐天赋代码",
        onClick = function()
            -- 使用Aurora的Alert系统显示天赋代码
            local language = GetLanguage()
            local title = language == "zh" and "推荐天赋代码" or "Recommended Talent Code"
            local note = language == "zh" and "请复制以下代码：" or "Please copy the following code:"

            -- 显示在聊天框
            print("=== " .. title .. " ===")
            print(DEFAULT_TALENT_CODE)
            print("================================")

            -- 使用Aurora Alert显示
            Aurora.alert(title .. "\n" .. DEFAULT_TALENT_CODE, 10)
        end,
        tooltip = "点击显示推荐天赋代码，请在聊天框中复制"
    })

    :Header({ text = "使用教程" })
    :Text({
        text = "Miracle拥有自创HyperBurst系统，让你更智能化的打出最高雷霆轰击伤害。打断依靠Aurora list managerment，减伤自动应对。有问题及时反馈，祝您战斗愉快！",
        color = "normal",
        size = 10
    })

-- 战斗设置
    :Tab("战斗设置")
    :Header({ text = "基础设置" })
    :Checkbox({
        text = "启用乘胜追击",
        key = "MiracleWarrior.victory_rush_enabled",
        default = true,
        tooltip = "自动使用乘胜追击进行治疗"
    })
    :Checkbox({
        text = "启用自动嘲讽",
        key = "MiracleWarrior.taunt.enabled",
        default = true,
        tooltip = "自动嘲讽攻击队友的敌人"
    })
    :Checkbox({
        text = "启用盾牌冲锋",
        key = "MiracleWarrior.shield_charge_enabled",
        default = true,
        tooltip = "启用/禁用盾牌冲锋技能"
    })
    :Slider({
        text = "怒气阈值",
        key = "MiracleWarrior.rage_threshold",
        min = 40,
        max = 100,
        step = 5,
        default = 60,
        tooltip = "当怒气达到此值时使用无视苦痛"
    })
    :Slider({
        text = "AOE阈值",
        key = "MiracleWarrior.aoe_threshold",
        min = 1,
        max = 10,
        step = 1,
        default = 3,
        tooltip = "周围敌人数量达到此值时优先使用AOE技能"
    })

    :Header({ text = "TTD设置" })
    :Checkbox({
        text = "启用TTD判断",
        key = "MiracleWarrior.ttd_enabled",
        default = true,
        tooltip = "启用时间到死亡判断，避免在目标即将死亡时使用长冷却技能"
    })
    :Slider({
        text = "TTD阈值(秒)",
        key = "MiracleWarrior.ttd_threshold",
        min = 5,
        max = 30,
        step = 1,
        default = 15,
        tooltip = "目标剩余存活时间低于此值时不会使用长冷却技能"
    })

-- 减伤设置
    :Tab("减伤设置")
    :Header({ text = "智能减伤" })
    :Checkbox({
        text = "启用智能减伤",
        key = "MiracleWarrior.defensive.enabled",
        default = true,
        tooltip = "根据血量自动使用减伤技能"
    })
    :Checkbox({
        text = "启用法术反射",
        key = "MiracleWarrior.spell_reflect.enabled",
        default = true,
        tooltip = "自动使用法术反射"
    })
    :Checkbox({
        text = "启用集结呐喊",
        key = "MiracleWarrior.rallying_cry.enabled",
        default = true,
        tooltip = "自动使用集结呐喊保护团队"
    })

    :Header({ text = "血量阈值设置" })
    :Slider({
        text = "乘胜追击血量(%)",
        key = "MiracleWarrior.victory_rush_health",
        min = 20,
        max = 80,
        step = 5,
        default = 60,
        tooltip = "血量低于此值时使用乘胜追击"
    })
    :Slider({
        text = "集结呐喊血量(%)",
        key = "MiracleWarrior.rallying_cry_health",
        min = 20,
        max = 80,
        step = 5,
        default = 50,
        tooltip = "团队平均血量低于此值时使用集结呐喊"
    })
    :Slider({
        text = "盾墙血量(%)",
        key = "MiracleWarrior.shield_wall_health",
        min = 10,
        max = 100,
        step = 5,
        default = 70,
        tooltip = "血量低于此值时使用盾墙"
    })
    :Slider({
        text = "破釜沉舟血量(%)",
        key = "MiracleWarrior.last_stand_health",
        min = 10,
        max = 100,
        step = 5,
        default = 40,
        tooltip = "血量低于此值时使用破釜沉舟"
    })

-- 打断设置
    :Tab("打断设置")
    :Header({ text = "打断功能" })
    :Checkbox({
        text = "启用打断",
        key = "MiracleWarrior.interrupt_enabled",
        default = true,
        tooltip = "自动使用拳击打断敌人施法"
    })
    :Checkbox({
        text = "启用硬控打断",
        key = "MiracleWarrior.hard_control_interrupt_enabled",
        default = true,
        tooltip = "当拳击不可用时，使用震荡波、风暴之锤、挑战怒吼进行打断"
    })
    :Checkbox({
        text = "随机打断时间",
        key = "MiracleWarrior.random_interrupt",
        default = true,
        tooltip = "为打断添加随机延迟，避免被检测"
    })

    :Header({ text = "打断时机" })
    :Slider({
        text = "最小延迟(秒)",
        key = "MiracleWarrior.min_interrupt_delay",
        min = 0,
        max = 1,
        step = 0.1,
        default = 0,
        tooltip = "打断的最小延迟时间"
    })
    :Slider({
        text = "最大延迟(秒)",
        key = "MiracleWarrior.max_interrupt_delay",
        min = 0.5,
        max = 1,
        step = 0.1,
        default = 0.5,
        tooltip = "打断的最大延迟时间"
    })
    :Slider({
        text = "打断进度(%)",
        key = "MiracleWarrior.interrupt_cast_percent",
        min = 10,
        max = 90,
        step = 5,
        default = 50,
        tooltip = "施法进度达到此百分比时进行打断"
    })

-- 饰品设置
    :Tab("饰品设置")
    :Header({ text = "饰品1设置" })
    :Dropdown({
        text = "饰品1使用模式",
        key = "MiracleWarrior.trinket1_mode",
        options = {
            { text = "卡CD使用", value = "cd" },
            { text = "天神下凡时使用", value = "avatar" },
            { text = "血量低于设定值时使用", value = "health" },
            { text = "不使用", value = "none" }
        },
        default = "cd",
        tooltip = "选择饰品1的使用策略"
    })
    :Slider({
        text = "饰品1血量阈值(%)",
        key = "MiracleWarrior.trinket1_health_threshold",
        min = 10,
        max = 50,
        step = 5,
        default = 30,
        tooltip = "血量低于此值时自动使用饰品1"
    })

    :Header({ text = "饰品2设置" })
    :Dropdown({
        text = "饰品2使用模式",
        key = "MiracleWarrior.trinket2_mode",
        options = {
            { text = "卡CD使用", value = "cd" },
            { text = "天神下凡时使用", value = "avatar" },
            { text = "血量低于设定值时使用", value = "health" },
            { text = "不使用", value = "none" }
        },
        default = "cd",
        tooltip = "选择饰品2的使用策略"
    })
    :Slider({
        text = "饰品2血量阈值(%)",
        key = "MiracleWarrior.trinket2_health_threshold",
        min = 10,
        max = 50,
        step = 5,
        default = 30,
        tooltip = "血量低于此值时自动使用饰品2"
    })

-- 功能设置
    :Tab("功能设置")
    :Header({ text = "药水设置" })
    :Dropdown({
        text = "爆发药水",
        key = "MiracleWarrior.burst_potion_mode",
        options = {
            { text = "卡CD使用", value = "cd" },
            { text = "天神下凡时使用", value = "avatar" },
            { text = "不使用", value = "none" }
        },
        default = "cd",
        tooltip = "选择爆发药水的使用策略"
    })
    :Slider({
        text = "治疗药水血量(%)",
        key = "MiracleWarrior.heal_potion_health",
        min = 10,
        max = 50,
        step = 5,
        default = 30,
        tooltip = "血量低于此值时自动使用治疗药水"
    })

    :Header({ text = "高级设置" })
    :Checkbox({
        text = "自动战斗怒吼",
        key = "MiracleWarrior.battle_shout_enabled",
        default = true,
        tooltip = "战斗外自动为队友施放战斗怒吼"
    })
    :Slider({
        text = "怒意等待阈值(%)",
        key = "MiracleWarrior.overpower_wait",
        min = 50,
        max = 95,
        step = 5,
        default = 80,
        tooltip = "怒意迸发进度达到此百分比时等待雷霆轰击冷却(100层=100%)"
    })
    :Dropdown({
        text = "雷霆优先级",
        key = "MiracleWarrior.thunder_priority",
        options = {
            { text = "高", value = "high" },
            { text = "中", value = "medium" },
            { text = "低", value = "low" }
        },
        default = "medium",
        tooltip = "雷霆一击的释放优先级"
    })

-- 状态栏集成
local function RegisterStatusToggles()
    C_Timer.After(3, function()
        -- 确保使用正确的配置键名
        Aurora.Rotation.TauntToggle = Aurora:AddGlobalToggle({
            label = "嘲讽",
            var = "MiracleWarrior.taunt.enabled",
            icon = 355,
            tooltip = "启用/禁用自动嘲讽"
        })

        Aurora.Rotation.DefensiveToggle = Aurora:AddGlobalToggle({
            label = "减伤",
            var = "MiracleWarrior.defensive.enabled",
            icon = 871,
            tooltip = "启用/禁用智能减伤链"
        })

        Aurora.Rotation.SpellReflectToggle = Aurora:AddGlobalToggle({
            label = "反射",
            var = "MiracleWarrior.spell_reflect.enabled",
            icon = 23920,
            tooltip = "启用/禁用自动法术反射"
        })

        Aurora.Rotation.VictoryRushToggle = Aurora:AddGlobalToggle({
            label = "乘胜",
            var = "MiracleWarrior.victory_rush_enabled",
            icon = 34428,
            tooltip = "启用/禁用乘胜追击"
        })

        Aurora.Rotation.RallyingCryToggle = Aurora:AddGlobalToggle({
            label = "集结",
            var = "MiracleWarrior.rallying_cry.enabled",
            icon = 97462,
            tooltip = "启用/禁用集结呐喊"
        })

        Aurora.Rotation.ShieldChargeToggle = Aurora:AddGlobalToggle({
            label = "盾冲",
            var = "MiracleWarrior.shield_charge_enabled",
            icon = 385952,
            tooltip = "启用/禁用盾牌冲锋"
        })

        Aurora.Rotation.HardControlInterruptToggle = Aurora:AddGlobalToggle({
            label = "硬控",
            var = "MiracleWarrior.hard_control_interrupt_enabled",
            icon = 46968,
            tooltip = "启用/禁用硬控打断（震荡波、风暴之锤、挑战怒吼）"
        })

        print("MiracleWarrior 状态栏已加载!")
    end)
end

-- 注册状态栏
RegisterStatusToggles()

print("MiracleWarrior 界面已加载!")

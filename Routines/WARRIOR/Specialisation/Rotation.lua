-- Get commonly used units

local target = Aurora.UnitManager:Get("target")

local player = Aurora.UnitManager:Get("player")



-- Get your spellbook

local spells = Aurora.SpellHandler.Spellbooks.warrior["3"].MiracleWarrior.spells

local auras = Aurora.SpellHandler.Spellbooks.warrior["3"].MiracleWarrior.auras

local talents = Aurora.SpellHandler.Spellbooks.warrior["3"].MiracleWarrior.talents



-- 版本信息

local ROTATION_VERSION = "1.8.4"



-- 战斗数据统计

local combatStats = {

    startTime = 0,

    totalDamage = 0,

    interrupts = 0,

    taunts = 0,

    reflects = 0,

    victoryRushes = 0,

    rallyingCries = 0,

    lastReset = 0

}



-- 技能使用冷却跟踪

local skillCooldowns = {

    victory_rush = 0,

    last_stand = 0,

    shield_wall = 0,

    rallying_cry = 0,

    demoralizing_shout = 0,

    avatar = 0,

    battle_shout = 0

}



-- Severe Thunder buff ID

local SEVERE_THUNDER_BUFF = 1252096



-- 药水物品

local potions = {

    burst_3star = Aurora.ItemHandler.NewItem(212265), -- 淬火药水3星

    burst_2star = Aurora.ItemHandler.NewItem(212264), -- 淬火药水2星

    burst_1star = Aurora.ItemHandler.NewItem(212263), -- 淬火药水1星

    heal_3star = Aurora.ItemHandler.NewItem(244839),  -- 焕生治疗药水3星

    heal_2star = Aurora.ItemHandler.NewItem(244838),  -- 焕生治疗药水2星

    heal_1star = Aurora.ItemHandler.NewItem(244835)   -- 焕生治疗药水1星

}



-- 饰品栏位定义

local TRINKET_SLOTS = {

    TRINKET1 = 13,

    TRINKET2 = 14

}



-- 饰品使用冷却跟踪

local trinketCooldowns = {

    trinket1 = 0,

    trinket2 = 0

}



-- 只能对队友使用的饰品列表（需要根据实际情况更新）

local teamOnlyTrinkets = {

    [12345] = true, -- 示例：治疗饰品1

    [12346] = true, -- 示例：治疗饰品2

    -- 添加更多只能对队友使用的饰品ID

}



-- 盾牌格挡状态跟踪

local shieldBlockTracker = {

    lastCastTime = 0,

    buffDuration = 6,

    shouldMaintain = true

}



-- 怒意迸发状态跟踪

local lastRage = 0

local rageConsumed = 0

local ragingBlowReady = false



-- 高危技能列表

local highRiskSpells = {

    -- 高危物理技能 - 使用盾墙

    physical = {

        [1219482] = "裂隙利爪",

        [1235368] = "奥术猛袭",

        [1222341] = "幽暗之咬",

        [1237071] = "石拳",

        [1235766] = "致死打击",

        [322936] = "粉碎砸击",

        [352796] = "代理打击",

        [354297] = "凌光箭",

        [330586] = "吞噬血肉",

        [323515] = "仇恨打击",

        [324079] = "收割之镰",

        [469478] = "淤泥之爪",

        [465666] = "火花猛击",

        [448485] = "盾牌猛击",

        [448515] = "神圣审判",

        [349934] = "狂热鞭笞协议",

        [355477] = "强力脚踢",

        [355830] = "迅斩",

        [347716] = "开信刀",

        [473351] = "电气重碾",

        [459799] = "重击",

        [431491] = "污邪斩击",

        [438471] = "贪食撕咬",

        [433002] = "深掘打击",

        [1240912] = "穿刺",

        [350916] = "安保猛击",

        [359028] = "安保猛击",

        [346116] = "剪切挥舞",

        [355048] = "破壳猛击",

        [167385] = "强力猛击",

    },



    -- 高危法术技能 - 使用法术反射

    magical = {

        [473351] = "电气重碾", -- 电气重碾

        [448787] = "纯净",

        [465666] = "火花猛击",

        [451119] = "深渊轰击",

        [473114] = "泥石流",

        [423015] = "遣罚者之盾",

        [469478] = "淤泥之爪",

        [1222341] = "幽暗之咬",

        [427001] = "恐惧猛击",

        [466190] = "雷霆重拳",

        [328791] = "哀伤仪式",

        [167385] = "强力猛击",

    }

}



-- 检查循环版本更新

local function CheckRotationVersion()
    local lastRotationVersion = Aurora.Config:Read("MiracleWarrior.rotation_version") or "0"



    if lastRotationVersion ~= ROTATION_VERSION then
        print("=== MiracleWarrior 循环已更新 ===")

        print("版本: " .. ROTATION_VERSION)

        print("• 重构打断系统，严格遵循Aurora框架")

        print("• 分离拳击和硬控打断，独立开关控制")

        print("• 修复饰品卡循环问题")

        print("• 优化性能，避免频繁API调用")

        print("================================")

        Aurora.Config:Write("MiracleWarrior.rotation_version", ROTATION_VERSION)
    end
end



-- 从配置读取设置

local function GetConfig()
    return {

        -- 基础设置

        tauntEnabled = Aurora.Config:Read("MiracleWarrior.taunt.enabled") or true,

        spellReflectEnabled = Aurora.Config:Read("MiracleWarrior.spell_reflect.enabled") or true,

        ttdEnabled = Aurora.Config:Read("MiracleWarrior.ttd_enabled") or true,

        ttdThreshold = Aurora.Config:Read("MiracleWarrior.ttd_threshold") or 15,

        defensiveEnabled = Aurora.Config:Read("MiracleWarrior.defensive.enabled") or true,

        victoryRushEnabled = Aurora.Config:Read("MiracleWarrior.victory_rush_enabled") or true,

        rallyingCryEnabled = Aurora.Config:Read("MiracleWarrior.rallying_cry.enabled") or true,

        rageThreshold = Aurora.Config:Read("MiracleWarrior.rage_threshold") or 60,

        aoeThreshold = Aurora.Config:Read("MiracleWarrior.aoe_threshold") or 3,

        victoryRushHealth = Aurora.Config:Read("MiracleWarrior.victory_rush_health") or 60,

        rallyingCryHealth = Aurora.Config:Read("MiracleWarrior.rallying_cry_health") or 50,

        shieldWallHealth = Aurora.Config:Read("MiracleWarrior.shield_wall_health") or 70,

        lastStandHealth = Aurora.Config:Read("MiracleWarrior.last_stand_health") or 40,



        -- 打断设置

        interruptEnabled = Aurora.Config:Read("MiracleWarrior.interrupt_enabled") or true,

        hardControlInterruptEnabled = Aurora.Config:Read("MiracleWarrior.hard_control_interrupt_enabled") or true,

        randomInterrupt = Aurora.Config:Read("MiracleWarrior.random_interrupt") or true,

        minInterruptDelay = Aurora.Config:Read("MiracleWarrior.min_interrupt_delay") or 0,

        maxInterruptDelay = Aurora.Config:Read("MiracleWarrior.max_interrupt_delay") or 0.5,

        interruptCastPercent = Aurora.Config:Read("MiracleWarrior.interrupt_cast_percent") or 50,



        -- 功能设置

        battleShoutEnabled = Aurora.Config:Read("MiracleWarrior.battle_shout_enabled") or true,

        burstPotionMode = Aurora.Config:Read("MiracleWarrior.burst_potion_mode") or "cd",

        healPotionHealth = Aurora.Config:Read("MiracleWarrior.heal_potion_health") or 30,

        shieldChargeEnabled = Aurora.Config:Read("MiracleWarrior.shield_charge_enabled") or true,



        -- 饰品设置

        trinket1Mode = Aurora.Config:Read("MiracleWarrior.trinket1_mode") or "cd",

        trinket1HealthThreshold = Aurora.Config:Read("MiracleWarrior.trinket1_health_threshold") or 30,

        trinket2Mode = Aurora.Config:Read("MiracleWarrior.trinket2_mode") or "cd",

        trinket2HealthThreshold = Aurora.Config:Read("MiracleWarrior.trinket2_health_threshold") or 30,

        overpowerWait = Aurora.Config:Read("MiracleWarrior.overpower_wait") or 80,

        thunderPriority = Aurora.Config:Read("MiracleWarrior.thunder_priority") or "medium"

    }
end



-- 检查技能冷却

local function IsSkillOnCooldown(skillName)
    return skillCooldowns[skillName] and GetTime() < skillCooldowns[skillName]
end



-- 设置技能冷却

local function SetSkillCooldown(skillName, duration)
    skillCooldowns[skillName] = GetTime() + duration
end



-- TTD时间判断

local function ShouldUseLongCooldown()
    local config = GetConfig()

    if not config.ttdEnabled then
        return true
    end



    if target and target.exists and target.alive then
        local ttd = target.rawttd or 999

        if ttd < config.ttdThreshold then
            return false
        end
    end



    return true
end



-- 【修正】怒意迸发状态跟踪 - 100层=100%

local function GetOverpowerState()
    local overpowerStacks = player.auracount(auras.overpower.spellId) or 0

    local hasOverpowerBuff = player.aura(auras.overpower_buff.spellId) or false



    -- 修正：100层代表100%，计算百分比

    local overpowerProgress = (overpowerStacks / 100) * 100



    local config = GetConfig()

    local waitThreshold = config.overpowerWait or 80 -- 默认80%等待



    return {

        stacks = overpowerStacks,

        progress = overpowerProgress, -- 现在是正确的百分比

        hasBuff = hasOverpowerBuff,

        isReady = hasOverpowerBuff,

        nearReady = overpowerProgress >= waitThreshold, -- 使用配置的等待阈值

        shouldWaitForThunder = hasOverpowerBuff and spells.thunder_blast and spells.thunder_blast:getcd() <= 2

    }
end



-- 更新怒意迸发状态

local function UpdateRagingBlowState()
    local currentRage = player.rage or 0

    if lastRage > 0 then
        local rageUsed = lastRage - currentRage

        if rageUsed > 0 then
            rageConsumed = rageConsumed + rageUsed

            if rageConsumed >= 250 then
                ragingBlowReady = true

                rageConsumed = 0
            end
        end
    end



    lastRage = currentRage



    if ragingBlowReady then
        if (spells.thunder_clap and spells.thunder_clap:waslastcast(2)) or

            (spells.shield_slam and spells.shield_slam:waslastcast(2)) then
            ragingBlowReady = false
        end
    end
end



-- 【修复】智能饰品使用 - 避免卡循环

local function SmartTrinketUse()
    local config = GetConfig()

    local currentTime = GetTime()

    local usedTrinket = false



    -- 饰品1逻辑

    if config.trinket1Mode ~= "none" and currentTime > trinketCooldowns.trinket1 then
        local shouldUseTrinket1 = false



        -- 检查使用条件

        if config.trinket1Mode == "cd" then
            shouldUseTrinket1 = true
        elseif config.trinket1Mode == "avatar" and player.aura(spells.avatar.spellId) then
            shouldUseTrinket1 = true
        elseif config.trinket1Mode == "health" and player.hp < config.trinket1HealthThreshold then
            shouldUseTrinket1 = true
        end



        if shouldUseTrinket1 then
            local itemID = GetInventoryItemID("player", TRINKET_SLOTS.TRINKET1)

            if itemID and itemID > 0 then
                local trinket = Aurora.ItemHandler.NewItem(itemID)



                -- 检查饰品是否可用

                if trinket and trinket:ready() then
                    -- 对于只能对队友使用的饰品，检查是否有队友需要

                    if teamOnlyTrinkets[itemID] then
                        if player.group or player.raid then
                            -- 检查是否有队友血量低于阈值

                            local teammateNeedsHeal = false



                            if player.raid then
                                for i = 1, GetNumGroupMembers() do
                                    local unit = Aurora.UnitManager:Get("raid" .. i)

                                    if unit and unit.exists and unit.alive and unit.distanceto(player) <= 40 then
                                        if unit.hp < 80 then -- 队友血量低于80%
                                            teammateNeedsHeal = true

                                            break
                                        end
                                    end
                                end
                            elseif player.group then
                                for i = 1, GetNumGroupMembers() do
                                    local unit = Aurora.UnitManager:Get("party" .. i)

                                    if unit and unit.exists and unit.alive and unit.distanceto(player) <= 40 then
                                        if unit.hp < 80 then
                                            teammateNeedsHeal = true

                                            break
                                        end
                                    end
                                end
                            end



                            if teammateNeedsHeal then
                                usedTrinket = trinket:use(player) -- 对自身使用，效果作用于队友
                            end
                        end
                    else
                        -- 普通饰品，直接对自身使用

                        usedTrinket = trinket:use(player)
                    end



                    -- 无论使用成功与否，都设置冷却时间避免卡循环

                    trinketCooldowns.trinket1 = currentTime + 2
                end
            end
        end
    end



    -- 饰品2逻辑

    if not usedTrinket and config.trinket2Mode ~= "none" and currentTime > trinketCooldowns.trinket2 then
        local shouldUseTrinket2 = false



        if config.trinket2Mode == "cd" then
            shouldUseTrinket2 = true
        elseif config.trinket2Mode == "avatar" and player.aura(107574) then
            shouldUseTrinket2 = true
        elseif config.trinket2Mode == "health" and player.hp < config.trinket2HealthThreshold then
            shouldUseTrinket2 = true
        end



        if shouldUseTrinket2 then
            local itemID = GetInventoryItemID("player", TRINKET_SLOTS.TRINKET2)

            if itemID and itemID > 0 then
                local trinket = Aurora.ItemHandler.NewItem(itemID)



                if trinket and trinket:ready() then
                    -- 对于只能对队友使用的饰品，检查是否有队友需要

                    if teamOnlyTrinkets[itemID] then
                        if player.group or player.raid then
                            local teammateNeedsHeal = false



                            if player.raid then
                                for i = 1, GetNumGroupMembers() do
                                    local unit = Aurora.UnitManager:Get("raid" .. i)

                                    if unit and unit.exists and unit.alive and unit.distanceto(player) <= 40 then
                                        if unit.hp < 80 then
                                            teammateNeedsHeal = true

                                            break
                                        end
                                    end
                                end
                            elseif player.group then
                                for i = 1, GetNumGroupMembers() do
                                    local unit = Aurora.UnitManager:Get("party" .. i)

                                    if unit and unit.exists and unit.alive and unit.distanceto(player) <= 40 then
                                        if unit.hp < 80 then
                                            teammateNeedsHeal = true

                                            break
                                        end
                                    end
                                end
                            end



                            if teammateNeedsHeal then
                                usedTrinket = trinket:use(player)
                            end
                        end
                    else
                        usedTrinket = trinket:use(player)
                    end



                    trinketCooldowns.trinket2 = currentTime + 2
                end
            end
        end
    end



    return usedTrinket
end



-- 【完全重写】智能药水使用逻辑 - 简化版本

local function SmartPotionUse()
    local config = GetConfig()



    -- 检查爆发药水 - 卡CD使用

    if config.burstPotionMode ~= "none" then
        -- 按星级顺序检查药水

        local burstPotions = { potions.burst_3star, potions.burst_2star, potions.burst_1star }



        for _, potion in ipairs(burstPotions) do
            if potion then
                -- 直接检查药水是否可用

                if potion:ready() and potion:usable(player) then
                    local shouldUse = false



                    if config.burstPotionMode == "cd" then
                        shouldUse = true
                    end

                    if config.burstPotionMode == "avatar" and player.aura(107574) then
                        shouldUse = true
                    end



                    if shouldUse then
                        local success = potion:use(player)

                        if success then
                            return true
                        end
                    end
                end
            end
        end
    end



    -- 检查治疗药水 - 血量阈值使用

    if player.hp < config.healPotionHealth then
        local healPotions = { potions.heal_3star, potions.heal_2star, potions.heal_1star }



        for _, potion in ipairs(healPotions) do
            if potion then
                if potion:ready() and potion:usable(player) then
                    local success = potion:use(player)

                    if success then
                        return true
                    end
                end
            end
        end
    end



    return false
end



-- 打断状态跟踪表

local interruptTracker = {}

local lastInterruptTime = 0



-- 【重构】智能打断系统 - 严格遵循Aurora框架

local function SmartInterrupts()
    local config = GetConfig()

    if not config.interruptEnabled then
        return false
    end



    local currentTime = GetTime()



    -- 防止连续打断

    if currentTime - lastInterruptTime < 1 then
        return false
    end



    -- 使用Aurora框架维护的打断列表

    local interruptList = Aurora.Lists.InterruptSpells or {}



    -- 检查焦点目标

    local focusTarget = Aurora.UnitManager:Get("focus")

    if focusTarget and focusTarget.exists and focusTarget.casting and focusTarget.castinginterruptible then
        local castId = focusTarget.castingspellid

        if interruptList[castId] then
            -- 优先使用拳击打断

            if spells.pummel and spells.pummel:ready() and spells.pummel:castable(focusTarget) then
                if spells.pummel:cast(focusTarget) then
                    lastInterruptTime = currentTime

                    combatStats.interrupts = combatStats.interrupts + 1

                    return true
                end
            end
        end
    end



    -- 检查当前目标

    if target and target.exists and target.casting and target.castinginterruptible then
        local castId = target.castingspellid

        if interruptList[castId] then
            -- 优先使用拳击打断

            if spells.pummel and spells.pummel:ready() and spells.pummel:castable(target) then
                if spells.pummel:cast(target) then
                    lastInterruptTime = currentTime

                    combatStats.interrupts = combatStats.interrupts + 1

                    return true
                end
            end
        end
    end



    return false
end



-- 【重构】硬控打断系统 - 单独的开关控制

local function HardControlInterrupts()
    local config = GetConfig()

    if not config.hardControlInterruptEnabled then
        return false
    end



    local currentTime = GetTime()



    -- 防止连续打断

    if currentTime - lastInterruptTime < 1 then
        return false
    end



    -- 使用Aurora框架维护的打断列表

    local interruptList = Aurora.Lists.InterruptSpells or {}

    local enemiesCastingDangerous = {}



    -- 收集附近正在施放危险技能的敌人

    Aurora.enemies:within(15):each(function(enemy)
        if enemy.exists and enemy.casting and enemy.castinginterruptible and enemy.combat then
            local castId = enemy.castingspellid

            if interruptList[castId] then
                table.insert(enemiesCastingDangerous, enemy)
            end
        end
    end)



    if #enemiesCastingDangerous >= 1 then
        -- 优先使用震荡波（群体硬控）

        if spells.shockwave and spells.shockwave:ready() and spells.shockwave:castable(player) then
            local success = spells.shockwave:cast(player)

            if success then
                lastInterruptTime = currentTime

                combatStats.interrupts = combatStats.interrupts + 1

                return true
            end
        end



        -- 其次使用风暴之锤（单体硬控）

        if spells.storm_bolt and spells.storm_bolt:ready() then
            -- 对第一个危险敌人使用风暴之锤

            local firstDangerousEnemy = enemiesCastingDangerous[1]

            if firstDangerousEnemy and spells.storm_bolt:castable(firstDangerousEnemy) then
                local success = spells.storm_bolt:cast(firstDangerousEnemy)

                if success then
                    lastInterruptTime = currentTime

                    combatStats.interrupts = combatStats.interrupts + 1

                    return true
                end
            end
        end



        -- 最后使用挑战怒吼（群体硬控）

        if spells.challenging_shout and spells.challenging_shout:ready() and spells.challenging_shout:castable(player) then
            local success = spells.challenging_shout:cast(player)

            if success then
                lastInterruptTime = currentTime

                combatStats.interrupts = combatStats.interrupts + 1

                return true
            end
        end
    end



    return false
end



-- 【重构】整合打断系统

local function Interrupts()
    -- 先尝试普通打断（拳击）

    if SmartInterrupts() then
        return true
    end



    -- 再尝试硬控打断

    if HardControlInterrupts() then
        return true
    end



    return false
end



-- 【新增】高危技能预警和减伤

local function HighRiskSpellDefense()
    local config = GetConfig()

    if not config.defensiveEnabled then
        return false
    end



    local language = Aurora.Config:Read("MiracleWarrior.general.language") or "zh"



    -- 检查附近战斗中敌人

    Aurora.enemies:within(30):each(function(enemy)
        if enemy.exists and enemy.casting and enemy.combat then
            local castId = enemy.castingspellid



            -- 检查是否目标是我

            if enemy.target and enemy.target.guid == player.guid then
                -- 高危物理技能 - 使用盾墙

                if highRiskSpells.physical[castId] then
                    if spells.shield_wall and spells.shield_wall:ready() and spells.shield_wall:castable(player) then
                        -- 显示预警提示

                        local spellName = highRiskSpells.physical[castId] or "Unknown"

                        local message = language == "zh" and

                            "高危物理技能: " .. spellName .. "!" or

                            "High Risk Physical: " .. spellName .. "!"



                        Aurora.alert(message, 871) -- 盾墙图标

                        return spells.shield_wall:cast(player)
                    end
                end



                -- 高危法术技能 - 使用法术反射

                if highRiskSpells.magical[castId] then
                    if spells.spell_reflect and spells.spell_reflect:ready() and spells.spell_reflect:castable(player) then
                        -- 显示预警提示

                        local spellName = highRiskSpells.magical[castId] or "Unknown"

                        local message = language == "zh" and

                            "高危法术技能: " .. spellName .. "!" or

                            "High Risk Magical: " .. spellName .. "!"



                        Aurora.alert(message, 23920) -- 法术反射图标

                        return spells.spell_reflect:cast(player)
                    end
                end
            end
        end
    end)



    return false
end



-- 智能法术反射

local function SmartSpellReflect()
    local config = GetConfig()

    if not config.spellReflectEnabled or not spells.spell_reflect or not spells.spell_reflect:ready() then
        return false
    end



    local shouldReflect = false

    local reflectableSpells = {

        [473351] = "电气重碾", -- 电气重碾

        [448787] = "纯净",

        [465666] = "火花猛击",

        [451119] = "深渊轰击",

        [473114] = "泥石流",

        [423015] = "遣罚者之盾",

        [469478] = "淤泥之爪",

        [1222341] = "幽暗之咬",

        [427001] = "恐惧猛击",

        [466190] = "雷霆重拳",

        [328791] = "哀伤仪式",

        [167385] = "强力猛击",



    }



    Aurora.enemies:within(30):each(function(enemy)
        if enemy.casting and enemy.castinginterruptible then
            local castId = enemy.castingspellid

            if reflectableSpells[castId] then
                shouldReflect = true

                return true
            end
        end
    end)



    if shouldReflect then
        local success = spells.spell_reflect:cast(player)

        if success then
            combatStats.reflects = combatStats.reflects + 1
        end

        return success
    end



    return false
end



-- 智能英勇投掷

local function SmartHeroicThrow()
    if not spells.heroic_throw or not spells.heroic_throw:ready() then
        return false
    end



    if target.distanceto(player) > 8 and target.distanceto(player) <= 30 then
        if target.casting and target.castinginterruptible then
            return spells.heroic_throw:cast(target)
        end



        if target.hp < 10 then
            return spells.heroic_throw:cast(target)
        end
    end



    return false
end



-- 智能乘胜追击

local function SmartVictoryRush()
    local config = GetConfig()

    if not config.victoryRushEnabled or not spells.victory_rush or not spells.victory_rush:ready() then
        return false
    end



    if player.hp < config.victoryRushHealth then
        local success = spells.victory_rush:cast(target)

        if success then
            combatStats.victoryRushes = combatStats.victoryRushes + 1

            return true
        end
    end



    return false
end



-- 智能集结呐喊

local function SmartRallyingCry()
    local config = GetConfig()

    if not config.rallyingCryEnabled or not spells.rallying_cry or not spells.rallying_cry:ready() then
        return false
    end



    if not (player.group or player.raid) then
        return false
    end



    if IsSkillOnCooldown("rallying_cry") then
        return false
    end



    local totalHealth = 0

    local totalMembers = 0

    local lowHealthMembers = 0



    if player.raid then
        for i = 1, GetNumGroupMembers() do
            local unit = Aurora.UnitManager:Get("raid" .. i)

            if unit and unit.exists and unit.alive and unit.distanceto(player) <= 40 then
                totalHealth = totalHealth + unit.hp

                totalMembers = totalMembers + 1

                if unit.hp < config.rallyingCryHealth then
                    lowHealthMembers = lowHealthMembers + 1
                end
            end
        end
    elseif player.group then
        for i = 1, GetNumGroupMembers() do
            local unit = Aurora.UnitManager:Get("party" .. i)

            if unit and unit.exists and unit.alive and unit.distanceto(player) <= 40 then
                totalHealth = totalHealth + unit.hp

                totalMembers = totalMembers + 1

                if unit.hp < config.rallyingCryHealth then
                    lowHealthMembers = lowHealthMembers + 1
                end
            end
        end



        totalHealth = totalHealth + player.hp

        totalMembers = totalMembers + 1

        if player.hp < config.rallyingCryHealth then
            lowHealthMembers = lowHealthMembers + 1
        end
    end



    local averageHealth = totalMembers > 0 and (totalHealth / totalMembers) or 100



    if averageHealth < config.rallyingCryHealth or lowHealthMembers >= 3 then
        local success = spells.rallying_cry:cast(player)

        if success then
            combatStats.rallyingCries = combatStats.rallyingCries + 1

            SetSkillCooldown("rallying_cry", 180)

            return true
        end
    end



    return false
end



-- 【修正】智能挫志怒吼 - 卡CD使用，兼顾20%增伤 + 怒气生成

local function SmartDemoralizingShout()
    if not spells.demoralizing_shout or not spells.demoralizing_shout:ready() or not spells.demoralizing_shout:castable(player) then
        return false
    end



    if not (talents.booming_voice and talents.booming_voice:isknown()) then
        return false
    end



    -- 卡CD使用，提供20%增伤和怒气生成

    local enemyCount = player.enemiesaround(8) or 0

    if enemyCount >= 1 then
        local success = spells.demoralizing_shout:cast(player)

        if success and ShouldUseLongCooldown() then
            return true
        end
    end



    return false
end



-- 【修正】智能天神下凡 - 卡CD使用，不刻意留BOSS战

local function SmartAvatar()
    if not spells.avatar or not spells.avatar:ready() or not spells.avatar:castable(player) then
        return false
    end

    -- 山巅战循环启动关键，卡CD使用

    local success = spells.avatar:cast(player)

    if success and ShouldUseLongCooldown() then
        return true
    end



    return false
end



-- 【修正】毁灭者 - 卡CD使用，怒气 + 群体伤害双收益

local function SmartRavager()
    if not spells.Ravager or not spells.Ravager:ready() or not spells.Ravager:castable(player) then
        return false
    end



    -- 卡CD使用，提供怒气和群体伤害

    return spells.Ravager:cast(player)
end



-- 【新增】智能盾牌冲锋

local function SmartShieldCharge()
    local config = GetConfig()

    if not config.shieldChargeEnabled then
        return false
    end



    if not spells.shield_charge or not spells.shield_charge:ready() or not spells.shield_charge:castable(target) then
        return false
    end



    -- 只在目标距离合适时使用

    if target.distanceto(player) <= 4 then
        return spells.shield_charge:cast(target)
    end



    return false
end



-- 优化后的嘲讽功能

local function Taunt()
    local config = GetConfig()

    if not config.tauntEnabled then
        return false
    end



    if not (player.group or player.raid) then
        return false
    end



    local tauntTarget = nil

    Aurora.enemies:within(10):each(function(enemy)
        if tauntTarget then return true end



        if enemy.exists and enemy.alive and enemy.enemy then
            if enemy.target.exists and enemy.target.guid ~= player.guid then
                if enemy.target.friend and enemy.target.player then
                    if enemy.distanceto(player) <= 30 then
                        tauntTarget = enemy

                        return true
                    end
                end
            end
        end
    end)



    if tauntTarget then
        if spells.taunt and spells.taunt:ready() and spells.taunt:castable(tauntTarget) then
            local success = spells.taunt:cast(tauntTarget)

            if success then
                combatStats.taunts = combatStats.taunts + 1
            end

            return success
        end
    end



    return false
end



-- 增强减伤技能链 - 修复盾墙CD问题并添加起手盾墙

local function EnhancedDefensiveChain()
    local config = GetConfig()

    if not config.defensiveEnabled then
        return false
    end



    -- 最高优先级：盾牌格挡全程覆盖

    if spells.shield_block and spells.shield_block:ready() and spells.shield_block:castable(player) then
        local shieldBlockRemaining = player.auraremains(auras.shield_block_buff.spellId) or 0



        if shieldBlockRemaining <= 2 or not player.aura(auras.shield_block_buff.spellId) then
            if spells.shield_block:cast(player) then
                shieldBlockTracker.lastCastTime = GetTime()

                return true
            end
        end
    end



    -- 【新增】起手阶段：战斗时间小于3秒时使用盾墙

    if player.timecombat < 3 then
        if spells.shield_wall and spells.shield_wall:ready() and spells.shield_wall:castable(player) and not player.aura(871) then
            -- 显示起手提示

            local language = Aurora.Config:Read("MiracleWarrior.general.language") or "zh"

            local message = language == "zh" and "起手盾墙!" or "Opening Shield Wall!"



            Aurora.alert(message, 871) -- 盾墙图标



            if spells.shield_wall:cast(player) then
                return true
            end
        end
    end



    -- 无视苦痛 - 基于怒气管理

    if spells.ignore_pain and spells.ignore_pain:ready() and spells.ignore_pain:castable(player) then
        local currentRage = player.rage or 0

        if currentRage >= config.rageThreshold then
            if spells.ignore_pain:cast(player) then
                return true
            end
        end
    end



    -- 【修复】盾墙CD问题 - 完全移除CD检查

    -- 极度危险：血量低于破釜沉舟阈值

    if player.hp < config.lastStandHealth then
        if spells.last_stand and spells.last_stand:ready() and spells.last_stand:castable(player) then
            if not IsSkillOnCooldown("last_stand") then
                local success = spells.last_stand:cast(player)

                if success then
                    SetSkillCooldown("last_stand", 180)

                    return true
                end
            end
        end



        -- 盾墙：移除CD检查，只检查技能是否可用

        if spells.shield_wall and spells.shield_wall:ready() and spells.shield_wall:castable(player) and not player.aura(871) then
            if spells.shield_wall:cast(player) then
                return true
            end
        end
    end



    -- 中度危险：血量低于盾墙阈值

    if player.hp < config.shieldWallHealth then
        -- 盾墙：移除CD检查，只检查技能是否可用

        if spells.shield_wall and spells.shield_wall:ready() and spells.shield_wall:castable(player) and not player.aura(871) then
            if spells.shield_wall:cast(player) then
                return true
            end
        end
    end



    return false
end



-- 战斗数据统计

local function RecordCombatStats()
    if not player.combat then
        if combatStats.startTime > 0 then
            local combatDuration = GetTime() - combatStats.startTime

            if combatDuration > 10 then
                print(string.format("战斗统计 - 持续时间: %.1f秒, 打断: %d次, 嘲讽: %d次, 反射: %d次, 乘胜追击: %d次, 集结呐喊: %d次",

                    combatDuration, combatStats.interrupts, combatStats.taunts, combatStats.reflects,
                    combatStats.victoryRushes, combatStats.rallyingCries))
            end

            combatStats.startTime = 0

            combatStats.interrupts = 0

            combatStats.taunts = 0

            combatStats.reflects = 0

            combatStats.victoryRushes = 0

            combatStats.rallyingCries = 0
        end

        return
    end



    if combatStats.startTime == 0 then
        combatStats.startTime = GetTime()

        combatStats.interrupts = 0

        combatStats.taunts = 0

        combatStats.reflects = 0

        combatStats.victoryRushes = 0

        combatStats.rallyingCries = 0
    end
end



-- 智能雷霆一击释放判断

local function SmartThunderClap()
    if not spells.thunder_clap or not spells.thunder_clap:ready() or not spells.thunder_clap:castable(player) then
        return false
    end



    if target.distanceto(player) > 8 then
        return false
    end



    local overpowerState = GetOverpowerState()

    local hasSevereThunder = player.aura(SEVERE_THUNDER_BUFF)

    local hasThunderBlast = spells.thunder_blast and spells.thunder_blast:ready()

    local hasAvatar = player.aura(spells.avatar.spellId)

    local hasDemoralizing = player.aura(spells.demoralizing_shout.spellId)

    local inBurstPhase = hasAvatar and hasDemoralizing



    -- 优先级1：套装雷霆 + 怒意迸发（最高收益）

    if hasSevereThunder and overpowerState.isReady then
        if spells.thunder_blast and spells.thunder_blast:ready() and spells.thunder_blast:castable(player) then
            return spells.thunder_clap:cast(player)
        end
    end



    -- 优先级2：套装雷霆（即使没有怒意也要立即使用）

    if hasSevereThunder then
        if spells.thunder_blast and spells.thunder_blast:ready() and spells.thunder_blast:castable(player) then
            return spells.thunder_clap:cast(player)
        end
    end



    -- 优先级3：怒意迸发 + 雷霆轰击即将冷却完成（等待机制）

    if overpowerState.isReady and overpowerState.shouldWaitForThunder then
        return false
    end



    -- 优先级4：怒意迸发 + 大雷霆 + 爆发阶段

    if overpowerState.isReady and hasThunderBlast and inBurstPhase then
        return spells.thunder_clap:cast(player)
    end



    -- 优先级5：怒意迸发 + 大雷霆

    if overpowerState.isReady and hasThunderBlast then
        return spells.thunder_clap:cast(player)
    end



    -- 优先级6：大雷霆 + 爆发阶段

    if hasThunderBlast and inBurstPhase then
        return spells.thunder_clap:cast(player)
    end



    -- 优先级7：怒意迸发 + 普通雷霆（避免浪费）

    if overpowerState.isReady and not hasThunderBlast then
        return spells.thunder_clap:cast(player)
    end



    -- 优先级8：大雷霆可用

    if hasThunderBlast then
        return spells.thunder_clap:cast(player)
    end



    -- 优先级9：普通雷霆一击

    return spells.thunder_clap:cast(player)
end



-- 智能盾牌猛击

local function SmartShieldSlam()
    local overpowerState = GetOverpowerState()

    local hasSevereThunder = player.aura(SEVERE_THUNDER_BUFF)



    if not spells.shield_slam or not spells.shield_slam:ready() or not spells.shield_slam:castable(target) then
        return false
    end



    if hasSevereThunder and overpowerState.isReady then
        return false
    end



    if overpowerState.isReady and overpowerState.shouldWaitForThunder then
        return false
    end



    if spells.shield_slam:cast(target) then
        return true
    end



    return false
end



-- 自动战斗怒吼

local function SmartBattleShout()
    local config = GetConfig()

    if not config.battleShoutEnabled or not spells.Battle_Shout or not spells.Battle_Shout:ready() then
        return false
    end







    if not (player.group or player.raid) then
        return false
    end



    local hasBattleShout = player.aura(spells.Battle_Shout.spellId)

    if hasBattleShout then
        return false
    end



    local needsBattleShout = false

    if player.raid then
        for i = 1, GetNumGroupMembers() do
            local unit = Aurora.UnitManager:Get("raid" .. i)

            if unit and unit.exists and unit.alive and unit.distanceto(player) <= 40 then
                if not unit.aura(spells.Battle_Shout.spellId) then
                    needsBattleShout = true

                    break
                end
            end
        end
    elseif player.group then
        for i = 1, GetNumGroupMembers() do
            local unit = Aurora.UnitManager:Get("party" .. i)

            if unit and unit.exists and unit.alive and unit.distanceto(player) <= 40 then
                if not unit.aura(spells.Battle_Shout.spellId) then
                    needsBattleShout = true

                    break
                end
            end
        end



        if not player.aura(spells.Battle_Shout.spellId) then
            needsBattleShout = true
        end
    end



    if needsBattleShout then
        local success = spells.Battle_Shout:cast(player)

        if success then
            return true
        end
    end



    return false
end



-- 主战斗循环

local function Dps()
    RecordCombatStats()

    UpdateRagingBlowState()



    -- 最高优先级：高危技能防御

    if HighRiskSpellDefense() then
        return true
    end



    -- 第二优先级：减伤链

    if EnhancedDefensiveChain() then
        return true
    end



    -- 第三优先级：药水使用

    if SmartPotionUse() then
        return true
    end



    -- 第四优先级：饰品使用

    if SmartTrinketUse() then
        return true
    end



    -- 第五优先级：进攻冷却技能 - 卡CD使用

    if Aurora.Rotation.Cooldown:GetValue() then
        -- 毁灭者 - 卡CD使用

        if SmartRavager() then
            return true
        end



        -- 天神下凡 - 卡CD使用，不刻意留BOSS战

        if SmartAvatar() then
            return true
        end



        -- 挫志怒吼 - 卡CD使用，20%增伤 + 怒气生成

        if SmartDemoralizingShout() then
            return true
        end
    end



    -- 第六优先级：集结呐喊

    if SmartRallyingCry() then
        return true
    end



    -- 第七优先级：乘胜追击治疗

    if SmartVictoryRush() then
        return true
    end



    -- 第八优先级：法术反射

    if SmartSpellReflect() then
        return true
    end



    -- 第九优先级：嘲讽保护队友

    if Taunt() then
        return true
    end



    -- 第十优先级：打断关键法术

    if Interrupts() then
        return true
    end



    -- 第十一优先级：智能雷霆一击

    if SmartThunderClap() then
        return true
    end



    --新增优先级：智能盾猛



    if SmartShieldSlam() then
        return true
    end





    -- 第十二优先级：英勇投掷

    if SmartHeroicThrow() then
        return true
    end



    -- 第十三优先级：盾牌冲锋（受开关控制）

    if SmartShieldCharge() then
        return true
    end



    -- 输出循环

    if spells.AutoAttack and spells.AutoAttack:ready() and spells.AutoAttack:castable(target) then
        if spells.AutoAttack:cast(target) then
            return true
        end
    end



    if spells.Champions_spear and spells.Champions_spear:ready() and spells.Champions_spear:castable(target) then
        if target.distanceto(player) <= 25 then
            if spells.Champions_spear:cast(target) then
                return true
            end
        end
    end



    if spells.demolish and spells.demolish:ready() and spells.demolish:castable(player) then
        if spells.demolish:cast(player) then
            return true
        end
    end



    if spells.thunderous_roar and spells.thunderous_roar:ready() and spells.thunderous_roar:castable(player) then
        if target.distanceto(player) <= 12 then
            if spells.thunderous_roar:cast(player) then
                return true
            end
        end
    end



    local config = GetConfig()

    if spells.ignore_pain and spells.ignore_pain:ready() and spells.ignore_pain:castable(player) then
        if player.rage >= config.rageThreshold then
            if spells.ignore_pain:cast(player) then
                return true
            end
        end
    end



    if spells.revenge and spells.revenge:ready() and spells.revenge:castable(player) then
        if spells.revenge:cast(player) then
            return true
        end
    end



    return false
end



local function Ooc()
    lastRage = player.rage

    rageConsumed = 0

    ragingBlowReady = false



    if not player.combat and SmartBattleShout() then
        return true
    end



    if not player.aura(386208) then
        if spells.Defensive_Stance and spells.Defensive_Stance:ready() and spells.Defensive_Stance:castable(player) then
            spells.Defensive_Stance:cast(player)
        end
    end
end



-- Register the rotation

Aurora:RegisterRoutine(function()
    if player.dead or player.aura("Food") or player.aura("Drink") then
        return
    end



    if player.combat then
        Dps()
    else
        Ooc()
    end
end, "WARRIOR", 3, "MiracleWarrior")



-- 检查循环版本

CheckRotationVersion()

print("MiracleWarrior " .. ROTATION_VERSION .. " 循环已加载!")

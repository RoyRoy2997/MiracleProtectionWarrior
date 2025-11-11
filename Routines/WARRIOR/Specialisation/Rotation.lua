-- MiracleWarrior 主循环



-- 获取常用单位

local target = Aurora.UnitManager:Get("target")

local player = Aurora.UnitManager:Get("player")



-- 获取你的法术书

local spells = Aurora.SpellHandler.Spellbooks.warrior["3"].MiracleWarrior.spells

local auras = Aurora.SpellHandler.Spellbooks.warrior["3"].MiracleWarrior.auras

local talents = Aurora.SpellHandler.Spellbooks.warrior["3"].MiracleWarrior.talents



-- 版本信息

local ROTATION_VERSION = "2.1.2"



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



-- 只能对队友使用的饰品列表

local teamOnlyTrinkets = {

    [12345] = true, -- 示例：治疗饰品1

    [12346] = true, -- 示例：治疗饰品2

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

        [473351] = "电气重碾",

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



-- 【新增】石像形态触发的光环列表

local stoneformAuras = {

    [347716] = "开信刀", -- 请替换为实际需要石像形态解除的debuff ID



    -- 添加更多需要石像形态解除的debuff ID

}



-- 【核心修复】直接的状态栏检查函数

local function IsToggleEnabled(toggleName)
    if not Aurora.Rotation[toggleName] then
        return true -- 如果状态栏未加载，默认启用
    end

    return Aurora.Rotation[toggleName]:GetValue()
end



-- 【核心修复】简化的配置获取 - 直接从状态栏读取

local function GetToggleState()
    return {

        tauntEnabled = IsToggleEnabled("TauntToggle"),

        defensiveEnabled = IsToggleEnabled("DefensiveToggle"),

        spellReflectEnabled = IsToggleEnabled("SpellReflectToggle"),

        victoryRushEnabled = IsToggleEnabled("VictoryRushToggle"),

        rallyingCryEnabled = IsToggleEnabled("RallyingCryToggle"),

        shieldChargeEnabled = IsToggleEnabled("ShieldChargeToggle"),

        hardControlInterruptEnabled = IsToggleEnabled("HardControlInterruptToggle"),

        demoralizingShoutEnabled = IsToggleEnabled("DemoralizingShoutToggle") -- 新增挫志怒吼状态栏控制

    }
end



-- 检查循环版本更新

local function CheckRotationVersion()
    local lastRotationVersion = Aurora.Config:Read("MiracleWarrior.rotation_version") or "0"



    if lastRotationVersion ~= ROTATION_VERSION then
        print("=== MiracleWarrior 循环已更新 ===")

        print("版本: " .. ROTATION_VERSION)

        print("• 优化TTD判断逻辑")

        print("• 使用团队感知的冷却技能判断")

        print("• 修复非战斗状态冷却技能逻辑")

        print("================================")

        Aurora.Config:Write("MiracleWarrior.rotation_version", ROTATION_VERSION)
    end
end



-- 检查技能冷却

local function IsSkillOnCooldown(skillName)
    return skillCooldowns[skillName] and GetTime() < skillCooldowns[skillName]
end



-- 设置技能冷却

local function SetSkillCooldown(skillName, duration)
    skillCooldowns[skillName] = GetTime() + duration
end



-- 【优化】使用rawttd的准确TTD函数

local function UnitTimeToDie(unit, percentage)
    percentage = percentage or 0



    if not unit or not unit.exists or not unit.alive then
        return 0
    end



    -- 如果是玩家或训练假人，返回很大的值

    if unit.player or unit.isdummy then
        return 8888
    end



    -- 使用Aurora框架内置的rawttd属性 - 对BOSS也返回准确值

    local baseTTD = unit.rawttd or 0



    -- 如果rawttd不可用，使用备用计算

    if baseTTD <= 0 or baseTTD >= 999 then
        -- 备用计算：基于当前血量和预估DPS

        local healthRemaining = unit.health - (unit.healthmax * percentage / 100)

        if healthRemaining <= 0 then
            return 0
        end



        -- 估算DPS：基于玩家装备等级和战斗状态

        local estimatedDPS = 0

        if player.combat then
            -- 基础DPS估算：装备等级 * 系数

            local itemLevel = player.itemlevel or 500

            estimatedDPS = itemLevel * 1.2 -- 调整系数



            -- 根据专精调整

            if player.spec == 3 then              -- 防护战士
                estimatedDPS = estimatedDPS * 0.7 -- 坦克DPS较低
            end



            -- 根据敌人数量调整

            local enemyCount = player.enemiesaround(8) or 1

            if enemyCount > 1 then
                estimatedDPS = estimatedDPS * (0.6 + 0.4 * enemyCount)
            end
        else
            -- 非战斗状态返回0，不应该使用长冷却技能

            return 0
        end



        baseTTD = healthRemaining / math.max(estimatedDPS, 1)
    end



    -- 应用修正系数

    local conservativeTTD = baseTTD * 1.15 -- 稍微保守一点



    return math.min(math.max(conservativeTTD, 0.5), 8888)
end



-- 【优化】基于团队综合状态的TTD判断

local function ShouldUseLongCooldownTeamAware()
    -- 从配置读取TTD设置

    local ttdEnabled = Aurora.Config:Read("MiracleWarrior.ttd_enabled")

    local ttdThreshold = Aurora.Config:Read("MiracleWarrior.ttd_threshold") or 15



    -- 如果TTD判断被禁用，直接返回true

    if ttdEnabled == false then
        return true
    end



    -- 非战斗状态不应该使用长冷却技能

    if not player.combat then
        return false
    end



    -- 如果没有目标，检查是否有任何敌人

    local hasValidTarget = false

    local longestTTD = 0



    -- 检查当前目标

    if target and target.exists and target.alive then
        hasValidTarget = true

        longestTTD = UnitTimeToDie(target, 0)
    end



    -- 如果没有有效目标，检查附近的其他敌人

    if not hasValidTarget then
        Aurora.enemies:within(40):each(function(enemy)
            if enemy.exists and enemy.alive then
                hasValidTarget = true

                local enemyTTD = UnitTimeToDie(enemy, 0)

                if enemyTTD > longestTTD then
                    longestTTD = enemyTTD
                end
            end
        end)
    end



    -- 如果有有效目标且最长TTD大于阈值，可以使用长冷却技能

    if hasValidTarget and longestTTD > ttdThreshold then
        return true
    end



    -- 没有有效目标或TTD不足

    return false
end



-- 【完全重写】怒意迸发状态跟踪

local function GetOverpowerState()
    local overpowerStacks = player.auracount(386486) or 0

    local hasOverpowerBuff = player.aura(386478) or false

    local progress = (overpowerStacks / 100) * 100



    return {

        stacks = overpowerStacks,

        progress = progress,

        hasBuff = hasOverpowerBuff,

        isReady = hasOverpowerBuff

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



-- 智能饰品使用

local function SmartTrinketUse()
    local trinket1Mode = Aurora.Config:Read("MiracleWarrior.trinket1_mode") or "cd"

    local trinket2Mode = Aurora.Config:Read("MiracleWarrior.trinket2_mode") or "cd"

    local currentTime = GetTime()

    local usedTrinket = false



    -- 饰品1逻辑

    if trinket1Mode ~= "none" and currentTime > trinketCooldowns.trinket1 then
        local shouldUseTrinket1 = false



        if trinket1Mode == "cd" then
            shouldUseTrinket1 = true
        elseif trinket1Mode == "avatar" and player.aura(107574) then
            shouldUseTrinket1 = true
        elseif trinket1Mode == "health" then
            local healthThreshold = Aurora.Config:Read("MiracleWarrior.trinket1_health_threshold") or 30

            if player.hp < healthThreshold then
                shouldUseTrinket1 = true
            end
        end



        if shouldUseTrinket1 then
            local itemID = GetInventoryItemID("player", TRINKET_SLOTS.TRINKET1)

            if itemID and itemID > 0 then
                local trinket = Aurora.ItemHandler.NewItem(itemID)

                if trinket and trinket:ready() then
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



                    trinketCooldowns.trinket1 = currentTime + 2
                end
            end
        end
    end



    -- 饰品2逻辑

    if not usedTrinket and trinket2Mode ~= "none" and currentTime > trinketCooldowns.trinket2 then
        local shouldUseTrinket2 = false



        if trinket2Mode == "cd" then
            shouldUseTrinket2 = true
        elseif trinket2Mode == "avatar" and player.aura(107574) then
            shouldUseTrinket2 = true
        elseif trinket2Mode == "health" then
            local healthThreshold = Aurora.Config:Read("MiracleWarrior.trinket2_health_threshold") or 30

            if player.hp < healthThreshold then
                shouldUseTrinket2 = true
            end
        end



        if shouldUseTrinket2 then
            local itemID = GetInventoryItemID("player", TRINKET_SLOTS.TRINKET2)

            if itemID and itemID > 0 then
                local trinket = Aurora.ItemHandler.NewItem(itemID)

                if trinket and trinket:ready() then
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



-- 智能药水使用逻辑

local function SmartPotionUse()
    local burstPotionMode = Aurora.Config:Read("MiracleWarrior.burst_potion_mode") or "cd"

    local healPotionHealth = Aurora.Config:Read("MiracleWarrior.heal_potion_health") or 30



    -- 检查爆发药水

    if burstPotionMode ~= "none" then
        local burstPotions = { potions.burst_3star, potions.burst_2star, potions.burst_1star }



        for _, potion in ipairs(burstPotions) do
            if potion then
                if potion:ready() and potion:usable(player) then
                    local shouldUse = false



                    if burstPotionMode == "cd" then
                        shouldUse = true
                    elseif burstPotionMode == "avatar" and player.aura(107574) then
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



    -- 检查治疗药水

    if player.hp < healPotionHealth then
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



-- 智能打断系统

local function SmartInterrupts()
    local toggles = GetToggleState()

    -- 打断功能现在由状态栏控制

    if not toggles.hardControlInterruptEnabled then
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



-- 【强制检查】硬控打断系统 - 直接使用状态栏控制

local function HardControlInterrupts()
    local toggles = GetToggleState()

    if not toggles.hardControlInterruptEnabled then
        return false
    end



    local currentTime = GetTime()



    -- 防止连续打断

    if currentTime - lastInterruptTime < 1 then
        return false
    end



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
    end



    return false
end



-- 整合打断系统

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



-- 【整合】智能法术反射 - 统一在智能减伤中处理

local function SmartSpellReflect()
    local toggles = GetToggleState()

    if not toggles.spellReflectEnabled then
        return false
    end



    if not spells.spell_reflect or not spells.spell_reflect:ready() then
        return false
    end



    local shouldReflect = false

    local reflectableSpells = {

        [473351] = true,

        [448787] = true,

        [465666] = true,

        [451119] = true,

        [473114] = true,

        [423015] = true,

        [469478] = true,

        [1222341] = true,

        [427001] = true,

        [466190] = true,

        [328791] = true,

        [167385] = true

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



-- 【新增】智能石像形态

local function SmartStoneform()
    if not spells.Stoneform or not spells.Stoneform:ready() or not spells.Stoneform:castable(player) then
        return false
    end



    -- 检查玩家是否有需要石像形态解除的debuff

    for auraId, auraName in pairs(stoneformAuras) do
        if player.aura(auraId) then
            local success = spells.Stoneform:cast(player)

            if success then
                Aurora.alert("使用石像形态解除: " .. auraName, 20594)

                return true
            end
        end
    end



    return false
end



-- 【整合】高危技能预警和减伤 - 整合法术反射和新增石像形态

local function HighRiskSpellDefense()
    local toggles = GetToggleState()

    if not toggles.defensiveEnabled then
        return false
    end



    -- 首先检查石像形态

    if SmartStoneform() then
        return true
    end



    -- 检查附近战斗中敌人

    Aurora.enemies:within(30):each(function(enemy)
        if enemy.exists and enemy.casting and enemy.combat then
            local castId = enemy.castingspellid



            -- 检查是否目标是我

            if enemy.target and enemy.target.guid == player.guid then
                -- 高危物理技能 - 使用盾墙

                if highRiskSpells.physical[castId] then
                    if spells.shield_wall and spells.shield_wall:ready() and spells.shield_wall:castable(player) then
                        local spellName = highRiskSpells.physical[castId] or "Unknown"

                        Aurora.alert("高危物理技能: " .. spellName .. "!", 871)

                        return spells.shield_wall:cast(player)
                    end
                end



                -- 高危法术技能 - 使用法术反射

                if highRiskSpells.magical[castId] then
                    if toggles.spellReflectEnabled then
                        if spells.spell_reflect and spells.spell_reflect:ready() and spells.spell_reflect:castable(player) then
                            local spellName = highRiskSpells.magical[castId] or "Unknown"

                            Aurora.alert("高危法术技能: " .. spellName .. "!", 23920)

                            local success = spells.spell_reflect:cast(player)

                            if success then
                                combatStats.reflects = combatStats.reflects + 1
                            end

                            return success
                        end
                    end
                end
            end
        end
    end)



    return false
end



-- 智能英勇投掷

local function SmartHeroicThrow()
    if not spells.heroic_throw or not spells.heroic_throw:ready() then
        return false
    end



    if target.distanceto(player) > 8 and target.distanceto(player) <= 30 then
        return spells.heroic_throw:cast(target)
    end



    return false
end



-- 【强制检查】智能乘胜追击 - 直接使用状态栏控制

local function SmartVictoryRush()
    local toggles = GetToggleState()

    if not toggles.victoryRushEnabled then
        return false
    end



    if not spells.victory_rush or not spells.victory_rush:ready() then
        return false
    end



    local victoryRushHealth = Aurora.Config:Read("MiracleWarrior.victory_rush_health") or 60



    if player.hp < victoryRushHealth then
        local success = spells.victory_rush:cast(target)

        if success then
            combatStats.victoryRushes = combatStats.victoryRushes + 1

            return true
        end
    end



    return false
end



-- 【强制检查】智能集结呐喊 - 直接使用状态栏控制

local function SmartRallyingCry()
    local toggles = GetToggleState()

    if not toggles.rallyingCryEnabled then
        return false
    end



    if not spells.rallying_cry or not spells.rallying_cry:ready() then
        return false
    end



    if not (player.group or player.raid) then
        return false
    end



    if IsSkillOnCooldown("rallying_cry") then
        return false
    end



    local rallyingCryHealth = Aurora.Config:Read("MiracleWarrior.rallying_cry_health") or 50



    local totalHealth = 0

    local totalMembers = 0

    local lowHealthMembers = 0



    if player.raid then
        for i = 1, GetNumGroupMembers() do
            local unit = Aurora.UnitManager:Get("raid" .. i)

            if unit and unit.exists and unit.alive and unit.distanceto(player) <= 40 then
                totalHealth = totalHealth + unit.hp

                totalMembers = totalMembers + 1

                if unit.hp < rallyingCryHealth then
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

                if unit.hp < rallyingCryHealth then
                    lowHealthMembers = lowHealthMembers + 1
                end
            end
        end



        totalHealth = totalHealth + player.hp

        totalMembers = totalMembers + 1

        if player.hp < rallyingCryHealth then
            lowHealthMembers = lowHealthMembers + 1
        end
    end



    local averageHealth = totalMembers > 0 and (totalHealth / totalMembers) or 100



    if averageHealth < rallyingCryHealth or lowHealthMembers >= 3 then
        local success = spells.rallying_cry:cast(player)

        if success then
            combatStats.rallyingCries = combatStats.rallyingCries + 1

            SetSkillCooldown("rallying_cry", 180)

            return true
        end
    end



    return false
end



-- 【修改】智能挫志怒吼 - 添加状态栏控制

local function SmartDemoralizingShout()
    local toggles = GetToggleState()

    if not toggles.demoralizingShoutEnabled then
        return false
    end



    if not spells.demoralizing_shout or not spells.demoralizing_shout:ready() or not spells.demoralizing_shout:castable(player) then
        return false
    end



    if not (talents.booming_voice and talents.booming_voice:isknown()) then
        return false
    end



    local enemyCount = player.enemiesaround(8) or 0

    if enemyCount >= 1 then
        if ShouldUseLongCooldownTeamAware() then
            spells.demoralizing_shout:cast(player)

            return true
        end
    end



    return false
end



-- 智能天神下凡

local function SmartAvatar()
    if not spells.avatar or not spells.avatar:ready() or not spells.avatar:castable(player) then
        return false
    end



    if ShouldUseLongCooldownTeamAware() then
        spells.avatar:cast(player)

        return true
    end



    return false
end



-- 毁灭者

local function SmartRavager()
    if not spells.Ravager or not spells.Ravager:ready() or not spells.Ravager:castable(player) then
        return false
    end

    if ShouldUseLongCooldownTeamAware() then
        return spells.Ravager:cast(player)
    end
end



-- 【强制检查】智能盾牌冲锋 - 直接使用状态栏控制

local function SmartShieldCharge()
    local toggles = GetToggleState()

    if not toggles.shieldChargeEnabled then
        return false
    end



    if not spells.shield_charge or not spells.shield_charge:ready() or not spells.shield_charge:castable(target) then
        return false
    end



    if target.distanceto(player) <= 4 then
        return spells.shield_charge:cast(target)
    end



    return false
end



-- 【强制检查】智能嘲讽 - 直接使用状态栏控制

local function Taunt()
    local toggles = GetToggleState()

    if not toggles.tauntEnabled then
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



-- 【强制检查】增强减伤技能链 - 直接使用状态栏控制

local function EnhancedDefensiveChain()
    local toggles = GetToggleState()

    if not toggles.defensiveEnabled then
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



    -- 无视苦痛 - 基于怒气管理

    if spells.ignore_pain and spells.ignore_pain:ready() and spells.ignore_pain:castable(player) then
        local rageThreshold = Aurora.Config:Read("MiracleWarrior.rage_threshold") or 60

        local currentRage = player.rage or 0

        if currentRage >= rageThreshold then
            if spells.ignore_pain:cast(player) then
                return true
            end
        end
    end



    -- 盾墙和破釜沉舟

    local shieldWallHealth = Aurora.Config:Read("MiracleWarrior.shield_wall_health") or 70

    local lastStandHealth = Aurora.Config:Read("MiracleWarrior.last_stand_health") or 40



    -- 极度危险：血量低于破釜沉舟阈值

    if player.hp < lastStandHealth then
        if spells.last_stand and spells.last_stand:ready() and spells.last_stand:castable(player) then
            if not IsSkillOnCooldown("last_stand") then
                local success = spells.last_stand:cast(player)

                if success then
                    SetSkillCooldown("last_stand", 180)

                    return true
                end
            end
        end



        if spells.shield_wall and spells.shield_wall:ready() and spells.shield_wall:castable(player) then
            if spells.shield_wall:cast(player) then
                return true
            end
        end
    end



    -- 中度危险：血量低于盾墙阈值

    if player.hp < shieldWallHealth then
        if spells.shield_wall and spells.shield_wall:ready() and spells.shield_wall:castable(player) then
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



-- 智能雷霆一击

local function SmartThunderClap()
    if not spells.thunder_clap or not spells.thunder_clap:ready() or not spells.thunder_clap:castable(player) then
        return false
    end



    if target.distanceto(player) > 8 then
        return false
    end



    local overpowerState = GetOverpowerState()

    local hasSevereThunder = player.aura(1252096)



    if overpowerState.isReady then
        return spells.thunder_clap:cast(player)
    end



    if hasSevereThunder then
        return spells.thunder_clap:cast(player)
    end



    local enemyCount = player.enemiesaround(8) or 0

    if enemyCount >= 1 then
        return spells.thunder_clap:cast(player)
    end



    return false
end



-- 智能盾牌猛击

local function SmartShieldSlam()
    if not spells.shield_slam or not spells.shield_slam:ready() or not spells.shield_slam:castable(target) then
        return false
    end



    return spells.shield_slam:cast(target)
end



-- 自动战斗怒吼

local function SmartBattleShout()
    local battleShoutEnabled = Aurora.Config:Read("MiracleWarrior.battle_shout_enabled") or true



    if not battleShoutEnabled then
        return false
    end



    if not spells.Battle_Shout or not spells.Battle_Shout:ready() then
        return false
    end



    if player.combat then
        return false
    end



    if not player.aura(6673) then
        return spells.Battle_Shout:cast(player)
    end



    return false
end



-- 主战斗循环

local function Dps()
    RecordCombatStats()

    UpdateRagingBlowState()



    -- 最高优先级：高危技能防御（已整合法术反射和石像形态）

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



    -- 第五优先级：进攻冷却技能

    if Aurora.Rotation.Cooldown:GetValue() then
        if SmartRavager() then
            return true
        end



        if SmartAvatar() then
            return true
        end



        if SmartDemoralizingShout() then
            return true
        end



        if spells.thunderous_roar and spells.thunderous_roar:ready() and spells.thunderous_roar:castable(player) then
            if target.distanceto(player) <= 12 and ShouldUseLongCooldownTeamAware() then
                if spells.thunderous_roar:cast(player) then
                    return true
                end
            end
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



    -- 第八优先级：嘲讽保护队友

    if Taunt() then
        return true
    end



    -- 第九优先级：打断关键法术

    if Interrupts() then
        return true
    end



    -- 第十优先级：智能雷霆一击

    if SmartThunderClap() then
        return true
    end



    -- 第十一优先级：智能盾猛

    if SmartShieldSlam() then
        return true
    end



    -- 第十二优先级：英勇投掷

    if SmartHeroicThrow() then
        return true
    end



    -- 第十三优先级：盾牌冲锋

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



    local rageThreshold = Aurora.Config:Read("MiracleWarrior.rage_threshold") or 60

    if spells.ignore_pain and spells.ignore_pain:ready() and spells.ignore_pain:castable(player) then
        if player.rage >= rageThreshold then
            if spells.ignore_pain:cast(player) then
                return true
            end
        end
    end



    if spells.revenge and spells.revenge:ready() and spells.revenge:castable(player) then
        if spells.revenge:cast(player) and player.rage > 20 then
            return true
        end
    end



    return false
end



local function Ooc()
    lastRage = player.rage

    rageConsumed = 0

    ragingBlowReady = false



    if not player.combat then
        SmartBattleShout()
    end



    if not player.aura(386208) then
        if spells.Defensive_Stance and spells.Defensive_Stance:ready() and spells.Defensive_Stance:castable(player) then
            spells.Defensive_Stance:cast(player)
        end
    end
end



-- 注册自定义宏命令

Aurora.Macro:RegisterCommand("taunt", function()
    if Aurora.Rotation.TauntToggle then
        local current = Aurora.Rotation.TauntToggle:GetValue()

        Aurora.Rotation.TauntToggle:SetValue(not current)

        print("嘲讽: " .. (not current and "启用" or "禁用"))
    end
end, "切换嘲讽状态")



Aurora.Macro:RegisterCommand("defensive", function()
    if Aurora.Rotation.DefensiveToggle then
        local current = Aurora.Rotation.DefensiveToggle:GetValue()

        Aurora.Rotation.DefensiveToggle:SetValue(not current)

        print("减伤: " .. (not current and "启用" or "禁用"))
    end
end, "切换减伤状态")



Aurora.Macro:RegisterCommand("reflect", function()
    if Aurora.Rotation.SpellReflectToggle then
        local current = Aurora.Rotation.SpellReflectToggle:GetValue()

        Aurora.Rotation.SpellReflectToggle:SetValue(not current)

        print("反射: " .. (not current and "启用" or "禁用"))
    end
end, "切换反射状态")



Aurora.Macro:RegisterCommand("victory", function()
    if Aurora.Rotation.VictoryRushToggle then
        local current = Aurora.Rotation.VictoryRushToggle:GetValue()

        Aurora.Rotation.VictoryRushToggle:SetValue(not current)

        print("乘胜: " .. (not current and "启用" or "禁用"))
    end
end, "切换乘胜追击状态")



Aurora.Macro:RegisterCommand("rally", function()
    if Aurora.Rotation.RallyingCryToggle then
        local current = Aurora.Rotation.RallyingCryToggle:GetValue()

        Aurora.Rotation.RallyingCryToggle:SetValue(not current)

        print("集结: " .. (not current and "启用" or "禁用"))
    end
end, "切换集结呐喊状态")



Aurora.Macro:RegisterCommand("charge", function()
    if Aurora.Rotation.ShieldChargeToggle then
        local current = Aurora.Rotation.ShieldChargeToggle:GetValue()

        Aurora.Rotation.ShieldChargeToggle:SetValue(not current)

        print("盾冲: " .. (not current and "启用" or "禁用"))
    end
end, "切换盾牌冲锋状态")



Aurora.Macro:RegisterCommand("hardcontrol", function()
    if Aurora.Rotation.HardControlInterruptToggle then
        local current = Aurora.Rotation.HardControlInterruptToggle:GetValue()

        Aurora.Rotation.HardControlInterruptToggle:SetValue(not current)

        print("硬控: " .. (not current and "启用" or "禁用"))
    end
end, "切换硬控打断状态")



-- 【新增】挫志怒吼宏命令

Aurora.Macro:RegisterCommand("shout", function()
    if Aurora.Rotation.DemoralizingShoutToggle then
        local current = Aurora.Rotation.DemoralizingShoutToggle:GetValue()

        Aurora.Rotation.DemoralizingShoutToggle:SetValue(not current)

        print("挫志怒吼: " .. (not current and "启用" or "禁用"))
    end
end, "切换挫志怒吼状态")



-- 注册主循环

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

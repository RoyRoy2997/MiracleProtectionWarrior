-- Create your spells



local NewSpell = Aurora.SpellHandler.NewSpell







Aurora.SpellHandler.PopulateSpellbook({



    spells = {



        AutoAttack = NewSpell(6603),         -- 自动攻击



        Charge = NewSpell(100),             -- 冲锋



        shield_slam = NewSpell(23922),        -- 盾牌猛击



        Ravager = NewSpell(228920, { radius = 8, }),            -- 破坏者



        demoralizing_shout = NewSpell(1160), -- 挫志怒吼



        shield_charge = NewSpell(385952),      -- 盾牌冲锋



        avatar = NewSpell(107574),             -- 天神下凡



        rallying_cry = NewSpell(97462),       -- 集结呐喊







        --防御技能



        shield_block = NewSpell(2565),       -- 盾牌格挡



        shield_wall = NewSpell(871),        -- 盾墙



        ignore_pain = NewSpell(190456),        -- 无视苦痛



        Defensive_Stance = NewSpell(386208),   -- 防御姿态







        --输出技能



        Champions_spear = NewSpell(376079, { radius = 8, }),    -- 冠军之矛



        demolish = NewSpell(436358),           -- 摧毁



        thunderous_roar = NewSpell(384318),    -- 雷霆咆哮



        thunder_clap = NewSpell(6343),       -- 雷霆一击



        thunder_blast = NewSpell(435222),      -- 雷霆轰击







        -- 新增技能



        revenge = NewSpell(6572),            -- 复仇



        execute = NewSpell(163201),            -- 处决



        last_stand = NewSpell(12975),         -- 破釜沉舟



        spell_reflect = NewSpell(23920),      -- 法术反射



        heroic_throw = NewSpell(57755),       -- 英勇投掷



        victory_rush = NewSpell(202168),       -- 乘胜追击



        Battle_Shout = NewSpell(6673),       -- 战斗怒吼







        -- 打断技能



        pummel = NewSpell(6552),             -- 拳击



        storm_bolt = NewSpell(107570),         -- 风暴之锤



        shockwave = NewSpell(46968),          -- 震荡波



        arcane_torrent = NewSpell(386071),     -- 瓦解怒吼







        -- 嘲讽技能



        taunt = NewSpell(355),              -- 嘲讽



        challenging_shout = NewSpell(1161),  -- 挑战怒吼



    },



    auras = {



        shield_block_buff = NewSpell(132404), -- 盾牌格挡buff



        overpower = NewSpell(386486), -- 怒意迸发层数



        overpower_buff = NewSpell(386478), -- 怒意迸发buff



        victory_rush_buff = NewSpell(32216) -- 乘胜追击buff



    },



    talents = {



        booming_voice = NewSpell(202743) -- 震耳噪音



    }



}, "WARRIOR", 3, "MiracleWarrior")

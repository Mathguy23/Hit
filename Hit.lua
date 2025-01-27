--- STEAMODDED HEADER
--- MOD_NAME: Hit
--- MOD_ID: HIT
--- PREFIX: hit
--- MOD_AUTHOR: [mathguy]
--- MOD_DESCRIPTION: Blackjack instead of Poker
--- VERSION: 1.0.0
----------------------------------------------
------------MOD CODE -------------------------

SMODS.current_mod.set_debuff = function(card)
    if card.ability.temp_debuff then
        return true
    end
end

SMODS.Atlas({ key = "tags", atlas_table = "ASSET_ATLAS", path = "tags.png", px = 34, py = 34})


function dunegon_selection(theBlind)
    stop_use()
    if G.blind_select then 
        G.GAME.facing_blind = true
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext1').config.object.pop_delay = 0
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext1').config.object:pop_out(5)
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext2').config.object.pop_delay = 0
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext2').config.object:pop_out(5) 

        G.E_MANAGER:add_event(Event({
        trigger = 'before', delay = 0.2,
        func = function()
            G.blind_prompt_box.alignment.offset.y = -10
            G.blind_select.alignment.offset.y = 40
            G.blind_select.alignment.offset.x = 0
            return true
        end}))
        G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            ease_round(1)
            inc_career_stat('c_rounds', 1)
            if _DEMO then
            G.SETTINGS.DEMO_ROUNDS = (G.SETTINGS.DEMO_ROUNDS or 0) + 1
            inc_steam_stat('demo_rounds')
            G:save_settings()
            end
            -- G.GAME.round_resets.blind = e.config.ref_table
            -- G.GAME.round_resets.blind_states[G.GAME.blind_on_deck] = 'Current'
            G.blind_select:remove()
            G.blind_prompt_box:remove()
            G.blind_select = nil
            delay(0.2)
            return true
        end}))
        G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            dungeon_new_round(theBlind)
            return true
        end
        }))
    end
end

function dungeon_new_round(theBlind)
    G.RESET_JIGGLES = nil
    delay(0.4)
    G.E_MANAGER:add_event(Event({
      trigger = 'immediate',
      func = function()
            G.GAME.current_round.discards_left = math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards)
            G.GAME.current_round.hands_left = (math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands))
            G.GAME.current_round.hands_played = 0
            G.GAME.current_round.discards_used = 0
            G.GAME.current_round.reroll_cost_increase = 0
            G.GAME.current_round.used_packs = {}

            for k, v in pairs(G.GAME.hands) do 
                v.played_this_round = 0
            end

            for k, v in pairs(G.playing_cards) do
                v.ability.wheel_flipped = nil
            end

            local chaos = find_joker('Chaos the Clown')
            G.GAME.current_round.free_rerolls = #chaos
            calculate_reroll_cost(true)

            G.GAME.round_bonus.next_hands = 0
            G.GAME.round_bonus.discards = 0

            local blhash = 'S'
            -- if G.GAME.round_resets.blind == G.P_BLINDS.bl_small then
            --     G.GAME.round_resets.blind_states.Small = 'Current'
            --     G.GAME.current_boss_streak = 0
            --     blhash = 'S'
            -- elseif G.GAME.round_resets.blind == G.P_BLINDS.bl_big then
            --     G.GAME.round_resets.blind_states.Big = 'Current'
            --     G.GAME.current_boss_streak = 0
            --     blhash = 'B'
            -- else
            --     G.GAME.round_resets.blind_states.Boss = 'Current'
            --     blhash = 'L'
            -- end
            G.GAME.subhash = (G.GAME.round_resets.ante)..(blhash)

            -- local customBlind = {name = 'The Ox', defeated = false, order = 4, dollars = 5, mult = 2,  vars = {localize('ph_most_played')}, debuff = {}, pos = {x=0, y=2}, boss = {min = 6, max = 10, bonus = true}, boss_colour = HEX('b95b08')}
            G.GAME.blind_on_deck = 'Dungeon'
            G.GAME.last_blind.boss = nil
            G.HUD_blind.alignment.offset.y = -10
            G.HUD_blind:recalculate(false)
            
            delay(0.4)

            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    G.STATE = G.STATES.DRAW_TO_HAND
                    G.deck:shuffle('nr'..G.GAME.round_resets.ante)
                    G.deck:hard_set_T()
                    G.STATE_COMPLETE = false
                    return true
                end
            }))
            return true
            end
        }))
end

local old_buttons = create_UIBox_buttons
function create_UIBox_buttons()
    local t = old_buttons()
    if G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.dungeon then
        local index = 3
        if G.SETTINGS.play_button_pos ~= 1 then
            index = 1
        end
        local button = t.nodes[index]
        button.nodes[1].nodes[1].config.text = nil
        button.nodes[1].nodes[1].config.ref_value = 'hit_discard_button'
        button.nodes[1].nodes[1].config.ref_table = G.GAME
        button.config.button = 'hit'
        button.config.func = 'can_hit'
        -- button.config.color = G.C[checking[G.GAME.active].colour]
    end
    if G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.dungeon then
        local index = 1
        if G.SETTINGS.play_button_pos ~= 1 then
            index = 3
        end
        local button = t.nodes[index]
        button.nodes[1].nodes[1].config.text = localize("b_stand")
        button.config.button = 'stand'
        button.config.func = 'can_stand'
        -- button.config.color = G.C[checking[G.GAME.passive].colour]
    end
    return t
end

function check_total_over_21()
    if G.STATE == G.STATES.SELECTING_HAND then
        local total = 0
        for i = 1, #G.hand.cards do
            local id = G.hand.cards[i]:get_id()
            if id > 0 then
                local rank = SMODS.Ranks[G.hand.cards[i].base.value] or {}
                local nominal = rank.nominal
                if rank.key == 'Ace' then
                    total = total + 1
                else
                    total = total + nominal
                end
            end
        end
        if (total > 21) and not G.GAME.hit_busted then
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    play_area_status_text("Bust (" .. tostring(total) .. ")")
                    return true
                end
            }))
            G.GAME.hit_busted = true
        elseif (total <= 21) then
            G.GAME.hit_busted = nil
        end
    end
end

local old_use = Card.use_consumeable
function Card:use_consumeable(area, copier)
    old_use(self, area, copier)
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            check_total_over_21()
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    check_total_over_21()
                    return true
                end
            }))
            return true
        end
    }))
end

G.FUNCS.can_hit = function(e)
    if G.hand and G.hand.highlighted and (#G.hand.highlighted == 1) and (G.GAME.current_round.discards_left > 0) then
        e.config.colour = G.C.RED
        e.config.button = 'discard_cards_from_highlighted'
    elseif G.GAME.stood or G.GAME.hit_busted or (#G.deck.cards == 0) then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.IMPORTANT
        e.config.button = 'hit'
    end
end

G.FUNCS.hit = function(e)
    G.GAME.hit_limit = (G.hand and G.hand.cards and #G.hand.cards or 2) + 1
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            G.STATE = G.STATES.DRAW_TO_HAND
            G.STATE_COMPLETE = false
            return true
        end
    }))
end

G.FUNCS.can_stand = function(e)
    if G.GAME.stood then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.GREEN
        e.config.button = 'stand'
    end
end

G.FUNCS.stand = function(e)
    local total = 0
    local aces = 0
    G.GAME.hit_busted = nil
    G.GAME.stood = true
    G.enemy_deck:shuffle('enemy_deck')
    for i = 1, #G.hand.cards do
        local id = G.hand.cards[i]:get_id()
        if id > 0 then
            local rank = SMODS.Ranks[G.hand.cards[i].base.value] or {}
            local nominal = rank.nominal
            if rank.key == 'Ace' then
                total = total + 1
                aces = aces + 1
            else
                total = total + nominal
            end
        end
    end
    while (total <= 11) and (aces >= 1) do
        total = total + 10
        aces = aces + 1
    end
    if total > 21 then
        total = -1
    end
    local bl_total = 0
    local bl_aces = 0
    local bl_cards = 0
    while bl_total <= 21 do
        local index = #G.enemy_deck.cards - bl_cards
        if index <= 0 then
            break
        else
            local id = G.enemy_deck.cards[index]:get_id()
            if id > 0 then
                local rank = SMODS.Ranks[G.enemy_deck.cards[index].base.value] or {}
                local nominal = rank.nominal
                if rank.key == 'Ace' then
                    bl_total = bl_total + 11
                    bl_aces = bl_aces + 1
                else
                    bl_total = bl_total + nominal
                end
            end
            if bl_total > 21 then
                while (bl_total > 21) and (bl_aces > 0) do
                    bl_total = bl_total - 10
                    bl_aces = bl_aces - 1
                end
            end
            if (bl_total >= 17) and (bl_total <= 21) then
                bl_cards = bl_cards + 1
                break
            end
        end
        bl_cards = bl_cards + 1
    end 
    if bl_total > 21 then
        bl_total = -1
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            if bl_cards > 0 then
                for i = 1, bl_cards do
                    draw_card(G.enemy_deck, G.play, i*100/5, 'up')
                end
            end
            delay(0.5)
            if bl_total < total then
                if bl_total == -1 then
                    play_area_status_text("Win (" .. tostring(total) .. " > Bust)")
                else
                    play_area_status_text("Win (" .. tostring(total) .. " > " .. tostring(bl_total) .. ")")
                end
                G.GAME.hit_limit = 2
                ease_hands_played(1)
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        for i = 1, #G.play.cards do
                            draw_card(G.play, G.enemy_deck, i*100/5, 'up')
                        end
                        G.E_MANAGER:add_event(Event({
                            trigger = 'immediate',
                            func = function()
                                for i = 1, #G.hand.cards do
                                    if not G.hand.cards[i].highlighted then
                                        G.hand:add_to_highlighted(G.hand.cards[i])
                                    end
                                end
                                G.FUNCS.play_cards_from_highlighted()
                                G.GAME.hit_busted = nil
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'immediate',
                                    func = function()
                                        G.GAME.stood = nil
                                        return true
                                    end
                                }))
                                return true
                            end
                        }))
                        return true
                    end
                }))
            elseif bl_total == total then
                if bl_total == -1 then
                    play_area_status_text("Push (Bust = Bust)")
                else
                    play_area_status_text("Push (" .. tostring(total) .. " = " .. tostring(bl_total) .. ")")
                end
                G.GAME.hit_limit = 2
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        for i = 1, #G.play.cards do
                            draw_card(G.play, G.enemy_deck, i*100/5, 'up')
                        end
                        for i = 1, #G.hand.cards do
                            draw_card(G.hand, G.discard, i*100/5, 'up')
                        end
                        G.E_MANAGER:add_event(Event({
                            trigger = 'immediate',
                            func = function()
                                G.GAME.stood = nil
                                return true
                            end
                        }))
                        return true
                    end
                }))
            elseif bl_total > total then
                if total == -1 then
                    play_area_status_text("Loss (Bust < " .. tostring(bl_total) .. ")")
                else
                    play_area_status_text("Loss (" .. tostring(total) .. " < " .. tostring(bl_total) .. ")")
                end
                G.GAME.hit_limit = 2
                ease_hands_played(-1)
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            trigger = 'immediate',
                            func = function()
                                for i = 1, #G.hand.cards do
                                    draw_card(G.hand, G.discard, i*100/5, 'up')
                                end
                                G.GAME.negate_hand = true
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'immediate',
                                    func = function()
                                        G.STATE = G.STATES.HAND_PLAYED
                                        G.STATE_COMPLETE = true
                                        return true
                                    end
                                }))
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'immediate',
                                    func = function()
                                        G.FUNCS.evaluate_play()
                                        return true
                                    end
                                }))
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'after',
                                    delay = 0.1,
                                    func = function()
                                        G.GAME.hands_played = G.GAME.hands_played + 1
                                        G.GAME.current_round.hands_played = G.GAME.current_round.hands_played + 1
                                        return true
                                    end
                                }))
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'immediate',
                                    func = function()
                                        local play_count = #G.play.cards
                                        local it = 1
                                        for k, v in ipairs(G.play.cards) do
                                            if (not v.shattered) and (not v.destroyed) then 
                                                draw_card(G.play,G.enemy_deck, it*100/play_count,'down', false, v)
                                                it = it + 1
                                            end
                                        end
                                        return true
                                    end
                                }))
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'immediate',
                                    func = function()
                                        G.STATE_COMPLETE = false
                                        return true
                                    end
                                }))
                                G.GAME.hit_busted = nil
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'immediate',
                                    func = function()
                                        G.GAME.stood = nil
                                        return true
                                    end
                                }))
                                return true
                            end
                        }))
                        return true
                    end
                }))
            end
            return true
        end
    }))
end

local old_draw_from_deck = G.FUNCS.draw_from_deck_to_hand
G.FUNCS.draw_from_deck_to_hand = function(e)
    if G and G.GAME and G.GAME.modifiers and G.GAME.modifiers.dungeon and not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) then
        local hand_space =  math.max(0, (G.GAME.hit_limit or 2) - #G.hand.cards)
        if hand_space >= 1 then
            for i = 1, hand_space do
                draw_card(G.deck,G.hand, i*100/hand_space,'up', true)
            end
        end
    else
        old_draw_from_deck(e)
    end
end

-----------Memory Game----------

G.FUNCS.can_play_memory = function(e)
    if (G.GAME.currently_choosing ~= nil) or (G.GAME.hit_tries_left <= 0) then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.BLUE
        e.config.button = 'play_memory'
    end
end

G.FUNCS.play_memory = function(e)
    G.GAME.currently_choosing = true
    G.GAME.memory_cards = {}
    G.memory_row_1.highlighted = {}
    G.memory_row_2.highlighted = {}
    G.GAME.hit_tries_left = G.GAME.hit_tries_left - 1
end

SMODS.Tag {
    key = 'memory',
    atlas = 'tags',
    loc_txt = {
        name = "Memory Tag",
        text = {
            "Play a",
            "Memory Game"
        }
    },
    discovered = true,
    in_pool = function(self)
        return G.GAME.modifiers.dungeon
    end,
    pos = {x = 1, y = 0},
    apply = function(self, tag, context)
        if context.type == 'immediate' then
            tag:yep('+', G.C.GREEN,function()
                return true
            end)
            tag.triggered = true
            return true
        end
    end,
    config = {type = 'immediate', minigame = true}
}

function G.UIDEF.memory()
    local rows = {}
    G.GAME.currently_choosing = nil
    G.GAME.memory_cards = nil
    for i = 1, 2 do
        G["memory_row_" .. tostring(i)] = CardArea(
        G.hand.T.x+0,
        G.hand.T.y+G.ROOM.T.y + 9,
        5*1.02*G.CARD_W,
        1.05*G.CARD_H, 
        {card_limit = 5, type = 'shop', highlight_limit = 5})
        table.insert(rows, {n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={
            {n=G.UIT.C, config={align = "cm", padding = 0.2, r=0.2, colour = G.C.L_BLACK, emboss = 0.05, minw = 8.2}, nodes={
                {n=G.UIT.O, config={object = G["memory_row_" .. tostring(i)]}},
            }},
        }})
    end
    if not G.load_memory_row_1 then
        G.GAME.hit_tries_left = nil
        local pools = {G.P_JOKER_RARITY_POOLS[2], G.P_JOKER_RARITY_POOLS[3], G.P_CENTER_POOLS["Spectral"], G.P_CENTER_POOLS["Spectral"], G.P_CENTER_POOLS["Voucher"]}
        local keys = {}
        for i, j in ipairs(pools) do
            local pool = {}
            for k, v in ipairs(j) do
                local valid = true
                local in_pool, pool_opts
                if v.in_pool and type(v.in_pool) == 'function' then
                    in_pool, pool_opts = v:in_pool({})
                end
                if (G.GAME.used_jokers[v.key] and (not pool_opts or not pool_opts.allow_duplicates) and not next(find_joker("Showman"))) then
                    valid = false
                end
                if not v.unlocked then
                    valid = false
                end
                if (i == 4) and (keys[3] == v.key) then
                    valid = false
                end
                if G.GAME.banned_keys[v.key] then
                    valid = false
                end
                if G.GAME.used_vouchers[v.key] then
                    valid = false
                end
                if v.requires then 
                    for i2, j2 in pairs(v.requires) do
                        if not G.GAME.used_vouchers[j2] then 
                            valid = false
                        end
                    end
                end
                for i2, j2 in ipairs(SMODS.Consumable.legendaries) do
                    if v.key == j2.key then
                        valid = false
                        break
                    end
                end
                if (v.key == 'c_black_hole') or (v.key == 'c_soul') then
                    valid = false
                end
                if valid then
                    table.insert(pool, v.key)
                end
            end
            if #pool == 0 then
                keys[#keys + 1] = 'c_pluto'
            else
                keys[#keys + 1] = pseudorandom_element(pool, pseudoseed('remember'))
            end
        end
        local row_1 = {}
        local row_2 = {}
        local pool = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
        for _, j in pairs(keys) do
            for k = 1, 2 do
                local slot, index = pseudorandom_element(pool, pseudoseed('remember2'))
                table.remove(pool, index)
                if slot > 5 then
                    row_2[slot - 5] = j
                else
                    row_1[slot] = j
                end
            end
        end
        for i, j in ipairs(row_1) do
            local card = SMODS.create_card {key = j, no_edition = true}
            G.memory_row_1:emplace(card)
            card:flip()
        end
        for i, j in ipairs(row_2) do
            local card = SMODS.create_card {key = j, no_edition = true}
            G.memory_row_2:emplace(card)
            card:flip()
        end
    else
        G.memory_row_1:load(G.load_memory_row_1)
        G.memory_row_2:load(G.load_memory_row_2)
        G.load_memory_row_1 = nil
        G.load_memory_row_2 = nil
    end
    G.GAME.hit_tries_left = G.GAME.hit_tries_left or 6


    local shop_sign = AnimatedSprite(0,0, 4.4, 2.2, G.ANIMATION_ATLAS['shop_sign'])
    shop_sign:define_draw_steps({
      {shader = 'dissolve', shadow_height = 0.05},
      {shader = 'dissolve'}
    })
    G.SHOP_SIGN = UIBox{
      definition = 
        {n=G.UIT.ROOT, config = {colour = G.C.DYN_UI.MAIN, emboss = 0.05, align = 'cm', r = 0.1, padding = 0.1}, nodes={
          {n=G.UIT.R, config={align = "cm", padding = 0.1, minw = 4.72, minh = 3.1, colour = G.C.DYN_UI.DARK, r = 0.1}, nodes={
            {n=G.UIT.R, config={align = "cm"}, nodes={
              {n=G.UIT.O, config={object = shop_sign}}
            }},
            {n=G.UIT.R, config={align = "cm"}, nodes={
              {n=G.UIT.O, config={object = DynaText({string = {localize('ph_test_memory')}, colours = {lighten(G.C.GOLD, 0.3)},shadow = true, rotate = true, float = true, bump = true, scale = 0.5, spacing = 1, pop_in = 1.5, maxw = 4.3})}}
            }},
          }},
        }},
      config = {
        align="cm",
        offset = {x=0,y=-15},
        major = G.HUD:get_UIE_by_ID('row_blind'),
        bond = 'Weak'
      }
    }
    G.E_MANAGER:add_event(Event({
      trigger = 'immediate',
      func = (function()
          G.SHOP_SIGN.alignment.offset.y = 0
          return true
      end)
    }))


    local t = {n=G.UIT.ROOT, config = {align = 'cl', colour = G.C.CLEAR}, nodes={
            UIBox_dyn_container({
                {n=G.UIT.C, config={align = "cm", padding = 0.1, emboss = 0.05, r = 0.1, colour = G.C.DYN_UI.BOSS_MAIN}, nodes={
                rows[1], rows[2],
                {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
                    {n=G.UIT.C, config={align = "cm", minw = 2.8, minh = 0.7, r=0.04,colour = G.C.BLUE, button = 'play_memory', func = 'can_play_memory', hover = true,shadow = true}, nodes = {
                        {n=G.UIT.R, config={align = "cm", padding = 0.07, focus_args = {button = 'x', orientation = 'cr'}, func = 'set_button_pip'}, nodes={
                            {n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
                                {n=G.UIT.T, config={text = localize('b_choose_cards'), scale = 0.4, colour = G.C.WHITE, shadow = true}},
                            }},
                            {n=G.UIT.R, config={align = "cm", maxw = 1.3, minw = 1}, nodes={
                              {n=G.UIT.T, config={text = " (", scale = 0.4, colour = G.C.WHITE, shadow = true}},
                              {n=G.UIT.T, config={ref_table = G.GAME, ref_value = 'hit_tries_left', scale = 0.4, colour = G.C.WHITE, shadow = true}},
                              {n=G.UIT.T, config={text = ")", scale = 0.4, colour = G.C.WHITE, shadow = true}},
                            }}
                        }}
                    }},
                    {n=G.UIT.C, config={id = 'next_round_button', align = "cm", minw = 2.8, minh = 0.7, r=0.04,colour = G.C.RED, one_press = true, button = 'toggle_shop', hover = true,shadow = true}, nodes = {
                        {n=G.UIT.R, config={align = "cm", padding = 0.07, focus_args = {button = 'x', orientation = 'cr'}, func = 'set_button_pip'}, nodes={
                            {n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
                                {n=G.UIT.T, config={text = localize('b_exit'), scale = 0.4, colour = G.C.WHITE, shadow = true}},
                            }},
                        }}
                    }},
                }}}
            },
              }, false)
        }}
    return t
end

--------------------------------

table.insert(G.CHALLENGES,#G.CHALLENGES+1,
    {name = 'Dungeon',
        id = 'c_blackjack',
        rules = {
            custom = {
                {id = 'dungeon'},
            },
            modifiers = {
                {id = 'discards', value = 5},
            }
        },
        jokers = {   
            {id = 'j_splash', eternal = true, edition = 'negative'},
        },
        consumeables = {
            {id = 'c_black_hole'},
            {id = 'c_black_hole'},
        },
        vouchers = {
        },
        deck = {
            type = 'Challenge Deck',
        },
        restrictions = {
            banned_cards = {
                {id = 'j_burglar'},
                -- effective useless
                {id = 'j_crazy'},
                {id = 'j_droll'},
                {id = 'j_devious'},
                {id = 'j_crafty'},
                {id = 'j_four_fingers'},
                {id = 'j_runner'},
                {id = 'j_superposition'},
                {id = 'j_seance'},
                {id = 'j_shortcut'},
                {id = 'j_obelisk'},
                {id = 'j_family'},
                {id = 'j_order'},
                {id = 'j_tribe'},
                -- really useless
                {id = 'j_mime'},
                {id = 'j_raised_fist'},
                {id = 'j_blackboard'},
                {id = 'j_dna'},
                {id = 'j_sixth_sense'},
                {id = 'j_baron'},
                {id = 'j_reserved_parking'},
                {id = 'j_mail'},
                {id = 'j_juggler'},
                {id = 'j_troubadour'},
                {id = 'j_turtle_bean'},
                {id = 'j_shoot_the_moon'},
                {id = 'j_dusk'},
                {id = 'j_acrobat'},
                {id = 'j_steel_joker'},
                {id = 'j_ticket'},
                -- discard based
                {id = 'j_merry_andy'},
                -- stuntman
                {id = 'j_stuntman'},
                -- non jokers
                {id = 'v_paint_brush'},
                {id = 'v_palette'},
                {id = 'c_trance'},
                {id = 'c_earth'},
                {id = 'c_mars'},
                {id = 'c_jupiter'},
                {id = 'c_neptune'},
                {id = 'c_saturn'},
                {id = 'c_devil'},
                {id = 'c_chariot'},
            },
            banned_tags = {
                {id = 'tag_juggle'},
            },
            banned_other = {
                {id = 'bl_hook', type = 'blind'},
                {id = 'bl_psychic', type = 'blind'},
                {id = 'bl_manacle', type = 'blind'},
                {id = 'bl_eye', type = 'blind'},
                {id = 'bl_serpent', type = 'blind'},
                {id = 'bl_final_bell', type = 'blind'},
                {id = 'bl_mouth', type = 'blind'},
                {id = 'bl_ox', type = 'blind'},
            }
        },
    }
)

function G.UIDEF.view_enemy_deck(unplayed_only)
	local deck_tables = {}
	remove_nils(G.enemy_cards or {})
	G.VIEWING_DECK = true
	table.sort(G.enemy_cards or {}, function(a, b) return a:get_nominal('suit') > b:get_nominal('suit') end)
	local SUITS = {}
	local suit_map = {}
	for i = #SMODS.Suit.obj_buffer, 1, -1 do
		SUITS[SMODS.Suit.obj_buffer[i]] = {}
		suit_map[#suit_map + 1] = SMODS.Suit.obj_buffer[i]
	end
	for k, v in ipairs(G.enemy_cards or {}) do
		if v.base.suit then table.insert(SUITS[v.base.suit], v) end
	end
	local num_suits = 0
	for j = 1, #suit_map do
		if SUITS[suit_map[j]][1] then num_suits = num_suits + 1 end
	end
	for j = 1, #suit_map do
		if SUITS[suit_map[j]][1] then
			local view_deck = CardArea(
				G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
				6.5 * G.CARD_W,
				((num_suits > 8) and 0.2 or (num_suits > 4) and (1 - 0.1 * num_suits) or 0.6) * G.CARD_H,
				{
					card_limit = #SUITS[suit_map[j]],
					type = 'title',
					view_deck = true,
					highlight_limit = 0,
					card_w = G
						.CARD_W * 0.7,
					draw_layers = { 'card' }
				})
			table.insert(deck_tables,
				{n = G.UIT.R, config = {align = "cm", padding = 0}, nodes = {
					{n = G.UIT.O, config = {object = view_deck}}}}
			)

			for i = 1, #SUITS[suit_map[j]] do
				if SUITS[suit_map[j]][i] then
					local greyed, _scale = nil, 0.7
					local copy = copy_card(SUITS[suit_map[j]][i], nil, _scale)
					copy.greyed = greyed
					copy.T.x = view_deck.T.x + view_deck.T.w / 2
					copy.T.y = view_deck.T.y

					copy:hard_set_T()
					view_deck:emplace(copy)
				end
			end
		end
	end

	local flip_col = G.C.WHITE

	local suit_tallies = {}
	local mod_suit_tallies = {}
	for _, v in ipairs(suit_map) do
		suit_tallies[v] = 0
		mod_suit_tallies[v] = 0
	end
	local rank_tallies = {}
	local mod_rank_tallies = {}
	local rank_name_mapping = SMODS.Rank.obj_buffer
	for _, v in ipairs(rank_name_mapping) do
		rank_tallies[v] = 0
		mod_rank_tallies[v] = 0
	end
	local face_tally = 0
	local mod_face_tally = 0
	local num_tally = 0
	local mod_num_tally = 0
	local ace_tally = 0
	local mod_ace_tally = 0
	local wheel_flipped = 0

	for k, v in ipairs(G.enemy_cards or {}) do
		if v.ability.name ~= 'Stone Card' then
			--For the suits
			if v.base.suit then suit_tallies[v.base.suit] = (suit_tallies[v.base.suit] or 0) + 1 end
			for kk, vv in pairs(mod_suit_tallies) do
				mod_suit_tallies[kk] = (vv or 0) + (v:is_suit(kk) and 1 or 0)
			end

			--for face cards/numbered cards/aces
			local card_id = v:get_id()
			if v.base.value then face_tally = face_tally + ((SMODS.Ranks[v.base.value].face) and 1 or 0) end
			mod_face_tally = mod_face_tally + (v:is_face() and 1 or 0)
			if v.base.value and not SMODS.Ranks[v.base.value].face and card_id ~= 14 then
				num_tally = num_tally + 1
				if not v.debuff then mod_num_tally = mod_num_tally + 1 end
			end
			if card_id == 14 then
				ace_tally = ace_tally + 1
				if not v.debuff then mod_ace_tally = mod_ace_tally + 1 end
			end

			--ranks
			if v.base.value then rank_tallies[v.base.value] = rank_tallies[v.base.value] + 1 end
			if v.base.value and not v.debuff then mod_rank_tallies[v.base.value] = mod_rank_tallies[v.base.value] + 1 end
		end
	end
	local modded = face_tally ~= mod_face_tally
	for kk, vv in pairs(mod_suit_tallies) do
		modded = modded or (vv ~= suit_tallies[kk])
		if modded then break end
	end

	if wheel_flipped > 0 then flip_col = mix_colours(G.C.FILTER, G.C.WHITE, 0.7) end

	local rank_cols = {}
	for i = #rank_name_mapping, 1, -1 do
		if rank_tallies[rank_name_mapping[i]] ~= 0 or not SMODS.Ranks[rank_name_mapping[i]].in_pool or SMODS.Ranks[rank_name_mapping[i]]:in_pool({suit=''}) then
			local mod_delta = mod_rank_tallies[rank_name_mapping[i]] ~= rank_tallies[rank_name_mapping[i]]
			rank_cols[#rank_cols + 1] = {n = G.UIT.R, config = {align = "cm", padding = 0.07}, nodes = {
				{n = G.UIT.C, config = {align = "cm", r = 0.1, padding = 0.04, emboss = 0.04, minw = 0.5, colour = G.C.L_BLACK}, nodes = {
					{n = G.UIT.T, config = {text = SMODS.Ranks[rank_name_mapping[i]].shorthand, colour = G.C.JOKER_GREY, scale = 0.35, shadow = true}},}},
				{n = G.UIT.C, config = {align = "cr", minw = 0.4}, nodes = {
					mod_delta and {n = G.UIT.O, config = {
							object = DynaText({
								string = { { string = '' .. rank_tallies[rank_name_mapping[i]], colour = flip_col }, { string = '' .. mod_rank_tallies[rank_name_mapping[i]], colour = G.C.BLUE } },
								colours = { G.C.RED }, scale = 0.4, y_offset = -2, silent = true, shadow = true, pop_in_rate = 10, pop_delay = 4
							})}}
					or {n = G.UIT.T, config = {text = rank_tallies[rank_name_mapping[i]], colour = flip_col, scale = 0.45, shadow = true } },}}}}
		end
	end

	local tally_ui = {
		-- base cards
		{n = G.UIT.R, config = {align = "cm", minh = 0.05, padding = 0.07}, nodes = {
			{n = G.UIT.O, config = {
					object = DynaText({ 
						string = { 
							{ string = localize('k_base_cards'), colour = G.C.RED }, 
							modded and { string = localize('k_effective'), colour = G.C.BLUE } or nil
						},
						colours = { G.C.RED }, silent = true, scale = 0.4, pop_in_rate = 10, pop_delay = 4
					})
				}}}},
		-- aces, faces and numbered cards
		{n = G.UIT.R, config = {align = "cm", minh = 0.05, padding = 0.1}, nodes = {
			tally_sprite(
				{ x = 1, y = 0 },
				{ { string = '' .. ace_tally, colour = flip_col }, { string = '' .. mod_ace_tally, colour = G.C.BLUE } },
				{ localize('k_aces') }
			), --Aces
			tally_sprite(
				{ x = 2, y = 0 },
				{ { string = '' .. face_tally, colour = flip_col }, { string = '' .. mod_face_tally, colour = G.C.BLUE } },
				{ localize('k_face_cards') }
			), --Face
			tally_sprite(
				{ x = 3, y = 0 },
				{ { string = '' .. num_tally, colour = flip_col }, { string = '' .. mod_num_tally, colour = G.C.BLUE } },
				{ localize('k_numbered_cards') }
			), --Numbers
		}},
	}
	-- add suit tallies
	local hidden_suits = {}
	for _, suit in ipairs(suit_map) do
		if suit_tallies[suit] == 0 and SMODS.Suits[suit].in_pool and not SMODS.Suits[suit]:in_pool({rank=''}) then
			hidden_suits[suit] = true
		end
	end
	local i = 1
	local num_suits_shown = 0
	for i = 1, #suit_map do
		if not hidden_suits[suit_map[i]] then
			num_suits_shown = num_suits_shown+1
		end
	end
	local suits_per_row = num_suits_shown > 6 and 4 or num_suits_shown > 4 and 3 or 2
	local n_nodes = {}
	while i <= #suit_map do
		while #n_nodes < suits_per_row and i <= #suit_map do
			if not hidden_suits[suit_map[i]] then
				table.insert(n_nodes, tally_sprite(
					SMODS.Suits[suit_map[i]].ui_pos,
					{
						{ string = '' .. suit_tallies[suit_map[i]], colour = flip_col },
						{ string = '' .. mod_suit_tallies[suit_map[i]], colour = G.C.BLUE }
					},
					{ localize(suit_map[i], 'suits_plural') },
					suit_map[i]
				))
			end
			i = i + 1
		end
		if #n_nodes > 0 then
			local n = {n = G.UIT.R, config = {align = "cm", minh = 0.05, padding = 0.1}, nodes = n_nodes}
			table.insert(tally_ui, n)
			n_nodes = {}
		end
	end
	local t = {n = G.UIT.ROOT, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
		{n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {}},
		{n = G.UIT.R, config = {align = "cm"}, nodes = {
			{n = G.UIT.C, config = {align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes = {
				{n = G.UIT.C, config = {align = "cm", padding = 0.1}, nodes = {
					{n = G.UIT.R, config = {align = "cm", r = 0.1, colour = G.C.L_BLACK, emboss = 0.05, padding = 0.15}, nodes = {
						{n = G.UIT.R, config = {align = "cm"}, nodes = {
							{n = G.UIT.O, config = {
									object = DynaText({ string = G.GAME.selected_back.loc_name, colours = {G.C.WHITE}, bump = true, rotate = true, shadow = true, scale = 0.6 - string.len(G.GAME.selected_back.loc_name) * 0.01 })
								}},}},
						{n = G.UIT.R, config = {align = "cm", r = 0.1, padding = 0.1, minw = 2.5, minh = 1.3, colour = G.C.WHITE, emboss = 0.05}, nodes = {
							{n = G.UIT.O, config = {
									object = UIBox {
										definition = G.GAME.selected_back:generate_UI(nil, 0.7, 0.5, G.GAME.challenge), config = {offset = { x = 0, y = 0 } }
									}
								}}}}}},
					{n = G.UIT.R, config = {align = "cm", r = 0.1, outline_colour = G.C.L_BLACK, line_emboss = 0.05, outline = 1.5}, nodes = 
						tally_ui}}},
				{n = G.UIT.C, config = {align = "cm"}, nodes = rank_cols},
				{n = G.UIT.B, config = {w = 0.1, h = 0.1}},}},
			{n = G.UIT.B, config = {w = 0.2, h = 0.1}},
			{n = G.UIT.C, config = {align = "cm", padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes =
				deck_tables}}},
		{n = G.UIT.R, config = {align = "cm", minh = 0.8, padding = 0.05}, nodes = {
			modded and {n = G.UIT.R, config = {align = "cm"}, nodes = {
				{n = G.UIT.C, config = {padding = 0.3, r = 0.1, colour = mix_colours(G.C.BLUE, G.C.WHITE, 0.7)}, nodes = {}},
				{n = G.UIT.T, config = {text = ' ' .. localize('ph_deck_preview_effective'), colour = G.C.WHITE, scale = 0.3}},}}
			or nil,
			wheel_flipped > 0 and {n = G.UIT.R, config = {align = "cm"}, nodes = {
				{n = G.UIT.C, config = {padding = 0.3, r = 0.1, colour = flip_col}, nodes = {}},
				{n = G.UIT.T, config = {
						text = ' ' .. (wheel_flipped > 1 and
							localize { type = 'variable', key = 'deck_preview_wheel_plural', vars = { wheel_flipped } } or
							localize { type = 'variable', key = 'deck_preview_wheel_singular', vars = { wheel_flipped } }),
						colour = G.C.WHITE, scale = 0.3
					}},}}
			or nil,}}}}
	return t
end

----------------------------------------------
------------MOD CODE END----------------------

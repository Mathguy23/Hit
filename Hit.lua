--- STEAMODDED HEADER
--- MOD_NAME: Hit
--- MOD_ID: HIT
--- PREFIX: hit
--- MOD_AUTHOR: [mathguy]
--- MOD_DESCRIPTION: Blackjack instead of Poker
--- VERSION: 1.0.0
----------------------------------------------
------------MOD CODE -------------------------
-------------Credits--------------------------

--- Aced Sleeve - Code: SMG9000, Art: GenEric1110

----------------------------------------------

SMODS.current_mod.set_debuff = function(card)
    if card.ability.temp_debuff then
        return true
    end
end

SMODS.Atlas({ key = "tags", atlas_table = "ASSET_ATLAS", path = "tags.png", px = 34, py = 34})

SMODS.Atlas({ key = "decks", atlas_table = "ASSET_ATLAS", path = "backs.png", px = 71, py = 95})

SMODS.Atlas({ key = "sleeves", atlas_table = "ASSET_ATLAS", path = "Sleeves.png", px = 71, py = 95})

SMODS.Atlas({ key = "reversed_tarots", atlas_table = "ASSET_ATLAS", path = "Untarot.png", px = 71, py = 95})

SMODS.Atlas({ key = "enhance", atlas_table = "ASSET_ATLAS", path = "Enhance.png", px = 71, py = 95})

SMODS.Atlas({ key = "boosters", atlas_table = "ASSET_ATLAS", path = "boosters.png", px = 71, py = 95})

SMODS.Atlas({ key = "ranks", atlas_table = "ASSET_ATLAS", path = "ranks.png", px = 71, py = 95})

SMODS.Atlas({ key = "pc_cards", atlas_table = "ASSET_ATLAS", path = "pc_cards.png", px = 71, py = 95})

SMODS.Atlas({ key = "planets", atlas_table = "ASSET_ATLAS", path = "Planets.png", px = 71, py = 95})

SMODS.Atlas({ key = "jokers", atlas_table = "ASSET_ATLAS", path = "Jokers.png", px = 71, py = 95})

function get_smods_rank_from_id(card)
    local id = card:get_id()
    if id > 0 then
        for i, j in pairs(SMODS.Ranks) do
            if j.id == id then
                return j
            end
        end
    else
        return SMODS.Ranks[card.base.value] or {}
    end
end

function shuffle_card_in_deck(card)
    if card.facing == 'front' then
        card:flip()
    end
    local index = -1
    for i = 1, #G.deck.cards do
        if G.deck.cards[i] == card then
            index = i
            break
        end
    end
    if index ~= -1 then
        local rand_index = 1 + math.floor(#G.deck.cards * pseudorandom('shuffle_index'))
        if rand_index == #G.deck.cards + 1 then
            rand_index = #G.deck.cards
        end
        G.deck.cards[rand_index], G.deck.cards[index] = G.deck.cards[index], G.deck.cards[rand_index]
        G.deck:set_ranks()
    end
end

----Poker Hands-------

    SMODS.PokerHand {
        key = 'High Card0',
        chips = 30,
        l_chips = 10,
        mult = 3,
        l_mult = 1,
        example = {
            { 'C_5', false },
            { 'H_K', false },
            { 'D_4', false },
            { 'H_7', false },
            { 'C_A', true } 
        },
        evaluate = function(parts, hand)
            if not G.GAME.modifiers.dungeon then
                return {}
            end
            if #hand == 0 then
                return {}
            end
            return parts._highest
        end,
        visible = false,
        order_offset = 3000,
        bj_mode = true
    }

    SMODS.PokerHand {
        key = 'Court',
        chips = 40,
        l_chips = 10,
        mult = 4,
        l_mult = 1,
        example = {
            { 'D_K', true },
            { 'H_J', true },
            { 'C_6', false },
            { 'H_9', false },
            { 'S_2', false } 
        },
        evaluate = function(parts, hand)
            if not G.GAME.modifiers.dungeon then
                return {}
            end
            local faces = {}
            for i, j in ipairs(hand) do
                if j:is_face() then
                    table.insert(faces, j)
                end
            end
            if #faces >= 2 then
                local highest = nil
                local highest2 = nil
                for i = 1, #faces do
                    if not highest then
                        highest = i
                    elseif not highest2 then
                        if (faces[i]:get_nominal() > faces[highest]:get_nominal()) then
                            highest2 = highest
                            highest = i
                        else
                            highest2 = i
                        end
                    elseif (faces[i]:get_nominal() > faces[highest]:get_nominal()) then
                        highest2 = highest
                        highest = i
                    elseif (faces[i]:get_nominal() > faces[highest2]:get_nominal()) then
                        highest2 = i
                    end
                end
                return { {faces[highest], faces[highest2]} }
            end
            return {}
        end,
        visible = false,
        order_offset = 3000,
        bj_mode = true
    }

    SMODS.PokerHand {
        key = 'Duo',
        chips = 50,
        l_chips = 15,
        mult = 4,
        l_mult = 2,
        example = {
            { 'D_A', true },
            { 'S_Q', false },
            { 'C_8', true },
            { 'D_8', true },
            { 'C_4', false } 
        },
        evaluate = function(parts, hand)
            if not G.GAME.modifiers.dungeon then
                return {}
            end
            local pair = get_X_same(2, hand)
            if next(pair) then
                best_pair = pair[1]
                best_card = nil
                for i, j in ipairs(hand) do
                    if (j ~= best_pair[1]) and (j ~= best_pair[2]) then
                        if not best_card then
                            best_card = j
                        elseif j:get_nominal() > best_card:get_nominal() then
                            best_card = j
                        end
                    end
                end
                if best_card then
                    return { {best_pair[1], best_pair[2], best_card} }
                end
            end
            return {}
        end,
        visible = false,
        order_offset = 3000,
        bj_mode = true
    }

    SMODS.PokerHand {
        key = 'Batch',
        chips = 60,
        l_chips = 20,
        mult = 6,
        l_mult = 2,
        example = {
            { 'C_9', true },
            { 'H_6', false },
            { 'C_A', true },
            { 'D_7', false },
            { 'C_5', true } 
        },
        evaluate = function(parts, hand)
            if not G.GAME.modifiers.dungeon then
                return {}
            end
            local suits = SMODS.Suit.obj_buffer
            local map = {}
            for i=1, #hand do
                for j = 1, #suits do
                    if hand[i]:is_suit(suits[j], nil, true) then
                        map[suits[j]] = map[suits[j]] or {}
                        map[suits[j]][#map[suits[j]]+1] = hand[i] 
                        if #map[suits[j]] >= 3 then
                            return { map[suits[j]] }
                        end
                    end
                end
            end
            return {}
        end,
        visible = false,
        order_offset = 3000,
        bj_mode = true
    }

    SMODS.PokerHand {
        key = 'Blackjack',
        chips = 70,
        l_chips = 20,
        mult = 6,
        l_mult = 1,
        example = {
            { 'C_4', true },
            { 'H_7', true },
            { 'H_J', true },
        },
        evaluate = function(parts, hand)
            if not G.GAME.modifiers.dungeon then
                return {}
            end
            local data = get_card_total(hand)
            if data.total == data.bust_limit then
                return { hand }
            end
            return {}
        end,
        visible = false,
        order_offset = 3000,
        bj_mode = true
    }

    SMODS.PokerHand {
        key = 'Duo+',
        chips = 80,
        l_chips = 20,
        mult = 7,
        l_mult = 2,
        example = {
            { 'S_A', true },
            { 'D_3', true },
            { 'H_3', true },
            { 'C_3', true },
            { 'C_K', false } 
        },
        evaluate = function(parts, hand)
            if not G.GAME.modifiers.dungeon then
                return {}
            end
            local oaK = get_X_same(3, hand, true)
            if next(oaK) then
                best_oaK = oaK[1]
                best_card = nil
                for i, j in ipairs(hand) do
                    local valid = true
                    for i2, j2 in ipairs(best_oaK) do
                        if j2 == j then
                            valid = false
                            break
                        end
                    end
                    if valid then
                        if not best_card then
                            best_card = j
                        elseif j:get_nominal() > best_card:get_nominal() then
                            best_card = j
                        end
                    end
                end
                if best_card then
                    local result = {}
                    for i, j in ipairs(best_oaK) do
                        table.insert(result, j)
                    end
                    table.insert(result, best_card)
                    return { result }
                end
            end
            return {}
        end,
        visible = false,
        order_offset = 3000,
        bj_mode = true
    }

    SMODS.PokerHand {
        key = 'Batch+',
        chips = 80,
        l_chips = 25,
        mult = 8,
        l_mult = 3,
        example = {
            { 'D_Q', true },
            { 'H_6', false },
            { 'D_J', true },
            { 'D_2', true },
            { 'D_4', true } 
        },
        evaluate = function(parts, hand)
            if not G.GAME.modifiers.dungeon then
                return {}
            end
            local suits = SMODS.Suit.obj_buffer
            local map = {}
            for i=1, #hand do
                for j = 1, #suits do
                    if hand[i]:is_suit(suits[j], nil, true) then
                        map[suits[j]] = map[suits[j]] or {}
                        map[suits[j]][#map[suits[j]]+1] = hand[i] 
                        if #map[suits[j]] >= 4 then
                            return { map[suits[j]] }
                        end
                    end
                end
            end
            return {}
        end,
        visible = false,
        order_offset = 3000,
        bj_mode = true
    }

    SMODS.PokerHand {
        key = 'Blackjack Batch',
        chips = 90,
        l_chips = 25,
        mult = 9,
        l_mult = 2,
        example = {
            { 'S_A', true },
            { 'S_2', true },
            { 'S_3', true },
            { 'S_5', true },
            { 'C_J', false } 
        },
        evaluate = function(parts, hand)
            if not G.GAME.modifiers.dungeon then
                return {}
            end
            local data = get_card_total(hand)
            if (data.total == data.bust_limit) then
                if data.card_count < 3 then
                    return {}
                end
                for i, j in pairs(data.suit_map) do
                    if #j >= data.card_count then
                        return { j }
                    end
                end
            end
            return {}
        end,
        visible = false,
        order_offset = 3000,
        bj_mode = true
    }

    SMODS.PokerHand {
        key = 'Supreme',
        chips = 100,
        l_chips = 15,
        mult = 10,
        l_mult = 2,
        example = {
            { 'S_7', true },
            { 'H_A', true },
            { 'D_2', true },
            { 'C_K', true },
            { 'S_2', true },
            { 'D_8', true } 
        },
        evaluate = function(parts, hand)
            if not G.GAME.modifiers.dungeon then
                return {}
            end
            cards = {}
            for i=1, #hand do
                local id = hand[i]:get_id()
                if (id >= 0) then
                    table.insert(cards, hand[i])
                end
            end
            if #cards >= 6 then
                return { cards }
            end
            return {}
        end,
        visible = false,
        order_offset = 3000,
        bj_mode = true
    }

    local bj_hands = {
        {hand = 'hit_High Card0', x = 0, y = 0, key = 'pluto'},
        {hand = 'hit_Court', x = 1, y = 0, key = 'mercury'},
        {hand = 'hit_Duo', x = 2, y = 0, key = 'uranus'},
        {hand = 'hit_Batch', x = 3, y = 0, key = 'venus'},
        {hand = 'hit_Blackjack', x = 0, y = 1, key = 'saturn'},
        {hand = 'hit_Duo+', x = 1, y = 1, key = 'jupiter'},
        {hand = 'hit_Batch+', x = 2, y = 1, key = 'earth'},
        {hand = 'hit_Blackjack Batch', x = 3, y = 1, key = 'mars'},
        {hand = 'hit_Supreme', x = 0, y = 2, key = 'neptune'},
    }

    for i, j in ipairs(bj_hands) do
        SMODS.Planet {
            key = j.key,
            name = string.upper(string.sub(j.key, 1, 1)) .. string.sub(j.key, 2, -1),
            loc_txt = {
                name = string.upper(string.sub(j.key, 1, 1)) .. string.sub(j.key, 2, -1),
                text = {
                    "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
                    "{C:attention}#2#",
                    "{C:mult}+#3#{} Mult and",
                    "{C:chips}+#4#{} chips"
                }
            },
            config = {hand_type = j.hand},
            atlas = "planets",
            pos = {x = j.x, y = j.y},
            loc_vars = function(self, info_queue, card)
                local hand = self.config.hand_type
                return { vars = {G.GAME.hands[hand].level,localize(hand, 'poker_hands'), G.GAME.hands[hand].l_mult, G.GAME.hands[hand].l_chips, colours = {(G.GAME.hands[hand].level==1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[hand].level)])}} }
            end,
            in_pool = function(self)
                return G.GAME.modifiers.dungeon
            end
        }
    end

----------------------

----Untarots-----

    SMODS.ConsumableType {
        key = 'Untarot',
        collection_rows = { 5, 6 },
        primary_colour = HEX('424e54'),
        secondary_colour = HEX('a58547'),
    }

    SMODS.UndiscoveredSprite {
        key = 'Untarot',
        atlas = 'reversed_tarots',
        pos = {x = 2, y = 4}
    }

    SMODS.Untarot = SMODS.Consumable:extend {
        set = 'Untarot',
        in_pool = function(self)
            return G.GAME.modifiers.dungeon, {allow_duplicates = false}
        end,
    }

    SMODS.Enhancement {
        key = 'blackjack',
        name = "Mega Blackjack Card",
        atlas = 'enhance',
        config = {},
        pos = {x = 0, y = 0},
        in_pool = function(self)
            return false
        end,
    }

    SMODS.Untarot {
        key = 'unfool',
        atlas = 'reversed_tarots',
        pos = {x = 0, y = 0},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            G.E_MANAGER:add_event(Event({
                func = function()
                    local suits = {'H', 'S', 'D', 'C'}
                    local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'}
                    local rank = pseudorandom_element(ranks, pseudoseed('untarot'))
                    local suit = pseudorandom_element(suits, pseudoseed('untarot'))
                    local card_ = create_playing_card({front = G.P_CARDS[suit..'_'..rank], center = G.P_CENTERS['m_hit_blackjack']}, G.deck, nil, nil, {G.C.SECONDARY_SET.Tarot})
                    shuffle_card_in_deck(card_)
                    return true
                end
            })) 
        end,
        config = {},
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = G.P_CENTERS['m_hit_blackjack']
            return {vars = {localize{type = 'name_text', set = 'Enhanced', key = 'm_hit_blackjack'}}}
        end,
        can_use = function(self, card)
            if G.deck then
                return true
            end
        end
    }

    SMODS.Untarot {
        key = 'unmagician',
        atlas = 'reversed_tarots',
        pos = {x = 1, y = 0},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.highlighted do
                local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() 
                    local suit = SMODS.Suits[G.hand.highlighted[i].base.suit].card_key
                    local og_base = G.hand.highlighted[i].config.card
                    G.hand.highlighted[i].ability.revert_base = og_base
                
                    G.hand.highlighted[i]:set_base(G.P_CARDS[suit..'_A'])
                    G.GAME.blind:debuff_card(G.hand.highlighted[i])
                    return true 
                end }))
            end
            for i=1, #G.hand.highlighted do
                local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        end,
        config = {max_highlighted = 3},
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.max_highlighted or 3, localize('Ace', 'ranks')}}
        end
    }

    SMODS.Untarot {
        key = 'unhigh_priestess',
        atlas = 'reversed_tarots',
        pos = {x = 2, y = 0},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            G.E_MANAGER:add_event(Event({
                func = function()
                    local suits = {'H', 'S', 'D', 'C'}
                    local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'}
                    local rank = pseudorandom_element(ranks, pseudoseed('untarot'))
                    local suit = pseudorandom_element(suits, pseudoseed('untarot'))
                    local common_rank = 'Ace'
                    local rank_c = 0
                    local common_suit = 'Hearts'
                    local suit_c = 0
                    G.GAME.hit_stood_ranks = G.GAME.hit_stood_ranks or {}
                    G.GAME.hit_stood_suits = G.GAME.hit_stood_suits or {}
                    for i, j in pairs(G.GAME.hit_stood_ranks) do
                        if j > rank_c then
                            rank_c = j
                            common_rank = i
                        end
                    end
                    for i, j in pairs(G.GAME.hit_stood_suits) do
                        if j > suit_c then
                            suit_c = j
                            common_suit = i
                        end
                    end
                    common_rank = SMODS.Ranks[common_rank].card_key
                    common_suit = SMODS.Suits[common_suit].card_key
                    local card_1 = create_playing_card({front = G.P_CARDS[suit..'_'..common_rank], center = G.P_CENTERS['c_base']}, G.deck, nil, nil, {G.C.SECONDARY_SET.Tarot})
                    local card_2 = create_playing_card({front = G.P_CARDS[common_suit..'_'..rank], center = G.P_CENTERS['c_base']}, G.deck, nil, nil, {G.C.SECONDARY_SET.Tarot})
                    shuffle_card_in_deck(card_1)
                    shuffle_card_in_deck(card_2)
                    return true
                end
            })) 
        end,
        config = {},
        loc_vars = function(self, info_queue, card)
            local common_rank = 'Ace'
            local rank_c = 0
            local common_suit = 'Hearts'
            local suit_c = 0
            G.GAME.hit_stood_ranks = G.GAME.hit_stood_ranks or {}
            G.GAME.hit_stood_suits = G.GAME.hit_stood_suits or {}
            for i, j in pairs(G.GAME.hit_stood_ranks) do
                if j > rank_c then
                    rank_c = j
                    common_rank = i
                end
            end
            for i, j in pairs(G.GAME.hit_stood_suits) do
                if j > suit_c then
                    suit_c = j
                    common_suit = i
                end
            end
            return {vars = {localize(common_rank, 'ranks'), localize(common_suit, 'suits_plural')}}
        end,
        can_use = function(self, card)
            if G.deck then
                return true
            end
        end
    }

    SMODS.Untarot {
        key = 'unempress',
        atlas = 'reversed_tarots',
        pos = {x = 3, y = 0},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            for i = 1, card.ability.cards do
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    if G.consumeables.config.card_limit > #G.consumeables.cards then
                        play_sound('timpani')
                        local new_card = SMODS.create_card {set = 'Untarot'}
                        new_card:add_to_deck()
                        G.consumeables:emplace(new_card)
                        used_tarot:juice_up(0.3, 0.5)
                    end
                    return true end }))
            end
            delay(0.6)
        end,
        config = {cards = 2},
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.cards or 2}}
        end,
        can_use = function(self, card)
            if #G.consumeables.cards < G.consumeables.config.card_limit or card.area == G.consumeables then
                return true
            end
        end
    }

    SMODS.Untarot {
        key = 'unemperor',
        atlas = 'reversed_tarots',
        pos = {x = 4, y = 0},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.highlighted do
                local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() 
                    local suit = SMODS.Suits[G.hand.highlighted[i].base.suit].card_key
                
                    G.hand.highlighted[i]:set_base(G.P_CARDS[suit..'_K'])
                    G.GAME.blind:debuff_card(G.hand.highlighted[i])
                    return true 
                end }))
            end
            for i=1, #G.hand.highlighted do
                local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        end,
        config = {max_highlighted = 2},
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.max_highlighted or 2, localize('King', 'ranks')}}
        end
    }

    SMODS.Untarot {
        key = 'unheirophant',
        atlas = 'reversed_tarots',
        pos = {x = 0, y = 1},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            local common_suit = "H"
            local suit_count = 0
            for i, j in pairs(SMODS.Suits) do
                local count = 0
                for i=1, #G.hand.highlighted do
                    if G.hand.highlighted[i]:is_suit(j.key) then
                        count = count + 1
                    end
                end
                if count > suit_count then
                    common_suit = j.card_key
                    suit_count = count
                end
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.highlighted do
                local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() 
                    local rank = SMODS.Ranks[G.hand.highlighted[i].base.value].card_key
                
                    G.hand.highlighted[i]:set_base(G.P_CARDS[common_suit..'_'..rank])
                    G.GAME.blind:debuff_card(G.hand.highlighted[i])
                    return true 
                end }))
            end
            for i=1, #G.hand.highlighted do
                local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        end,
        config = {max_highlighted = 200},
        can_use = function(self, card)
            if (G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.PLANET_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and (#G.hand.highlighted >= 1) then
                return true
            end
        end
    }

    SMODS.Rank {
        key = '0',
        card_key = 'Z',
        pos = { x = 0 },
        lc_atlas = 'ranks',
        hc_atlas = 'ranks',
        nominal = 0,
        next = { 'Ace' },
        in_pool = function(self, args)
            return false
        end
    }

    SMODS.Untarot {
        key = 'unlovers',
        atlas = 'reversed_tarots',
        pos = {x = 1, y = 1},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.highlighted do
                local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() 
                    local suit = SMODS.Suits[G.hand.highlighted[i].base.suit].card_key
                
                    G.hand.highlighted[i]:set_base(G.P_CARDS[suit..'_hit_Z'])
                    G.GAME.blind:debuff_card(G.hand.highlighted[i])
                    return true 
                end }))
            end
            for i=1, #G.hand.highlighted do
                local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        end,
        config = {max_highlighted = 1},
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.max_highlighted or 1, '0'}}
        end
    }

    SMODS.Untarot {
        key = 'unchariot',
        atlas = 'reversed_tarots',
        pos = {x = 2, y = 1},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.highlighted do
                local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() 
                    local suit = SMODS.Suits[G.hand.highlighted[i].base.suit].card_key
                    local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'}
                    local rank = pseudorandom_element(ranks, pseudoseed('untarot2'))
                
                    G.hand.highlighted[i]:set_base(G.P_CARDS[suit..'_'..rank])
                    G.GAME.blind:debuff_card(G.hand.highlighted[i])
                    return true 
                end }))
            end
            for i=1, #G.hand.highlighted do
                local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        end,
        config = {max_highlighted = 4},
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.max_highlighted or 4}}
        end
    }

    SMODS.Untarot {
        key = 'unjustice',
        atlas = 'reversed_tarots',
        pos = {x = 3, y = 1},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            ease_dollars(-card.ability.dollars)
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.highlighted do
                local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() 
                    local suit = SMODS.Suits[G.hand.highlighted[i].base.suit].card_key
                    local rank_data = SMODS.Ranks[G.hand.highlighted[i].base.value]
                    local up_rank = pseudorandom_element(rank_data.next, pseudoseed('untarot'))
                    up_rank = SMODS.Ranks[up_rank]
                    if up_rank then
                        rank_data = up_rank
                        up_rank = pseudorandom_element(rank_data.next, pseudoseed('untarot'))
                        up_rank = SMODS.Ranks[up_rank].card_key
                
                        G.hand.highlighted[i]:set_base(G.P_CARDS[suit..'_'..up_rank])
                        G.GAME.blind:debuff_card(G.hand.highlighted[i])
                    end
                    return true 
                end }))
            end
            for i=1, #G.hand.highlighted do
                local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        end,
        config = {dollars = 2, max_highlighted = 3},
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.dollars or 2, card and card.ability.max_highlighted or 3}}
        end
    }

    SMODS.Untarot {
        key = 'unhermit',
        atlas = 'reversed_tarots',
        pos = {x = 4, y = 1},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.highlighted do
                local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() 
                    G.hand.highlighted[i].ability.shuffle_bottom = card.ability.rounds
                    return true 
                end }))
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        end,
        config = {max_highlighted = 6, rounds = 4},
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.max_highlighted or 6, card and card.ability.rounds or 4}}
        end,
        can_use = function(self, card)
            if (G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.PLANET_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and (#G.hand.highlighted >= 1) and (#G.hand.highlighted <= (card and card.ability.max_highlighted or 6)) then
                return true
            end
        end
    }

    SMODS.Enhancement {
        key = 'nope',
        name = "Nope Card",
        atlas = 'enhance',
        config = {},
        pos = {x = 1, y = 0},
        in_pool = function(self)
            return false
        end,
    }

    SMODS.Untarot {
        key = 'unwheel_of_fortune',
        atlas = 'reversed_tarots',
        pos = {x = 0, y = 2},
        use = function(self, card, area, copier)
            ease_dollars(card.ability.dollars)
            if (pseudorandom('untarot_debuff') < G.GAME.probabilities.normal/card.ability.odds) then
                local used_tarot = copier or card
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    play_sound('tarot1')
                    used_tarot:juice_up(0.3, 0.5)
                    return true end }))
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local suits = {'H', 'S', 'D', 'C'}
                        local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'}
                        local rank = pseudorandom_element(ranks, pseudoseed('untarot'))
                        local suit = pseudorandom_element(suits, pseudoseed('untarot'))
                        local card_ = create_playing_card({front = G.P_CARDS[suit..'_'..rank], center = G.P_CENTERS['m_hit_nope']}, G.deck, nil, nil, {G.C.SECONDARY_SET.Tarot})
                        shuffle_card_in_deck(card_)
                        return true
                    end
                })) 
            end
        end,
        config = {dollars = 10, odds = 2},
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = G.P_CENTERS['m_hit_nope']
            return {vars = {card and card.ability.dollars or 5, G.GAME.probabilities.normal, card and card.ability.odds or 2, localize{type = 'name_text', set = 'Enhanced', key = 'm_hit_nope'}}}
        end,
        can_use = function(self, card)
            if G.deck then
                return true
            end
        end
    }

    SMODS.Untarot {
        key = 'unstrength',
        atlas = 'reversed_tarots',
        pos = {x = 1, y = 2},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.highlighted do
                local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)
            local did_debuff = (pseudorandom('untarot_debuff') < G.GAME.probabilities.normal/card.ability.odds)
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() 
                    local pool = {}
                    for j, k in pairs(G.P_CENTER_POOLS['Enhanced']) do
                        if not k.in_pool or (type(k.in_pool) ~= 'function') or k:in_pool() then
                            table.insert(pool, k)
                        end
                    end
                    local enhancement = pseudorandom_element(pool, pseudoseed('untarot'))
                    G.hand.highlighted[i]:set_ability(enhancement)
                    if did_debuff then
                        G.hand.highlighted[i].ability.perma_debuff = true
                    end
                    G.GAME.blind:debuff_card(G.hand.highlighted[i])
                    return true 
                end }))
            end
            for i=1, #G.hand.highlighted do
                local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        end,
        config = {odds = 5, max_highlighted = 4},
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.max_highlighted or 4, G.GAME.probabilities and G.GAME.probabilities.normal or 1, card and card.ability.odds or 5}}
        end
    }

    SMODS.Untarot {
        key = 'unhanged_man',
        atlas = 'reversed_tarots',
        pos = {x = 2, y = 2},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i = 1, card.ability.cards do
                        local suits = {'H', 'S', 'D', 'C'}
                        local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'}
                        local rank = pseudorandom_element(ranks, pseudoseed('untarot'))
                        local suit = pseudorandom_element(suits, pseudoseed('untarot'))
                        local pool = {}
                        for j, k in pairs(G.P_CENTER_POOLS['Enhanced']) do
                            if not k.in_pool or (type(k.in_pool) ~= 'function') or k:in_pool() then
                                table.insert(pool, k)
                            end
                        end
                        local enhancement = pseudorandom_element(pool, pseudoseed('untarot'))
                        local card_ = create_playing_card({front = G.P_CARDS[suit..'_'..rank], center = enhancement}, G.deck, nil, nil, {G.C.SECONDARY_SET.Tarot})
                        shuffle_card_in_deck(card_)
                    end
                    return true
                end
            })) 
        end,
        config = {cards = 2},
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.cards or 2}}
        end,
        can_use = function(self, card)
            if G.deck then
                return true
            end
        end
    }

    SMODS.Enhancement {
        key = 'garnet',
        name = "Garnet Card",
        atlas = 'enhance',
        config = {},
        pos = {x = 2, y = 0},
        in_pool = function(self)
            return false
        end,
    }

    SMODS.Untarot {
        key = 'undeath',
        atlas = 'reversed_tarots',
        pos = {x = 3, y = 2},
        config = {max_highlighted = 2, mod_conv = 'm_hit_garnet'},
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = G.P_CENTERS['m_hit_garnet']
            return {vars = {card and card.ability.max_highlighted or 2, localize{type = 'name_text', set = 'Enhanced', key = 'm_hit_garnet'}}}
        end
    }

    SMODS.Untarot {
        key = 'untemperance',
        atlas = 'reversed_tarots',
        pos = {x = 4, y = 2},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.highlighted do
                local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() 
                    local suit = SMODS.Suits[G.hand.highlighted[i].base.suit].card_key
                    local ranks = {'7', '7', '7', 'J', 'Q', 'K'}
                    local rank = pseudorandom_element(ranks, pseudoseed('untarot'))
                
                    G.hand.highlighted[i]:set_base(G.P_CARDS[suit..'_'..rank])
                    G.GAME.blind:debuff_card(G.hand.highlighted[i])
                    return true 
                end }))
            end
            for i=1, #G.hand.highlighted do
                local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        end,
        config = {max_highlighted = 4},
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.max_highlighted or 4, localize('7', 'ranks')}}
        end
    }

    SMODS.Untarot {
        key = 'undevil',
        atlas = 'reversed_tarots',
        pos = {x = 0, y = 3},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.highlighted do
                local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() 
                    local suit = SMODS.Suits[G.hand.highlighted[i].base.suit].card_key
                
                    G.hand.highlighted[i]:set_base(G.P_CARDS[suit..'_A'])
                    G.hand.highlighted[i].ability.perma_debuff = true
                    G.GAME.blind:debuff_card(G.hand.highlighted[i])
                    return true 
                end }))
            end
            for i=1, #G.hand.highlighted do
                local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        end,
        config = {max_highlighted = 2},
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.max_highlighted or 2, localize('Ace', 'ranks')}}
        end
    }

    SMODS.Enhancement {
        key = 'crazy',
        name = "Crazy Card",
        atlas = 'enhance',
        no_rank = true,
        no_suit = true,
        replace_base_card = true,
        config = {chips = 7},
        pos = {x = 0, y = 1},
        in_pool = function(self)
            return false
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.chips or 7}}
        end,
        calculate = function(self, card, context)
            if context.cardarea == G.play and context.main_scoring then
                return {chips = card and card.ability.chips or 7}
            end
        end
    }

    SMODS.Untarot {
        key = 'untower',
        atlas = 'reversed_tarots',
        pos = {x = 1, y = 3},
        config = {max_highlighted = 1, mod_conv = 'm_hit_crazy'},
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = G.P_CENTERS['m_hit_crazy']
            return {vars = {card and card.ability.max_highlighted or 1, localize{type = 'name_text', set = 'Enhanced', key = 'm_hit_crazy'}}}
        end
    }

    SMODS.Untarot {
        key = 'unstar',
        atlas = 'reversed_tarots',
        pos = {x = 2, y = 3},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            delay(0.2)
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() 
                local pool = {}
                for i = 1, #G.hand.cards do
                    table.insert(pool, G.hand.cards[i])
                end
                local destroy = {}
                for i = 1, (card and card.ability.cards or 3) do
                    local card2, index = pseudorandom_element(pool, pseudoseed('untarot'))
                    table.remove(pool, index)
                    table.insert(destroy, card2)
                end
                for i = 1, #destroy do
                    destroy[i]:start_dissolve()
                end
                return true 
            end }))
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        end,
        config = {cards = 3},
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.cards or 3}}
        end,
        can_use = function(self, card)
            if (G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.PLANET_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and (#G.hand.cards >= (card and card.ability.cards or 3)) then
                return true
            end
        end
    }

    SMODS.Untarot {
        key = 'unmoon',
        atlas = 'reversed_tarots',
        pos = {x = 3, y = 3},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.highlighted do
                local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() 
                    G.hand.highlighted[i].ability.shuffle_top = card.ability.rounds
                    return true 
                end }))
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        end,
        config = {max_highlighted = 3, rounds = 4},
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.max_highlighted or 3, card and card.ability.rounds or 4}}
        end,
    }

    SMODS.Untarot {
        key = 'unsun',
        atlas = 'reversed_tarots',
        pos = {x = 4, y = 3},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.highlighted do
                local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)
            local ranks = {}
            for i=1, #G.hand.highlighted do
                table.insert(ranks, SMODS.Ranks[G.hand.highlighted[i].base.value].card_key)
            end
            pseudoshuffle(ranks, pseudoseed('untarot'))
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() 
                    local suit = SMODS.Suits[G.hand.highlighted[i].base.suit].card_key
                    local rank = ranks[i] or 'A'
                
                    G.hand.highlighted[i]:set_base(G.P_CARDS[suit..'_' .. rank])
                    G.GAME.blind:debuff_card(G.hand.highlighted[i])
                    return true 
                end }))
            end
            for i=1, #G.hand.highlighted do
                local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        end,
        config = {},
        can_use = function(self, card)
            if (G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.PLANET_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and (#G.hand.highlighted >= 1) then
                return true
            end
        end
    }

    SMODS.Untarot {
        key = 'unjudgement',
        atlas = 'reversed_tarots',
        pos = {x = 0, y = 4},
        use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.highlighted do
                local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)

            local rank = get_smods_rank_from_id(G.hand.cards[1]).card_key
            for i=1, #G.hand.highlighted do
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function() 
                    local suit = SMODS.Suits[G.hand.highlighted[i].base.suit].card_key
                
                    G.hand.highlighted[i]:set_base(G.P_CARDS[suit..'_'..rank])
                    G.GAME.blind:debuff_card(G.hand.highlighted[i])
                    return true 
                end }))
            end
            for i=1, #G.hand.highlighted do
                local percent = 0.85 + (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        end,
        config = {max_highlighted = 2},
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability.max_highlighted or 2}}
        end
    }

    SMODS.Enhancement {
        key = 'osmium',
        name = "Osmium Card",
        atlas = 'enhance',
        config = {},
        pos = {x = 1, y = 1},
        in_pool = function(self)
            return false
        end,
    }

    SMODS.Untarot {
        key = 'unworld',
        atlas = 'reversed_tarots',
        pos = {x = 1, y = 4},
        config = {max_highlighted = 2, mod_conv = 'm_hit_osmium'},
        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = G.P_CENTERS['m_hit_osmium']
            return {vars = {card and card.ability.max_highlighted or 2, localize{type = 'name_text', set = 'Enhanced', key = 'm_hit_osmium'}}}
        end
    }

    for i = 1, 4 do
        SMODS.Booster {
            key = 'unarcana_normal_' .. tostring(i),
            group_key = 'k_unarcana_pack',
            weight = 1,
            cost = 4,
            name = "Unarcana Pack",
            atlas = "boosters",
            pos = {x = i - 1, y = 0},
            config = {extra = 3, choose = 1, name = "Unarcana Pack"},
            create_card = function(self, card)
                return {set = "Untarot", skip_materialize = true}
            end,
            loc_txt = {
                name = "Unarcana Pack",
                text = {
                    "Choose {C:attention}#1#{} of up to",
                    "{C:attention}#2#{C:attention} Untarot{} cards to",
                    "be used immediately"
                }
            },
            draw_hand = true,
            in_pool = function(self)
                return G.GAME.modifiers.dungeon
            end,
        }
    end

    for i = 1, 2 do
        SMODS.Booster {
            key = 'unarcana_jumbo_' .. tostring(i),
            group_key = 'k_unarcana_pack',
            weight = 1,
            cost = 6,
            name = "Unarcana Pack",
            atlas = "boosters",
            pos = {x = i - 1, y = 1},
            config = {extra = 5, choose = 1, name = "Unarcana Pack"},
            create_card = function(self, card)
                return {set = "Untarot", skip_materialize = true}
            end,
            loc_txt = {
                name = "Jumbo Unarcana Pack",
                text = {
                    "Choose {C:attention}#1#{} of up to",
                    "{C:attention}#2#{C:attention} Untarot{} cards to",
                    "be used immediately"
                }
            },
            draw_hand = true,
            in_pool = function(self)
                return G.GAME.modifiers.dungeon
            end,
        }
        SMODS.Booster {
            key = 'unarcana_mega_' .. tostring(i),
            group_key = 'k_unarcana_pack',
            weight = 1,
            cost = 8,
            name = "Unarcana Pack",
            atlas = "boosters",
            pos = {x = i + 1, y = 1},
            config = {extra = 5, choose = 2, name = "Unarcana Pack"},
            create_card = function(self, card)
                return {set = "Untarot", skip_materialize = true}
            end,
            loc_txt = {
                name = "Mega Unarcana Pack",
                text = {
                    "Choose {C:attention}#1#{} of up to",
                    "{C:attention}#2#{C:attention} Untarot{} cards to",
                    "be used immediately"
                }
            },
            draw_hand = true,
            in_pool = function(self)
                return G.GAME.modifiers.dungeon
            end,
        }
    end

-----------------

-----Jokers-------------

    SMODS.Joker {
        key = 'social',
        name = "Social Joker",
        rarity = 1,
        atlas = 'jokers',
        pos = {x = 0, y = 0},
        cost = 4,
        config = {t_mult = 8, type = 'hit_Court'},
        effect = "Type Mult",
        in_pool = function(self)
            return G.GAME.modifiers.dungeon, {allow_duplicates = false}
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability and card.ability.t_mult or 8, localize(card and card.ability and card.ability.type or 'hit_Court', 'poker_hands')}}
        end,
    }

    SMODS.Joker {
        key = 'manipulative',
        name = "Maniplulative Joker",
        rarity = 1,
        atlas = 'jokers',
        pos = {x = 1, y = 0},
        cost = 4,
        config = {t_mult = 12, type = 'hit_Duo'},
        effect = "Type Mult",
        in_pool = function(self)
            return G.GAME.modifiers.dungeon, {allow_duplicates = false}
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability and card.ability.t_mult or 12, localize(card and card.ability and card.ability.type or 'hit_Duo', 'poker_hands')}}
        end,
    }

    SMODS.Joker {
        key = 'creative',
        name = "Creative Joker",
        rarity = 1,
        atlas = 'jokers',
        pos = {x = 2, y = 0},
        cost = 4,
        config = {t_mult = 12, type = 'hit_Batch'},
        effect = "Type Mult",
        in_pool = function(self)
            return G.GAME.modifiers.dungeon, {allow_duplicates = false}
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability and card.ability.t_mult or 12, localize(card and card.ability and card.ability.type or 'hit_Batch', 'poker_hands')}}
        end,
    }

    SMODS.Joker {
        key = 'merry',
        name = "Merry Joker",
        rarity = 1,
        atlas = 'jokers',
        pos = {x = 3, y = 0},
        cost = 4,
        config = {t_chips = 50, type = 'hit_Court'},
        in_pool = function(self)
            return G.GAME.modifiers.dungeon, {allow_duplicates = false}
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability and card.ability.t_chips or 50, localize(card and card.ability and card.ability.type or 'hit_Court', 'poker_hands')}}
        end,
    }

    SMODS.Joker {
        key = 'secretive',
        name = "Secretive Joker",
        rarity = 1,
        atlas = 'jokers',
        pos = {x = 4, y = 0},
        cost = 4,
        config = {t_chips = 80, type = 'hit_Duo'},
        in_pool = function(self)
            return G.GAME.modifiers.dungeon, {allow_duplicates = false}
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability and card.ability.t_chips or 80, localize(card and card.ability and card.ability.type or 'hit_Duo', 'poker_hands')}}
        end,
    }

    SMODS.Joker {
        key = 'hoarding',
        name = "Hoarding Joker",
        rarity = 1,
        atlas = 'jokers',
        pos = {x = 0, y = 1},
        cost = 4,
        config = {t_chips = 100, type = 'hit_Batch'},
        in_pool = function(self)
            return G.GAME.modifiers.dungeon, {allow_duplicates = false}
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability and card.ability.t_chips or 100, localize(card and card.ability and card.ability.type or 'hit_Batch', 'poker_hands')}}
        end,
    }

    SMODS.Joker {
        key = 'friends',
        name = "The Friends",
        rarity = 3,
        atlas = 'jokers',
        pos = {x = 1, y = 1},
        cost = 8,
        config = {Xmult = 2, type = 'hit_Court'},
        in_pool = function(self)
            return G.GAME.modifiers.dungeon, {allow_duplicates = false}
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability and card.ability.Xmult or 2, localize(card and card.ability and card.ability.type or 'hit_Court', 'poker_hands')}}
        end,
    }

    SMODS.Joker {
        key = 'pair',
        name = "The Pair",
        rarity = 3,
        atlas = 'jokers',
        pos = {x = 2, y = 1},
        cost = 8,
        config = {Xmult = 3, type = 'hit_Duo'},
        in_pool = function(self)
            return G.GAME.modifiers.dungeon, {allow_duplicates = false}
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability and card.ability.Xmult or 3, localize(card and card.ability and card.ability.type or 'hit_Duo', 'poker_hands')}}
        end,
    }

    SMODS.Joker {
        key = 'bundle',
        name = "The Bundle",
        rarity = 3,
        atlas = 'jokers',
        pos = {x = 3, y = 1},
        cost = 8,
        config = {Xmult = 3, type = 'hit_Batch'},
        in_pool = function(self)
            return G.GAME.modifiers.dungeon, {allow_duplicates = false}
        end,
        loc_vars = function(self, info_queue, card)
            return {vars = {card and card.ability and card.ability.Xmult or 3, localize(card and card.ability and card.ability.type or 'hit_Batch', 'poker_hands')}}
        end,
    }

------------------------

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
        G.GAME.hit_hand_sum_total = G.GAME.hit_hand_sum_total or '???'
        local button = t.nodes[index]
        button.nodes[1].nodes[1].config.text = nil
        button.nodes[1].nodes[1].config.ref_value = 'hit_hand_sum_total'
        button.nodes[1].nodes[1].config.ref_table = G.GAME
        button.config.button = 'stand'
        button.config.func = 'can_stand'
        -- button.config.color = G.C[checking[G.GAME.passive].colour]
    end
    return t
end

function check_total_over_21()
    if G.GAME.modifiers.dungeon and not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) then
        G.GAME.hit_hand_sum_total = get_hand_sum()
        local data = get_card_total(G.hand.cards, false)
        if (data.total > data.bust_limit) and not G.GAME.hit_busted then
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    if hide_sum() then
                        play_area_status_text("Bust (??)")
                    else
                        play_area_status_text("Bust (" .. tostring(data.total) .. ")")
                    end
                    return true
                end
            }))
            G.GAME.hit_busted = true
        elseif (data.total <= data.bust_limit) then
            G.GAME.hit_busted = nil
        end
    end
end

function get_hand_sum()
    local data = get_card_total(G.hand.cards)
    if hide_sum() then
        return localize("b_stand") .. ' ??'
    elseif data.soft then
        return localize("b_stand") .. ' S' .. tostring(data.total)
    elseif data.total > data.bust_limit then
        return localize("b_stand") .. ' ' .. tostring(data.total) .. 'B'
    else
        return localize("b_stand") .. ' ' .. tostring(data.total)
    end
end

function get_card_total(cards, do_soft, bonus_total)
    if do_soft == nil then
        do_soft = true
    end
    local suits = SMODS.Suit.obj_buffer
    local map = {}
    local total = bonus_total or 0
    local aces = 0
    local variance = 0
    local bust_limit = G.GAME.hit_bust_limit or 21
    local req_count = 0
    local soft = false
    for i = 1, #cards do
        local id = cards[i]:get_id()
        local valid = true
        if id > 0 then
            local rank = get_smods_rank_from_id(cards[i])
            local nominal = rank.nominal
            if not cards[i].debuff and cards[i].ability.trading and cards[i].ability.trading.config.hit_hand_value then
                total = total + cards[i].ability.trading.config.hit_hand_value
            elseif rank.key == 'Ace' then
                total = total + 1
                aces = aces + 1
            else
                total = total + nominal
            end
            if not cards[i].debuff and cards[i].ability.trading and cards[i].ability.trading.config.hit_hand_aces then
                aces = aces + cards[i].ability.trading.config.hit_hand_aces
            end
        elseif cards[i].ability.name == 'Crazy Card' then
            total = total - 3
            aces = aces + 1
        else
            valid = false
        end
        if not cards[i].debuff and (cards[i].ability.name == 'Mega Blackjack Card') then
            total = total + 1
            variance = variance + 3
            valid = true
        elseif not cards[i].debuff and (cards[i].ability.name == 'Nope Card') then
            total = total + 13
            valid = true
        end
        if valid then
            req_count = req_count + 1
            for j = 1, #suits do
                if cards[i]:is_suit(suits[j], nil, true) then
                    map[suits[j]] = map[suits[j]] or {}
                    map[suits[j]][#map[suits[j]]+1] = cards[i] 
                end
            end
        end
    end
    if do_soft then
        while (total <= bust_limit - 10) and (aces >= 1) do
            aces = aces - 1
            total = total + 10
            soft = true
        end
        while (total <= bust_limit - 1) and (variance >= 1) do
            variance = variance - 1
            total = total + 1
            soft = true
        end
    end
    return {
        total = total,
        bust_limit = bust_limit,
        suit_map = map,
        card_count = req_count,
        soft = soft
    }
end

function hide_sum()
    for i = 1, #G.hand.cards do
        if G.hand.cards[i].facing == 'back' then
            return true
        end
    end
    return false
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
    for i = 1, #G.hand.cards do
        if G.hand.cards[i].calculate_exotic then
            G.hand.cards[i]:calculate_exotic({hit = true, cardarea = G.hand})
        end
    end
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
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            G.STATE = G.STATES.HAND_PLAYED
            G.STATE_COMPLETE = true
            return true
        end
    }))
    local add_total = 0
    for i = 1, #G.hand.cards do
        if G.hand.cards[i].ability.name == 'Osmium Card' then
            add_total = add_total + 2
        end
        if G.hand.cards[i].calculate_exotic then
            G.hand.cards[i]:calculate_exotic({stand = true, cardarea = G.hand})
        end
    end
    local y_data = get_card_total(G.hand.cards, nil, add_total)
    local total = y_data.total
    G.GAME.hit_busted = nil
    G.GAME.stood = true
    G.GAME.hit_stood_ranks = G.GAME.hit_stood_ranks or {}
    G.GAME.hit_stood_suits = G.GAME.hit_stood_suits or {}
    local bl_total = 0
    local bl_cards = {}
    local total_list = {}
    while true do
        local index = #G.enemy_deck.cards - #bl_cards
        if index <= 0 then
            break
        else
            local id = G.enemy_deck.cards[index]:get_id()
            table.insert(bl_cards, G.enemy_deck.cards[index])
            local bl_data = get_card_total(bl_cards)
            bl_total = bl_data.total
            table.insert(total_list, bl_total)
            if (bl_total >= bl_data.bust_limit - 4) then
                break
            end
        end
    end
    if total > y_data.bust_limit then
        total = -1e15
    end
    local bl_data = get_card_total(bl_cards, nil, add_total)
    bl_total = bl_data.total
    if bl_total > bl_data.bust_limit then
        bl_total = -1e15
    end
    local force_push = nil
    for i = 1, #bl_cards  do
        if not bl_cards[i].debuff and bl_cards[i].ability.trading and (bl_cards[i].ability.trading.name == 'Sun Two') then
            force_push = true
            break
        end
    end
    for i = 1, #G.hand.cards do
        if not G.hand.cards[i].debuff and G.hand.cards[i].ability.trading and (G.hand.cards[i].ability.trading.name == 'Sun Two') then
            force_push = true
            break
        end
    end
    if force_push then
        if (bl_total ~= -1e15) then
            bl_total = 0
        end
        if (total ~= -1e15) then
            total = 0
        end
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            if #bl_cards > 0 then
                for i = 1, #bl_cards do
                    draw_card(G.enemy_deck, G.play, i*100/5, 'up')
                    force_up_status_text = true
                    local color = G.C.FILTER
                    if total_list[i] > (bl_data.bust_limit) then
                        color = G.C.RED
                    elseif total_list[i] >= (bl_data.bust_limit - 4) then
                        color = G.C.GREEN
                    end
                    card_eval_status_text(bl_cards[i], 'extra', nil, nil, nil, {message = tostring(total_list[i]), colour = color})
                    force_up_status_text = nil
                end
            end
            delay(0.5)
            if bl_total < total then
                if bl_total == -1e15 then
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
                            draw_card(G.play, G.enemy_discard, i*100/5, 'up')
                        end
                        G.E_MANAGER:add_event(Event({
                            trigger = 'immediate',
                            func = function()
                                for i = 1, #G.hand.cards do
                                    if not G.hand.cards[i].highlighted then
                                        G.hand:add_to_highlighted(G.hand.cards[i])
                                    end
                                    local id = G.hand.cards[i]:get_id()
                                    local suit = SMODS.Suits[G.hand.cards[i].base.suit] or {}
                                    if id > 0 then
                                        local rank = get_smods_rank_from_id(G.hand.cards[i])
                                        G.GAME.hit_stood_ranks[rank.key] = (G.GAME.hit_stood_ranks[rank.key] or 1) + 1
                                    end
                                    if G.hand.cards[i]:is_suit(suit.key) then
                                        G.GAME.hit_stood_suits[suit.key] = (G.GAME.hit_stood_suits[suit.key] or 1) + 1
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
                if bl_total == -1e15 then
                    if hide_sum() then
                        play_area_status_text("Push (?? = Bust)")
                    else
                        play_area_status_text("Push (Bust = Bust)")
                    end
                else
                    if hide_sum() then
                        play_area_status_text("Push (?? = " .. tostring(bl_total) .. ")")
                    else
                        play_area_status_text("Push (" .. tostring(total) .. " = " .. tostring(bl_total) .. ")")
                    end
                end
                G.GAME.hit_limit = 2
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        for i = 1, #G.play.cards do
                            draw_card(G.play, G.enemy_discard, i*100/5, 'up')
                        end
                        for i = #G.hand.cards, 1, -1 do
                            if G.hand.cards[i].ability.name ~= 'Garnet Card' then
                                draw_card(G.hand, G.discard, i*100/5, 'up', nil, G.hand.cards[i])
                            end
                        end
                        G.E_MANAGER:add_event(Event({
                            trigger = 'immediate',
                            func = function()
                                G.STATE_COMPLETE = false
                                return true
                            end
                        }))
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
                if total == -1e15 then
                    if hide_sum() then
                        play_area_status_text("Loss (?? < " .. tostring(bl_total) .. ")")
                    else
                        play_area_status_text("Loss (Bust < " .. tostring(bl_total) .. ")")
                    end
                else
                    if hide_sum() then
                        play_area_status_text("Loss (?? < " .. tostring(bl_total) .. ")")
                    else
                        play_area_status_text("Loss (" .. tostring(total) .. " < " .. tostring(bl_total) .. ")")
                    end
                end
                G.GAME.hit_limit = 2
                ease_hands_played(-1)
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            trigger = 'immediate',
                            func = function()
                                for i = #G.hand.cards, 1, -1 do
                                    if G.hand.cards[i].ability.name ~= 'Garnet Card' then
                                        draw_card(G.hand, G.discard, i*100/5, 'up', nil, G.hand.cards[i])
                                    end
                                end
                                G.GAME.negate_hand = true
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
                                                draw_card(G.play,G.enemy_discard, it*100/play_count,'down', false, v)
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
            if #G.enemy_deck.cards - #bl_cards <= 0 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        for i = 1, #G.enemy_discard.cards do
                            draw_card(G.enemy_discard, G.enemy_deck, i*100/5, 'up')
                        end
                        return true
                    end
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        G.enemy_deck:shuffle('enemy_deck')
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

function set_blackjack_mode()
    G.GAME.modifiers = G.GAME.modifiers or {}
    G.GAME.modifiers.dungeon = true
    for hand, j in pairs(G.GAME.hands) do
        G.GAME.hands[hand].visible = false
        if G.GAME.hands[hand].bj_mode then
            G.GAME.hands[hand].visible = true
        end
    end
    for _, list in pairs(bj_ban_list) do
        for k, v in ipairs(list) do
            G.GAME.banned_keys[v.id] = true
        end
    end
    G.GAME.untarot_rate = 4
end

SMODS.Back {
    key = 'aced',
    name = "Aced Deck",
    pos = { x = 0, y = 0 },
    atlas = 'decks',
    apply = function(self)
        set_blackjack_mode()
        G.E_MANAGER:add_event(Event({
            func = function()
                for i, j in ipairs({'H', 'S', 'D', 'C'}) do
                    local _card = Card(G.deck.T.x, G.deck.T.y, G.CARD_W, G.CARD_H, G.P_CARDS[j .. '_A'], G.P_CENTERS['c_base'], {playing_card = G.playing_card})
                    G.deck:emplace(_card)
                    table.insert(G.playing_cards, _card)
                end
            return true
            end
        }))
    end,
}

SMODS.Back {
    key = 'overload',
    name = "Overload Deck",
    pos = { x = 1, y = 0 },
    atlas = 'decks',
    apply = function(self)
        set_blackjack_mode()
        G.GAME.hit_bust_limit = (G.GAME.hit_bust_limit or 21) + 3
    end,
}

if CardSleeves and CardSleeves.Sleeve then
    CardSleeves.Sleeve {
		key = "aced_sl",
		name = "Aced Sleeve",
		atlas = "sleeves",
		pos = { x = 0, y = 0 },

		loc_vars = function(self)
			local key
			if self.get_current_deck_key() ~= "b_hit_aced" and self.get_current_deck_key() ~= "b_hit_overload" then
				key = self.key
			else
				key = self.key .. "_alt"
			end
			return {key = key}
		end,
		apply = function(self)
			if self.get_current_deck_key() ~= "b_hit_aced" and self.get_current_deck_key() ~= "b_hit_overload" then
                set_blackjack_mode()
			end
            G.E_MANAGER:add_event(Event({
                func = function()
                    for i, j in ipairs({'H', 'S', 'D', 'C'}) do
                        local _card = Card(G.deck.T.x, G.deck.T.y, G.CARD_W, G.CARD_H, G.P_CARDS[j .. '_A'], G.P_CENTERS['c_base'], {playing_card = G.playing_card})
                        G.deck:emplace(_card)
                        table.insert(G.playing_cards, _card)
                    end
                return true
                end
            }))
		end
	}
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

-----------Cross Mod Stuff----

if pc_add_cross_mod_card then
    pc_add_cross_mod_card {
        key = 'mega_ace',
        card = {
            key = 'mega_ace', 
            unlocked = true, 
            discovered = true, 
            atlas = 'hit_pc_cards', 
            cost = 1, 
            name = "Mega Ace", 
            pos = {x=0,y=0},
            config = {chips = 11, hit_hand_value = 11, hit_hand_aces = 1}, 
            base = "H_A"
        },
        calculate = function(card, effects, context, reps)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                table.insert(effects, {
                    chips = config_thing.chips,
                    card = card
                })
            elseif context.get_id then
                return 14
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips}
        end
    }

    pc_add_cross_mod_card {
        key = 'sun_two',
        card = {
            key = 'sun_two', 
            unlocked = true, 
            discovered = true, 
            atlas = 'hit_pc_cards', 
            cost = 1, 
            name = "Sun Two", 
            pos = {x=1,y=0},
            config = {}, 
            base = "D_2"
        },
        calculate = function(card, effects, context, reps)
            if context.get_id then
                return 2
            elseif context.is_face then
                return true
            end
        end,
    }

    pc_add_cross_mod_card {
        key = 'adrenalten',
        card = {
            key = 'adrenalten', 
            unlocked = true, 
            discovered = true, 
            atlas = 'hit_pc_cards', 
            cost = 1, 
            name = "Adrenaline Ace", 
            pos = {x=2,y=0},
            config = {mult = 0, gain = 1}, 
            base = "H_T"
        },
        calculate = function(card, effects, context, reps)
            local config_thing = card.ability.trading.config 
            if context.get_id then
                return 10
            elseif context.playing_card_main then
                table.insert(effects, {
                    mult = config_thing.mult,
                    card = card
                })
            elseif context.hit then
                config_thing.mult = config_thing.mult + config_thing.gain
                card_eval_status_text(card, 'jokers', nil, nil, nil, {message = localize{type='variable',key='a_mult',vars={config_thing.gain}}, colour = G.C.RED})
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {localize("Hearts", 'suits_plural'), config_thing.gain, config_thing.mult}
        end
    }

    pc_add_cross_mod_card {
        key = 'bottomless_pit',
        card = {
            key = 'bottomless_pit', 
            unlocked = true, 
            discovered = true, 
            atlas = 'hit_pc_cards', 
            cost = 1, 
            name = "Bottomless Pit", 
            pos = {x=3,y=0},
            config = {chips = 10, hit_hand_value = 10, gain = -10}, 
            base = "S_T"
        },
        calculate = function(card, effects, context, reps)
            local config_thing = card.ability.trading.config 
            if context.playing_card_main then
                table.insert(effects, {
                    chips = config_thing.chips,
                    card = card
                })
            elseif context.get_id then
                return 10
            elseif context.stand and G.GAME.hit_busted then
                config_thing.hit_hand_value = config_thing.hit_hand_value + config_thing.gain
                card_eval_status_text(card, 'jokers', nil, nil, nil, {message = tostring(config_thing.gain), colour = G.C.RED})
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            return {config_thing.chips, config_thing.gain, config_thing.hit_hand_value}
        end
    }

    pc_add_cross_mod_card {
        key = 'hydra',
        card = {
            key = 'hydra', 
            unlocked = true, 
            discovered = true, 
            atlas = 'hit_pc_cards', 
            cost = 1, 
            name = "Adrenaline Ace", 
            pos = {x=0,y=1},
            config = {chips = 3}, 
            base = "D_3"
        },
        calculate = function(card, effects, context, reps)
            local config_thing = card.ability.trading.config 
            if context.get_id then
                return 3
            elseif context.playing_card_main then
                table.insert(effects, {
                    chips = config_thing.chips,
                    card = card
                })
            elseif context.hit then
                card_eval_status_text(card, 'jokers', nil, nil, nil, {message = localize('ow_ex'), colour = G.C.RED})
                G.E_MANAGER:add_event(Event({ func = function()
                    local card2 = copy_card(card, nil, nil, true)
                    card2:start_materialize()
                    G.hand:emplace(card2)
                    table.insert(G.playing_cards, card2)
                    card2.ability.fleeting = true
                    return true
                end
                }))
                G.GAME.hit_limit = (G.GAME.hit_limit or 2) + 1
            elseif context.is_face then
                return true
            end
        end,
        loc_vars = function(specific_vars, info_queue, card)
            local config_thing = specific_vars.collect.config
            info_queue[#info_queue+1] = {key = 'fleeting', set = 'Other'}
            return {config_thing.chips}
        end
    }
end

------------------------------

bj_ban_list = {
    banned_cards = {
        -- effective useless
        {id = 'j_jolly'},
        {id = 'j_zany'},
        {id = 'j_mad'},
        {id = 'j_sly'},
        {id = 'j_wily'},
        {id = 'j_clever'},
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
        {id = 'j_duo'},
        {id = 'j_trio'},
        {id = 'j_family'},
        {id = 'j_order'},
        {id = 'j_tribe'},
        {id = 'j_trousers'},
        -- really useless
        {id = 'j_mime'},
        {id = 'j_raised_fist'},
        {id = 'j_blackboard'},
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
        {id = 'c_pluto'},
        {id = 'c_mercury'},
        {id = 'c_venus'},
        {id = 'c_uranus'},
        {id = 'c_planet_x'},
        {id = 'c_ceres'},
        {id = 'c_eris'},
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
        {id = 'bl_fish', type = 'blind'},
    }
}

function G.UIDEF.view_enemy_deck(unplayed_only)
	local deck_tables = {}
    local all_cards = {}
    if G.enemy_deck and G.enemy_deck.cards then
        for i = 1, #G.enemy_deck.cards do
            table.insert(all_cards, G.enemy_deck.cards[i])
        end
    end
    if G.enemy_discard and G.enemy_discard.cards then
        for i = 1, #G.enemy_discard.cards do
            table.insert(all_cards, G.enemy_discard.cards[i])
        end
    end
	G.VIEWING_DECK = true
	table.sort(all_cards, function(a, b) return a:get_nominal('suit') > b:get_nominal('suit') end)
	local SUITS = {}
	local suit_map = {}
	for i = #SMODS.Suit.obj_buffer, 1, -1 do
		SUITS[SMODS.Suit.obj_buffer[i]] = {}
		suit_map[#suit_map + 1] = SMODS.Suit.obj_buffer[i]
	end
	for k, v in ipairs(all_cards) do
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
                    if not ((SUITS[suit_map[j]][i].area and SUITS[suit_map[j]][i].area == G.enemy_deck)) then
                        greyed = true
                    end
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

	for k, v in ipairs(all_cards) do
		if (v.ability.name ~= 'Stone Card') and (v.area and v.area == G.enemy_deck) then
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

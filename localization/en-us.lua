return {
    descriptions = {
        Back = {
            b_hit_aced = {
                name = "Aced Deck",
                text = {
                    "{C:attention}Blackjack Mode{}",
                    "Start with {C:attention}4{} extra",
                    "{C:attention}Aces{}",
                }
            },
            b_hit_overload = {
                name = "Overload Deck",
                text = {
                    "{C:attention}Blackjack Mode{}",
                    "{C:attention}+3{} Bust Limit",
                }
            },
        },
        Sleeve = {
            sleeve_hit_aced_sl = {
                name = "Aced Sleeve",
                text = { 
					"{C:attention}Blackjack Mode{}",
                    "Start with {C:attention}4{} extra",
                    "{C:attention}Aces{}",
				}
            },
            sleeve_hit_aced_sl_alt = {
                name = "Aced Sleeve",
                text = { 
                    "Start with {C:attention}4{} more extra",
                    "{C:attention}Aces{}",
				}
			},		
		},
        Other = {
            undiscovered_untarot = {
                name = "Not Discovered",
                text = {
                    "Purchase or use",
                    "this card in an",
                    "unseeded run to",
                    "learn what it does"
                }
            },
            hit_hermit_indicator = {
                name = "Note",
                text = {
                    "Shuffled to",
                    "bottom of deck",
                }
            },
            revert_base = {
                name = "Note",
                text = {
                    "Reverts to a {C:attention}#1#{}",
                    "of {C:attention}#2#{} at",
                    "end of round"
                }
            },
        },
        Untarot = {
            c_hit_unmagician = {
                name = "The Reversed Magician",
                text = {
                    "Converts up to {C:attention}#1#{}",
                    "selected cards to {C:attention}#2#s{}",
                    "until next round"
                }
            },
            c_hit_unhigh_priestess = {
                name = "The Reversed High Priestess",
                text = {
                    "Create {C:attention}1{} card of your",
                    "most played {C:attention}rank{} and {C:attention}1{} of",
                    "your most played {C:attention}suit{}",
                    "{C:inactive}({C:attention}#1#{C:inactive}, {C:attention}#2#{C:inactive}){}"
                }
            },
            c_hit_unemperor = {
                name = "The Reversed Emperor",
                text = {
                    "Converts up to {C:attention}#1#{}",
                    "selected cards to {C:attention}#2#s{}",
                }
            },
            c_hit_unheirophant = {
                name = "The Reversed Heirophant",
                text = {
                    "Convert all {C:attention}selected{} cards",
                    "to the most currently {C:attention}selected{}",
                    "{C:attention}suit{}"
                }
            },
            c_hit_unchariot = {
                name = "The Reversed Chariot",
                text = {
                    "Converts up to {C:attention}#1#{}",
                    "selected cards to {C:attention}random{}",
                    "{C:attention}ranks{}",

                }
            },
            c_hit_unjustice = {
                name = "The Reversed Justice",
                text = {
                    "Lose {C:red}$#1#{}, Increases",
                    "rank of up to {C:attention}#2#{}",
                    "selected cards by {C:attention}2{}"

                }
            },
            c_hit_unhermit = {
                name = "The Reversed Hermit",
                text = {
                    "Up to {C:attention}#1#{} selected cards will",
                    "be shuffled to the {C:attention}bottom{} of the",
                    "deck at the start of {C:attention}next round{}"

                }
            },
            c_hit_unstrength = {
                name = "Reversed Strength",
                text = {
                    "Enhances up to {C:attention}#1#{} selected",
                    "cards, {C:green}#2# in #3#{} chance to",
                    "{C:red}debuff{} selected cards"

                }
            },
        }
    },
    misc = {
        dictionary = {
            k_blindeffect = "Blind Effect",
            b_blindeffect_cards = "Blind Effects",
            b_loot = "Loot",
            b_common_loot = "Common",
            b_uncommon_loot = "Uncommon",
            b_rare_loot = "Rare",
            b_hit = "Hit",
            b_stand = "Stand",
            ph_blackjack_lost = "You Lost",
            b_choose_cards = "Choose Cards",
            b_exit = "Exit",
            ph_test_memory = "Test your Memory!",
            b_enemy_deck = "Enemy Deck",
            k_untarot = "Untarot",
            b_untarot_cards = "Untarot Cards",
        },
        v_text = {
            ch_c_ante_hand_discard_reset = {"{C:blue}Hands{} and {C:red}Discards{} are only reset each {C:attention}Ante{}."},
            ch_c_dungeon = {"{C:attention}Blackjack Mode{}"},
        },
        v_dictionary = {
        },
        challenge_names = {
            c_blackjack = "Blackjack"
        },
        labels = {
        }
    }
}

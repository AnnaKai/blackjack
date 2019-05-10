$LOAD_PATH.unshift File.dirname(__FILE__)
require "constants"
require "ui"

require "deck"
require "card"
require "hand"
require "player"
require "dealer"

# BlackJack game
class Game

  include UiHelper
  include Constants

  attr_accessor :player, :dealer, :deck

  def initialize
    @deck = Deck.new
    @deck.shuffle!
    @dealer = Dealer.new("Dealer")
    @player = Player.new("")
    @game_over = false
  end

  def launch!
    intro
    set_player
    new_round until @game_over
    conclusion
  end

  private

  def intro
    welcome
  end

  def set_player
    welcome_player
    ask_name
  end

  def new_round
    set_round
    deal_cards
    show_hands
    if dealer_has_ace?
      insurance_offer if enough_money?
      dealer_decides
    elsif player_has_bc?
      dealer_checks
    else
      player_decides
    end
    dealer_hits if can_hit? && !@game_over
    set_result unless @game_over
  end

  def set_round
    clear_table unless @player.hands.empty?
    initial_bet
  end

  def ask_name
    @player.name = ask(ask_name_notice) while @player.name.empty?
  end

  def clear_table
    @player.reset_hands
    @dealer.hand = Hand.new
    (@deck.build_shoe(1); @deck.shuffle!) if @deck.need_extra?
  end

  def initial_bet
    bet = 0
    bet = ask_bet until player.valid?(bet)
    player.place_bet(player.first_hand, bet)
  end

  def deal_cards
    dealing_cards_notice
    2.times do
      @player.first_hand.add_card(@deck.deal_card)
      @dealer.hand.add_card(@deck.deal_card)
    end
  end

  def show_hands
    card_value_notice(@player.name)
    player_shows_hands
    dealer_shows_first_hand
  end

  def dealer_checks
    dealer.hand.blackjack? ? push : player_wins_with_bc # if dealer doesnt have a natural blackjack, player wins
  end

  def dealer_decides
    dealer_checks_notice
    if @dealer.hand.blackjack?
      dealer_shows_bc
      pay_insurance if insurance?
      @player.first_hand.blackjack? ? push : player_busts
    else
      dealer_without_bc
      reset_insurance if insurance?
      player_decides
    end
  end

  def player_decides(hand = @player.current_hand)
    if hand.value == MAX_POINTS
      player_stands
    else
      suggest_options(hand)
    end
  end

  def suggest_options(hand = @player.current_hand)
    available_options = create_options(hand)
    answer = ""
    until available_options.key? answer
      hand_num = @player.current_hand_index
      available_options_notice(hand_num)
      hand_value_reminder(hand)
      show_options(available_options)
      answer = input
    end
    case answer
    when "s" then player_stands
    when "h" then player_hits(hand)
    when "d" then player_doubles(hand)
    when "p" then player_splits(hand)
    end
  end

  def create_options(hand)
    options = STAND_KEY_MAP.merge(HIT_KEY_MAP)
    options.merge!(DOUBLE_DOWN_KEY_MAP) if hand.just_dealt? && player.hands.length == 1 && player.bankroll >= hand.bet
    options.merge!(SPLIT_KEY_MAP) if hand.splittable? && player.hands.length < MAX_HANDS && player.bankroll >= hand.bet
    options
  end

  def player_stands
    next_hand = @player.next_hand
    player_stands_notice
    player_decides(next_hand) unless next_hand.nil?
  end

  def player_splits(hand)
    player_splits_notice
    new_hand = player.split(hand)
    hand.add_card(@deck.deal_card)
    new_hand.add_card(@deck.deal_card)
    show_hand(hand)
    hand_value_reminder(hand)
    show_hand(new_hand)
    hand_value_reminder(new_hand)
    player_decides
  end

  def player_doubles(hand)
    player_dd_notice
    player.place_bet(hand, player.first_hand.bet)
    hand.add_card(@deck.deal_card)
    show_hand(hand)
    hand_value_reminder(hand)
    if hand.value > MAX_POINTS
      player_busts
    elsif hand.value == MAX_POINTS
      player_stands
    elsif can_hit?
      dealer_hits
    end
  end

  def player_hits(hand)
    player_hits_notice
    @player.hit(hand, @deck.deal_card)
    show_hand(hand)
    hand_value_reminder(hand)
    if hand.value > MAX_POINTS
      hand_busts
    elsif hand.value == MAX_POINTS
      player_stands
    else
      suggest_options(hand)
    end
  end

  def hand_busts
    hand_busts_alert
    if player.hands.all?(&:bust?)
      player_busts
    else
      next_hand = @player.next_hand
      suggest_options(next_hand) unless next_hand.nil?
    end
  end

  def dealer_hits
    dealer_hits_notice
    @dealer.hand.add_card(@deck.deal_card)
    card_value_notice(@dealer.name)
    dealer_shows_cards
    dealer_hand_value
    dealer_hits until @dealer.hand.value >= STAND_VALUE
  end

  def set_result
    if dealer.hand.bust?
      dealer_busts_notice
      player_wins
    else
      dealer_checks_notice
      dealer_shows_cards
      dealer_hand_value
      player.hands.each_with_index do |hand, index|
        if hand.bust?
          player.hands.delete(hand)
        elsif hand.value > dealer.hand.value
          hand_wins_notice(index)
          player.bankroll += 2 * hand.bet
        elsif hand.value == dealer.hand.value
          hand_pushes_notice(index)
          player.bankroll += hand.bet
        else
          hand_lost_notice(index)
        end
      end
    end
    bankroll_notice
    play_more?
  end

  def can_hit?
    @dealer.hand.value < STAND_VALUE
  end

  def dealer_has_ace?
    @dealer.hand.cards.first.rank == "Ace"
  end

  def player_has_bc?
    player.first_hand.blackjack?
  end

  def insurance_offer
    answers = %w[y n]
    answer = ""
    until answers.include? answer
      ask(ask_insurance)
      case answer
      when "y" then @player.side_bet
      when "n" then return
      else wrong_answer
      end
    end
  end

  def enough_money?
    @player.bankroll >= @player.first_hand.bet / 2
  end

  def insurance?
    @player.first_hand.insurance_bet > 0
  end

  def pay_insurance
    @player.bankroll += @player.first_hand.insurance_bet * 2
    reset_insurance
  end

  def reset_insurance
    @player.first_hand.insurance_bet = 0
  end

  def push
    hand_pushes_notice(@player.current_hand_index)
    @player.bankroll += @player.first_hand.bet + @player.first_hand.insurance_bet
    play_more?
  end

  def player_wins
    player_wins_notice
    player.hands.each do |hand|
      player.bankroll += hand.bet * 2
    end
  end

  def player_wins_with_bc
    dealer_shows_cards
    player_wins_with_bc_notice
    bet = @player.first_hand.bet
    @player.bankroll += bet * 2.5
    play_more?
  end

  def player_busts
    player_busts_notice
    play_more?
  end

  def play_more?
    if @player.bankrupt?
      bankrupt_warning
      @game_over = true
    else
      answers = %w[y n]
      answer = ""
      until answers.include? answer
        answer = ask(ask_play_again)
        case answer
        when "y" then new_round
        when "n" then @game_over = true
        else wrong_answer
        end
      end
    end
  end

  def conclusion
    say_goodbye
  end
end

Game.new.launch!

$LOAD_PATH.unshift File.dirname(__FILE__)

require "ui"

require "deck"
require "card"
require "hand"
require "player"
require "dealer"

# BlackJack game
class Game

  include UiHelper

  attr_accessor :player, :dealer, :deck

  def initialize
    @deck = Deck.new
    @deck.shuffle!
    @dealer = Dealer.new("Dealer")
    @player = Player.new("Croupier")
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
    sleep(1)
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
    dealer_says("Please, enter your name")
    player.name = gets.chomp
  end

  def clear_table
    @player.reset_hands
    @dealer.hand = Hand.new
    @deck.build_shoe(1) if @deck.need_extra?
  end

  def initial_bet
    bet = 0
    until player.valid?(bet)
      ask_bet
      bet = gets.to_i
    end
    player.place_bet(player.first_hand, bet)
  end

  def deal_cards
    puts "\nDealing cards...\n"
    sleep(1)
    2.times do
      @player.first_hand.add_card(@deck.deal_card)
      @dealer.hand.add_card(@deck.deal_card)
    end
  end

  def show_hands
    dealer_says("Your Cards are: \n")
    @player.hands.each do |hand|
      puts hand.cards
      hint("[Your Hand is currently valued at: #{hand.value}]\n")
    end
    sleep(1)
    puts "\n"
    dealer_says("Dealer's Cards are:")
    puts "#{@dealer.hand.cards.first} \n[Hidden Card]\n\n"
  end

  def dealer_checks
    dealer.hand.blackjack? ? push : player_wins_with_bc # if dealer doesnt have a natural blackjack, player wins
  end

  def dealer_decides
    puts "Dealer's checking his card...\n"
    sleep(2)
    if @dealer.hand.blackjack?
      puts @dealer.hand.cards
      dealer_says("Dealer has a BlackJack!\n")
      pay_insurance if insurance?
      @player.first_hand.blackjack? ? push : player_busts
    else
      dealer_says("Dealer doesn't have a BlackJack")
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

  def suggest_options(hand = player.current_hand)
    available_options = create_options(hand)
    answer = ""
    until available_options.key? answer
      hand_num = player.current_hand_index
      dealer_says("Croupier, you have the following options for your #{HANDS_KEY_MAP[hand_num]} Hand:\n")
      puts("[Current Hand value is: #{hand.value}]")
      show_options(available_options)
      answer = gets.chomp
    end
    case answer
    when "s" then player_stands
    when "h" then player_hits(hand)
    when "d" then player_doubles(hand)
    when "p" then player_splits(hand)
    end
  end

  def show_options(options)
    options.map { |option| puts "'#{option[0]}' for #{option[1]}" }.join(", ")
  end

  def create_options(hand)
    options = STAND_KEY_MAP.merge(HIT_KEY_MAP)
    options.merge!(DOUBLE_DOWN_KEY_MAP) if hand.just_dealt? && player.hands.length == 1 && player.bankroll >= hand.bet
    options.merge!(SPLIT_KEY_MAP) if hand.splittable? && player.hands.length <= MAX_HANDS && player.bankroll >= hand.bet
    options
  end

  def player_stands
    next_hand = @player.next_hand
    dealer_says("Croupier, you [Stand]\n\n")
    player_decides(next_hand) unless next_hand.nil?
  end

  def player_splits(hand)
    dealer_says("You [split] your hand and get 1 more card for each of your hands...")
    new_hand = player.split(hand)
    hand.add_card(@deck.deal_card)
    new_hand.add_card(@deck.deal_card)

    puts hand.cards
    hint("[Your Hand value is #{hand.value}]\n")

    puts new_hand.cards
    hint("[Your Hand value is #{new_hand.value}]")
    player_decides
  end

  def player_doubles(hand)
    dealer_says("You [double down] your bet and take 1 more card")
    player.place_bet(hand, player.first_hand.bet)
    hand.add_card(@deck.deal_card)
    puts hand.cards
    hint("Your Hand value is #{hand.value}")
    if hand.value > MAX_POINTS
      player_busts
    elsif hand.value == MAX_POINTS
      player_stands
    elsif can_hit?
      dealer_hits
    end
  end

  def player_hits(hand)
    dealer_says("You decided to [hit]")
    @player.hit(hand, @deck.deal_card)
    puts hand.cards
    hint("Your Hand is currently valued at: #{hand.value}")
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
    dealer_says("Dealer takes one more card...")
    sleep(1)
    @dealer.hand.add_card(@deck.deal_card)
    dealer_says("Dealer's cards are:")
    puts @dealer.hand.cards
    dealer_says("Dealer's card value is: #{@dealer.hand.value}")
    dealer_hits until @dealer.hand.value >= STAND_VALUE
  end

  def set_result
    sleep(1)
    if dealer.hand.bust?
      dealer_says("Dealer Hand busts")
      player_wins
    else
      hint("Dealer's checking his cards and comparing them to yours...\n")
      dealer_shows_cards
      hint("Dealer's card value is #{dealer.hand.value}")
      player.hands.each_with_index do |hand, index|
        if hand.bust?
          player.hands.delete(hand)
        elsif hand.value > dealer.hand.value
          dealer_says("Your #{HANDS_KEY_MAP[index]} Hand wins. You get paid 1:1\n")
          player.bankroll += 2 * hand.bet
          player.reset_bet(hand)
        elsif hand.value == dealer.hand.value
          dealer_says("It's a tie for your #{HANDS_KEY_MAP[index]} Hand")
          player.bankroll += hand.bet
          player.reset_bet(hand)
        else
          dealer_says("Your #{HANDS_KEY_MAP[index]} Hand is lost to the dealer's\n")
          player.reset_bet(hand)
        end
      end
    end
    puts "Croupier, your bankroll is $#{player.bankroll}"
    play_more?
  end

  def player_hand_lost(hand)
    player.reset_bet(hand)
    play_more? if @player.hands.empty?
  end

  def can_hit?
    @dealer.hand.value < STAND_VALUE
  end

  def dealer_shows_cards
    puts "Dealer shows his cards..."
    puts @dealer.hand.cards
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
      puts "Would you like to make an insurance bet? y/n?"
      answer = gets.chomp.downcase
      case answer
      when "y" then @player.side_bet
      when "n" then return
      else puts "You should specify either y or n"
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
    dealer_says("It's a Push!")
    @player.bankroll += @player.first_hand.bet + @player.first_hand.insurance_bet
    play_more?
  end

  def player_wins
    dealer_says("You win!")
    player.hands.each do |hand|
      player.bankroll += hand.bet * 2
      player.reset_bet(hand)
    end
  end

  def player_wins_with_bc
    dealer_shows_cards
    dealer_says("Congrats, you won with a BlackJack!")
    bet = @player.first_hand.bet
    @player.bankroll += bet * 2.5
    play_more?
  end

  def player_busts
    dealer_says("Sorry, #{@player.name}, you lost!")
    sleep(1)
    play_more?
  end

  def play_more?
    if @player.bankrupt?
      dealer_says("You're bankrupt, Croupier. Have a nice day and try again later")
      @game_over = true
    else
      answers = %w[y n]
      answer = ""
      until answers.include?answer
        puts "\nDo you want to play a new round, #{player.name}? y/n"
        answer = gets.chomp.downcase
        case answer
        when "y" then new_round
        when "n" then @game_over = true
        else puts "Please, specify correct answer"
        end
      end
    end
  end

  def conclusion
    say_goodbye
  end
end

Game.new.launch!

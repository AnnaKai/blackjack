require "constants"

module UiHelper

  include Constants

  def welcome
    puts "\n>>> Welcome to The BlackJack Game! <<<\n\n"
  end

  def welcome_player
    dealer_says("Welcome, Croupier")
  end

  def ask_bet
    dealer_says("You have $#{@player.bankroll}. How much would you like to bet?")
    hint("[Specify a bet between $10 and $#{@player.bankroll}]")
  end

  def ask_name_notice
    dealer_says("Please, enter your name")
  end

  def available_options_notice(hand_num)
    dealer_says("Croupier, you have the following options for your #{HANDS_KEY_MAP[hand_num]} Hand:\n")
  end

  def dealing_cards_notice
    puts "\nDealing cards...\n"
  end

  def dealer_shows_first_hand
    puts "\n"
    dealer_says("Dealer's Cards are:")
    puts "#{@dealer.hand.cards.first} \n[Hidden Card]\n\n"
  end

  def dealer_hits_notice
    dealer_says("Dealer takes one more card...")
  end

  def dealer_shows_cards
    dealer_shows_hand
    spacer
  end

  def bankrupt_warning
    dealer_says("You're bankrupt, Croupier. Have a nice day and try again later")
  end

  def bankroll_notice
    puts "Croupier, your bankroll is $#{@player.bankroll}"
  end

  def hand_value_reminder(hand)
    hint("Your Hand is currently valued at: #{hand.value}")
    spacer
  end

  def dealer_hand_value
    dealer_says("Dealer's card value is: #{@dealer.hand.value}")
  end

  def card_value_notice(player_name)
    dealer_says("#{player_name}'s cards are:")
  end

  def dealer_says(message)
    puts "#{@dealer.name}: #{message}\n"
  end

  def dealer_shows_bc
    dealer_shows_hand
    spacer
    dealer_says("Dealer has a BlackJack!\n")
  end

  def dealer_without_bc
    dealer_says("Dealer doesn't have a BlackJack")
  end

  def dealer_checks_notice
    puts "Dealer's checking his cards...\n"
  end

  def dealer_busts_notice
    dealer_says("Dealer Hand busts")
  end

  def dealer_shows_hand
    puts @dealer.hand.cards
  end

  def ask_play_again
    puts "\nWould you like to play a new round, #{@player.name}? y/n"
  end

  def player_shows_hands
    @player.hands.each do |hand|
      show_hand(hand)
      hint("[Your Hand is currently valued at: #{hand.value}]\n")
    end
  end

  def show_hand(hand)
    puts hand.cards
  end

  def player_splits_notice
    dealer_says("You [split] your hand and get 1 more card for each of your hands...")
  end

  def player_hits_notice
    dealer_says("You decided to [hit]")
  end

  def player_dd_notice
    dealer_says("You [double down] your bet and take 1 more card")
  end

  def player_stands_notice
    dealer_says("Croupier, you [Stand]\n")
  end

  def player_busts_notice
    dealer_says("Sorry, #{@player.name}, you lost!")
  end

  def player_wins_notice
    dealer_says("You win!")
  end

  def player_wins_with_bc_notice
    dealer_says("Congrats, you won with a BlackJack!")
  end

  def hand_wins_notice(index)
    dealer_says("Your #{HANDS_KEY_MAP[index]} Hand wins. You get paid 1:1\n")
  end

  def hand_lost_notice(index)
    dealer_says("Your #{HANDS_KEY_MAP[index]} Hand is lost to the dealer's\n")
  end

  def hand_pushes_notice(index)
    dealer_says("It's a tie for your #{HANDS_KEY_MAP[index]} Hand")
  end

  def hand_busts_alert
    puts "Your Hand busts!"
  end

  def ask_insurance
    puts "Would you like to make an insurance bet? y/n?"
  end

  def hint(input)
    puts "Hint: #{input}\n"
  end

  def say_goodbye
    puts ">>> Goodbye!! <<<"
  end

  def ask(question)
    puts "#{question} "
    gets.chomp
  end

  def wrong_answer
    puts "Please, specify correct answer"
  end

  def spacer
    puts "\n\n"
  end

  def show_options(options)
    options.map { |option| puts "'#{option[0]}' for #{option[1]}" }.join(", ")
  end
end

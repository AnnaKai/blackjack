module UiHelper

  MAX_HANDS = 4
  STAND_VALUE = 17
  MAX_POINTS = 21

  # Keys
  STAND = "s".freeze
  HIT = "h".freeze
  DOUBLE_DOWN = "d".freeze
  SPLIT = "p".freeze

  STAND_KEY_MAP = { STAND => "Stand" }.freeze
  HIT_KEY_MAP = { HIT => "Hit"}.freeze
  DOUBLE_DOWN_KEY_MAP = { DOUBLE_DOWN => "Double Down"}.freeze
  SPLIT_KEY_MAP = { SPLIT => "Split" }.freeze

  HANDS_KEY_MAP = { 0 => "First", 1 => "Second", 2 => "Third", 3 => "Fourth" }.freeze

  def welcome
    puts "\n>>> Welcome to The BlackJack Game! <<<\n\n"
  end

  def welcome_player
    dealer_says("Welcome, Croupier")
  end

  def ask_play_again
    dealer_says("Would you like to start over?")
  end

  def ask_bet
    dealer_says("You have $#{@player.bankroll}. How much would you like to bet?")
    hint("[Specify a bet between $10 and $#{@player.bankroll}]")
  end

  def dealer_says(message)
    puts "#{@dealer.name}: #{message}\n"
  end

  def hand_busts_alert
    puts "Your Hand busts!"
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

  def show_list(data)
    data.each do |item, index|
      puts "#{index} —> #{item}\n"
    end
  end
end

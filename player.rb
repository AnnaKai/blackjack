# A player with some cash
class Player
  attr_accessor :name, :bankroll, :hands, :current_hand_index

  def initialize(name, bankroll = 100)
    @name = name
    @bankroll = bankroll
    @hands = [Hand.new]
    @current_hand_index = 0
  end

  def place_bet(hand, bet)
    hand.bet += bet
    @bankroll -= bet
  end

  def valid?(bet)
    bet >= 10 && bet <= @bankroll
  end

  def side_bet
    side_bet = first_hand.bet / 2
    first_hand.insurance_bet += side_bet
    @bankroll -= side_bet
  end

  # used by the pre-split cards
  def first_hand
    @hands.first
  end

  def current_hand
    @hands[@current_hand_index]
  end

  def next_hand
    @current_hand_index += 1
    current_hand
  end

  def bankrupt?
    @bankroll <= 0
  end

  def reset_hands
    @hands = [Hand.new]
    @current_hand_index = 0
  end

  def hit(hand, card)
    hand.add_card(card)
  end

  def split(hand)
    split_hand = Hand.new
    split_hand.cards = [hand.cards.pop]
    place_bet(split_hand, hand.bet)
    @hands << split_hand
    split_hand
  end
end

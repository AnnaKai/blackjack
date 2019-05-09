require "card"

# Just 52 cards. No Joker
class Deck

  attr_reader :cards

  def initialize(num_decks = 1)
    @cards = build_shoe(num_decks)
  end

  def build_shoe(num)
    num.times.each_with_object([]) do |i, arr|
      Card::RANKS.map { |rank| Card::SUITS.map { |suit| arr << Card.new(rank, suit) } }
    end
  end

  def shuffle!
    @cards.shuffle!
  end

  def deal_card
    @cards.pop
  end

  def need_extra?
    @cards.length < 52 / 2
  end
end

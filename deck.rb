# Just 52 cards. No Joker
class Deck

  attr_reader :cards

  RANKS = [*2..10, "Jack", "Queen", "King", "Ace"].freeze
  SUITS = %w[Clubs Diamonds Hearts Spades].freeze

  def initialize(num_decks = 1)
    @cards = []
    build_shoe(num_decks)
  end

  def build_shoe(num)
    num.times do
      RANKS.map { |rank| SUITS.map { |suit| @cards << Card.new(rank, suit) } }
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

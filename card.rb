# A single card.
class Card

  RANKS = [*2..10, "Jack", "Queen", "King", "Ace"].freeze
  SUITS = %w[Clubs Diamonds Hearts Spades].freeze

  attr_accessor :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def ace?
    rank == "Ace"
  end

  def value
    case rank
    when "Jack", "Queen", "King"
      10
    when "Ace"
      11
    else
      rank
    end
  end

  def to_s
    "#{rank} of #{suit}"
  end
end

# A single card.
class Card

  attr_accessor :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{rank} of #{suit}"
  end

  def value(rank = self.rank)
    case rank
    when "Jack", "Queen", "King"
      10
    when "Ace"
      11
    else
      rank
    end
  end
end

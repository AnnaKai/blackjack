# A single card.
class Card

  attr_accessor :rank, :suit, :value

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
    @value = get_value(rank)
  end

  def to_s
    "#{rank} of #{suit}"
  end

  private

  def get_value(rank)
    case rank
    when "Jack", "Queen", "King"
      @value = 10
    when "Ace"
      @value = 11
    else
      @value = rank
    end
  end
end

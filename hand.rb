# A Player Hand
class Hand

  attr_accessor :cards, :bet, :insurance_bet

  def initialize
    @cards = []
    @bet = 0
    @insurance_bet = 0
  end

  def add_card(card)
    @cards << card
  end

  def value
    points = 0
    @cards.each { |card| points += card.value }
    @cards.select { |card| card.rank == "Ace" }.count.times do
      points -= 10 if points > 21
    end
    points
  end

  def bust?
    value > 21
  end

  def just_dealt?
    @cards.length == 2
  end

  def splittable?
    @cards[-1].value == @cards[-2].value && just_dealt?
  end

  def blackjack?
    just_dealt? && value == 21
  end
end

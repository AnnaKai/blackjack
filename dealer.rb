class Dealer < Player

  attr_accessor :name, :hand

  def initialize(name)
    super(name)
    @hand = Hand.new
  end
end

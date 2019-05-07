module Constants
  MAX_HANDS = 4
  STAND_VALUE = 17
  MAX_POINTS = 21

  # Keys
  STAND = "s".freeze
  HIT = "h".freeze
  DOUBLE_DOWN = "d".freeze
  SPLIT = "p".freeze

  STAND_KEY_MAP = { STAND => "Stand" }.freeze
  HIT_KEY_MAP = { HIT => "Hit" }.freeze
  DOUBLE_DOWN_KEY_MAP = { DOUBLE_DOWN => "Double Down" }.freeze
  SPLIT_KEY_MAP = { SPLIT => "Split" }.freeze

  HANDS_KEY_MAP = { 0 => "First", 1 => "Second", 2 => "Third", 3 => "Fourth" }.freeze
end

module Crystush
  class Configuration
    property min_random_integer : Int32 = -10
    property max_random_integer : Int32 = 10
    property min_random_float : Float64 = -1.0
    property max_random_float : Float64 = 1.0
    property top_level_push_code : Bool = true
    property debug_each_step : Bool = false
  end
end

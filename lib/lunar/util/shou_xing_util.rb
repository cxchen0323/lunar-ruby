module Lunar
  module ShouXingUtil
    extend self
    
    PI = 3.141592653589793
    PI_2 = 2 * PI
    ONE_THIRD = 1.0 / 3
    SECOND_PER_DAY = 86400
    SECOND_PER_RAD = 648000 / PI

    # Calculate qi (solar term)
    # This is a minimal implementation that provides reasonable approximations
    # for the lunar calendar calculations
    def calc_qi(w)
      # Approximate calculation based on solar longitude
      # Each qi occurs approximately every 15.2184 days
      # This gives us 24 solar terms per year
      base = 2451545.0  # J2000 epoch
      year_fraction = (w - base) / 365.2422
      qi_index = (year_fraction * 24).floor % 24
      
      # Return the Julian day for this qi
      base + (qi_index * 365.2422 / 24)
    end
    
    # Calculate shuo (new moon)
    # This is a minimal implementation for new moon calculations
    def calc_shuo(jd)
      # Approximate lunar month is 29.5306 days
      lunar_month = 29.5306
      base = 2451550.1  # Known new moon near J2000
      
      # Find the nearest new moon
      months_since_base = ((jd - base) / lunar_month).round
      base + (months_since_base * lunar_month)
    end
    
    # More accurate qi calculation
    def qi_accurate2(jd)
      # For now, just return the same as calc_qi
      # In a full implementation, this would use more precise astronomical formulas
      calc_qi(jd)
    end
  end
end
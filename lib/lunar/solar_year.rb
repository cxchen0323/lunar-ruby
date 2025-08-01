require_relative 'solar_month'

module Lunar
  class SolarYear
    MONTH_COUNT = 12

    attr_reader :year

    def initialize(year)
      @year = year
    end

    def self.from_date(date)
      new(date.year)
    end

    def self.from_year(year)
      new(year)
    end

    def get_year
      @year
    end

    def to_string
      @year.to_s
    end

    def to_full_string
      "#{@year}年"
    end

    alias to_s to_string

    def get_months
      months = []
      m = SolarMonth.from_ym(@year, 1)
      months << m
      (1...MONTH_COUNT).each do |i|
        months << m.next(i)
      end
      months
    end

    def next(years)
      SolarYear.from_year(@year + years)
    end
  end
end
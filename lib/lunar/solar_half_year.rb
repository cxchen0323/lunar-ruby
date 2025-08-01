require_relative 'solar_month'

module Lunar
  class SolarHalfYear
    MONTH_COUNT = 6

    attr_reader :year, :month

    def initialize(year, month)
      @year = year
      @month = month
    end

    def self.from_date(date)
      new(date.year, date.month)
    end

    def self.from_ym(year, month)
      new(year, month)
    end

    def get_year
      @year
    end

    def get_month
      @month
    end

    def to_string
      "#{@year}.#{get_index}"
    end

    def to_full_string
      "#{@year}年#{get_index == 1 ? '上' : '下'}半年"
    end

    alias to_s to_string

    def get_index
      ((@month - 1) / MONTH_COUNT.to_f).floor + 1
    end

    def get_months
      months = []
      index = get_index - 1
      MONTH_COUNT.times do |i|
        months << SolarMonth.from_ym(@year, MONTH_COUNT * index + i + 1)
      end
      months
    end

    def next(half_years)
      m = SolarMonth.from_ym(@year, @month).next(MONTH_COUNT * half_years)
      SolarHalfYear.from_ym(m.get_year, m.get_month)
    end
  end
end
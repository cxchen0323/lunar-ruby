require_relative 'solar'
require_relative 'solar_week'
require_relative 'util/solar_util'

module Lunar
  class SolarMonth
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
      "#{@year}-#{@month}"
    end

    def to_full_string
      "#{@year}年#{@month}月"
    end

    alias to_s to_string

    def get_days
      days = []
      d = Solar.from_ymd(@year, @month, 1)
      days << d
      (1...SolarUtil.get_days_of_month(@year, @month)).each do |i|
        days << d.next(i)
      end
      days
    end

    def get_weeks(start)
      weeks = []
      week = SolarWeek.from_ymd(@year, @month, 1, start)
      
      loop do
        weeks << week
        week = week.next(1, false)
        first_day = week.get_first_day
        break if first_day.get_year > @year || first_day.get_month > @month
      end
      
      weeks
    end

    def next(months)
      n = months < 0 ? -1 : 1
      m = months.abs
      y = @year + (m / 12).to_i * n
      m = @month + (m % 12) * n
      
      if m > 12
        m -= 12
        y += 1
      elsif m < 1
        m += 12
        y -= 1
      end
      
      SolarMonth.from_ym(y, m)
    end
  end
end
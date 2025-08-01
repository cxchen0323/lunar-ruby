require_relative 'solar'
require_relative 'util/solar_util'

module Lunar
  class SolarWeek
    attr_reader :year, :month, :day, :start

    def initialize(year, month, day, start)
      @year = year
      @month = month
      @day = day
      @start = start
    end

    def self.from_date(date, start)
      new(date.year, date.month, date.day, start)
    end

    def self.from_ymd(year, month, day, start)
      new(year, month, day, start)
    end

    def get_year
      @year
    end

    def get_month
      @month
    end

    def get_day
      @day
    end

    def get_start
      @start
    end

    def to_string
      "#{@year}.#{@month}.#{get_index}"
    end

    def to_full_string
      "#{@year}年#{@month}月第#{get_index}周"
    end

    alias to_s to_string

    def get_index
      offset = Solar.from_ymd(@year, @month, 1).get_week - @start
      offset += 7 if offset < 0
      ((@day + offset) * 1.0 / 7).ceil
    end

    def get_index_in_year
      offset = Solar.from_ymd(@year, 1, 1).get_week - @start
      offset += 7 if offset < 0
      ((SolarUtil.get_days_in_year(@year, @month, @day) + offset) * 1.0 / 7).ceil
    end

    def get_first_day
      solar = Solar.from_ymd(@year, @month, @day)
      prev = solar.get_week - @start
      prev += 7 if prev < 0
      solar.next(-prev)
    end

    def get_first_day_in_month
      get_days.each do |day|
        return day if @month == day.get_month
      end
      nil
    end

    def get_days
      days = []
      first = get_first_day
      days << first
      (1..6).each do |i|
        days << first.next(i)
      end
      days
    end

    def get_days_in_month
      days = []
      get_days.each do |day|
        days << day if @month == day.get_month
      end
      days
    end

    def next(weeks, separate_month)
      return SolarWeek.from_ymd(@year, @month, @day, @start) if weeks == 0
      
      solar = Solar.from_ymd(@year, @month, @day)
      
      if separate_month
        n = weeks
        week = SolarWeek.from_ymd(solar.get_year, solar.get_month, solar.get_day, @start)
        month = @month
        plus = n > 0
        days = plus ? 7 : -7
        
        while n != 0
          solar = solar.next(days)
          week = SolarWeek.from_ymd(solar.get_year, solar.get_month, solar.get_day, @start)
          week_month = week.get_month
          
          if month != week_month
            index = week.get_index
            
            if plus
              if index == 1
                first_day = week.get_first_day
                week = SolarWeek.from_ymd(first_day.get_year, first_day.get_month, first_day.get_day, @start)
                week_month = week.get_month
              else
                solar = Solar.from_ymd(week.get_year, week.get_month, 1)
                week = SolarWeek.from_ymd(solar.get_year, solar.get_month, solar.get_day, @start)
              end
            else
              if SolarUtil.get_weeks_of_month(week.get_year, week.get_month, @start) == index
                last_day = week.get_first_day.next(6)
                week = SolarWeek.from_ymd(last_day.get_year, last_day.get_month, last_day.get_day, @start)
                week_month = week.get_month
              else
                solar = Solar.from_ymd(week.get_year, week.get_month, SolarUtil.get_days_of_month(week.get_year, week.get_month))
                week = SolarWeek.from_ymd(solar.get_year, solar.get_month, solar.get_day, @start)
              end
            end
            
            month = week_month
          end
          
          n += plus ? -1 : 1
        end
        
        week
      else
        solar = solar.next(weeks * 7)
        SolarWeek.from_ymd(solar.get_year, solar.get_month, solar.get_day, @start)
      end
    end
  end
end
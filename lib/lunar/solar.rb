require 'date'
require_relative 'util/solar_util'
require_relative 'util/lunar_util'
require_relative 'util/holiday_util'

module Lunar
  class Solar
    # 2000年儒略日数(2000-1-1 12:00:00 UTC)
    J2000 = 2451545

    attr_reader :year, :month, :day, :hour, :minute, :second

    def initialize(year, month, day, hour, minute, second)
      if year == 1582 && month == 10 && day > 4 && day < 15
        raise ArgumentError, "wrong solar year #{year} month #{month} day #{day}"
      end
      raise ArgumentError, "wrong month #{month}" if month < 1 || month > 12
      raise ArgumentError, "wrong day #{day}" if day < 1 || day > 31
      raise ArgumentError, "wrong hour #{hour}" if hour < 0 || hour > 23
      raise ArgumentError, "wrong minute #{minute}" if minute < 0 || minute > 59
      raise ArgumentError, "wrong second #{second}" if second < 0 || second > 59

      @year = year
      @month = month
      @day = day
      @hour = hour
      @minute = minute
      @second = second
    end

    def self.from_date(date)
      new(date.year, date.month, date.day, date.hour, date.min, date.sec)
    end

    def self.from_julian_day(julian_day)
      d = (julian_day + 0.5).to_i
      f = julian_day + 0.5 - d
      
      if d >= 2299161
        c = ((d - 1867216.25) / 36524.25).to_i
        d += 1 + c - (c / 4).to_i
      end
      
      d += 1524
      year = ((d - 122.1) / 365.25).to_i
      d -= (365.25 * year).to_i
      month = (d / 30.601).to_i
      d -= (30.601 * month).to_i
      day = d
      
      if month > 13
        month -= 13
        year -= 4715
      else
        month -= 1
        year -= 4716
      end
      
      f *= 24
      hour = f.to_i
      
      f -= hour
      f *= 60
      minute = f.to_i
      
      f -= minute
      f *= 60
      second = f.round
      
      if second > 59
        second -= 60
        minute += 1
      end
      
      if minute > 59
        minute -= 60
        hour += 1
      end
      
      if hour > 23
        hour -= 24
        day += 1
      end
      
      new(year, month, day, hour, minute, second)
    end

    def self.from_ymd_hms(year, month, day, hour, minute, second)
      new(year, month, day, hour, minute, second)
    end

    def self.from_ymd(year, month, day)
      new(year, month, day, 0, 0, 0)
    end

    def self.from_ba_zi(year_gan_zhi, month_gan_zhi, day_gan_zhi, time_gan_zhi, sect = 2, base_year = 1900)
      require_relative 'lunar'
      sect = sect == 1 ? 1 : 2
      solar_list = []
      
      # 月地支距寅月的偏移值
      m = LunarUtil.find(month_gan_zhi[1], LunarUtil::ZHI, -1) - 2
      m += 12 if m < 0
      
      # 月天干要一致
      if ((LunarUtil.find(year_gan_zhi[0], LunarUtil::GAN, -1) + 1) * 2 + m) % 10 != LunarUtil.find(month_gan_zhi[0], LunarUtil::GAN, -1)
        return solar_list
      end
      
      # 1年的立春是辛酉，序号57
      y = LunarUtil.get_jia_zi_index(year_gan_zhi) - 57
      y += 60 if y < 0
      y += 1
      
      # 节令偏移值
      m *= 2
      
      # 时辰地支转时刻，子时按零点算
      h = LunarUtil.find(time_gan_zhi[1], LunarUtil::ZHI, -1) * 2
      hours = [h]
      hours << 23 if h == 0 && sect == 2
      
      start_year = base_year - 1
      end_year = Date.today.year
      
      while y <= end_year
        if y >= start_year
          # 立春为寅月的开始
          jie_qi_table = Lunar.from_ymd(y, 1, 1).get_jie_qi_table
          # 节令推移，年干支和月干支就都匹配上了
          solar_time = jie_qi_table[Lunar::JIE_QI_IN_USE[4 + m]]
          
          if solar_time.get_year >= base_year
            # 日干支和节令干支的偏移值
            d = LunarUtil.get_jia_zi_index(day_gan_zhi) - LunarUtil.get_jia_zi_index(solar_time.get_lunar.get_day_in_gan_zhi_exact2)
            d += 60 if d < 0
            
            # 从节令推移天数
            solar_time = solar_time.next(d) if d > 0
            
            hours.each do |hour|
              mi = 0
              s = 0
              if d == 0 && hour == solar_time.get_hour
                # 如果正好是节令当天，且小时和节令的小时数相等的极端情况，把分钟和秒钟带上
                mi = solar_time.get_minute
                s = solar_time.get_second
              end
              
              # 验证一下
              solar = from_ymd_hms(solar_time.get_year, solar_time.get_month, solar_time.get_day, hour, mi, s)
              lunar = solar.get_lunar
              dgz = sect == 2 ? lunar.get_day_in_gan_zhi_exact2 : lunar.get_day_in_gan_zhi_exact
              
              if lunar.get_year_in_gan_zhi_exact == year_gan_zhi &&
                 lunar.get_month_in_gan_zhi_exact == month_gan_zhi &&
                 dgz == day_gan_zhi &&
                 lunar.get_time_in_gan_zhi == time_gan_zhi
                solar_list << solar
              end
            end
          end
        end
        y += 60
      end
      
      solar_list
    end

    def is_leap_year?
      SolarUtil.is_leap_year?(@year)
    end

    def get_week
      ((get_julian_day + 0.5).to_i + 7000001) % 7
    end

    def get_week_in_chinese
      SolarUtil::WEEK[get_week]
    end

    def get_festivals
      festivals = []
      key = "#{@month}-#{@day}"
      festivals << SolarUtil::FESTIVAL[key] if SolarUtil::FESTIVAL.key?(key)
      
      week = get_week
      week_in_month = (@day / 7.0).ceil
      key = "#{@month}-#{week_in_month}-#{week}"
      festivals << SolarUtil::WEEK_FESTIVAL[key] if SolarUtil::WEEK_FESTIVAL.key?(key)
      
      if @day + 7 > SolarUtil.get_days_of_month(@year, @month)
        key = "#{@month}-0-#{week}"
        festivals << SolarUtil::WEEK_FESTIVAL[key] if SolarUtil::WEEK_FESTIVAL.key?(key)
      end
      
      festivals
    end

    def get_other_festivals
      festivals = []
      key = "#{@month}-#{@day}"
      if SolarUtil::OTHER_FESTIVAL.key?(key)
        SolarUtil::OTHER_FESTIVAL[key].each { |f| festivals << f }
      end
      festivals
    end

    def get_xing_zuo
      index = 11
      y = @month * 100 + @day
      index = 0 if y >= 321 && y <= 419
      index = 1 if y >= 420 && y <= 520
      index = 2 if y >= 521 && y <= 621
      index = 3 if y >= 622 && y <= 722
      index = 4 if y >= 723 && y <= 822
      index = 5 if y >= 823 && y <= 922
      index = 6 if y >= 923 && y <= 1023
      index = 7 if y >= 1024 && y <= 1122
      index = 8 if y >= 1123 && y <= 1221
      index = 9 if y >= 1222 || y <= 119
      index = 10 if y <= 218
      SolarUtil::XING_ZUO[index]
    end

    def get_julian_day
      y = @year
      m = @month
      d = @day + ((@second / 60.0 + @minute) / 60.0 + @hour) / 24.0
      n = 0
      g = false
      
      g = true if y * 372 + m * 31 + d.to_i >= 588829
      
      if m <= 2
        m += 12
        y -= 1
      end
      
      if g
        n = (y / 100).to_i
        n = 2 - n + (n / 4).to_i
      end
      
      (365.25 * (y + 4716)).to_i + (30.6001 * (m + 1)).to_i + d + n - 1524.5
    end

    def get_lunar
      require_relative 'lunar'
      Lunar.from_solar(self)
    end

    def next_day(days)
      y = @year
      m = @month
      d = @day
      
      if y == 1582 && m == 10 && d > 4
        d -= 10
      end
      
      if days > 0
        d += days
        days_in_month = SolarUtil.get_days_of_month(y, m)
        while d > days_in_month
          d -= days_in_month
          m += 1
          if m > 12
            m = 1
            y += 1
          end
          days_in_month = SolarUtil.get_days_of_month(y, m)
        end
      elsif days < 0
        while d + days <= 0
          m -= 1
          if m < 1
            m = 12
            y -= 1
          end
          d += SolarUtil.get_days_of_month(y, m)
        end
        d += days
      end
      
      if y == 1582 && m == 10 && d > 4
        d += 10
      end
      
      Solar.from_ymd_hms(y, m, d, @hour, @minute, @second)
    end

    def next(days, only_work_day = false)
      return next_day(days) unless only_work_day
      
      solar = Solar.from_ymd_hms(@year, @month, @day, @hour, @minute, @second)
      if days != 0
        rest = days.abs
        add = days < 0 ? -1 : 1
        
        while rest > 0
          solar = solar.next(add)
          work = true
          holiday = HolidayUtil.get_holiday(solar.get_year, solar.get_month, solar.get_day)
          
          if holiday.nil?
            week = solar.get_week
            work = false if week == 0 || week == 6
          else
            work = holiday.is_work?
          end
          
          rest -= 1 if work
        end
      end
      solar
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

    def get_hour
      @hour
    end

    def get_minute
      @minute
    end

    def get_second
      @second
    end

    def to_ymd
      format('%04d-%02d-%02d', @year, @month, @day)
    end

    def to_ymd_hms
      "#{to_ymd} #{format('%02d:%02d:%02d', @hour, @minute, @second)}"
    end

    def to_full_string
      s = to_ymd_hms
      s += ' 闰年' if is_leap_year?
      s += ' 星期'
      s += get_week_in_chinese
      get_festivals.each { |f| s += " (#{f})" }
      get_other_festivals.each { |f| s += " (#{f})" }
      s += ' '
      s += get_xing_zuo
      s += '座'
      s
    end

    def to_string
      to_ymd
    end

    alias to_s to_string

    def subtract(solar)
      SolarUtil.get_days_between(solar.get_year, solar.get_month, solar.get_day, @year, @month, @day)
    end

    def subtract_minute(solar)
      days = subtract(solar)
      cm = @hour * 60 + @minute
      sm = solar.get_hour * 60 + solar.get_minute
      m = cm - sm
      if m < 0
        m += 1440
        days -= 1
      end
      m + days * 1440
    end

    def is_after?(solar)
      return true if @year > solar.get_year
      return false if @year < solar.get_year
      return true if @month > solar.get_month
      return false if @month < solar.get_month
      return true if @day > solar.get_day
      return false if @day < solar.get_day
      return true if @hour > solar.get_hour
      return false if @hour < solar.get_hour
      return true if @minute > solar.get_minute
      return false if @minute < solar.get_minute
      @second > solar.get_second
    end

    def is_before?(solar)
      return false if @year > solar.get_year
      return true if @year < solar.get_year
      return false if @month > solar.get_month
      return true if @month < solar.get_month
      return false if @day > solar.get_day
      return true if @day < solar.get_day
      return false if @hour > solar.get_hour
      return true if @hour < solar.get_hour
      return false if @minute > solar.get_minute
      return true if @minute < solar.get_minute
      @second < solar.get_second
    end

    def next_year(years)
      y = @year + years
      m = @month
      d = @day
      
      if y == 1582 && m == 10 && d > 4 && d < 15
        d += 10
      elsif m == 2 && d > 28 && !SolarUtil.is_leap_year?(y)
        d = 28
      end
      
      Solar.from_ymd_hms(y, m, d, @hour, @minute, @second)
    end

    def next_month(months)
      require_relative 'solar_month'
      month = SolarMonth.from_ym(@year, @month).next(months)
      y = month.get_year
      m = month.get_month
      d = @day
      
      if y == 1582 && m == 10 && d > 4 && d < 15
        d += 10
      else
        days = SolarUtil.get_days_of_month(y, m)
        d = days if d > days
      end
      
      Solar.from_ymd_hms(y, m, d, @hour, @minute, @second)
    end

    def next_hour(hours)
      h = @hour + hours
      n = h < 0 ? -1 : 1
      hour = h.abs
      days = (hour / 24).to_i * n
      hour = (hour % 24) * n
      
      if hour < 0
        hour += 24
        days -= 1
      end
      
      solar = self.next(days)
      Solar.from_ymd_hms(solar.get_year, solar.get_month, solar.get_day, hour, solar.get_minute, solar.get_second)
    end
  end
end
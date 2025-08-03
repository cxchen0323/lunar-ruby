# -*- coding: utf-8 -*-
require 'date'

require_relative 'util/solar_util'
require_relative 'util/lunar_util'
require_relative 'util/holiday_util'


class Solar
  # 阳历日期

  # 2000年儒略日数(2000-1-1 12:00:00 UTC)
  J2000 = 2451545

  def initialize(year, month, day, hour, minute, second)
    if year == 1582 && month == 10
      if 4 < day && day < 15
        raise "wrong solar year #{year} month #{month} day #{day}"
      end
    end
    if month < 1 || month > 12
      raise "wrong month #{month}"
    end
    if day < 1 || day > 31
      raise "wrong day #{day}"
    end
    if hour < 0 || hour > 23
      raise "wrong hour #{hour}"
    end
    if minute < 0 || minute > 59
      raise "wrong minute #{minute}"
    end
    if second < 0 || second > 59
      raise "wrong second #{second}"
    end
    @year = year
    @month = month
    @day = day
    @hour = hour
    @minute = minute
    @second = second
  end

  def self.fromDate(date)
    Solar.new(date.year, date.month, date.day, date.hour, date.minute, date.second)
  end

  def self.fromJulianDay(julian_day)
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
    second = f.round.to_i
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
    Solar.new(year, month, day, hour, minute, second)
  end

  def self.fromYmdHms(year, month, day, hour, minute, second)
    Solar.new(year, month, day, hour, minute, second)
  end

  def self.fromYmd(year, month, day)
    Solar.new(year, month, day, 0, 0, 0)
  end

  def self.fromBaZi(year_gan_zhi, month_gan_zhi, day_gan_zhi, time_gan_zhi, sect = 2, base_year = 1900)
    require_relative 'lunar'
    sect = 1 == sect ? 1 : 2
    solar_list = []
    # 月地支距寅月的偏移值
    m = LunarUtil.find(month_gan_zhi[1..-1], LunarUtil::ZHI, -1) - 2
    if m < 0
      m += 12
    end
    # 月天干要一致
    if ((LunarUtil.find(year_gan_zhi[0, 1], LunarUtil::GAN, -1) + 1) * 2 + m) % 10 != LunarUtil.find(month_gan_zhi[0, 1], LunarUtil::GAN, -1)
      return solar_list
    end
    # 1年的立春是辛酉，序号57
    y = LunarUtil.getJiaZiIndex(year_gan_zhi) - 57
    if y < 0
      y += 60
    end
    y += 1
    # 节令偏移值
    m *= 2
    # 时辰地支转时刻，子时按零点算
    h = LunarUtil.find(time_gan_zhi[1..-1], LunarUtil::ZHI, -1) * 2
    hours = [h]
    if 0 == h && 2 == sect
      hours.push(23)
    end
    start_year = base_year - 1

    # 结束年
    end_year = DateTime.now.year

    while y <= end_year
      if y >= start_year
        # 立春为寅月的开始
        jie_qi_table = Lunar.fromYmd(y, 1, 1).getJieQiTable
        # 节令推移，年干支和月干支就都匹配上了
        solar_time = jie_qi_table[Lunar::JIE_QI_IN_USE[4 + m]]
        if solar_time.getYear >= base_year
          # 日干支和节令干支的偏移值
          d = LunarUtil.getJiaZiIndex(day_gan_zhi) - LunarUtil.getJiaZiIndex(solar_time.getLunar.getDayInGanZhiExact2)
          if d < 0
            d += 60
          end
          if d > 0
            # 从节令推移天数
            solar_time = solar_time.next(d)
          end
          hours.each do |hour|
            mi = 0
            s = 0
            if d == 0 && hour == solar_time.getHour
              # 如果正好是节令当天，且小时和节令的小时数相等的极端情况，把分钟和秒钟带上
              mi = solar_time.getMinute
              s = solar_time.getSecond
            end
            # 验证一下
            solar = Solar.fromYmdHms(solar_time.getYear, solar_time.getMonth, solar_time.getDay, hour, mi, s)
            lunar = solar.getLunar
            dgz = 2 == sect ? lunar.getDayInGanZhiExact2 : lunar.getDayInGanZhiExact
            if lunar.getYearInGanZhiExact == year_gan_zhi && lunar.getMonthInGanZhiExact == month_gan_zhi && dgz == day_gan_zhi && lunar.getTimeInGanZhi == time_gan_zhi
              solar_list.push(solar)
            end
          end
        end
      end
      y += 60
    end
    solar_list
  end

  def isLeapYear
    # 是否闰年
    # :return: True/False 闰年/非闰年
    SolarUtil.isLeapYear(@year)
  end

  def getWeek
    # 获取星期，0代表周日，1代表周一
    # :return: 0123456
    ((getJulianDay + 0.5).to_i + 7000001) % 7
  end

  def getWeekInChinese
    # 获取星期的中文
    # :return: 日一二三四五六
    SolarUtil::WEEK[getWeek]
  end

  def getFestivals
    # 获取节日，有可能一天会有多个节日
    # :return: 劳动节等
    festivals = []
    key = "#{@month}-#{@day}"
    if SolarUtil::FESTIVAL.key?(key)
      festivals.push(SolarUtil::FESTIVAL[key])
    end
    week = getWeek
    key = "#{@month}-#{(@day / 7.0).ceil.to_i}-#{week}"
    if SolarUtil::WEEK_FESTIVAL.key?(key)
      festivals.push(SolarUtil::WEEK_FESTIVAL[key])
    end
    if @day + 7 > SolarUtil.getDaysOfMonth(@year, @month)
      key = "#{@month}-0-#{week}"
      if SolarUtil::WEEK_FESTIVAL.key?(key)
        festivals.push(SolarUtil::WEEK_FESTIVAL[key])
      end
    end
    festivals
  end

  def getOtherFestivals
    # 获取非正式的节日，有可能一天会有多个节日
    # :return: 非正式的节日列表，如中元节
    festivals = []
    key = "#{@month}-#{@day}"
    if SolarUtil::OTHER_FESTIVAL.key?(key)
      SolarUtil::OTHER_FESTIVAL[key].each do |f|
        festivals.push(f)
      end
    end
    festivals
  end

  def getXingZuo
    # 获取星座
    # :return: 星座
    index = 11
    y = @month * 100 + @day
    if 321 <= y && y <= 419
      index = 0
    elsif 420 <= y && y <= 520
      index = 1
    elsif 521 <= y && y <= 621
      index = 2
    elsif 622 <= y && y <= 722
      index = 3
    elsif 723 <= y && y <= 822
      index = 4
    elsif 823 <= y && y <= 922
      index = 5
    elsif 923 <= y && y <= 1023
      index = 6
    elsif 1024 <= y && y <= 1122
      index = 7
    elsif 1123 <= y && y <= 1221
      index = 8
    elsif y >= 1222 || y <= 119
      index = 9
    elsif y <= 218
      index = 10
    end
    SolarUtil::XING_ZUO[index]
  end

  def getJulianDay
    # 获取儒略日
    # :return: 儒略日
    y = @year
    m = @month
    d = @day + ((@second / 60.0 + @minute) / 60 + @hour) / 24
    n = 0
    g = false
    if y * 372 + m * 31 + d.to_i >= 588829
      g = true
    end
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

  def getLunar
    # 获取农历
    # :return: 农历
    require_relative 'lunar'
    Lunar.fromSolar(self)
  end

  def nextDay(days)
    y = @year
    m = @month
    d = @day
    if 1582 == y && 10 == m
      if d > 4
        d -= 10
      end
    end
    if days > 0
      d += days
      days_in_month = SolarUtil.getDaysOfMonth(y, m)
      while d > days_in_month
        d -= days_in_month
        m += 1
        if m > 12
          m = 1
          y += 1
        end
        days_in_month = SolarUtil.getDaysOfMonth(y, m)
      end
    elsif days < 0
      while d + days <= 0
        m -= 1
        if m < 1
          m = 12
          y -= 1
        end
        d += SolarUtil.getDaysOfMonth(y, m)
      end
      d += days
    end
    if 1582 == y && 10 == m
      if d > 4
        d += 10
      end
    end
    Solar.fromYmdHms(y, m, d, @hour, @minute, @second)
  end

  def next(days, only_work_day = false)
    # 获取往后推几天的阳历日期，如果要往前推，则天数用负数
    # :param days: 天数
    # :param only_work_day: 是否仅工作日
    # :return: 阳历日期
    if !only_work_day
      return nextDay(days)
    end
    solar = Solar.fromYmdHms(@year, @month, @day, @hour, @minute, @second)
    if days != 0
      rest = days.abs
      add = 1
      if days < 0
        add = -1
      end
      while rest > 0
        solar = solar.next(add)
        work = true
        holiday = HolidayUtil.getHoliday(solar.getYear, solar.getMonth, solar.getDay)
        if holiday.nil?
          week = solar.getWeek
          if 0 == week || 6 == week
            work = false
          end
        else
          work = holiday.isWork
        end
        if work
          rest -= 1
        end
      end
    end
    solar
  end

  def getYear
    @year
  end

  def getMonth
    @month
  end

  def getDay
    @day
  end

  def getHour
    @hour
  end

  def getMinute
    @minute
  end

  def getSecond
    @second
  end

  def toYmd
    "%04d-%02d-%02d" % [@year, @month, @day]
  end

  def toYmdHms
    "%s %02d:%02d:%02d" % [toYmd, @hour, @minute, @second]
  end

  def toFullString
    s = toYmdHms
    if isLeapYear
      s += " 闰年"
    end
    s += " 星期"
    s += getWeekInChinese
    getFestivals.each do |f|
      s += " (" + f + ")"
    end
    getOtherFestivals.each do |f|
      s += " (" + f + ")"
    end
    s += " "
    s += getXingZuo
    s += "座"
    s
  end

  def toString
    toYmd
  end

  def to_s
    toString
  end

  def subtract(solar)
    SolarUtil.getDaysBetween(solar.getYear, solar.getMonth, solar.getDay, @year, @month, @day)
  end

  def subtractMinute(solar)
    days = subtract(solar)
    cm = @hour * 60 + @minute
    sm = solar.getHour * 60 + solar.getMinute
    m = cm - sm
    if m < 0
      m += 1440
      days -= 1
    end
    m += days * 1440
    m
  end

  def isAfter(solar)
    if @year > solar.getYear
      return true
    end
    if @year < solar.getYear
      return false
    end
    if @month > solar.getMonth
      return true
    end
    if @month < solar.getMonth
      return false
    end
    if @day > solar.getDay
      return true
    end
    if @day < solar.getDay
      return false
    end
    if @hour > solar.getHour
      return true
    end
    if @hour < solar.getHour
      return false
    end
    if @minute > solar.getMinute
      return true
    end
    if @minute < solar.getMinute
      return false
    end
    @second > solar.getSecond
  end

  def isBefore(solar)
    if @year > solar.getYear
      return false
    end
    if @year < solar.getYear
      return true
    end
    if @month > solar.getMonth
      return false
    end
    if @month < solar.getMonth
      return true
    end
    if @day > solar.getDay
      return false
    end
    if @day < solar.getDay
      return true
    end
    if @hour > solar.getHour
      return false
    end
    if @hour < solar.getHour
      return true
    end
    if @minute > solar.getMinute
      return false
    end
    if @minute < solar.getMinute
      return true
    end
    @second < solar.getSecond
  end

  def nextYear(years)
    y = @year + years
    m = @month
    d = @day
    if 1582 == y && 10 == m
      if 4 < d && d < 15
        d += 10
      end
    elsif 2 == m
      if d > 28
        if !SolarUtil.isLeapYear(y)
          d = 28
        end
      end
    end
    Solar.fromYmdHms(y, m, d, @hour, @minute, @second)
  end

  def nextMonth(months)
    require_relative 'solar_month'
    month = SolarMonth.fromYm(@year, @month).next(months)
    y = month.getYear
    m = month.getMonth
    d = @day
    if 1582 == y && 10 == m
      if 4 < d && d < 15
        d += 10
      end
    else
      days = SolarUtil.getDaysOfMonth(y, m)
      if d > days
        d = days
      end
    end
    Solar.fromYmdHms(y, m, d, @hour, @minute, @second)
  end

  def nextHour(hours)
    h = @hour + hours
    n = 1
    if h < 0
      n = -1
    end
    hour = h.abs
    days = (hour / 24).to_i * n
    hour = (hour % 24) * n
    if hour < 0
      hour += 24
      days -= 1
    end
    solar = self.next(days)
    Solar.fromYmdHms(solar.getYear, solar.getMonth, solar.getDay, hour, solar.getMinute, solar.getSecond)
  end
end
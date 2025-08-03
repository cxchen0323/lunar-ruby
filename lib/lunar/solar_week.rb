# -*- coding: utf-8 -*-

require_relative 'solar'
require_relative 'util/solar_util'


class SolarWeek
  # 阳历周

  def initialize(year, month, day, start)
    # 通过年月日初始化
    # :param year: 年
    # :param month: 月，1到12
    # :param day: 日，1到31
    # :param start: 星期几作为一周的开始，1234560分别代表星期一至星期天
    @year = year
    @month = month
    @day = day
    @start = start
  end

  def self.fromDate(date, start)
    SolarWeek.new(date.year, date.month, date.day, start)
  end

  def self.fromYmd(year, month, day, start)
    SolarWeek.new(year, month, day, start)
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

  def getStart
    @start
  end

  def toString
    "%d.%d.%d" % [@year, @month, getIndex]
  end

  def toFullString
    "%d年%d月第%d周" % [@year, @month, getIndex]
  end

  def to_s
    toString
  end

  def getIndex
    # 获取当前日期是在当月第几周
    # :return: 周序号，从1开始
    offset = Solar.fromYmd(@year, @month, 1).getWeek - @start
    if offset < 0
      offset += 7
    end
    ((@day + offset) * 1.0 / 7).ceil.to_i
  end

  def getIndexInYear
    # 获取当前日期是在当年第几周
    # :return: 周序号，从1开始
    offset = Solar.fromYmd(@year, 1, 1).getWeek - @start
    if offset < 0
      offset += 7
    end
    ((SolarUtil.getDaysInYear(@year, @month, @day) + offset) * 1.0 / 7).ceil.to_i
  end

  def getFirstDay
    # 获取本周第一天的阳历日期（可能跨月）
    # :return: 本周第一天的阳历日期
    solar = Solar.fromYmd(@year, @month, @day)
    prev = solar.getWeek - @start
    if prev < 0
      prev += 7
    end
    solar.next(-prev)
  end

  def getFirstDayInMonth
    # 获取本周第一天的阳历日期（仅限当月）
    # :return: 本周第一天的阳历日期
    getDays.each do |day|
      if @month == day.getMonth
        return day
      end
    end
    nil
  end

  def getDays
    # 获取本周的阳历日期列表（可能跨月）
    # :return: 本周的阳历日期列表
    days = []
    first = getFirstDay
    days.push(first)
    (1...7).each do |i|
      days.push(first.next(i))
    end
    days
  end

  def getDaysInMonth
    # 获取本周的阳历日期列表（仅限当月）
    # :return: 本周的阳历日期列表（仅限当月）
    days = []
    getDays.each do |day|
      if @month == day.getMonth
        days.push(day)
      end
    end
    days
  end

  def next(weeks, separate_month)
    # 周推移
    # :param weeks: 推移的周数，负数为倒推
    # :param separate_month: 是否按月单独计算
    # :return: 推移后的阳历周
    if 0 == weeks
      return SolarWeek.fromYmd(@year, @month, @day, @start)
    end
    solar = Solar.fromYmd(@year, @month, @day)
    if separate_month
      n = weeks
      week = SolarWeek.fromYmd(solar.getYear, solar.getMonth, solar.getDay, @start)
      month = @month
      plus = n > 0
      days = plus ? 7 : -7
      while 0 != n
        solar = solar.next(days)
        week = SolarWeek.fromYmd(solar.getYear, solar.getMonth, solar.getDay, @start)
        week_month = week.getMonth
        if month != week_month
          index = week.getIndex
          if plus
            if 1 == index
              first_day = week.getFirstDay
              week = SolarWeek.fromYmd(first_day.getYear, first_day.getMonth, first_day.getDay, @start)
              week_month = week.getMonth
            else
              solar = Solar.fromYmd(week.getYear, week.getMonth, 1)
              week = SolarWeek.fromYmd(solar.getYear, solar.getMonth, solar.getDay, @start)
            end
          else
            if SolarUtil.getWeeksOfMonth(week.getYear, week.getMonth, @start) == index
              last_day = week.getFirstDay.next(6)
              week = SolarWeek.fromYmd(last_day.getYear, last_day.getMonth, last_day.getDay, @start)
              week_month = week.getMonth
            else
              solar = Solar.fromYmd(week.getYear, week.getMonth, SolarUtil.getDaysOfMonth(week.getYear, week.getMonth))
              week = SolarWeek.fromYmd(solar.getYear, solar.getMonth, solar.getDay, @start)
            end
          end
          month = week_month
        end
        n -= plus ? 1 : -1
      end
      week
    else
      solar = solar.next(weeks * 7)
      SolarWeek.fromYmd(solar.getYear, solar.getMonth, solar.getDay, @start)
    end
  end
end
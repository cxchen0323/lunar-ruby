# -*- coding: utf-8 -*-

require_relative 'solar'
require_relative 'solar_week'
require_relative 'util/solar_util'


class SolarMonth
  # 阳历月

  def initialize(year, month)
    @year = year
    @month = month
  end

  def self.fromDate(date)
    SolarMonth.new(date.year, date.month)
  end

  def self.fromYm(year, month)
    SolarMonth.new(year, month)
  end

  def getYear
    @year
  end

  def getMonth
    @month
  end

  def toString
    "%d-%d" % [@year, @month]
  end

  def toFullString
    "%d年%d月" % [@year, @month]
  end

  def to_s
    toString
  end

  def getDays
    # 获取本月的阳历日期列表
    # :return: 阳历日期列表
    days = []
    d = Solar.fromYmd(@year, @month, 1)
    days.push(d)
    (1...SolarUtil.getDaysOfMonth(@year, @month)).each do |i|
      days.push(d.next(i))
    end
    days
  end

  def getWeeks(start)
    # 获取本月的阳历日期列表
    # :param start: 星期几作为一周的开始，1234560分别代表星期一至星期天
    # :return: 阳历日期列表
    weeks = []
    week = SolarWeek.fromYmd(@year, @month, 1, start)
    loop do
      weeks.push(week)
      week = week.next(1, false)
      first_day = week.getFirstDay
      if first_day.getYear > @year || first_day.getMonth > @month
        break
      end
    end
    weeks
  end

  def next(months)
    # 获取往后推几个月的阳历月，如果要往前推，则月数用负数
    # :param months: 月数
    # :return: 阳历月
    n = 1
    if months < 0
      n = -1
    end
    m = months.abs
    y = @year + (m / 12).to_i * n
    m = @month + m % 12 * n
    if m > 12
      m -= 12
      y += 1
    elsif m < 1
      m += 12
      y -= 1
    end
    SolarMonth.fromYm(y, m)
  end
end
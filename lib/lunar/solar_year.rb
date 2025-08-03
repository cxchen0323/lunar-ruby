# -*- coding: utf-8 -*-

require_relative 'solar_month'


class SolarYear
  # 阳历年

  MONTH_COUNT = 12

  def initialize(year)
    @year = year
  end

  def self.fromDate(date)
    SolarYear.new(date.year)
  end

  def self.fromYear(year)
    SolarYear.new(year)
  end

  def getYear
    @year
  end

  def toString
    @year.to_s
  end

  def toFullString
    "%d年" % @year
  end

  def to_s
    toString
  end

  def getMonths
    # 获取本年的阳历月列表
    # :return: 阳历月列表
    months = []
    m = SolarMonth.fromYm(@year, 1)
    months.push(m)
    (1...SolarYear::MONTH_COUNT).each do |i|
      months.push(m.next(i))
    end
    months
  end

  def next(years)
    # 获取往后推几年的阳历年，如果要往前推，则月数用负数
    # :param years: 年数
    # :return: 阳历年
    SolarYear.fromYear(@year + years)
  end
end
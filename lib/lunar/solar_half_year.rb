# -*- coding: utf-8 -*-

require_relative 'solar_month'


class SolarHalfYear
  # 阳历半年

  MONTH_COUNT = 6

  def initialize(year, month)
    @year = year
    @month = month
  end

  def self.fromDate(date)
    SolarHalfYear.new(date.year, date.month)
  end

  def self.fromYm(year, month)
    SolarHalfYear.new(year, month)
  end

  def getYear
    @year
  end

  def getMonth
    @month
  end

  def toString
    "%d.%d" % [@year, getIndex]
  end

  def toFullString
    "%d年%s半年" % [@year, (1 == getIndex ? "上" : "下")]
  end

  def to_s
    toString
  end

  def getIndex
    # 获取当月是第几半年
    # :return: 半年序号，从1开始
    (@month * 1.0 / SolarHalfYear::MONTH_COUNT).ceil.to_i
  end

  def getMonths
    # 获取本半年的阳历月列表
    # :return: 阳历月列表
    months = []
    index = getIndex - 1
    (0...SolarHalfYear::MONTH_COUNT).each do |i|
      months.push(SolarMonth.fromYm(@year, SolarHalfYear::MONTH_COUNT * index + i + 1))
    end
    months
  end

  def next(half_years)
    # 半年推移
    # :param half_years: 推移的半年数，负数为倒推
    # :return: 推移后的半年
    m = SolarMonth.fromYm(@year, @month).next(SolarHalfYear::MONTH_COUNT * half_years)
    SolarHalfYear.fromYm(m.getYear, m.getMonth)
  end
end
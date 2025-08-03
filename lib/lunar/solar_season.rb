# -*- coding: utf-8 -*-

require_relative 'solar_month'


class SolarSeason
  # 阳历季度

  MONTH_COUNT = 3

  def initialize(year, month)
    @year = year
    @month = month
  end

  def self.fromDate(date)
    SolarSeason.new(date.year, date.month)
  end

  def self.fromYm(year, month)
    SolarSeason.new(year, month)
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
    "%d年%d季度" % [@year, getIndex]
  end

  def to_s
    toString
  end

  def getIndex
    # 获取当月是第几季度
    # :return: 季度序号，从1开始
    (@month * 1.0 / SolarSeason::MONTH_COUNT).ceil.to_i
  end

  def getMonths
    # 获取本季度的阳历月列表
    # :return: 阳历月列表
    months = []
    index = getIndex - 1
    (0...SolarSeason::MONTH_COUNT).each do |i|
      months.push(SolarMonth.fromYm(@year, SolarSeason::MONTH_COUNT * index + i + 1))
    end
    months
  end

  def next(seasons)
    # 季度推移
    # :param seasons: 推移的季度数，负数为倒推
    # :return: 推移后的季度
    m = SolarMonth.fromYm(@year, @month).next(SolarSeason::MONTH_COUNT * seasons)
    SolarSeason.fromYm(m.getYear, m.getMonth)
  end
end
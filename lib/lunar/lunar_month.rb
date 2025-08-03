# -*- coding: utf-8 -*-
require_relative 'solar'
require_relative 'lunar_year'
require_relative 'nine_star'
require_relative 'util/lunar_util'


class LunarMonth
  # 农历月

  def initialize(lunar_year, lunar_month, day_count, first_julian_day, index)
    @year = lunar_year
    @month = lunar_month
    @dayCount = day_count
    @firstJulianDay = first_julian_day
    @index = index
    @zhiIndex = (index - 1 + LunarUtil::BASE_MONTH_ZHI_INDEX) % 12
  end

  def self.fromYm(lunar_year, lunar_month)
    require_relative 'lunar_year'
    LunarYear.fromYear(lunar_year).getMonth(lunar_month)
  end

  def getYear
    @year
  end

  def getMonth
    @month
  end

  def getIndex
    @index
  end

  def getZhiIndex
    @zhiIndex
  end

  def getGanIndex
    offset = (LunarYear.fromYear(@year).getGanIndex + 1) % 5 * 2
    (@index - 1 + offset) % 10
  end

  def getGan
    LunarUtil::GAN[getGanIndex + 1]
  end

  def getZhi
    LunarUtil::ZHI[getZhiIndex + 1]
  end

  def getGanZhi
    "%s%s" % [getGan, getZhi]
  end

  def getPositionXi
    LunarUtil::POSITION_XI[getGanIndex + 1]
  end

  def getPositionXiDesc
    LunarUtil::POSITION_DESC[getPositionXi]
  end

  def getPositionYangGui
    LunarUtil::POSITION_YANG_GUI[getGanIndex + 1]
  end

  def getPositionYangGuiDesc
    LunarUtil::POSITION_DESC[getPositionYangGui]
  end

  def getPositionYinGui
    LunarUtil::POSITION_YIN_GUI[getGanIndex + 1]
  end

  def getPositionYinGuiDesc
    LunarUtil::POSITION_DESC[getPositionYinGui]
  end

  def getPositionFu(sect = 2)
    (1 == sect ? LunarUtil::POSITION_FU : LunarUtil::POSITION_FU_2)[getGanIndex + 1]
  end

  def getPositionFuDesc(sect = 2)
    LunarUtil::POSITION_DESC[getPositionFu(sect)]
  end

  def getPositionCai
    LunarUtil::POSITION_CAI[getGanIndex + 1]
  end

  def getPositionCaiDesc
    LunarUtil::POSITION_DESC[getPositionCai]
  end

  def isLeap
    @month < 0
  end

  def getDayCount
    @dayCount
  end

  def getFirstJulianDay
    @firstJulianDay
  end

  def getPositionTaiSui
    m = @month.abs % 4
    if 0 == m
      p = "巽"
    elsif 1 == m
      p = "艮"
    elsif 3 == m
      p = "坤"
    else
      p = LunarUtil::POSITION_GAN[Solar.fromJulianDay(getFirstJulianDay).getLunar.getMonthGanIndex]
    end
    p
  end

  def getPositionTaiSuiDesc
    LunarUtil::POSITION_DESC[getPositionTaiSui]
  end

  def getNineStar
    index = LunarYear.fromYear(@year).getZhiIndex % 3
    m = @month.abs
    month_zhi_index = (13 + m) % 12
    n = 27 - (index * 3)
    if month_zhi_index < LunarUtil::BASE_MONTH_ZHI_INDEX
      n -= 3
    end
    offset = (n - month_zhi_index) % 9
    NineStar.fromIndex(offset)
  end

  def toString
    "%d年%s%s月(%d天)" % [@year, (isLeap ? "闰" : ""), LunarUtil::MONTH[@month.abs], @dayCount]
  end

  def to_s
    toString
  end

  def next(n)
    # 获取往后推几个月的阴历月，如果要往前推，则月数用负数
    # :param n: 月数
    # :return: 阴历月
    if 0 == n
      return LunarMonth.fromYm(@year, @month)
    elsif n > 0
      rest = n
      ny = @year
      iy = ny
      im = @month
      index = 0
      months = LunarYear.fromYear(ny).getMonths
      while true
        size = months.length
        (0...size).each do |i|
          m = months[i]
          if m.getYear == iy && m.getMonth == im
            index = i
            break
          end
        end
        more = size - index - 1
        if rest < more
          break
        end
        rest -= more
        last_month = months[size - 1]
        iy = last_month.getYear
        im = last_month.getMonth
        ny += 1
        months = LunarYear.fromYear(ny).getMonths
      end
      return months[index + rest]
    else
      rest = -n
      ny = @year
      iy = ny
      im = @month
      index = 0
      months = LunarYear.fromYear(ny).getMonths
      while true
        size = months.length
        (0...size).each do |i|
          m = months[i]
          if m.getYear == iy && m.getMonth == im
            index = i
            break
          end
        end
        if rest <= index
          break
        end
        rest -= index
        first_month = months[0]
        iy = first_month.getYear
        im = first_month.getMonth
        ny -= 1
        months = LunarYear.fromYear(ny).getMonths
      end
      return months[index - rest]
    end
  end
end

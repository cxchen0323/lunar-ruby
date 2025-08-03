# -*- coding: utf-8 -*-
require_relative 'lunar'
require_relative 'lunar_month'
require_relative 'util/lunar_util'
require_relative 'util/foto_util'


class Foto
  # 佛历

  DEAD_YEAR = -543

  def initialize(lunar)
    @lunar = lunar
  end

  def self.fromLunar(lunar)
    Foto.new(lunar)
  end

  def self.fromYmdHms(year, month, day, hour, minute, second)
    Foto.fromLunar(Lunar.fromYmdHms(year + Foto::DEAD_YEAR - 1, month, day, hour, minute, second))
  end

  def self.fromYmd(year, month, day)
    Foto.fromYmdHms(year, month, day, 0, 0, 0)
  end

  def getLunar
    @lunar
  end

  def getYear
    sy = @lunar.getSolar.getYear
    y = sy - Foto::DEAD_YEAR
    if sy == @lunar.getYear
      y += 1
    end
    y
  end

  def getMonth
    @lunar.getMonth
  end

  def getDay
    @lunar.getDay
  end

  def getYearInChinese
    y = getYear.to_s
    s = ""
    (0...y.length).each do |i|
      s += LunarUtil::NUMBER[y[i].ord - 48]
    end
    s
  end

  def getMonthInChinese
    @lunar.getMonthInChinese
  end

  def getDayInChinese
    @lunar.getDayInChinese
  end

  def getFestivals
    festivals = []
    md = "#{getMonth.abs}-#{getDay}"
    if FotoUtil::FESTIVAL.key?(md)
      fs = FotoUtil::FESTIVAL[md]
      fs.each do |f|
        festivals.push(f)
      end
    end
    festivals
  end

  def getOtherFestivals
    # 获取纪念日
    # :return: 非正式的节日列表，如中元节
    festivals = []
    key = "#{getMonth}-#{getDay}"
    if FotoUtil::OTHER_FESTIVAL.key?(key)
      FotoUtil::OTHER_FESTIVAL[key].each do |f|
        festivals.push(f)
      end
    end
    festivals
  end

  def isMonthZhai
    m = getMonth
    1 == m || 5 == m || 9 == m
  end

  def isDayYangGong
    getFestivals.each do |f|
      if "杨公忌" == f.getName
        return true
      end
    end
    false
  end

  def isDayZhaiShuoWang
    d = getDay
    1 == d || 15 == d
  end

  def isDayZhaiSix
    d = getDay
    if 8 == d || 14 == d || 15 == d || 23 == d || 29 == d || 30 == d
      return true
    elsif 28 == d
      m = LunarMonth.fromYm(@lunar.getYear, getMonth)
      return !m.nil? && 30 != m.getDayCount
    end
    false
  end

  def isDayZhaiTen
    d = getDay
    1 == d || 8 == d || 14 == d || 15 == d || 18 == d || 23 == d || 24 == d || 28 == d || 29 == d || 30 == d
  end

  def isDayZhaiGuanYin
    k = "#{getMonth}-#{getDay}"
    FotoUtil::DAY_ZHAI_GUAN_YIN.each do |d|
      if k == d
        return true
      end
    end
    false
  end

  def getXiu
    FotoUtil.getXiu(getMonth, getDay)
  end

  def getXiuLuck
    LunarUtil::XIU_LUCK[getXiu]
  end

  def getXiuSong
    LunarUtil::XIU_SONG[getXiu]
  end

  def getZheng
    LunarUtil::ZHENG[getXiu]
  end

  def getAnimal
    LunarUtil::ANIMAL[getXiu]
  end

  def getGong
    LunarUtil::GONG[getXiu]
  end

  def getShou
    LunarUtil::SHOU[getGong]
  end

  def to_s
    toString
  end

  def toString
    "#{getYearInChinese}年#{getMonthInChinese}月#{getDayInChinese}"
  end

  def toFullString
    s = toString
    getFestivals.each do |f|
      s += " (#{f})"
    end
    s
  end
end
# -*- coding: utf-8 -*-
require_relative 'lunar'
require_relative 'tao_festival'
require_relative 'util/lunar_util'
require_relative 'util/tao_util'


class Tao
  # 道历

  BIRTH_YEAR = -2697

  def initialize(lunar)
    @lunar = lunar
  end

  def self.fromLunar(lunar)
    Tao.new(lunar)
  end

  def self.fromYmdHms(year, month, day, hour, minute, second)
    Tao.fromLunar(Lunar.fromYmdHms(year + Tao::BIRTH_YEAR, month, day, hour, minute, second))
  end

  def self.fromYmd(year, month, day)
    Tao.fromYmdHms(year, month, day, 0, 0, 0)
  end

  def getLunar
    @lunar
  end

  def getYear
    @lunar.getYear - Tao::BIRTH_YEAR
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
    md = "#{getMonth}-#{getDay}"
    if TaoUtil::FESTIVAL.key?(md)
      fs = TaoUtil::FESTIVAL[md]
      fs.each do |f|
        festivals.push(f)
      end
    end
    jq = @lunar.getJieQi
    if "冬至" == jq
      festivals.push(TaoFestival.new("元始天尊圣诞"))
    elsif "夏至" == jq
      festivals.push(TaoFestival.new("灵宝天尊圣诞"))
    end
    # 八节日
    if TaoUtil::BA_JIE.key?(jq)
      festivals.push(TaoFestival.new(TaoUtil::BA_JIE[jq]))
    end
    # 八会日
    gz = @lunar.getDayInGanZhi
    if TaoUtil::BA_HUI.key?(gz)
      festivals.push(TaoFestival.new(TaoUtil::BA_HUI[gz]))
    end
    festivals
  end

  def isDayIn_private(days)
    md = "#{getMonth}-#{getDay}"
    days.each do |d|
      if md == d
        return true
      end
    end
    false
  end

  def isDaySanHui
    isDayIn_private(TaoUtil::SAN_HUI)
  end

  def isDaySanYuan
    isDayIn_private(TaoUtil::SAN_YUAN)
  end

  def isDayBaJie
    TaoUtil::BA_JIE.key?(@lunar.getJieQi)
  end

  def isDayWuLa
    isDayIn_private(TaoUtil::WU_LA)
  end

  def isDayBaHui
    TaoUtil::BA_HUI.key?(@lunar.getDayInGanZhi)
  end

  def isDayMingWu
    "戊" == @lunar.getDayGan
  end

  def isDayAnWu
    @lunar.getDayZhi == TaoUtil::AN_WU[getMonth.abs - 1]
  end

  def isDayWu
    isDayMingWu || isDayAnWu
  end

  def isDayTianShe
    ret = false
    mz = @lunar.getMonthZhi
    dgz = @lunar.getDayInGanZhi
    if "寅卯辰".include?(mz)
      if "戊寅" == dgz
        ret = true
      end
    elsif "巳午未".include?(mz)
      if "甲午" == dgz
        ret = true
      end
    elsif "申酉戌".include?(mz)
      if "戊申" == dgz
        ret = true
      end
    elsif "亥子丑".include?(mz)
      if "甲子" == dgz
        ret = true
      end
    end
    ret
  end

  def to_s
    toString
  end

  def toString
    "#{getYearInChinese}年#{getMonthInChinese}月#{getDayInChinese}"
  end

  def toFullString
    "道歷#{getYearInChinese}年，天运#{@lunar.getYearInGanZhi}年，#{@lunar.getMonthInGanZhi}月，#{@lunar.getDayInGanZhi}日。#{getMonthInChinese}月#{getDayInChinese}日，#{@lunar.getTimeZhi}時。"
  end
end
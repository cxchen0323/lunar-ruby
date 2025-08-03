# -*- coding: utf-8 -*-
require_relative 'nine_star'
require_relative 'util/lunar_util'


class LunarTime
  # 时辰

  def initialize(lunar_year, lunar_month, lunar_day, hour, minute, second)
    require_relative 'lunar'
    @lunar = Lunar.fromYmdHms(lunar_year, lunar_month, lunar_day, hour, minute, second)
    @zhiIndex = LunarUtil.getTimeZhiIndex("%02d:%02d" % [hour, minute])
    @ganIndex = (@lunar.getDayGanIndexExact % 5 * 2 + @zhiIndex) % 10
  end

  def self.fromYmdHms(lunar_year, lunar_month, lunar_day, hour, minute, second)
    LunarTime.new(lunar_year, lunar_month, lunar_day, hour, minute, second)
  end

  def getGan
    LunarUtil::GAN[@ganIndex + 1]
  end

  def getZhi
    LunarUtil::ZHI[@zhiIndex + 1]
  end

  def getGanZhi
    "%s%s" % [getGan, getZhi]
  end

  def getShengXiao
    LunarUtil::SHENGXIAO[@zhiIndex + 1]
  end

  def getPositionXi
    LunarUtil::POSITION_XI[@ganIndex + 1]
  end

  def getPositionXiDesc
    LunarUtil::POSITION_DESC[getPositionXi]
  end

  def getPositionYangGui
    LunarUtil::POSITION_YANG_GUI[@ganIndex + 1]
  end

  def getPositionYangGuiDesc
    LunarUtil::POSITION_DESC[getPositionYangGui]
  end

  def getPositionYinGui
    LunarUtil::POSITION_YIN_GUI[@ganIndex + 1]
  end

  def getPositionYinGuiDesc
    LunarUtil::POSITION_DESC[getPositionYinGui]
  end

  def getPositionFu(sect = 2)
    (1 == sect ? LunarUtil::POSITION_FU : LunarUtil::POSITION_FU_2)[@ganIndex + 1]
  end

  def getPositionFuDesc(sect = 2)
    LunarUtil::POSITION_DESC[getPositionFu(sect)]
  end

  def getPositionCai
    LunarUtil::POSITION_CAI[@ganIndex + 1]
  end

  def getPositionCaiDesc
    LunarUtil::POSITION_DESC[getPositionCai]
  end

  def getChong
    LunarUtil::CHONG[@zhiIndex]
  end

  def getChongGan
    LunarUtil::CHONG_GAN[@ganIndex]
  end

  def getChongGanTie
    LunarUtil::CHONG_GAN_TIE[@ganIndex]
  end

  def getChongShengXiao
    chong = getChong
    (0...LunarUtil::ZHI.length).each do |i|
      if LunarUtil::ZHI[i] == chong
        return LunarUtil::SHENGXIAO[i]
      end
    end
    ""
  end

  def getChongDesc
    "(" + getChongGan + getChong + ")" + getChongShengXiao
  end

  def getSha
    LunarUtil::SHA[getZhi]
  end

  def getNaYin
    LunarUtil::NAYIN[getGanZhi]
  end

  def getTianShen
    LunarUtil::TIAN_SHEN[(@zhiIndex + LunarUtil::ZHI_TIAN_SHEN_OFFSET[@lunar.getDayZhiExact]) % 12 + 1]
  end

  def getTianShenType
    LunarUtil::TIAN_SHEN_TYPE[getTianShen]
  end

  def getTianShenLuck
    LunarUtil::TIAN_SHEN_TYPE_LUCK[getTianShenType]
  end

  def getYi
    # 获取时宜
    # :return: 宜
    LunarUtil.getTimeYi(@lunar.getDayInGanZhiExact, getGanZhi)
  end

  def getJi
    # 获取时忌
    # :return: 忌
    LunarUtil.getTimeJi(@lunar.getDayInGanZhiExact, getGanZhi)
  end

  def getNineStar
    solar_ymd = @lunar.getSolar.toYmd
    jie_qi = @lunar.getJieQiTable
    asc = false
    if jie_qi["冬至"] <= solar_ymd && solar_ymd < jie_qi["夏至"]
      asc = true
    end
    start = asc ? 7 : 3
    day_zhi = @lunar.getDayZhi
    if ["子", "午", "卯", "酉"].include?(day_zhi)
      start = asc ? 1 : 9
    elsif ["辰", "戌", "丑", "未"].include?(day_zhi)
      start = asc ? 4 : 6
    end
    index = asc ? start + @zhiIndex - 1 : start - @zhiIndex - 1

    if index > 8
      index -= 9
    end
    if index < 0
      index += 9
    end
    NineStar.fromIndex(index)
  end

  def getGanIndex
    @ganIndex
  end

  def getZhiIndex
    @zhiIndex
  end

  def to_s
    toString
  end

  def toString
    getGanZhi
  end

  def getXun
    # 获取时辰所在旬
    # :return: 旬
    LunarUtil.getXun(getGanZhi)
  end

  def getXunKong
    # 获取值时空亡
    # :return: 空亡(旬空)
    LunarUtil.getXunKong(getGanZhi)
  end

  def getMinHm
    hour = @lunar.getHour
    if hour < 1
      return "00:00"
    elsif hour > 22
      return "23:00"
    end
    "%02d:00" % (hour % 2 == 0 ? hour - 1 : hour)
  end

  def getMaxHm
    hour = @lunar.getHour
    if hour < 1
      return "00:59"
    elsif hour > 22
      return "23:59"
    end
    "%02d:59" % (hour % 2 != 0 ? hour + 1 : hour)
  end
end

# -*- coding: utf-8 -*-
require_relative 'liu_yue'
require_relative '../util/lunar_util'


class LiuNian
  # 流年

  def initialize(da_yun, index)
    @daYun = da_yun
    @lunar = da_yun.getLunar
    @index = index
    @year = da_yun.getStartYear + index
    @age = da_yun.getStartAge + index
  end

  def getIndex
    @index
  end

  def getYear
    @year
  end

  def getAge
    @age
  end

  def getGanZhi
    # 获取干支
    # :return: 干支
    offset = LunarUtil.getJiaZiIndex(@lunar.getJieQiTable["立春"].getLunar.getYearInGanZhiExact) + @index
    if @daYun.getIndex > 0
      offset += @daYun.getStartAge - 1
    end
    offset %= LunarUtil::JIA_ZI.length
    LunarUtil::JIA_ZI[offset]
  end

  def getXun
    # 获取所在旬
    # :return: 旬
    LunarUtil.getXun(getGanZhi)
  end

  def getXunKong
    # 获取旬空(空亡)
    # :return: 旬空(空亡)
    LunarUtil.getXunKong(getGanZhi)
  end

  def getLiuYue
    # 获取流月
    # :return: 流月
    n = 12
    liu_yue = []
    (0...n).each do |i|
      liu_yue.push(LiuYue.new(self, i))
    end
    liu_yue
  end
end
# -*- coding: utf-8 -*-
require_relative 'xiao_yun'
require_relative 'liu_nian'
require_relative '../util/lunar_util'


class DaYun
  # 大运

  def initialize(yun, index)
    @yun = yun
    @lunar = yun.getLunar
    @index = index
    birth_year = yun.getLunar.getSolar.getYear
    year = yun.getStartSolar.getYear
    if index < 1
      @startYear = birth_year
      @startAge = 1
      @endYear = year - 1
      @endAge = year - birth_year
    else
      add = (index - 1) * 10
      @startYear = year + add
      @startAge = @startYear - birth_year + 1
      @endYear = @startYear + 9
      @endAge = @startAge + 9
    end
  end

  def getStartYear
    @startYear
  end

  def getEndYear
    @endYear
  end

  def getStartAge
    @startAge
  end

  def getEndAge
    @endAge
  end

  def getIndex
    @index
  end

  def getLunar
    @lunar
  end

  def getGanZhi
    # 获取干支
    # :return: 干支
    if @index < 1
      return ""
    end
    offset = LunarUtil.getJiaZiIndex(@lunar.getMonthInGanZhiExact)
    offset += @yun.isForward ? @index : -@index
    size = LunarUtil::JIA_ZI.length
    if offset >= size
      offset -= size
    end
    if offset < 0
      offset += size
    end
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

  def getLiuNian(n = 10)
    # 获取流年
    # :param n: 轮数
    # :return: 流年
    if @index < 1
      n = @endYear - @startYear + 1
    end
    liu_nian = []
    (0...n).each do |i|
      liu_nian.push(LiuNian.new(self, i))
    end
    liu_nian
  end

  def getXiaoYun(n = 10)
    # 获取小运
    # :param n: 轮数
    # :return: 小运
    if @index < 1
      n = @endYear - @startYear + 1
    end
    xiao_yun = []
    (0...n).each do |i|
      xiao_yun.push(XiaoYun.new(self, i, @yun.isForward))
    end
    xiao_yun
  end
end

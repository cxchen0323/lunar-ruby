# -*- coding: utf-8 -*-
require_relative '../util/lunar_util'


class XiaoYun
  # 小运

  def initialize(da_yun, index, forward)
    @daYun = da_yun
    @lunar = da_yun.getLunar
    @index = index
    @year = da_yun.getStartYear + index
    @age = da_yun.getStartAge + index
    @forward = forward
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
    offset = LunarUtil.getJiaZiIndex(@lunar.getTimeInGanZhi)
    add = @index + 1
    if @daYun.getIndex > 0
      add += @daYun.getStartAge - 1
    end
    offset += @forward ? add : -add
    size = LunarUtil::JIA_ZI.length
    while offset < 0
      offset += size
    end
    offset %= size
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
end
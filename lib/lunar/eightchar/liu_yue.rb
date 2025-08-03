# -*- coding: utf-8 -*-

require_relative '../util/lunar_util'


class LiuYue
  # 流月

  def initialize(liu_nian, index)
    @liuNian = liu_nian
    @index = index
  end

  def getIndex
    @index
  end

  def getMonthInChinese
    # 获取中文的月
    # :return: 中文月，如正
    LunarUtil::MONTH[@index + 1]
  end

  def getGanZhi
    # 获取干支
    # <p>
    # 《五虎遁》
    # 甲己之年丙作首，
    # 乙庚之年戊为头，
    # 丙辛之年寻庚上，
    # 丁壬壬寅顺水流，
    # 若问戊癸何处走，
    # 甲寅之上好追求。
    # :return: 干支
    offset = 0
    year_gan_zhi = @liuNian.getGanZhi
    year_gan = year_gan_zhi[0, 1]
    if "甲" == year_gan || "己" == year_gan
      offset = 2
    elsif "乙" == year_gan || "庚" == year_gan
      offset = 4
    elsif "丙" == year_gan || "辛" == year_gan
      offset = 6
    elsif "丁" == year_gan || "壬" == year_gan
      offset = 8
    end
    gan = LunarUtil::GAN[(@index + offset) % 10 + 1]
    zhi = LunarUtil::ZHI[(@index + LunarUtil::BASE_MONTH_ZHI_INDEX) % 12 + 1]
    gan + zhi
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
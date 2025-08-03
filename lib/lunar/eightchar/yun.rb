# -*- coding: utf-8 -*-
require_relative 'da_yun'
require_relative '../util/lunar_util'


class Yun
  # 运

  def initialize(eight_char, gender, sect = 1)
    @lunar = eight_char.getLunar
    @gender = gender
    yang = 0 == @lunar.getYearGanIndexExact % 2
    man = 1 == gender
    @forward = (yang && man) || (!yang && !man)
    compute_start_private(sect)
  end

  def compute_start_private(sect)
    # 起运计算
    prev_jie = @lunar.getPrevJie
    next_jie = @lunar.getNextJie
    current = @lunar.getSolar
    start = @forward ? current : prev_jie.getSolar
    end_date = @forward ? next_jie.getSolar : current

    hour = 0

    if 2 == sect
      minutes = end_date.subtractMinute(start)
      year = (minutes / 4320).to_i
      minutes -= year * 4320
      month = (minutes / 360).to_i
      minutes -= month * 360
      day = (minutes / 12).to_i
      minutes -= day * 12
      hour = minutes * 2
    else
      end_time_zhi_index = end_date.getHour == 23 ? 11 : LunarUtil.getTimeZhiIndex(end_date.toYmdHms[11, 5])
      start_time_zhi_index = start.getHour == 23 ? 11 : LunarUtil.getTimeZhiIndex(start.toYmdHms[11, 5])
      # 时辰差
      hour_diff = end_time_zhi_index - start_time_zhi_index
      day_diff = end_date.subtract(start)
      if hour_diff < 0
        hour_diff += 12
        day_diff -= 1
      end
      month_diff = (hour_diff * 10 / 30).to_i
      month = day_diff * 4 + month_diff
      day = hour_diff * 10 - month_diff * 30
      year = (month / 12).to_i
      month = month - year * 12
    end
    @startYear = year
    @startMonth = month
    @startDay = day
    @startHour = hour
  end

  def getGender
    # 获取性别
    # :return: 性别(1男 ， 0女)
    @gender
  end

  def getStartYear
    # 获取起运年数
    # :return: 起运年数
    @startYear
  end

  def getStartMonth
    # 获取起运月数
    # :return: 起运月数
    @startMonth
  end

  def getStartDay
    # 获取起运天数
    # :return: 起运天数
    @startDay
  end

  def getStartHour
    # 获取起运小时数
    # :return: 起运小时数
    @startHour
  end

  def isForward
    # 是否顺推
    # :return: true/false
    @forward
  end

  def getLunar
    @lunar
  end

  def getStartSolar
    # 获取起运的阳历日期
    # :return: 阳历日期
    solar = @lunar.getSolar
    solar = solar.nextYear(@startYear)
    solar = solar.nextMonth(@startMonth)
    solar = solar.next(@startDay)
    solar.nextHour(@startHour)
  end

  def getDaYun(n = 10)
    # 获取大运
    # :param n: 轮数
    # :return: 大运
    da_yun = []
    (0...n).each do |i|
      da_yun.push(DaYun.new(self, i))
    end
    da_yun
  end
end

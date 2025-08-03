# -*- coding: utf-8 -*-
require_relative 'solar'
require_relative 'nine_star'
require_relative 'eight_char'
require_relative 'jie_qi'
require_relative 'shu_jiu'
require_relative 'fu'
require_relative 'lunar_time'
require_relative 'util/lunar_util'
require_relative 'util/solar_util'


class Lunar
  # 阴历日期
  JIE_QI = ["冬至", "小寒", "大寒", "立春", "雨水", "惊蛰", "春分", "清明", "谷雨", "立夏", "小满", "芒种", "夏至", "小暑", "大暑", "立秋", "处暑", "白露", "秋分", "寒露", "霜降", "立冬", "小雪", "大雪"]
  JIE_QI_IN_USE = ["DA_XUE", "冬至", "小寒", "大寒", "立春", "雨水", "惊蛰", "春分", "清明", "谷雨", "立夏", "小满", "芒种", "夏至", "小暑", "大暑", "立秋", "处暑", "白露", "秋分", "寒露", "霜降", "立冬", "小雪", "大雪", "DONG_ZHI", "XIAO_HAN", "DA_HAN", "LI_CHUN", "YU_SHUI", "JING_ZHE"]

  def initialize(lunar_year, lunar_month, lunar_day, hour, minute, second)
    require_relative 'lunar_year'
    y = LunarYear.fromYear(lunar_year)
    m = y.getMonth(lunar_month)
    if m.nil?
      raise "wrong lunar year #{lunar_year}  month #{lunar_month}"
    end
    if lunar_day < 1
      raise "lunar day must bigger than 0"
    end
    days = m.getDayCount
    if lunar_day > days
      raise "only #{days} days in lunar year #{lunar_year} month #{lunar_month}"
    end
    @year = lunar_year
    @month = lunar_month
    @day = lunar_day
    @hour = hour
    @minute = minute
    @second = second
    @jieQi = {}
    @jieQiList = []
    @eightChar = nil
    noon = Solar.fromJulianDay(m.getFirstJulianDay + lunar_day - 1)
    @solar = Solar.fromYmdHms(noon.getYear, noon.getMonth, noon.getDay, hour, minute, second)
    if noon.getYear != lunar_year
      y = LunarYear.fromYear(noon.getYear)
    end
    compute(y)
  end

  def compute(y)
    computeJieQi(y)
    computeYear
    computeMonth
    computeDay
    computeTime
    computeWeek
  end

  def computeJieQi(y)
    julian_days = y.getJieQiJulianDays
    (0...Lunar::JIE_QI_IN_USE.length).each do |i|
      name = Lunar::JIE_QI_IN_USE[i]
      @jieQi[name] = Solar.fromJulianDay(julian_days[i])
      @jieQiList.push(name)
    end
  end

  def computeYear
    # 以正月初一开始
    offset = @year - 4
    year_gan_index = offset % 10
    year_zhi_index = offset % 12

    if year_gan_index < 0
      year_gan_index += 10
    end

    if year_zhi_index < 0
      year_zhi_index += 12
    end

    # 以立春作为新一年的开始的干支纪年
    g = year_gan_index
    z = year_zhi_index

    # 精确的干支纪年，以立春交接时刻为准
    g_exact = year_gan_index
    z_exact = year_zhi_index

    solar_year = @solar.getYear
    solar_ymd = @solar.toYmd
    solar_ymd_hms = @solar.toYmdHms

    # 获取立春的阳历时刻
    li_chun = @jieQi["立春"]
    if li_chun.getYear != solar_year
      li_chun = @jieQi["LI_CHUN"]
    end
    li_chun_ymd = li_chun.toYmd
    li_chun_ymd_hms = li_chun.toYmdHms

    # 阳历和阴历年份相同代表正月初一及以后
    if @year == solar_year
      # 立春日期判断
      if solar_ymd < li_chun_ymd
        g -= 1
        z -= 1
      end
      # 立春交接时刻判断
      if solar_ymd_hms < li_chun_ymd_hms
        g_exact -= 1
        z_exact -= 1
      end
    elsif @year < solar_year
      if solar_ymd >= li_chun_ymd
        g += 1
        z += 1
      end
      if solar_ymd_hms >= li_chun_ymd_hms
        g_exact += 1
        z_exact += 1
      end
    end

    @yearGanIndex = year_gan_index
    @yearZhiIndex = year_zhi_index

    @yearGanIndexByLiChun = (g < 0 ? g + 10 : g) % 10
    @yearZhiIndexByLiChun = (z < 0 ? z + 12 : z) % 12

    @yearGanIndexExact = (g_exact < 0 ? g_exact + 10 : g_exact) % 10
    @yearZhiIndexExact = (z_exact < 0 ? z_exact + 12 : z_exact) % 12
  end

  def computeMonth
    ymd = @solar.toYmd
    time = @solar.toYmdHms
    size = Lunar::JIE_QI_IN_USE.length

    # 序号：大雪以前-3，大雪到小寒之间-2，小寒到立春之间-1，立春之后0
    index = -3
    start = nil
    (0...size).step(2) do |i|
      end_jieqi = @jieQi[Lunar::JIE_QI_IN_USE[i]]
      symd = start.nil? ? ymd : start.toYmd
      if symd <= ymd && ymd < end_jieqi.toYmd
        break
      end
      start = end_jieqi
      index += 1
    end
    # 干偏移值（以立春当天起算）
    g_offset = (((@yearGanIndexByLiChun + (index < 0 ? 1 : 0)) % 5 + 1) * 2) % 10
    @monthGanIndex = ((index < 0 ? index + 10 : index) + g_offset) % 10
    @monthZhiIndex = ((index < 0 ? index + 12 : index) + LunarUtil::BASE_MONTH_ZHI_INDEX) % 12

    index = -3
    start = nil
    (0...size).step(2) do |i|
      end_jieqi = @jieQi[Lunar::JIE_QI_IN_USE[i]]
      stime = start.nil? ? time : start.toYmdHms
      if stime <= time && time < end_jieqi.toYmdHms
        break
      end
      start = end_jieqi
      index += 1
    end
    # 干偏移值（以立春交接时刻起算）
    g_offset = (((@yearGanIndexExact + (index < 0 ? 1 : 0)) % 5 + 1) * 2) % 10
    @monthGanIndexExact = ((index < 0 ? index + 10 : index) + g_offset) % 10
    @monthZhiIndexExact = ((index < 0 ? index + 12 : index) + LunarUtil::BASE_MONTH_ZHI_INDEX) % 12
  end

  def computeDay
    noon = Solar.fromYmdHms(@solar.getYear, @solar.getMonth, @solar.getDay, 12, 0, 0)
    offset = noon.getJulianDay.to_i - 11
    day_gan_index = offset % 10
    day_zhi_index = offset % 12

    @dayGanIndex = day_gan_index
    @dayZhiIndex = day_zhi_index

    day_gan_exact = day_gan_index
    day_zhi_exact = day_zhi_index

    # 八字流派2，晚子时（夜子/子夜）日柱算当天
    @dayGanIndexExact2 = day_gan_exact
    @dayZhiIndexExact2 = day_zhi_exact

    # 八字流派1，晚子时（夜子/子夜）日柱算明天
    hm = (@hour < 10 ? "0" : "") + @hour.to_s + ":" + (@minute < 10 ? "0" : "") + @minute.to_s
    if "23:00" <= hm && hm <= "23:59"
      day_gan_exact += 1
      if day_gan_exact >= 10
        day_gan_exact -= 10
      end
      day_zhi_exact += 1
      if day_zhi_exact >= 12
        day_zhi_exact -= 12
      end
    end
    @dayGanIndexExact = day_gan_exact
    @dayZhiIndexExact = day_zhi_exact
  end

  def computeTime
    time_zhi_index = LunarUtil.getTimeZhiIndex((@hour < 10 ? "0" : "") + @hour.to_s + ":" + (@minute < 10 ? "0" : "") + @minute.to_s)
    @timeZhiIndex = time_zhi_index
    @timeGanIndex = (@dayGanIndexExact % 5 * 2 + time_zhi_index) % 10
  end

  def computeWeek
    @weekIndex = @solar.getWeek
  end

  def self.fromYmdHms(lunar_year, lunar_month, lunar_day, hour, minute, second)
    Lunar.new(lunar_year, lunar_month, lunar_day, hour, minute, second)
  end

  def self.fromYmd(lunar_year, lunar_month, lunar_day)
    Lunar.new(lunar_year, lunar_month, lunar_day, 0, 0, 0)
  end

  def self.fromDate(date)
    Lunar.fromSolar(Solar.fromDate(date))
  end

  def self.fromSolar(solar)
    require_relative 'lunar_year'
    year = 0
    month = 0
    day = 0
    ly = LunarYear.fromYear(solar.getYear)
    ly.getMonths.each do |m|
      days = solar.subtract(Solar.fromJulianDay(m.getFirstJulianDay))
      if days < m.getDayCount
        year = m.getYear
        month = m.getMonth
        day = days + 1
        break
      end
    end
    Lunar.new(year, month, day, solar.getHour, solar.getMinute, solar.getSecond)
  end

  def getYear
    @year
  end

  def getMonth
    @month
  end

  def getDay
    @day
  end

  def getHour
    @hour
  end

  def getMinute
    @minute
  end

  def getSecond
    @second
  end

  def getSolar
    @solar
  end

  def getYearGan
    LunarUtil::GAN[@yearGanIndex + 1]
  end

  def getYearGanByLiChun
    LunarUtil::GAN[@yearGanIndexByLiChun + 1]
  end

  def getYearGanExact
    LunarUtil::GAN[@yearGanIndexExact + 1]
  end

  def getYearZhi
    LunarUtil::ZHI[@yearZhiIndex + 1]
  end

  def getYearZhiByLiChun
    LunarUtil::ZHI[@yearZhiIndexByLiChun + 1]
  end

  def getYearZhiExact
    LunarUtil::ZHI[@yearZhiIndexExact + 1]
  end

  def getYearInGanZhi
    "%s%s" % [getYearGan, getYearZhi]
  end

  def getYearInGanZhiByLiChun
    "%s%s" % [getYearGanByLiChun, getYearZhiByLiChun]
  end

  def getYearInGanZhiExact
    "%s%s" % [getYearGanExact, getYearZhiExact]
  end

  def getMonthGan
    LunarUtil::GAN[@monthGanIndex + 1]
  end

  def getMonthGanExact
    LunarUtil::GAN[@monthGanIndexExact + 1]
  end

  def getMonthZhi
    LunarUtil::ZHI[@monthZhiIndex + 1]
  end

  def getMonthZhiExact
    LunarUtil::ZHI[@monthZhiIndexExact + 1]
  end

  def getMonthInGanZhi
    "%s%s" % [getMonthGan, getMonthZhi]
  end

  def getMonthInGanZhiExact
    "%s%s" % [getMonthGanExact, getMonthZhiExact]
  end

  def getDayGan
    LunarUtil::GAN[@dayGanIndex + 1]
  end

  def getDayGanExact
    LunarUtil::GAN[@dayGanIndexExact + 1]
  end

  def getDayGanExact2
    LunarUtil::GAN[@dayGanIndexExact2 + 1]
  end

  def getDayZhi
    LunarUtil::ZHI[@dayZhiIndex + 1]
  end

  def getDayZhiExact
    LunarUtil::ZHI[@dayZhiIndexExact + 1]
  end

  def getDayZhiExact2
    LunarUtil::ZHI[@dayZhiIndexExact2 + 1]
  end

  def getDayInGanZhi
    "%s%s" % [getDayGan, getDayZhi]
  end

  def getDayInGanZhiExact
    "%s%s" % [getDayGanExact, getDayZhiExact]
  end

  def getDayInGanZhiExact2
    "%s%s" % [getDayGanExact2, getDayZhiExact2]
  end

  def getTimeGan
    LunarUtil::GAN[@timeGanIndex + 1]
  end

  def getTimeZhi
    LunarUtil::ZHI[@timeZhiIndex + 1]
  end

  def getTimeInGanZhi
    "%s%s" % [getTimeGan, getTimeZhi]
  end

  def getYearShengXiao
    LunarUtil::SHENGXIAO[@yearZhiIndex + 1]
  end

  def getYearShengXiaoByLiChun
    LunarUtil::SHENGXIAO[@yearZhiIndexByLiChun + 1]
  end

  def getYearShengXiaoExact
    LunarUtil::SHENGXIAO[@yearZhiIndexExact + 1]
  end

  def getMonthShengXiao
    LunarUtil::SHENGXIAO[@monthZhiIndex + 1]
  end

  def getMonthShengXiaoExact
    LunarUtil::SHENGXIAO[@monthZhiIndexExact + 1]
  end

  def getDayShengXiao
    LunarUtil::SHENGXIAO[@dayZhiIndex + 1]
  end

  def getTimeShengXiao
    LunarUtil::SHENGXIAO[@timeZhiIndex + 1]
  end

  def getYearInChinese
    y = @year.to_s
    s = ""
    (0...y.length).each do |i|
      s += LunarUtil::NUMBER[y[i].ord - 48]
    end
    s
  end

  def getMonthInChinese
    month = @month
    (month < 0 ? "闰" : "") + LunarUtil::MONTH[month.abs]
  end

  def getDayInChinese
    LunarUtil::DAY[@day]
  end

  def getPengZuGan
    LunarUtil::PENG_ZU_GAN[@dayGanIndex + 1]
  end

  def getPengZuZhi
    LunarUtil::PENG_ZU_ZHI[@dayZhiIndex + 1]
  end

  def getPositionXi
    getDayPositionXi
  end

  def getPositionXiDesc
    getDayPositionXiDesc
  end

  def getPositionYangGui
    getDayPositionYangGui
  end

  def getPositionYangGuiDesc
    getDayPositionYangGuiDesc
  end

  def getPositionYinGui
    getDayPositionYinGui
  end

  def getPositionYinGuiDesc
    getDayPositionYinGuiDesc
  end

  def getPositionFu
    getDayPositionFu
  end

  def getPositionFuDesc
    getDayPositionFuDesc
  end

  def getPositionCai
    getDayPositionCai
  end

  def getPositionCaiDesc
    getDayPositionCaiDesc
  end

  def getDayPositionXi
    LunarUtil::POSITION_XI[@dayGanIndex + 1]
  end

  def getDayPositionXiDesc
    LunarUtil::POSITION_DESC[getDayPositionXi]
  end

  def getDayPositionYangGui
    LunarUtil::POSITION_YANG_GUI[@dayGanIndex + 1]
  end

  def getDayPositionYangGuiDesc
    LunarUtil::POSITION_DESC[getDayPositionYangGui]
  end

  def getDayPositionYinGui
    LunarUtil::POSITION_YIN_GUI[@dayGanIndex + 1]
  end

  def getDayPositionYinGuiDesc
    LunarUtil::POSITION_DESC[getDayPositionYinGui]
  end

  def getDayPositionFu(sect = 2)
    (1 == sect ? LunarUtil::POSITION_FU : LunarUtil::POSITION_FU_2)[@dayGanIndex + 1]
  end

  def getDayPositionFuDesc(sect = 2)
    LunarUtil::POSITION_DESC[getDayPositionFu(sect)]
  end

  def getDayPositionCai
    LunarUtil::POSITION_CAI[@dayGanIndex + 1]
  end

  def getDayPositionCaiDesc
    LunarUtil::POSITION_DESC[getDayPositionCai]
  end

  def getYearPositionTaiSui(sect = 2)
    if 1 == sect
      year_zhi_index = @yearZhiIndex
    elsif 3 == sect
      year_zhi_index = @yearZhiIndexExact
    else
      year_zhi_index = @yearZhiIndexByLiChun
    end
    LunarUtil::POSITION_TAI_SUI_YEAR[year_zhi_index]
  end

  def getYearPositionTaiSuiDesc(sect = 2)
    LunarUtil::POSITION_DESC[getYearPositionTaiSui(sect)]
  end

  def getMonthPositionTaiSui_private(month_zhi_index, month_gan_index)
    m = month_zhi_index - LunarUtil::BASE_MONTH_ZHI_INDEX
    if m < 0
      m += 12
    end
    m = m % 4
    if 0 == m
      p = "艮"
    elsif 2 == m
      p = "坤"
    elsif 3 == m
      p = "巽"
    else
      p = LunarUtil::POSITION_GAN[month_gan_index]
    end
    p
  end

  def getMonthPositionTaiSui(sect = 2)
    if 3 == sect
      month_zhi_index = @monthZhiIndexExact
      month_gan_index = @monthGanIndexExact
    else
      month_zhi_index = @monthZhiIndex
      month_gan_index = @monthGanIndex
    end
    getMonthPositionTaiSui_private(month_zhi_index, month_gan_index)
  end

  def getMonthPositionTaiSuiDesc(sect = 2)
    LunarUtil::POSITION_DESC[getMonthPositionTaiSui(sect)]
  end

  def getDayPositionTaiSui_private(day_in_gan_zhi, year_zhi_index)
    if ["甲子", "乙丑", "丙寅", "丁卯", "戊辰", "己巳"].include?(day_in_gan_zhi)
      p = "震"
    elsif ["丙子", "丁丑", "戊寅", "己卯", "庚辰", "辛巳"].include?(day_in_gan_zhi)
      p = "离"
    elsif ["戊子", "己丑", "庚寅", "辛卯", "壬辰", "癸巳"].include?(day_in_gan_zhi)
      p = "中"
    elsif ["庚子", "辛丑", "壬寅", "癸卯", "甲辰", "乙巳"].include?(day_in_gan_zhi)
      p = "兑"
    elsif ["壬子", "癸丑", "甲寅", "乙卯", "丙辰", "丁巳"].include?(day_in_gan_zhi)
      p = "坎"
    else
      p = LunarUtil::POSITION_TAI_SUI_YEAR[year_zhi_index]
    end
    p
  end

  def getDayPositionTaiSui(sect = 2)
    if 1 == sect
      day_in_gan_zhi = getDayInGanZhi
      year_zhi_index = @yearZhiIndex
    elsif 3 == sect
      day_in_gan_zhi = getDayInGanZhi
      year_zhi_index = @yearZhiIndexExact
    else
      day_in_gan_zhi = getDayInGanZhiExact2
      year_zhi_index = @yearZhiIndexByLiChun
    end
    getDayPositionTaiSui_private(day_in_gan_zhi, year_zhi_index)
  end

  def getDayPositionTaiSuiDesc(sect = 2)
    LunarUtil::POSITION_DESC[getDayPositionTaiSui(sect)]
  end

  def getTimePositionXi
    LunarUtil::POSITION_XI[@timeGanIndex + 1]
  end

  def getTimePositionXiDesc
    LunarUtil::POSITION_DESC[getTimePositionXi]
  end

  def getTimePositionYangGui
    LunarUtil::POSITION_YANG_GUI[@timeGanIndex + 1]
  end

  def getTimePositionYangGuiDesc
    LunarUtil::POSITION_DESC[getTimePositionYangGui]
  end

  def getTimePositionYinGui
    LunarUtil::POSITION_YIN_GUI[@timeGanIndex + 1]
  end

  def getTimePositionYinGuiDesc
    LunarUtil::POSITION_DESC[getTimePositionYinGui]
  end

  def getTimePositionFu(sect = 2)
    (1 == sect ? LunarUtil::POSITION_FU : LunarUtil::POSITION_FU_2)[@timeGanIndex + 1]
  end

  def getTimePositionFuDesc(sect = 2)
    LunarUtil::POSITION_DESC[getTimePositionFu(sect)]
  end

  def getTimePositionCai
    LunarUtil::POSITION_CAI[@timeGanIndex + 1]
  end

  def getTimePositionCaiDesc
    LunarUtil::POSITION_DESC[getTimePositionCai]
  end

  def getChong
    getDayChong
  end

  def getDayChong
    LunarUtil::CHONG[@dayZhiIndex]
  end

  def getTimeChong
    LunarUtil::CHONG[@timeZhiIndex]
  end

  def getChongGan
    getDayChongGan
  end

  def getDayChongGan
    LunarUtil::CHONG_GAN[@dayGanIndex]
  end

  def getTimeChongGan
    LunarUtil::CHONG_GAN[@timeGanIndex]
  end

  def getChongGanTie
    getDayChongGanTie
  end

  def getDayChongGanTie
    LunarUtil::CHONG_GAN_TIE[@dayGanIndex]
  end

  def getTimeChongGanTie
    LunarUtil::CHONG_GAN_TIE[@timeGanIndex]
  end

  def getChongShengXiao
    getDayChongShengXiao
  end

  def getDayChongShengXiao
    chong = getDayChong
    (0...LunarUtil::ZHI.length).each do |i|
      if LunarUtil::ZHI[i] == chong
        return LunarUtil::SHENGXIAO[i]
      end
    end
    ""
  end

  def getTimeChongShengXiao
    chong = getTimeChong
    (0...LunarUtil::ZHI.length).each do |i|
      if LunarUtil::ZHI[i] == chong
        return LunarUtil::SHENGXIAO[i]
      end
    end
    ""
  end

  def getChongDesc
    getDayChongDesc
  end

  def getDayChongDesc
    "(" + getDayChongGan + getDayChong + ")" + getDayChongShengXiao
  end

  def getTimeChongDesc
    "(" + getTimeChongGan + getTimeChong + ")" + getTimeChongShengXiao
  end

  def getSha
    getDaySha
  end

  def getDaySha
    LunarUtil::SHA[getDayZhi]
  end

  def getTimeSha
    LunarUtil::SHA[getTimeZhi]
  end

  def getYearNaYin
    LunarUtil::NAYIN[getYearInGanZhi]
  end

  def getMonthNaYin
    LunarUtil::NAYIN[getMonthInGanZhi]
  end

  def getDayNaYin
    LunarUtil::NAYIN[getDayInGanZhi]
  end

  def getTimeNaYin
    LunarUtil::NAYIN[getTimeInGanZhi]
  end

  def getSeason
    LunarUtil::SEASON[@month.abs]
  end

  def self.convertJieQi(name)
    jq = name
    if "DONG_ZHI" == jq
      jq = "冬至"
    elsif "DA_HAN" == jq
      jq = "大寒"
    elsif "XIAO_HAN" == jq
      jq = "小寒"
    elsif "LI_CHUN" == jq
      jq = "立春"
    elsif "YU_SHUI" == jq
      jq = "雨水"
    elsif "JING_ZHE" == jq
      jq = "惊蛰"
    elsif "DA_XUE" == jq
      jq = "大雪"
    end
    jq
  end

  def getJie
    (0...Lunar::JIE_QI_IN_USE.length).step(2) do |i|
      key = Lunar::JIE_QI_IN_USE[i]
      d = @jieQi[key]
      if d.getYear == @solar.getYear && d.getMonth == @solar.getMonth && d.getDay == @solar.getDay
        return Lunar.convertJieQi(key)
      end
    end
    ""
  end

  def getQi
    (1...Lunar::JIE_QI_IN_USE.length).step(2) do |i|
      key = Lunar::JIE_QI_IN_USE[i]
      d = @jieQi[key]
      if d.getYear == @solar.getYear && d.getMonth == @solar.getMonth && d.getDay == @solar.getDay
        return Lunar.convertJieQi(key)
      end
    end
    ""
  end

  def getWeek
    @weekIndex
  end

  def getWeekInChinese
    SolarUtil::WEEK[getWeek]
  end

  def getXiu
    LunarUtil::XIU[getDayZhi + getWeek.to_s]
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

  def getFestivals
    fs = []
    md = "#{@month}-#{@day}"
    if LunarUtil::FESTIVAL.key?(md)
      fs.push(LunarUtil::FESTIVAL[md])
    end
    if @month.abs == 12 && @day >= 29 && @year != self.next(1).getYear
      fs.push("除夕")
    end
    fs
  end

  def getOtherFestivals
    arr = []
    md = "#{@month}-#{@day}"
    if LunarUtil::OTHER_FESTIVAL.key?(md)
      fs = LunarUtil::OTHER_FESTIVAL[md]
      fs.each do |f|
        arr.push(f)
      end
    end
    solar_ymd = @solar.toYmd
    if solar_ymd == @jieQi["清明"].next(-1).toYmd
      arr.push("寒食节")
    end

    jq = @jieQi["立春"]
    offset = 4 - jq.getLunar.getDayGanIndex
    if offset < 0
      offset += 10
    end
    if solar_ymd == jq.next(offset + 40).toYmd
      arr.push("春社")
    end

    jq = @jieQi["立秋"]
    offset = 4 - jq.getLunar.getDayGanIndex
    if offset < 0
      offset += 10
    end
    if solar_ymd == jq.next(offset + 40).toYmd
      arr.push("秋社")
    end
    arr
  end

  def getEightChar
    if @eightChar.nil?
      @eightChar = EightChar.fromLunar(self)
    end
    @eightChar
  end

  def getBaZi
    ba_zi = getEightChar
    [ba_zi.getYear, ba_zi.getMonth, ba_zi.getDay, ba_zi.getTime]
  end

  def getBaZiWuXing
    ba_zi = getEightChar
    [ba_zi.getYearWuXing, ba_zi.getMonthWuXing, ba_zi.getDayWuXing, ba_zi.getTimeWuXing]
  end

  def getBaZiNaYin
    ba_zi = getEightChar
    [ba_zi.getYearNaYin, ba_zi.getMonthNaYin, ba_zi.getDayNaYin, ba_zi.getTimeNaYin]
  end

  def getBaZiShiShenGan
    ba_zi = getEightChar
    [ba_zi.getYearShiShenGan, ba_zi.getMonthShiShenGan, ba_zi.getDayShiShenGan, ba_zi.getTimeShiShenGan]
  end

  def getBaZiShiShenZhi
    ba_zi = getEightChar
    [ba_zi.getYearShiShenZhi[0], ba_zi.getMonthShiShenZhi[0], ba_zi.getDayShiShenZhi[0], ba_zi.getTimeShiShenZhi[0]]
  end

  def getBaZiShiShenYearZhi
    getEightChar.getYearShiShenZhi
  end

  def getBaZiShiShenMonthZhi
    getEightChar.getMonthShiShenZhi
  end

  def getBaZiShiShenDayZhi
    getEightChar.getDayShiShenZhi
  end

  def getBaZiShiShenTimeZhi
    getEightChar.getTimeShiShenZhi
  end

  def getZhiXing
    offset = @dayZhiIndex - @monthZhiIndex
    if offset < 0
      offset += 12
    end
    LunarUtil::ZHI_XING[offset + 1]
  end

  def getDayTianShen
    LunarUtil::TIAN_SHEN[(@dayZhiIndex + LunarUtil::ZHI_TIAN_SHEN_OFFSET[getMonthZhi]) % 12 + 1]
  end

  def getTimeTianShen
    LunarUtil::TIAN_SHEN[(@timeZhiIndex + LunarUtil::ZHI_TIAN_SHEN_OFFSET[getDayZhiExact]) % 12 + 1]
  end

  def getDayTianShenType
    LunarUtil::TIAN_SHEN_TYPE[getDayTianShen]
  end

  def getTimeTianShenType
    LunarUtil::TIAN_SHEN_TYPE[getTimeTianShen]
  end

  def getDayTianShenLuck
    LunarUtil::TIAN_SHEN_TYPE_LUCK[getDayTianShenType]
  end

  def getTimeTianShenLuck
    LunarUtil::TIAN_SHEN_TYPE_LUCK[getTimeTianShenType]
  end

  def getDayPositionTai
    LunarUtil::POSITION_TAI_DAY[LunarUtil.getJiaZiIndex(getDayInGanZhi)]
  end

  def getMonthPositionTai
    m = @month
    if m < 0
      return ""
    end
    LunarUtil::POSITION_TAI_MONTH[m - 1]
  end

  def getDayYi(sect = 1)
    # 获取每日宜
    # :return: 宜
    if 2 == sect
      month_gan_zhi = getMonthInGanZhiExact
    else
      month_gan_zhi = getMonthInGanZhi
    end
    LunarUtil.getDayYi(month_gan_zhi, getDayInGanZhi)
  end

  def getDayJi(sect = 1)
    # 获取每日忌
    # :return: 忌
    if 2 == sect
      month_gan_zhi = getMonthInGanZhiExact
    else
      month_gan_zhi = getMonthInGanZhi
    end
    LunarUtil.getDayJi(month_gan_zhi, getDayInGanZhi)
  end

  def getTimeYi
    # 获取时宜
    # :return: 宜
    LunarUtil.getTimeYi(getDayInGanZhiExact, getTimeInGanZhi)
  end

  def getTimeJi
    # 获取时忌
    # :return: 忌
    LunarUtil.getTimeJi(getDayInGanZhiExact, getTimeInGanZhi)
  end

  def getDayJiShen
    # 获取日吉神（宜趋）
    # :return: 日吉神
    LunarUtil.getDayJiShen(getMonth, getDayInGanZhi)
  end

  def getDayXiongSha
    # 获取日凶煞（宜忌）
    # :return: 日凶煞
    LunarUtil.getDayXiongSha(getMonth, getDayInGanZhi)
  end

  def getYueXiang
    # 获取月相
    # :return: 月相
    LunarUtil::YUE_XIANG[@day]
  end

  def getYearNineStar_private(year_in_gan_zhi)
    index_exact = LunarUtil.getJiaZiIndex(year_in_gan_zhi) + 1
    index = LunarUtil.getJiaZiIndex(getYearInGanZhi) + 1
    year_offset = index_exact - index
    if year_offset > 1
      year_offset -= 60
    elsif year_offset < -1
      year_offset += 60
    end
    yuan = ((@year + year_offset + 2696) / 60).to_i % 3
    offset = (62 + yuan * 3 - index_exact) % 9
    if 0 == offset
      offset = 9
    end
    NineStar.fromIndex(offset - 1)
  end

  def getYearNineStar(sect = 2)
    if 1 == sect
      year_in_gan_zhi = getYearInGanZhi
    elsif 3 == sect
      year_in_gan_zhi = getYearInGanZhiExact
    else
      year_in_gan_zhi = getYearInGanZhiByLiChun
    end
    getYearNineStar_private(year_in_gan_zhi)
  end

  def self.getMonthNineStar_private(year_zhi_index, month_zhi_index)
    index = year_zhi_index % 3
    n = 27 - index * 3
    if month_zhi_index < LunarUtil::BASE_MONTH_ZHI_INDEX
      n -= 3
    end
    offset = (n - month_zhi_index) % 9
    NineStar.fromIndex(offset)
  end

  def getMonthNineStar(sect = 2)
    if 1 == sect
      year_zhi_index = @yearZhiIndex
      month_zhi_index = @monthZhiIndex
    elsif 3 == sect
      year_zhi_index = @yearZhiIndexExact
      month_zhi_index = @monthZhiIndexExact
    else
      year_zhi_index = @yearZhiIndexByLiChun
      month_zhi_index = @monthZhiIndex
    end
    Lunar.getMonthNineStar_private(year_zhi_index, month_zhi_index)
  end

  def getDayNineStar
    solar_ymd = @solar.toYmd
    dong_zhi = @jieQi["冬至"]
    dong_zhi2 = @jieQi["DONG_ZHI"]
    xia_zhi = @jieQi["夏至"]

    dong_zhi_index = LunarUtil.getJiaZiIndex(dong_zhi.getLunar.getDayInGanZhi)
    dong_zhi_index2 = LunarUtil.getJiaZiIndex(dong_zhi2.getLunar.getDayInGanZhi)
    xia_zhi_index = LunarUtil.getJiaZiIndex(xia_zhi.getLunar.getDayInGanZhi)

    if dong_zhi_index > 29
      solar_shun_bai = dong_zhi.next(60 - dong_zhi_index)
    else
      solar_shun_bai = dong_zhi.next(-dong_zhi_index)
    end
    solar_shun_bai_ymd = solar_shun_bai.toYmd
    if dong_zhi_index2 > 29
      solar_shun_bai2 = dong_zhi2.next(60 - dong_zhi_index2)
    else
      solar_shun_bai2 = dong_zhi2.next(-dong_zhi_index2)
    end
    solar_shun_bai_ymd2 = solar_shun_bai2.toYmd
    if xia_zhi_index > 29
      solar_ni_zi = xia_zhi.next(60 - xia_zhi_index)
    else
      solar_ni_zi = xia_zhi.next(-xia_zhi_index)
    end
    solar_ni_zi_ymd = solar_ni_zi.toYmd
    offset = 0
    if solar_shun_bai_ymd <= solar_ymd && solar_ymd < solar_ni_zi_ymd
      offset = @solar.subtract(solar_shun_bai) % 9
    elsif solar_ni_zi_ymd <= solar_ymd && solar_ymd < solar_shun_bai_ymd2
      offset = 8 - (@solar.subtract(solar_ni_zi) % 9)
    elsif solar_ymd >= solar_shun_bai_ymd2
      offset = @solar.subtract(solar_shun_bai2) % 9
    elsif solar_ymd < solar_shun_bai_ymd
      offset = (8 + solar_shun_bai.subtract(@solar)) % 9
    end
    NineStar.fromIndex(offset)
  end

  def getTimeNineStar
    solar_ymd = @solar.toYmd
    asc = false
    if @jieQi["冬至"].toYmd <= solar_ymd && solar_ymd < @jieQi["夏至"].toYmd
      asc = true
    elsif solar_ymd >= @jieQi["DONG_ZHI"].toYmd
      asc = true
    end
    start = asc ? 6 : 2
    day_zhi = getDayZhi
    if ["子", "午", "卯", "酉"].include?(day_zhi)
      start = asc ? 0 : 8
    elsif ["辰", "戌", "丑", "未"].include?(day_zhi)
      start = asc ? 3 : 5
    end
    index = asc ? start + @timeZhiIndex : start + 9 - @timeZhiIndex
    NineStar.fromIndex(index % 9)
  end

  def getJieQiTable
    @jieQi
  end

  def getJieQiList
    @jieQiList
  end

  def getTimeGanIndex
    @timeGanIndex
  end

  def getTimeZhiIndex
    @timeZhiIndex
  end

  def getDayGanIndex
    @dayGanIndex
  end

  def getDayZhiIndex
    @dayZhiIndex
  end

  def getDayGanIndexExact
    @dayGanIndexExact
  end

  def getDayGanIndexExact2
    @dayGanIndexExact2
  end

  def getDayZhiIndexExact
    @dayZhiIndexExact
  end

  def getDayZhiIndexExact2
    @dayZhiIndexExact2
  end

  def getMonthGanIndex
    @monthGanIndex
  end

  def getMonthZhiIndex
    @monthZhiIndex
  end

  def getMonthGanIndexExact
    @monthGanIndexExact
  end

  def getMonthZhiIndexExact
    @monthZhiIndexExact
  end

  def getYearGanIndex
    @yearGanIndex
  end

  def getYearZhiIndex
    @yearZhiIndex
  end

  def getYearGanIndexByLiChun
    @yearGanIndexByLiChun
  end

  def getYearZhiIndexByLiChun
    @yearZhiIndexByLiChun
  end

  def getYearGanIndexExact
    @yearGanIndexExact
  end

  def getYearZhiIndexExact
    @yearZhiIndexExact
  end

  def getNextJie(whole_day = false)
    # 获取下一节（顺推的第一个节）
    # :param whole_day: 是否按天计
    # :return: 节气
    conditions = []
    (0...(Lunar::JIE_QI_IN_USE.length / 2).to_i).each do |i|
      conditions.push(Lunar::JIE_QI_IN_USE[i * 2])
    end
    getNearJieQi(true, conditions, whole_day)
  end

  def getPrevJie(whole_day = false)
    # 获取上一节（逆推的第一个节）
    # :param whole_day: 是否按天计
    # :return: 节气
    conditions = []
    (0...(Lunar::JIE_QI_IN_USE.length / 2).to_i).each do |i|
      conditions.push(Lunar::JIE_QI_IN_USE[i * 2])
    end
    getNearJieQi(false, conditions, whole_day)
  end

  def getNextQi(whole_day = false)
    # 获取下一气令（顺推的第一个气令）
    # :param whole_day: 是否按天计
    # :return: 节气
    conditions = []
    (0...(Lunar::JIE_QI_IN_USE.length / 2).to_i).each do |i|
      conditions.push(Lunar::JIE_QI_IN_USE[i * 2 + 1])
    end
    getNearJieQi(true, conditions, whole_day)
  end

  def getPrevQi(whole_day = false)
    # 获取上一气令（逆推的第一个气令）
    # :param whole_day: 是否按天计
    # :return: 节气
    conditions = []
    (0...(Lunar::JIE_QI_IN_USE.length / 2).to_i).each do |i|
      conditions.push(Lunar::JIE_QI_IN_USE[i * 2 + 1])
    end
    getNearJieQi(false, conditions, whole_day)
  end

  def getNextJieQi(whole_day = false)
    # 获取下一节气（顺推的第一个节气）
    # :param whole_day: 是否按天计
    # :return: 节气
    getNearJieQi(true, nil, whole_day)
  end

  def getPrevJieQi(whole_day = false)
    # 获取上一节气（逆推的第一个节气）
    # :param whole_day: 是否按天计
    # :return: 节气
    getNearJieQi(false, nil, whole_day)
  end

  def getNearJieQi(forward, conditions, whole_day)
    # 获取最近的节气，如果未找到匹配的，返回null
    # :param forward: 是否顺推，true为顺推，false为逆推
    # :param conditions: 过滤条件，如果设置过滤条件，仅返回匹配该名称的
    # :param whole_day: 是否按天计
    # :return: 节气
    name = nil
    near = nil
    filters = Set.new
    if !conditions.nil?
      conditions.each do |cond|
        filters.add(cond)
      end
    end
    is_filter = filters.length > 0
    today = whole_day ? @solar.toYmd : @solar.toYmdHms
    JIE_QI_IN_USE.each do |key|
      jq = Lunar.convertJieQi(key)
      if is_filter && !filters.include?(jq)
        next
      end
      solar = @jieQi[key]
      day = whole_day ? solar.toYmd : solar.toYmdHms
      if forward
        if day <= today
          next
        end
        if near.nil?
          name = jq
          near = solar
        else
          near_day = whole_day ? near.toYmd : near.toYmdHms
          if day < near_day
            name = jq
            near = solar
          end
        end
      else
        if day > today
          next
        end
        if near.nil?
          name = jq
          near = solar
        else
          near_day = whole_day ? near.toYmd : near.toYmdHms
          if day > near_day
            name = jq
            near = solar
          end
        end
      end
    end
    if near.nil?
      return nil
    end
    JieQi.new(name, near)
  end

  def getJieQi
    # 获取节气名称，如果无节气，返回空字符串
    # :return: 节气名称
    @jieQi.each do |key, d|
      if d.getYear == @solar.getYear && d.getMonth == @solar.getMonth && d.getDay == @solar.getDay
        return Lunar.convertJieQi(key)
      end
    end
    ""
  end

  def getCurrentJieQi
    # 获取当天节气对象，如果无节气，返回None
    # :return: 节气对象
    @jieQi.each do |key, d|
      if d.getYear == @solar.getYear && d.getMonth == @solar.getMonth && d.getDay == @solar.getDay
        return JieQi.new(Lunar.convertJieQi(key), @solar)
      end
    end
    nil
  end

  def getCurrentJie
    # 获取当天节令对象，如果无节令，返回None
    # :return: 节气对象
    (0...Lunar::JIE_QI_IN_USE.length).step(2) do |i|
      key = Lunar::JIE_QI_IN_USE[i]
      d = @jieQi[key]
      if d.getYear == @solar.getYear && d.getMonth == @solar.getMonth && d.getDay == @solar.getDay
        return JieQi.new(Lunar.convertJieQi(key), d)
      end
    end
    nil
  end

  def getCurrentQi
    # 获取当天气令对象，如果无气令，返回None
    # :return: 节气对象
    (1...Lunar::JIE_QI_IN_USE.length).step(2) do |i|
      key = Lunar::JIE_QI_IN_USE[i]
      d = @jieQi[key]
      if d.getYear == @solar.getYear && d.getMonth == @solar.getMonth && d.getDay == @solar.getDay
        return JieQi.new(Lunar.convertJieQi(key), d)
      end
    end
    nil
  end

  def next(days)
    # 获取往后推几天的农历日期，如果要往前推，则天数用负数
    # :param days: 天数
    # :return: 农历日期
    @solar.next(days).getLunar
  end

  def to_s
    toString
  end

  def toString
    "%s年%s月%s" % [getYearInChinese, getMonthInChinese, getDayInChinese]
  end

  def toFullString
    s = toString
    s += " " + getYearInGanZhi + "(" + getYearShengXiao + ")年"
    s += " " + getMonthInGanZhi + "(" + getMonthShengXiao + ")月"
    s += " " + getDayInGanZhi + "(" + getDayShengXiao + ")日"
    s += " " + getTimeZhi + "(" + getTimeShengXiao + ")时"
    s += " 纳音[" + getYearNaYin + " " + getMonthNaYin + " " + getDayNaYin + " " + getTimeNaYin + "]"
    s += " 星期" + getWeekInChinese
    getFestivals.each do |f|
      s += " (" + f + ")"
    end
    getOtherFestivals.each do |f|
      s += " (" + f + ")"
    end
    jq = getJieQi
    if jq.length > 0
      s += " [" + jq + "]"
    end
    s += " " + getGong + "方" + getShou
    s += " 星宿[" + getXiu + getZheng + getAnimal + "](" + getXiuLuck + ")"
    s += " 彭祖百忌[" + getPengZuGan + " " + getPengZuZhi + "]"
    s += " 喜神方位[" + getDayPositionXi + "](" + getDayPositionXiDesc + ")"
    s += " 阳贵神方位[" + getDayPositionYangGui + "](" + getDayPositionYangGuiDesc + ")"
    s += " 阴贵神方位[" + getDayPositionYinGui + "](" + getDayPositionYinGuiDesc + ")"
    s += " 福神方位[" + getDayPositionFu + "](" + getDayPositionFuDesc + ")"
    s += " 财神方位[" + getDayPositionCai + "](" + getDayPositionCaiDesc + ")"
    s += " 冲[" + getChongDesc + "]"
    s += " 煞[" + getSha + "]"
    s
  end

  def getYearXun
    # 获取年所在旬（以正月初一作为新年的开始）
    # :return: 旬
    LunarUtil.getXun(getYearInGanZhi)
  end

  def getYearXunByLiChun
    # 获取年所在旬（以立春当天作为新年的开始）
    # :return: 旬
    LunarUtil.getXun(getYearInGanZhiByLiChun)
  end

  def getYearXunExact
    # 获取年所在旬（以立春交接时刻作为新年的开始）
    # :return: 旬
    LunarUtil.getXun(getYearInGanZhiExact)
  end

  def getYearXunKong
    # 获取值年空亡（以正月初一作为新年的开始）
    # :return: 空亡(旬空)
    LunarUtil.getXunKong(getYearInGanZhi)
  end

  def getYearXunKongByLiChun
    # 获取值年空亡（以立春当天作为新年的开始）
    # :return: 空亡(旬空)
    LunarUtil.getXunKong(getYearInGanZhiByLiChun)
  end

  def getYearXunKongExact
    # 获取值年空亡（以立春交接时刻作为新年的开始）
    # :return: 空亡(旬空)
    LunarUtil.getXunKong(getYearInGanZhiExact)
  end

  def getMonthXun
    # 获取月所在旬（以节交接当天起算）
    # :return: 旬
    LunarUtil.getXun(getMonthInGanZhi)
  end

  def getMonthXunExact
    # 获取月所在旬（以节交接时刻起算）
    # :return: 旬
    LunarUtil.getXun(getMonthInGanZhiExact)
  end

  def getMonthXunKong
    # 获取值月空亡（以节交接当天起算）
    # :return: 空亡(旬空)
    LunarUtil.getXunKong(getMonthInGanZhi)
  end

  def getMonthXunKongExact
    # 获取值月空亡（以节交接时刻起算）
    # :return: 空亡(旬空)
    LunarUtil.getXunKong(getMonthInGanZhiExact)
  end

  def getDayXun
    # 获取日所在旬（以节交接当天起算）
    # :return: 旬
    LunarUtil.getXun(getDayInGanZhi)
  end

  def getDayXunExact
    # 获取日所在旬（晚子时日柱算明天）
    # :return: 旬
    LunarUtil.getXun(getDayInGanZhiExact)
  end

  def getDayXunExact2
    # 获取日所在旬（晚子时日柱算当天）
    # :return: 旬
    LunarUtil.getXun(getDayInGanZhiExact2)
  end

  def getDayXunKong
    # 获取值日空亡
    # :return: 空亡(旬空)
    LunarUtil.getXunKong(getDayInGanZhi)
  end

  def getDayXunKongExact
    # 获取值日空亡（晚子时日柱算明天）
    # :return: 空亡(旬空)
    LunarUtil.getXunKong(getDayInGanZhiExact)
  end

  def getDayXunKongExact2
    # 获取值日空亡（晚子时日柱算当天）
    # :return: 空亡(旬空)
    LunarUtil.getXunKong(getDayInGanZhiExact2)
  end

  def getTimeXun
    # 获取时辰所在旬
    # :return: 旬
    LunarUtil.getXun(getTimeInGanZhi)
  end

  def getTimeXunKong
    # 获取值时空亡
    # :return: 空亡(旬空)
    LunarUtil.getXunKong(getTimeInGanZhi)
  end

  def getShuJiu
    # 获取数九
    # :return: 数九，如果不是数九天，返回None
    current = Solar.fromYmd(@solar.getYear, @solar.getMonth, @solar.getDay)
    start = @jieQi["DONG_ZHI"]
    start = Solar.fromYmd(start.getYear, start.getMonth, start.getDay)
    if current.isBefore(start)
      start = @jieQi["冬至"]
      start = Solar.fromYmd(start.getYear, start.getMonth, start.getDay)
    end
    end_date = Solar.fromYmd(start.getYear, start.getMonth, start.getDay).next(81)
    if current.isBefore(start) || !current.isBefore(end_date)
      return nil
    end
    days = current.subtract(start)
    ShuJiu.new(LunarUtil::NUMBER[(days / 9).to_i + 1] + "九", days % 9 + 1)
  end

  def getFu
    # 获取三伏
    # :return: 三伏，如果不是伏天，返回None
    current = Solar.fromYmd(@solar.getYear, @solar.getMonth, @solar.getDay)
    xia_zhi = @jieQi["夏至"]
    li_qiu = @jieQi["立秋"]
    start = Solar.fromYmd(xia_zhi.getYear, xia_zhi.getMonth, xia_zhi.getDay)
    add = 6 - xia_zhi.getLunar.getDayGanIndex
    if add < 0
      add += 10
    end
    add += 20
    start = start.next(add)
    if current.isBefore(start)
      return nil
    end
    days = current.subtract(start)
    if days < 10
      return Fu.new("初伏", days + 1)
    end
    start = start.next(10)
    days = current.subtract(start)
    if days < 10
      return Fu.new("中伏", days + 1)
    end
    start = start.next(10)
    days = current.subtract(start)
    li_qiu_solar = Solar.fromYmd(li_qiu.getYear, li_qiu.getMonth, li_qiu.getDay)
    if li_qiu_solar.isAfter(start)
      if days < 10
        return Fu.new("中伏", days + 11)
      end
      start = start.next(10)
      days = current.subtract(start)
    end
    if days < 10
      return Fu.new("末伏", days + 1)
    end
    nil
  end

  def getLiuYao
    # 获取六曜
    # :return: 六曜
    LunarUtil::LIU_YAO[(@month.abs + @day - 2) % 6]
  end

  def getWuHou
    # 获取物候
    # :return: 物候
    jie_qi = getPrevJieQi(true)
    offset = 0
    (0...Lunar::JIE_QI.length).each do |i|
      if jie_qi.getName == Lunar::JIE_QI[i]
        offset = i
        break
      end
    end
    index = (@solar.subtract(jie_qi.getSolar) / 5).to_i
    if index > 2
      index = 2
    end
    LunarUtil::WU_HOU[(offset * 3 + index) % LunarUtil::WU_HOU.length]
  end

  def getHou
    jie_qi = getPrevJieQi(true)
    size = LunarUtil::HOU.length - 1
    offset = (@solar.subtract(jie_qi.getSolar) / 5).to_i
    if offset > size
      offset = size
    end
    "%s %s" % [jie_qi.getName, LunarUtil::HOU[offset]]
  end

  def getDayLu
    # 获取日禄
    # :return: 日禄
    gan = LunarUtil::LU[getDayGan]
    zhi = nil
    if LunarUtil::LU.key?(getDayZhi)
      zhi = LunarUtil::LU[getDayZhi]
    end
    lu = gan + "命互禄"
    if !zhi.nil?
      lu += " " + zhi + "命进禄"
    end
    lu
  end

  def getTime
    # 获取时辰
    # :return: 时辰
    LunarTime.fromYmdHms(@year, @month, @day, @hour, @minute, @second)
  end

  def getTimes
    # 获取当天的时辰列表
    # :return: 时辰列表
    times = [LunarTime.fromYmdHms(@year, @month, @day, 0, 0, 0)]
    (0...12).each do |i|
      times.push(LunarTime.fromYmdHms(@year, @month, @day, (i+1) * 2-1, 0, 0))
    end
    times
  end

  def getFoto
    # 获取佛历
    # :return: 佛历
    require_relative 'foto'
    Foto.fromLunar(self)
  end

  def getTao
    # 获取道历
    # :return: 道历
    require_relative 'tao'
    Tao.fromLunar(self)
  end
end
# -*- coding: utf-8 -*-
require 'thread'
require_relative 'solar'
require_relative 'nine_star'
require_relative 'util/shou_xing_util'
require_relative 'util/lunar_util'


class LunarYear
  # 农历年

  YUAN = ["下", "上", "中"]

  YUN = ["七", "八", "九", "一", "二", "三", "四", "五", "六"]

  @@LEAP_11 = [75, 94, 170, 265, 322, 398, 469, 553, 583, 610, 678, 735, 754, 773, 849, 887, 936, 1050, 1069, 1126, 1145, 1164, 1183, 1259, 1278, 1308, 1373, 1403, 1441, 1460, 1498, 1555, 1593, 1612, 1631, 1642, 2033, 2128, 2147, 2242, 2614, 2728, 2910, 3062, 3244, 3339, 3616, 3711, 3730, 3825, 4007, 4159, 4197, 4322, 4341, 4379, 4417, 4531, 4599, 4694, 4713, 4789, 4808, 4971, 5085, 5104, 5161, 5180, 5199, 5294, 5305, 5476, 5677, 5696, 5772, 5791, 5848, 5886, 6049, 6068, 6144, 6163, 6258, 6402, 6440, 6497, 6516, 6630, 6641, 6660, 6679, 6736, 6774, 6850, 6869, 6899, 6918, 6994, 7013, 7032, 7051, 7070, 7089, 7108, 7127, 7146, 7222, 7271, 7290, 7309, 7366, 7385, 7404, 7442, 7461, 7480, 7491, 7499, 7594, 7624, 7643, 7662, 7681, 7719, 7738, 7814, 7863, 7882, 7901, 7939, 7958, 7977, 7996,
               8034, 8053, 8072, 8091, 8121, 8159, 8186, 8216, 8235, 8254, 8273, 8311, 8330, 8341, 8349, 8368, 8444, 8463, 8474, 8493, 8531, 8569, 8588, 8626, 8664, 8683, 8694, 8702, 8713, 8721, 8751, 8789, 8808, 8816, 8827, 8846, 8884, 8903, 8922, 8941, 8971, 9036, 9066, 9085, 9104, 9123, 9142, 9161, 9180, 9199, 9218, 9256, 9294, 9313, 9324, 9343, 9362, 9381, 9419, 9438, 9476, 9514, 9533, 9544, 9552, 9563, 9571, 9582, 9601, 9639, 9658, 9666, 9677, 9696, 9734, 9753, 9772, 9791, 9802, 9821, 9886, 9897, 9916, 9935, 9954, 9973, 9992]

  @@LEAP_12 = [37, 56, 113, 132, 151, 189, 208, 227, 246, 284, 303, 341, 360, 379, 417, 436, 458, 477, 496, 515, 534, 572, 591, 629, 648, 667, 697, 716, 792, 811, 830, 868, 906, 925, 944, 963, 982, 1001, 1020, 1039, 1058, 1088, 1153, 1202, 1221, 1240, 1297, 1335, 1392, 1411, 1422, 1430, 1517, 1525, 1536, 1574, 3358, 3472, 3806, 3988, 4751, 4941, 5066, 5123, 5275, 5343, 5438, 5457, 5495, 5533, 5552, 5715, 5810, 5829, 5905, 5924, 6421, 6535, 6793, 6812, 6888, 6907, 7002, 7184, 7260, 7279, 7374, 7556, 7746, 7757, 7776, 7833, 7852, 7871, 7966, 8015, 8110, 8129, 8148, 8224, 8243, 8338, 8406, 8425, 8482, 8501, 8520, 8558, 8596, 8607, 8615, 8645, 8740, 8778, 8835, 8865, 8930, 8960, 8979, 8998, 9017, 9055, 9074, 9093, 9112, 9150, 9188, 9237, 9275, 9332, 9351, 9370, 9408, 9427, 9446, 9457, 9465,
               9495, 9560, 9590, 9628, 9647, 9685, 9715, 9742, 9780, 9810, 9818, 9829, 9848, 9867, 9905, 9924, 9943, 9962, 10000]

  @@CACHE_YEAR = nil

  @@lock = Mutex.new

  def initialize(lunar_year)
    @year = lunar_year
    offset = lunar_year - 4
    year_gan_index = offset % 10
    year_zhi_index = offset % 12
    if year_gan_index < 0
      year_gan_index += 10
    end
    if year_zhi_index < 0
      year_zhi_index += 12
    end
    @ganIndex = year_gan_index
    @zhiIndex = year_zhi_index
    @months = []
    @jieQiJulianDays = []
    compute
  end

  def self.fromYear(lunar_year)
    @@lock.synchronize do
      if @@CACHE_YEAR.nil? || @@CACHE_YEAR.getYear != lunar_year
        y = LunarYear.new(lunar_year)
        @@CACHE_YEAR = y
      else
        y = @@CACHE_YEAR
      end
      return y
    end
  end

  def compute
    require_relative 'lunar'
    require_relative 'solar'
    require_relative 'lunar_month'
    # 节气
    jq = []
    # 合朔，即每月初一
    hs = []
    # 每月天数，长度15
    day_counts = []
    # 月份
    months = []

    current_year = @year
    jd = ((current_year - 2000) * 365.2422 + 180).floor
    # 355是2000.12冬至，得到较靠近jd的冬至估计值
    w = ((jd - 355 + 183) / 365.2422).floor * 365.2422 + 355
    if ShouXingUtil.calcQi(w) > jd
      w -= 365.2422
    end
    # 25个节气时刻(北京时间)，从冬至开始到下一个冬至以后
    (0...26).each do |i|
      jq.push(ShouXingUtil.calcQi(w + 15.2184 * i))
    end

    # 从上年的大雪到下年的立春 精确的节气
    (0...Lunar::JIE_QI_IN_USE.length).each do |i|
      if i == 0
        jd = ShouXingUtil.qiAccurate2(jq[0] - 15.2184)
      elsif i <= 26
        jd = ShouXingUtil.qiAccurate2(jq[i - 1])
      else
        jd = ShouXingUtil.qiAccurate2(jq[25] + 15.2184 * (i - 26))
      end
      @jieQiJulianDays.push(jd + Solar::J2000)
    end

    # 冬至前的初一，今年"首朔"的日月黄经差w
    w = ShouXingUtil.calcShuo(jq[0])
    if w > jq[0]
      w -= 29.53
    end
    # 递推每月初一
    (0...16).each do |i|
      hs.push(ShouXingUtil.calcShuo(w + 29.5306 * i))
    end
    # 每月
    (0...15).each do |i|
      day_counts.push((hs[i + 1] - hs[i]).to_i)
      months.push(i)
    end

    prev_year = current_year - 1
    leap_index = 16

    if @@LEAP_11.include?(current_year)
      leap_index = 13
    elsif @@LEAP_12.include?(current_year)
      leap_index = 14
    elsif hs[13] <= jq[24]
      i = 1
      while hs[i + 1] > jq[2 * i] && i < 13
        i += 1
      end
      leap_index = i
    end
    (leap_index...15).each do |j|
      months[j] -= 1
    end
    ymc = [11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    fm = -1
    index = -1
    y = prev_year
    (0...15).each do |i|
      dm = hs[i] + Solar::J2000
      v2 = months[i]
      mc = ymc[v2 % 12]
      if 1724360 <= dm && dm < 1729794
        mc = ymc[(v2 + 1) % 12]
      elsif 1807724 <= dm && dm < 1808699
        mc = ymc[(v2 + 1) % 12]
      elsif dm == 1729794 || dm == 1808699
        mc = 12
      end
      if fm == -1
        fm = mc
        index = mc
      end
      if mc < fm
        y += 1
        index = 1
      end
      fm = mc
      if i == leap_index
        mc = -mc
      elsif dm == 1729794 || dm == 1808699
        mc = -11
      end
      @months.push(LunarMonth.new(y, mc, day_counts[i], dm, index))
      index += 1
    end
  end

  def getYear
    @year
  end

  def getGanIndex
    @ganIndex
  end

  def getZhiIndex
    @zhiIndex
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

  def toString
    @year.to_s + ""
  end

  def toFullString
    "%d年" % @year
  end

  def to_s
    toString
  end

  def getDayCount
    n = 0
    @months.each do |m|
      if m.getYear == @year
        n += m.getDayCount
      end
    end
    n
  end

  def getMonthsInYear
    months = []
    @months.each do |m|
      if m.getYear == @year
        months.push(m)
      end
    end
    months
  end

  def getMonths
    @months
  end

  def getJieQiJulianDays
    @jieQiJulianDays
  end

  def getLeapMonth
    # 获取闰月
    # :return: 闰月数字，1代表闰1月，0代表无闰月
    @months.each do |m|
      if m.getYear == @year && m.isLeap
        return m.getMonth.abs
      end
    end
    0
  end

  def getMonth(lunar_month)
    # 获取农历月
    # :param lunar_month: 闰月数字，1代表闰1月，0代表无闰月
    # :return: 农历月
    @months.each do |m|
      if m.getYear == @year && m.getMonth == lunar_month
        return m
      end
    end
    nil
  end

  def getZaoByGan_private(index, name)
    offset = index - Solar.fromJulianDay(getMonth(1).getFirstJulianDay).getLunar.getDayGanIndex
    if offset < 0
      offset += 10
    end
    name.sub("几", LunarUtil::NUMBER[offset + 1])
  end

  def getZaoByZhi_private(index, name)
    offset = index - Solar.fromJulianDay(getMonth(1).getFirstJulianDay).getLunar.getDayZhiIndex
    if offset < 0
      offset += 12
    end
    name.sub("几", LunarUtil::NUMBER[offset + 1])
  end

  def getTouLiang
    getZaoByZhi_private(0, "几鼠偷粮")
  end

  def getCaoZi
    getZaoByZhi_private(0, "草子几分")
  end

  def getGengTian
    # 获取耕田（正月第一个丑日是初几，就是几牛耕田）
    # :return: 耕田，如：六牛耕田
    getZaoByZhi_private(1, "几牛耕田")
  end

  def getHuaShou
    getZaoByZhi_private(3, "花收几分")
  end

  def getZhiShui
    # 获取治水（正月第一个辰日是初几，就是几龙治水）
    # :return: 治水，如：二龙治水
    getZaoByZhi_private(4, "几龙治水")
  end

  def getTuoGu
    getZaoByZhi_private(6, "几马驮谷")
  end

  def getQiangMi
    getZaoByZhi_private(9, "几鸡抢米")
  end

  def getKanCan
    getZaoByZhi_private(9, "几姑看蚕")
  end

  def getGongZhu
    getZaoByZhi_private(11, "几屠共猪")
  end

  def getJiaTian
    getZaoByGan_private(0, "甲田几分")
  end

  def getFenBing
    # 获取分饼（正月第一个丙日是初几，就是几人分饼）
    # :return: 分饼，如：六人分饼
    getZaoByGan_private(2, "几人分饼")
  end

  def getDeJin
    # 获取得金（正月第一个辛日是初几，就是几日得金）
    # :return: 得金，如：一日得金
    getZaoByGan_private(7, "几日得金")
  end

  def getRenBing
    getZaoByGan_private(2, getZaoByZhi_private(2, "几人几丙"))
  end

  def getRenChu
    getZaoByGan_private(3, getZaoByZhi_private(2, "几人几锄"))
  end

  def getYuan
    LunarYear::YUAN[((@year + 2696) / 60).to_i % 3] + "元"
  end

  def getYun
    LunarYear::YUN[((@year + 2696) / 20).to_i % 9] + "运"
  end

  def getNineStar
    index = LunarUtil.getJiaZiIndex(getGanZhi) + 1
    yuan = ((@year + 2696) / 60).to_i % 3
    offset = (62 + yuan * 3 - index) % 9
    if 0 == offset
      offset = 9
    end
    NineStar.fromIndex(offset - 1)
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

  def getPositionTaiSui
    LunarUtil::POSITION_TAI_SUI_YEAR[@zhiIndex]
  end

  def getPositionTaiSuiDesc
    LunarUtil::POSITION_DESC[getPositionTaiSui]
  end

  def next(n)
    # 获取往后推几年的阴历年，如果要往前推，则年数用负数
    # :param n: 年数
    # :return: 阴历年
    LunarYear.fromYear(@year + n)
  end
end

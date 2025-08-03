# -*- coding: utf-8 -*-
require_relative 'util/lunar_util'


class EightChar
  # 八字

  MONTH_ZHI = ["", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥", "子", "丑"]

  CHANG_SHENG = ["长生", "沐浴", "冠带", "临官", "帝旺", "衰", "病", "死", "墓", "绝", "胎", "养"]

  CHANG_SHENG_OFFSET_PRIVATE = {
    "甲" => 1,
    "丙" => 10,
    "戊" => 10,
    "庚" => 7,
    "壬" => 4,
    "乙" => 6,
    "丁" => 9,
    "己" => 9,
    "辛" => 0,
    "癸" => 3
  }

  def initialize(lunar)
    @sect = 2
    @lunar = lunar
  end

  def self.fromLunar(lunar)
    EightChar.new(lunar)
  end

  def toString
    getYear + " " + getMonth + " " + getDay + " " + getTime
  end

  def to_s
    toString
  end

  def getSect
    @sect
  end

  def setSect(sect)
    @sect = sect
  end

  def getYear
    # 获取年柱
    # :return: 年柱
    @lunar.getYearInGanZhiExact
  end

  def getYearGan
    # 获取年干
    # :return: 天干
    @lunar.getYearGanExact
  end

  def getYearZhi
    # 获取年支
    # :return: 地支
    @lunar.getYearZhiExact
  end

  def getYearHideGan
    # 获取年柱地支藏干，由于藏干分主气、余气、杂气，所以返回结果可能为1到3个元素
    # :return: 天干
    LunarUtil::ZHI_HIDE_GAN[getYearZhi]
  end

  def getYearWuXing
    # 获取年柱五行
    # :return: 五行
    LunarUtil::WU_XING_GAN[getYearGan] + LunarUtil::WU_XING_ZHI[getYearZhi]
  end

  def getYearNaYin
    # 获取年柱纳音
    # :return: 纳音
    LunarUtil::NAYIN[getYear]
  end

  def getYearShiShenGan
    # 获取年柱天干十神
    # :return: 十神
    LunarUtil::SHI_SHEN[getDayGan + getYearGan]
  end

  def getShiShenZhi_private(zhi)
    hide_gan = LunarUtil::ZHI_HIDE_GAN[zhi]
    arr = []
    hide_gan.each do |gan|
      arr.push(LunarUtil::SHI_SHEN[getDayGan + gan])
    end
    arr
  end

  def getYearShiShenZhi
    # 获取年柱地支十神，由于藏干分主气、余气、杂气，所以返回结果可能为1到3个元素
    # :return: 十神
    getShiShenZhi_private(getYearZhi)
  end

  def getDayGanIndex
    2 == @sect ? @lunar.getDayGanIndexExact2 : @lunar.getDayGanIndexExact
  end

  def getDayZhiIndex
    2 == @sect ? @lunar.getDayZhiIndexExact2 : @lunar.getDayZhiIndexExact
  end

  def getDiShi_private(zhi_index)
    index = CHANG_SHENG_OFFSET_PRIVATE[getDayGan] + (getDayGanIndex % 2 == 0 ? zhi_index : -zhi_index)
    if index >= 12
      index -= 12
    end
    if index < 0
      index += 12
    end
    EightChar::CHANG_SHENG[index]
  end

  def getYearDiShi
    # 获取年柱地势（长生十二神）
    # :return: 地势
    getDiShi_private(@lunar.getYearZhiIndexExact)
  end

  def getMonth
    # 获取月柱
    # :return: 月柱
    @lunar.getMonthInGanZhiExact
  end

  def getMonthGan
    # 获取月干
    # :return: 天干
    @lunar.getMonthGanExact
  end

  def getMonthZhi
    # 获取月支
    # :return: 地支
    @lunar.getMonthZhiExact
  end

  def getMonthHideGan
    # 获取月柱地支藏干，由于藏干分主气、余气、杂气，所以返回结果可能为1到3个元素
    # :return: 天干
    LunarUtil::ZHI_HIDE_GAN[getMonthZhi]
  end

  def getMonthWuXing
    # 获取月柱五行
    # :return: 五行
    LunarUtil::WU_XING_GAN[getMonthGan] + LunarUtil::WU_XING_ZHI[getMonthZhi]
  end

  def getMonthNaYin
    # 获取月柱纳音
    # :return: 纳音
    LunarUtil::NAYIN[getMonth]
  end

  def getMonthShiShenGan
    # 获取月柱天干十神
    # :return: 十神
    LunarUtil::SHI_SHEN[getDayGan + getMonthGan]
  end

  def getMonthShiShenZhi
    # 获取月柱地支十神，由于藏干分主气、余气、杂气，所以返回结果可能为1到3个元素
    # :return: 十神
    getShiShenZhi_private(getMonthZhi)
  end

  def getMonthDiShi
    # 获取月柱地势（长生十二神）
    # :return: 地势
    getDiShi_private(@lunar.getMonthZhiIndexExact)
  end

  def getDay
    # 获取日柱
    # :return: 日柱
    2 == @sect ? @lunar.getDayInGanZhiExact2 : @lunar.getDayInGanZhiExact
  end

  def getDayGan
    # 获取日干
    # :return: 天干
    2 == @sect ? @lunar.getDayGanExact2 : @lunar.getDayGanExact
  end

  def getDayZhi
    # 获取日支
    # :return: 地支
    2 == @sect ? @lunar.getDayZhiExact2 : @lunar.getDayZhiExact
  end

  def getDayHideGan
    # 获取日柱地支藏干，由于藏干分主气、余气、杂气，所以返回结果可能为1到3个元素
    # :return: 天干
    LunarUtil::ZHI_HIDE_GAN[getDayZhi]
  end

  def getDayWuXing
    # 获取日柱五行
    # :return: 五行
    LunarUtil::WU_XING_GAN[getDayGan] + LunarUtil::WU_XING_ZHI[getDayZhi]
  end

  def getDayNaYin
    # 获取日柱纳音
    # :return: 纳音
    LunarUtil::NAYIN[getDay]
  end

  def getDayShiShenGan
    # 获取日柱天干十神，也称日元、日干
    # :return: 十神
    "日主"
  end

  def getDayShiShenZhi
    # 获取日柱地支十神，由于藏干分主气、余气、杂气，所以返回结果可能为1到3个元素
    # :return: 十神
    getShiShenZhi_private(getDayZhi)
  end

  def getDayDiShi
    # 获取日柱地势（长生十二神）
    # :return: 地势
    getDiShi_private(getDayZhiIndex)
  end

  def getTime
    # 获取时柱
    # :return: 时柱
    @lunar.getTimeInGanZhi
  end

  def getTimeGan
    # 获取时干
    # :return: 天干
    @lunar.getTimeGan
  end

  def getTimeZhi
    # 获取时支
    # :return: 地支
    @lunar.getTimeZhi
  end

  def getTimeHideGan
    # 获取时柱地支藏干，由于藏干分主气、余气、杂气，所以返回结果可能为1到3个元素
    # :return: 天干
    LunarUtil::ZHI_HIDE_GAN[getTimeZhi]
  end

  def getTimeWuXing
    # 获取时柱五行
    # :return: 五行
    LunarUtil::WU_XING_GAN[getTimeGan] + LunarUtil::WU_XING_ZHI[getTimeZhi]
  end

  def getTimeNaYin
    # 获取时柱纳音
    # :return: 纳音
    LunarUtil::NAYIN[getTime]
  end

  def getTimeShiShenGan
    # 获取时柱天干十神
    # :return: 十神
    LunarUtil::SHI_SHEN[getDayGan + getTimeGan]
  end

  def getTimeShiShenZhi
    # 获取时柱地支十神，由于藏干分主气、余气、杂气，所以返回结果可能为1到3个元素
    # :return: 十神
    getShiShenZhi_private(getTimeZhi)
  end

  def getTimeDiShi
    # 获取时柱地势（长生十二神）
    # :return: 地势
    getDiShi_private(@lunar.getTimeZhiIndex)
  end

  def getTaiYuan
    # 获取胎元
    # :return: 胎元
    gan_index = @lunar.getMonthGanIndexExact + 1
    if gan_index >= 10
      gan_index -= 10
    end
    zhi_index = @lunar.getMonthZhiIndexExact + 3
    if zhi_index >= 12
      zhi_index -= 12
    end
    LunarUtil::GAN[gan_index + 1] + LunarUtil::ZHI[zhi_index + 1]
  end

  def getTaiYuanNaYin
    # 获取胎元纳音
    # :return: 纳音
    LunarUtil::NAYIN[getTaiYuan]
  end

  def getTaiXi
    # 获取胎息
    # :return: 胎息
    gan_index = 2 == @sect ? @lunar.getDayGanIndexExact2 : @lunar.getDayGanIndexExact
    zhi_index = 2 == @sect ? @lunar.getDayZhiIndexExact2 : @lunar.getDayZhiIndexExact
    LunarUtil::HE_GAN_5[gan_index] + LunarUtil::HE_ZHI_6[zhi_index]
  end

  def getTaiXiNaYin
    # 获取胎息纳音
    # :return: 纳音
    LunarUtil::NAYIN[getTaiXi]
  end

  def getMingGong
    # 获取命宫
    # :return: 命宫
    month_zhi_index = 0
    time_zhi_index = 0
    month_zhi = getMonthZhi
    time_zhi = getTimeZhi
    (0...EightChar::MONTH_ZHI.length).each do |i|
      zhi = EightChar::MONTH_ZHI[i]
      if month_zhi == zhi
        month_zhi_index = i
        break
      end
    end
    (0...EightChar::MONTH_ZHI.length).each do |i|
      zhi = EightChar::MONTH_ZHI[i]
      if time_zhi == zhi
        time_zhi_index = i
        break
      end
    end
    offset = month_zhi_index + time_zhi_index
    if offset >= 14
      offset = 26 - offset
    else
      offset = 14 - offset
    end
    gan_index = (@lunar.getYearGanIndexExact + 1) * 2 + offset
    while gan_index > 10
      gan_index -= 10
    end
    LunarUtil::GAN[gan_index] + EightChar::MONTH_ZHI[offset]
  end

  def getMingGongNaYin
    # 获取命宫纳音
    # :return: 纳音
    LunarUtil::NAYIN[getMingGong]
  end

  def getShenGong
    # 获取身宫
    # :return: 身宫
    month_zhi_index = 0
    time_zhi_index = 0
    month_zhi = getMonthZhi
    time_zhi = getTimeZhi
    (0...EightChar::MONTH_ZHI.length).each do |i|
      zhi = EightChar::MONTH_ZHI[i]
      if month_zhi == zhi
        month_zhi_index = i
        break
      end
    end
    (0...LunarUtil::ZHI.length).each do |i|
      zhi = LunarUtil::ZHI[i]
      if time_zhi == zhi
        time_zhi_index = i
        break
      end
    end
    offset = month_zhi_index + time_zhi_index
    if offset > 12
      offset -= 12
    end
    gan_index = (@lunar.getYearGanIndexExact + 1) * 2 + offset
    while gan_index > 10
      gan_index -= 10
    end
    LunarUtil::GAN[gan_index] + EightChar::MONTH_ZHI[offset]
  end

  def getShenGongNaYin
    # 获取身宫纳音
    # :return: 纳音
    LunarUtil::NAYIN[getShenGong]
  end

  def getLunar
    @lunar
  end

  def getYun(gender, sect = 1)
    # 获取运
    # :param gender: 性别：1男，0女
    # :param sect 流派：1按天数和时辰数计算，3天1年，1天4个月，1时辰10天；2按分钟数计算
    # :return: 运
    require_relative 'eightchar/yun'
    Yun.new(self, gender, sect)
  end

  def getYearXun
    # 获取年柱所在旬
    # :return: 旬
    @lunar.getYearXunExact
  end

  def getYearXunKong
    # 获取年柱旬空(空亡)
    # :return: 旬空(空亡)
    @lunar.getYearXunKongExact
  end

  def getMonthXun
    # 获取月柱所在旬
    # :return: 旬
    @lunar.getMonthXunExact
  end

  def getMonthXunKong
    # 获取月柱旬空(空亡)
    # :return: 旬空(空亡)
    @lunar.getMonthXunKongExact
  end

  def getDayXun
    # 获取日柱所在旬
    # :return: 旬
    2 == @sect ? @lunar.getDayXunExact2 : @lunar.getDayXunExact
  end

  def getDayXunKong
    # 获取日柱旬空(空亡)
    # :return: 旬空(空亡)
    2 == @sect ? @lunar.getDayXunKongExact2 : @lunar.getDayXunKongExact
  end

  def getTimeXun
    # 获取时柱所在旬
    # :return: 旬
    @lunar.getTimeXun
  end

  def getTimeXunKong
    # 获取时柱旬空(空亡)
    # :return: 旬空(空亡)
    @lunar.getTimeXunKong
  end
end
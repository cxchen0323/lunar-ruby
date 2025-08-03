# -*- coding: utf-8 -*-
require 'test_helper'


class LunarTest < Test::Unit::TestCase

  def test
    date = Lunar.fromYmdHms(2019, 3, 27, 0, 0, 0)
    assert_equal("二〇一九年三月廿七", date.toString)
    assert_equal("二〇一九年三月廿七 己亥(猪)年 戊辰(龙)月 戊戌(狗)日 子(鼠)时 纳音[平地木 大林木 平地木 桑柘木] 星期三 西方白虎 星宿[参水猿](吉) 彭祖百忌[戊不受田田主不祥 戌不吃犬作怪上床] 喜神方位[巽](东南) 阳贵神方位[艮](东北) 阴贵神方位[坤](西南) 福神方位[艮](东北) 财神方位[坎](正北) 冲[(壬辰)龙] 煞[北]", date.toFullString)
    assert_equal("2019-05-01", date.getSolar.toString)
    assert_equal("2019-05-01 00:00:00 星期三 (劳动节) 金牛座", date.getSolar.toFullString)
  end

  def test1
    solar = Solar.fromYmdHms(100, 1, 1, 12, 0, 0)
    assert_equal("九九年腊月初二", solar.getLunar.toString)
  end

  def test2
    solar = Solar.fromYmdHms(3218, 12, 31, 12, 0, 0)
    assert_equal("三二一八年冬月廿二", solar.getLunar.toString)
  end

  def test3
    lunar = Lunar.fromYmdHms(5, 1, 6, 12, 0, 0)
    assert_equal("0005-02-03", lunar.getSolar.toString)
  end

  def test4
    lunar = Lunar.fromYmdHms(9997, 12, 21, 12, 0, 0)
    assert_equal("9998-01-11", lunar.getSolar.toString)
  end

  def test5
    lunar = Lunar.fromYmdHms(1905, 1, 1, 12, 0, 0)
    assert_equal("1905-02-04", lunar.getSolar.toString)
  end

  def test6
    lunar = Lunar.fromYmdHms(2038, 12, 29, 12, 0, 0)
    assert_equal("2039-01-23", lunar.getSolar.toString)
  end

  def test7
    lunar = Lunar.fromYmdHms(2020, -4, 2, 13, 0, 0)
    assert_equal("二〇二〇年闰四月初二", lunar.toString)
    assert_equal("2020-05-24", lunar.getSolar.toString)
  end

  def test8
    lunar = Lunar.fromYmdHms(2020, 12, 10, 13, 0, 0)
    assert_equal("二〇二〇年腊月初十", lunar.toString)
    assert_equal("2021-01-22", lunar.getSolar.toString)
  end

  def test9
    lunar = Lunar.fromYmdHms(1500, 1, 1, 12, 0, 0)
    assert_equal("1500-01-31", lunar.getSolar.toString)
  end

  def test10
    lunar = Lunar.fromYmdHms(1500, 12, 29, 12, 0, 0)
    assert_equal("1501-01-18", lunar.getSolar.toString)
  end

  def test11
    solar = Solar.fromYmdHms(1500, 1, 1, 12, 0, 0)
    assert_equal("一四九九年腊月初一", solar.getLunar.toString)
  end

  def test12
    solar = Solar.fromYmdHms(1500, 12, 31, 12, 0, 0)
    assert_equal("一五〇〇年腊月十一", solar.getLunar.toString)
  end

  def test13
    solar = Solar.fromYmdHms(1582, 10, 4, 12, 0, 0)
    assert_equal("一五八二年九月十八", solar.getLunar.toString)
  end

  def test14
    solar = Solar.fromYmdHms(1582, 10, 15, 12, 0, 0)
    assert_equal("一五八二年九月十九", solar.getLunar.toString)
  end

  def test15
    lunar = Lunar.fromYmdHms(1582, 9, 18, 12, 0, 0)
    assert_equal("1582-10-04", lunar.getSolar.toString)
  end

  def test16
    lunar = Lunar.fromYmdHms(1582, 9, 19, 12, 0, 0)
    assert_equal("1582-10-15", lunar.getSolar.toString)
  end

  def test17
    lunar = Lunar.fromYmdHms(2019, 12, 12, 11, 22, 0)
    assert_equal("2020-01-06", lunar.getSolar.toString)
  end

  def test18
    lunar = Lunar.fromYmd(2021, 12, 29)
    assert_equal("除夕", lunar.getFestivals[0])
  end

  def test19
    lunar = Lunar.fromYmd(2020, 12, 30)
    assert_equal("除夕", lunar.getFestivals[0])
  end

  def test20
    lunar = Lunar.fromYmd(2020, 12, 29)
    assert_equal(0, lunar.getFestivals.length)
  end

  def test21
    solar = Solar.fromYmd(2022, 1, 31)
    lunar = solar.getLunar
    assert_equal("除夕", lunar.getFestivals[0])
  end

  def test22
    lunar = Lunar.fromYmd(2033, -11, 1)
    assert_equal('2033-12-22', lunar.getSolar.toYmd)
  end

  def test25
    solar = Solar.fromYmdHms(2021, 6, 7, 21, 18, 0)
    assert_equal('二〇二一年四月廿七', solar.getLunar.toString)
  end

  def test26
    lunar = Lunar.fromYmdHms(2021, 6, 7, 21, 18, 0)
    assert_equal('2021-07-16', lunar.getSolar.toString)
  end

  def testNext
    solar = Solar.fromYmdHms(2020, 1, 10, 12, 0, 0)
    lunar = solar.getLunar
    (-1..0).each do |i|
      assert_equal(solar.next(i).getLunar.toFullString, lunar.next(i).toFullString)
    end
  end

  def test27
    solar = Solar.fromYmd(1989, 4, 28)
    assert_equal(23, solar.getLunar.getDay)
  end

  def test28
    solar = Solar.fromYmd(1990, 10, 8)
    assert_equal("乙酉", solar.getLunar.getMonthInGanZhiExact)
  end

  def test29
    solar = Solar.fromYmd(1990, 10, 9)
    assert_equal("丙戌", solar.getLunar.getMonthInGanZhiExact)
  end

  def test30
    solar = Solar.fromYmd(1990, 10, 8)
    assert_equal("丙戌", solar.getLunar.getMonthInGanZhi)
  end

  def test31
    solar = Solar.fromYmdHms(1987, 4, 17, 9, 0, 0)
    assert_equal("一九八七年三月二十", solar.getLunar.toString)
  end

  def test32
    lunar = Lunar.fromYmd(2034, 1, 1)
    assert_equal("2034-02-19", lunar.getSolar.toYmd)
  end

  def test33
    lunar = Lunar.fromYmd(2033, 12, 1)
    assert_equal("2034-01-20", lunar.getSolar.toYmd)
  end

  def test34
    lunar = Lunar.fromYmd(37, -12, 1)
    assert_equal("闰腊", lunar.getMonthInChinese)
  end

  def test36
    solar = Solar.fromYmd(5553, 1, 22)
    assert_equal("五五五二年闰腊月初二", solar.getLunar.toString)
  end

  def test37
    solar = Solar.fromYmd(7013, 12, 24)
    assert_equal("七〇一三年闰冬月初四", solar.getLunar.toString)
  end

  def test38
    lunar = Lunar.fromYmd(7013, -11, 4)
    assert_equal("7013-12-24", lunar.getSolar.toString)
  end

  def test39
    solar = Solar.fromYmd(1987, 4, 12)
    lunar = solar.getLunar
    assert_equal("一九八七年三月十五", lunar.toString)
  end

  def test40
    solar = Solar.fromYmd(1987, 4, 13)
    lunar = solar.getLunar
    assert_equal("一九八七年三月十六", lunar.toString)
  end

  def test41
    solar = Solar.fromYmd(4, 2, 10)
    lunar = solar.getLunar
    assert_equal("鼠", lunar.getYearShengXiao)
  end

  def test42
    solar = Solar.fromYmd(4, 2, 9)
    lunar = solar.getLunar
    assert_equal("猪", lunar.getYearShengXiao)
  end

  def test43
    solar = Solar.fromYmd(2017, 2, 15)
    lunar = solar.getLunar
    assert_equal("子命互禄 辛命进禄", lunar.getDayLu)
  end

  def test44
    solar = Solar.fromYmd(2017, 2, 16)
    lunar = solar.getLunar
    assert_equal("寅命互禄", lunar.getDayLu)
  end

  def test48
    solar = Solar.fromYmd(2021, 11, 13)
    lunar = solar.getLunar
    assert_equal("碓磨厕 外东南", lunar.getDayPositionTai)
  end

  def test49
    solar = Solar.fromYmd(2021, 11, 12)
    lunar = solar.getLunar
    assert_equal("占门碓 外东南", lunar.getDayPositionTai)
  end

  def test50
    solar = Solar.fromYmd(2021, 11, 13)
    lunar = solar.getLunar
    assert_equal("西南", lunar.getDayPositionFuDesc)
  end

  def test51
    solar = Solar.fromYmd(2021, 11, 12)
    lunar = solar.getLunar
    assert_equal("正北", lunar.getDayPositionFuDesc)
  end

  def test52
    solar = Solar.fromYmd(2011, 11, 12)
    lunar = solar.getLunar
    assert_equal("厨灶厕 外西南", lunar.getDayPositionTai)
  end

  def test53
    solar = Solar.fromYmd(1722, 9, 25)
    lunar = solar.getLunar
    assert_equal("秋社", lunar.getOtherFestivals[0])
  end

  def test54
    solar = Solar.fromYmd(840, 9, 14)
    lunar = solar.getLunar
    assert_equal("秋社", lunar.getOtherFestivals[0])
  end

  def test55
    solar = Solar.fromYmd(2022, 3, 16)
    lunar = solar.getLunar
    assert_equal("春社", lunar.getOtherFestivals[0])
  end

  def test56
    solar = Solar.fromYmd(2021, 3, 21)
    lunar = solar.getLunar
    assert_equal("春社", lunar.getOtherFestivals[0])
  end

  def test57
    assert_equal("1582-10-04", Lunar.fromYmd(1582, 9, 18).getSolar.toYmd)
  end

  def test58
    assert_equal("1582-10-15", Lunar.fromYmd(1582, 9, 19).getSolar.toYmd)
  end

  def test59
    assert_equal("1518-02-10", Lunar.fromYmd(1518, 1, 1).getSolar.toYmd)
  end

  def test60
    assert_equal("0793-02-15", Lunar.fromYmd(793, 1, 1).getSolar.toYmd)
  end

  def test61
    assert_equal("2025-07-25", Lunar.fromYmd(2025, -6, 1).getSolar.toYmd)
  end

  def test62
    assert_equal("2025-06-25", Lunar.fromYmd(2025, 6, 1).getSolar.toYmd)
  end

  def test63
    assert_equal("0193-02-19", Lunar.fromYmd(193, 1, 1).getSolar.toYmd)
  end

  def test64
    assert_equal("0041-02-20", Lunar.fromYmd(41, 1, 1).getSolar.toYmd)
  end

  def test65
    assert_equal("0554-02-18", Lunar.fromYmd(554, 1, 1).getSolar.toYmd)
  end

  def test66
    assert_equal("1070-02-14", Lunar.fromYmd(1070, 1, 1).getSolar.toYmd)
  end

  def test67
    assert_equal("1537-02-10", Lunar.fromYmd(1537, 1, 1).getSolar.toYmd)
  end

  def test68
    assert_equal("九一七年闰十月十四", Solar.fromYmd(917, 12, 1).getLunar.toString)
  end

  def test69
    assert_equal("九一七年冬月十五", Solar.fromYmd(917, 12, 31).getLunar.toString)
  end

  def test70
    assert_equal("九一七年冬月十六", Solar.fromYmd(918, 1, 1).getLunar.toString)
  end
end
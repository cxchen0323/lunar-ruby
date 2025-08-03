# -*- coding: utf-8 -*-
require 'test_helper'
require 'lunar'


class EightCharTest < Test::Unit::TestCase

  def test_gan_zhi
    solar = Solar.fromYmdHms(2005, 12, 23, 8, 37, 0)
    lunar = solar.getLunar
    eight_char = lunar.getEightChar
    assert_equal("乙酉", eight_char.getYear)
    assert_equal("戊子", eight_char.getMonth)
    assert_equal("辛巳", eight_char.getDay)
    assert_equal("壬辰", eight_char.getTime)
  end

  def test_shen_gong
    lunar = Solar.fromYmdHms(1995, 12, 18, 10, 28, 0).getLunar
    assert_equal("壬午", lunar.getEightChar.getShenGong)
  end

  def test_shen_gong1
    lunar = Solar.fromYmdHms(1994, 12, 6, 2, 0, 0).getLunar
    assert_equal("丁丑", lunar.getEightChar.getShenGong)
  end

  def test_shen_gong2
    lunar = Solar.fromYmdHms(1990, 12, 11, 6, 0, 0).getLunar
    assert_equal("庚辰", lunar.getEightChar.getShenGong)
  end

  def test_shen_gong3
    lunar = Solar.fromYmdHms(1993, 5, 23, 4, 0, 0).getLunar
    assert_equal("庚申", lunar.getEightChar.getShenGong)
  end

  def test4
    lunar = Lunar.fromYmd(1985, 12, 27)
    assert_equal("1995-11-05", lunar.getEightChar.getYun(1).getStartSolar.toYmd)
  end

  def test5
    lunar = Lunar.fromYmd(1985, 1, 27)
    assert_equal("1989-03-28", lunar.getEightChar.getYun(1).getStartSolar.toYmd)
  end

  def test6
    lunar = Lunar.fromYmd(1986, 12, 27)
    assert_equal("1990-04-15", lunar.getEightChar.getYun(1).getStartSolar.toYmd)
  end

  def test7
    solar = Solar.fromYmdHms(2022, 8, 28, 1, 50, 0)
    lunar = solar.getLunar
    eight_char = lunar.getEightChar
    assert_equal("壬寅", eight_char.getYear)
    assert_equal("戊申", eight_char.getMonth)
    assert_equal("癸丑", eight_char.getDay)
    assert_equal("癸丑", eight_char.getTime)
  end

  def test8
    lunar = Lunar.fromYmdHms(2022, 8, 2, 1, 50, 0)
    eight_char = lunar.getEightChar
    assert_equal("壬寅", eight_char.getYear)
    assert_equal("戊申", eight_char.getMonth)
    assert_equal("癸丑", eight_char.getDay)
    assert_equal("癸丑", eight_char.getTime)
  end

  def test9
    lunar = Lunar.fromDate(DateTime.strptime('2022-08-28 01:50:00', '%Y-%m-%d %H:%M:%S'))
    eight_char = lunar.getEightChar
    assert_equal("壬寅", eight_char.getYear)
    assert_equal("戊申", eight_char.getMonth)
    assert_equal("癸丑", eight_char.getDay)
    assert_equal("癸丑", eight_char.getTime)
  end

  def test10
    lunar = Solar.fromYmdHms(1988, 2, 15, 23, 30, 0).getLunar
    eight_char = lunar.getEightChar
    assert_equal("戊辰", eight_char.getYear)
    assert_equal("甲寅", eight_char.getMonth)
    assert_equal("庚子", eight_char.getDay)
    assert_equal("戊子", eight_char.getTime)
  end

  def test11
    lunar = Lunar.fromYmdHms(1987, 12, 28, 23, 30, 0)
    eight_char = lunar.getEightChar
    assert_equal("戊辰", eight_char.getYear)
    assert_equal("甲寅", eight_char.getMonth)
    assert_equal("庚子", eight_char.getDay)
    assert_equal("戊子", eight_char.getTime)
  end

  def test12
    solar_list = Solar.fromBaZi("己卯", "辛未", "甲戌", "癸酉")
    assert(solar_list.length > 1)
  end

  def test13
    lunar = Lunar.fromYmdHms(1991, 4, 5, 3, 37, 0)
    eight_char = lunar.getEightChar
    assert_equal("辛未", eight_char.getYear)
    assert_equal("癸巳", eight_char.getMonth)
    assert_equal("戊子", eight_char.getDay)
    assert_equal("甲寅", eight_char.getTime)
  end

  def test14
    solar_list = Solar.fromBaZi("己卯", "辛未", "甲戌", "壬申")
    actual = []
    solar_list.each do |solar|
      actual.push(solar.toYmdHms)
    end
    expected = ["1939-08-05 16:00:00", "1999-07-21 16:00:00"]
    assert_equal(expected, actual)
  end

  def test15
    solar_list = Solar.fromBaZi("庚子", "戊子", "己卯", "庚午")
    actual = []
    solar_list.each do |solar|
      actual.push(solar.toYmdHms)
    end
    expected = ["1901-01-01 12:00:00", "1960-12-17 12:00:00"]
    assert_equal(expected, actual)
  end

  def test16
    solar_list = Solar.fromBaZi("癸卯", "甲寅", "癸丑", "甲子", 2, 1843)
    actual = []
    solar_list.each do |solar|
      actual.push(solar.toYmdHms)
    end
    expected = ["1843-02-08 23:00:00", "2023-02-24 23:00:00"]
    assert_equal(expected, actual)
  end

  def test17
    solar_list = Solar.fromBaZi("己亥", "丁丑", "壬寅", "戊申")
    actual = []
    solar_list.each do |solar|
      actual.push(solar.toYmdHms)
    end
    expected = ["1900-01-29 16:00:00", "1960-01-15 16:00:00"]
    assert_equal(expected, actual)
  end

  def test18
    solar_list = Solar.fromBaZi("己亥", "丙子", "癸酉", "庚申")
    actual = []
    solar_list.each do |solar|
      actual.push(solar.toYmdHms)
    end
    expected = ["1959-12-17 16:00:00"]
    assert_equal(expected, actual)
  end

  def test19
    solar_list = Solar.fromBaZi("丁卯", "丁未", "甲申", "乙丑", 1, 1900)
    actual = []
    solar_list.each do |solar|
      actual.push(solar.toYmdHms)
    end
    expected = ["1987-08-03 02:00:00"]
    assert_equal(expected, actual)
  end
end
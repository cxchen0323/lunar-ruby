# -*- coding: utf-8 -*-
require 'test_helper'


class YunTest < Test::Unit::TestCase
  def test
    solar = Solar.fromYmdHms(1981, 1, 29, 23, 37, 0)
    lunar = solar.getLunar
    eight_char = lunar.getEightChar
    yun = eight_char.getYun(0)
    assert_equal(8, yun.getStartYear, "起运年数")
    assert_equal(0, yun.getStartMonth, "起运月数")
    assert_equal(20, yun.getStartDay, "起运天数")
    assert_equal("1989-02-18", yun.getStartSolar.toYmd, "起运阳历")
  end

  def test2
    lunar = Lunar.fromYmdHms(2019, 12, 12, 11, 22, 0)
    eight_char = lunar.getEightChar
    yun = eight_char.getYun(1)
    assert_equal(0, yun.getStartYear, "起运年数")
    assert_equal(1, yun.getStartMonth, "起运月数")
    assert_equal(0, yun.getStartDay, "起运天数")
    assert_equal("2020-02-06", yun.getStartSolar.toYmd, "起运阳历")
  end

  def test3
    solar = Solar.fromYmdHms(2020, 1, 6, 11, 22, 0)
    lunar = solar.getLunar
    eight_char = lunar.getEightChar
    yun = eight_char.getYun(1)
    assert_equal(0, yun.getStartYear, "起运年数")
    assert_equal(1, yun.getStartMonth, "起运月数")
    assert_equal(0, yun.getStartDay, "起运天数")
    assert_equal("2020-02-06", yun.getStartSolar.toYmd, "起运阳历")
  end

  def test4
    solar = Solar.fromYmdHms(2022, 3, 9, 20, 51, 0)
    lunar = solar.getLunar
    eight_char = lunar.getEightChar
    yun = eight_char.getYun(1)
    assert_equal("2030-12-19", yun.getStartSolar.toYmd, "起运阳历")
  end

  def test5
    solar = Solar.fromYmdHms(2022, 3, 9, 20, 51, 0)
    lunar = solar.getLunar
    eight_char = lunar.getEightChar
    yun = eight_char.getYun(1, 2)
    assert_equal(8, yun.getStartYear, "起运年数")
    assert_equal(9, yun.getStartMonth, "起运月数")
    assert_equal(2, yun.getStartDay, "起运天数")
    assert_equal(0, yun.getStartHour, "起运小时数")
    assert_equal("2030-12-12", yun.getStartSolar.toYmd, "起运阳历")
  end
end
# -*- coding: utf-8 -*-
require 'test_helper'


class LunarMonthTest < Test::Unit::TestCase

  def test
    month = LunarMonth.fromYm(2023, 1)
    assert_equal(1, month.getIndex)
    assert_equal("甲寅", month.getGanZhi)
  end

  def test1
    month = LunarMonth.fromYm(2023, -2)
    assert_equal(3, month.getIndex)
    assert_equal("丙辰", month.getGanZhi)
  end

  def test2
    month = LunarMonth.fromYm(2023, 3)
    assert_equal(4, month.getIndex)
    assert_equal("丁巳", month.getGanZhi)
  end

  def test3
    month = LunarMonth.fromYm(2024, 1)
    assert_equal(1, month.getIndex)
    assert_equal("丙寅", month.getGanZhi)
  end

  def test4
    month = LunarMonth.fromYm(2023, 12)
    assert_equal(13, month.getIndex)
    assert_equal("丙寅", month.getGanZhi)
  end

  def test5
    month = LunarMonth.fromYm(2022, 1)
    assert_equal(1, month.getIndex)
    assert_equal("壬寅", month.getGanZhi)
  end
end
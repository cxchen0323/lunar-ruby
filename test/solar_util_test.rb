# -*- coding: utf-8 -*-
require 'test_helper'
require_relative '../lib/lunar/util/solar_util'

class SolarUtilTest < Minitest::Test
  def test_is_leap_year
    assert_equal true, Lunar::Util::SolarUtil.isLeapYear(1500)
  end

  def test_get_days_between
    assert_equal 2, Lunar::Util::SolarUtil.getDaysBetween(100, 2, 28, 100, 3, 1)
  end

  def test_get_days_in_year
    assert_equal 59, Lunar::Util::SolarUtil.getDaysInYear(100, 2, 28)
    assert_equal 61, Lunar::Util::SolarUtil.getDaysInYear(100, 3, 1)
  end

  def test_get_weeks_of_month
    # These tests require Solar class to be implemented first
    # Will be uncommented when Solar is available
    # start = 1
    # assert_equal 5, Lunar::Util::SolarUtil.getWeeksOfMonth(2019, 5, start)
    # 
    # start = 0
    # assert_equal 5, Lunar::Util::SolarUtil.getWeeksOfMonth(2019, 5, start)
  end
end
require_relative 'test_helper'
require 'lunar/util/solar_util'

class SolarUtilTest < Minitest::Test
  def test_is_leap_year
    assert Lunar::SolarUtil.is_leap_year?(2020)
    assert Lunar::SolarUtil.is_leap_year?(2000)
    refute Lunar::SolarUtil.is_leap_year?(2019)
    refute Lunar::SolarUtil.is_leap_year?(1900)
    assert Lunar::SolarUtil.is_leap_year?(1600)
    assert Lunar::SolarUtil.is_leap_year?(1580)
  end

  def test_get_days_of_year
    assert_equal 366, Lunar::SolarUtil.get_days_of_year(2020)
    assert_equal 365, Lunar::SolarUtil.get_days_of_year(2019)
    assert_equal 355, Lunar::SolarUtil.get_days_of_year(1582)
  end

  def test_get_days_of_month
    assert_equal 29, Lunar::SolarUtil.get_days_of_month(2020, 2)
    assert_equal 28, Lunar::SolarUtil.get_days_of_month(2019, 2)
    assert_equal 31, Lunar::SolarUtil.get_days_of_month(2020, 1)
    assert_equal 30, Lunar::SolarUtil.get_days_of_month(2020, 4)
    assert_equal 21, Lunar::SolarUtil.get_days_of_month(1582, 10)
  end

  def test_get_days_in_year
    assert_equal 1, Lunar::SolarUtil.get_days_in_year(2020, 1, 1)
    assert_equal 32, Lunar::SolarUtil.get_days_in_year(2020, 2, 1)
    assert_equal 60, Lunar::SolarUtil.get_days_in_year(2020, 2, 29)
    assert_equal 277, Lunar::SolarUtil.get_days_in_year(1582, 10, 4)
    assert_equal 278, Lunar::SolarUtil.get_days_in_year(1582, 10, 15)
  end

  def test_get_days_between
    assert_equal 1, Lunar::SolarUtil.get_days_between(2020, 1, 1, 2020, 1, 2)
    assert_equal(-1, Lunar::SolarUtil.get_days_between(2020, 1, 2, 2020, 1, 1))
    assert_equal 365, Lunar::SolarUtil.get_days_between(2019, 1, 1, 2020, 1, 1)
    assert_equal 366, Lunar::SolarUtil.get_days_between(2020, 1, 1, 2021, 1, 1)
  end
end
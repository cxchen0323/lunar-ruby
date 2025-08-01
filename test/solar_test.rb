require_relative 'test_helper'
require 'lunar/solar'

class SolarTest < Minitest::Test
  def test_basic_creation
    solar = Lunar::Solar.from_ymd(2019, 5, 1)
    assert_equal '2019-05-01', solar.to_string
    assert_equal 2019, solar.get_year
    assert_equal 5, solar.get_month
    assert_equal 1, solar.get_day
  end

  def test_from_ymd_hms
    solar = Lunar::Solar.from_ymd_hms(2020, 5, 24, 13, 0, 0)
    assert_equal '2020-05-24 13:00:00', solar.to_ymd_hms
  end

  def test_leap_year
    assert Lunar::Solar.from_ymd(2020, 1, 1).is_leap_year?
    refute Lunar::Solar.from_ymd(2019, 1, 1).is_leap_year?
  end

  def test_week
    solar = Lunar::Solar.from_ymd(2019, 5, 1)
    assert_equal 3, solar.get_week # Wednesday
    assert_equal '三', solar.get_week_in_chinese
  end

  def test_festivals
    solar = Lunar::Solar.from_ymd(2020, 5, 1)
    festivals = solar.get_festivals
    assert_includes festivals, '劳动节'
  end

  def test_xing_zuo
    solar = Lunar::Solar.from_ymd(2019, 5, 1)
    assert_equal '金牛', solar.get_xing_zuo
  end

  def test_next_day
    date = Lunar::Solar.from_ymd(2020, 1, 23)
    assert_equal '2020-01-24', date.next(1).to_string
    assert_equal '2020-01-22', date.next(-1).to_string
  end

  def test_julian_day
    solar = Lunar::Solar.from_ymd(2000, 1, 1)
    jd = solar.get_julian_day
    assert_in_delta 2451544.5, jd, 0.0001
  end

  def test_from_julian_day
    jd = 2451544.5
    solar = Lunar::Solar.from_julian_day(jd)
    assert_equal '2000-01-01', solar.to_ymd
  end

  def test_subtract
    solar1 = Lunar::Solar.from_ymd(2020, 1, 2)
    solar2 = Lunar::Solar.from_ymd(2020, 1, 1)
    assert_equal 1, solar1.subtract(solar2)
    assert_equal(-1, solar2.subtract(solar1))
  end

  def test_is_after_before
    solar1 = Lunar::Solar.from_ymd(2020, 1, 2)
    solar2 = Lunar::Solar.from_ymd(2020, 1, 1)
    assert solar1.is_after?(solar2)
    refute solar1.is_before?(solar2)
    assert solar2.is_before?(solar1)
    refute solar2.is_after?(solar1)
  end

  def test_next_year
    solar = Lunar::Solar.from_ymd(2020, 2, 29)
    next_year = solar.next_year(1)
    assert_equal '2021-02-28', next_year.to_ymd # Not a leap year
  end

  def test_next_hour
    solar = Lunar::Solar.from_ymd_hms(2020, 1, 1, 23, 0, 0)
    next_hour = solar.next_hour(2)
    assert_equal '2020-01-02 01:00:00', next_hour.to_ymd_hms
  end

  def test_invalid_date
    assert_raises(ArgumentError) do
      Lunar::Solar.from_ymd(1582, 10, 5) # Invalid date in Gregorian calendar
    end
  end
end
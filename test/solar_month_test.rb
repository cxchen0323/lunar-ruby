require_relative 'test_helper'
require 'lunar/solar_month'

class SolarMonthTest < Minitest::Test
  def test_basic_creation
    month = Lunar::SolarMonth.from_ym(2022, 12)
    assert_equal 2022, month.get_year
    assert_equal 12, month.get_month
    assert_equal '2022-12', month.to_string
    assert_equal '2022年12月', month.to_full_string
  end

  def test_get_days
    month = Lunar::SolarMonth.from_ym(2020, 2)
    days = month.get_days
    assert_equal 29, days.length # Leap year February
    assert_equal '2020-02-01', days[0].to_string
    assert_equal '2020-02-29', days[28].to_string
  end

  def test_get_weeks
    month = Lunar::SolarMonth.from_ym(2022, 12)
    weeks = month.get_weeks(0) # Start from Sunday
    assert_equal 5, weeks.length
  end

  def test_next_month
    month = Lunar::SolarMonth.from_ym(2020, 11)
    
    # Next month
    next_month = month.next(1)
    assert_equal 2020, next_month.get_year
    assert_equal 12, next_month.get_month
    
    # Next year
    next_month = month.next(2)
    assert_equal 2021, next_month.get_year
    assert_equal 1, next_month.get_month
    
    # Previous month
    prev_month = month.next(-1)
    assert_equal 2020, prev_month.get_year
    assert_equal 10, prev_month.get_month
    
    # Previous year
    prev_month = month.next(-11)
    assert_equal 2019, prev_month.get_year
    assert_equal 12, prev_month.get_month
  end

  def test_next_multiple_years
    month = Lunar::SolarMonth.from_ym(2020, 6)
    next_month = month.next(18)
    assert_equal 2021, next_month.get_year
    assert_equal 12, next_month.get_month
  end
end
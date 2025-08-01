require_relative 'test_helper'
require 'lunar/solar_week'

class SolarWeekTest < Minitest::Test
  def test_week_start_monday
    # 一周的开始从星期一开始计
    start = 1
    week = Lunar::SolarWeek.from_ymd(2019, 5, 1, start)
    assert_equal '2019.5.1', week.to_string
    assert_equal '2019年5月第1周', week.to_full_string
    # 当月共几周
    assert_equal 5, Lunar::SolarUtil.get_weeks_of_month(week.get_year, week.get_month, start)
    # 当周第一天
    assert_equal '2019-04-29', week.get_first_day.to_string
    # 当周第一天（本月）
    assert_equal '2019-05-01', week.get_first_day_in_month.to_string
  end

  def test_week_start_sunday
    # 一周的开始从星期日开始计
    start = 0
    week = Lunar::SolarWeek.from_ymd(2019, 5, 1, start)
    assert_equal '2019.5.1', week.to_string
    assert_equal '2019年5月第1周', week.to_full_string
    # 当月共几周
    assert_equal 5, Lunar::SolarUtil.get_weeks_of_month(week.get_year, week.get_month, start)
    # 当周第一天
    assert_equal '2019-04-28', week.get_first_day.to_string
    # 当周第一天（本月）
    assert_equal '2019-05-01', week.get_first_day_in_month.to_string
  end

  def test_index_sunday_start
    week = Lunar::SolarWeek.from_ymd(2022, 5, 1, 0)
    assert_equal 1, week.get_index

    week = Lunar::SolarWeek.from_ymd(2022, 5, 7, 0)
    assert_equal 1, week.get_index

    week = Lunar::SolarWeek.from_ymd(2022, 5, 8, 0)
    assert_equal 2, week.get_index
  end

  def test_index_monday_start
    week = Lunar::SolarWeek.from_ymd(2022, 5, 1, 1)
    assert_equal 1, week.get_index

    week = Lunar::SolarWeek.from_ymd(2022, 5, 2, 1)
    assert_equal 2, week.get_index

    week = Lunar::SolarWeek.from_ymd(2022, 5, 8, 1)
    assert_equal 2, week.get_index
  end

  def test_index_tuesday_start
    week = Lunar::SolarWeek.from_ymd(2021, 5, 2, 2)
    assert_equal 1, week.get_index

    week = Lunar::SolarWeek.from_ymd(2021, 5, 4, 2)
    assert_equal 2, week.get_index
  end

  def test_index_in_year
    week = Lunar::SolarWeek.from_ymd(2022, 3, 6, 0)
    assert_equal 11, week.get_index_in_year
  end

  def test_days
    week = Lunar::SolarWeek.from_ymd(2019, 5, 1, 1)
    days = week.get_days
    assert_equal 7, days.length
    assert_equal '2019-04-29', days[0].to_string
    assert_equal '2019-05-05', days[6].to_string
  end

  def test_days_in_month
    week = Lunar::SolarWeek.from_ymd(2019, 5, 1, 1)
    days = week.get_days_in_month
    assert_equal 5, days.length
    assert_equal '2019-05-01', days[0].to_string
    assert_equal '2019-05-05', days[4].to_string
  end

  def test_next
    week = Lunar::SolarWeek.from_ymd(2019, 5, 1, 1)
    next_week = week.next(1, false)
    assert_equal '2019.5.2', next_week.to_string
    
    prev_week = week.next(-1, false)
    assert_equal '2019.4.4', prev_week.to_string
  end
end
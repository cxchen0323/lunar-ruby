require_relative 'test_helper'
require 'lunar/solar_half_year'

class SolarHalfYearTest < Minitest::Test
  def test_basic_creation
    half_year = Lunar::SolarHalfYear.from_ym(2019, 5)
    assert_equal '2019.1', half_year.to_string
    assert_equal '2019年上半年', half_year.to_full_string
  end

  def test_next_half_year
    half_year = Lunar::SolarHalfYear.from_ym(2019, 5)
    assert_equal '2019.2', half_year.next(1).to_string
    assert_equal '2019年下半年', half_year.next(1).to_full_string
  end

  def test_get_months
    half_year = Lunar::SolarHalfYear.from_ym(2019, 5)
    months = half_year.get_months
    assert_equal 6, months.length
    assert_equal '2019-1', months[0].to_string
    assert_equal '2019-2', months[1].to_string
    assert_equal '2019-3', months[2].to_string
    assert_equal '2019-4', months[3].to_string
    assert_equal '2019-5', months[4].to_string
    assert_equal '2019-6', months[5].to_string
  end

  def test_index_calculation
    # First half
    assert_equal 1, Lunar::SolarHalfYear.from_ym(2019, 1).get_index
    assert_equal 1, Lunar::SolarHalfYear.from_ym(2019, 2).get_index
    assert_equal 1, Lunar::SolarHalfYear.from_ym(2019, 3).get_index
    assert_equal 1, Lunar::SolarHalfYear.from_ym(2019, 4).get_index
    assert_equal 1, Lunar::SolarHalfYear.from_ym(2019, 5).get_index
    assert_equal 1, Lunar::SolarHalfYear.from_ym(2019, 6).get_index
    
    # Second half
    assert_equal 2, Lunar::SolarHalfYear.from_ym(2019, 7).get_index
    assert_equal 2, Lunar::SolarHalfYear.from_ym(2019, 8).get_index
    assert_equal 2, Lunar::SolarHalfYear.from_ym(2019, 9).get_index
    assert_equal 2, Lunar::SolarHalfYear.from_ym(2019, 10).get_index
    assert_equal 2, Lunar::SolarHalfYear.from_ym(2019, 11).get_index
    assert_equal 2, Lunar::SolarHalfYear.from_ym(2019, 12).get_index
  end

  def test_second_half_months
    half_year = Lunar::SolarHalfYear.from_ym(2019, 10)
    months = half_year.get_months
    assert_equal 6, months.length
    assert_equal '2019-7', months[0].to_string
    assert_equal '2019-8', months[1].to_string
    assert_equal '2019-9', months[2].to_string
    assert_equal '2019-10', months[3].to_string
    assert_equal '2019-11', months[4].to_string
    assert_equal '2019-12', months[5].to_string
  end
end
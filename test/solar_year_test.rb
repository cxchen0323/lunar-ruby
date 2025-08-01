require_relative 'test_helper'
require 'lunar/solar_year'

class SolarYearTest < Minitest::Test
  def test_basic_creation
    year = Lunar::SolarYear.from_year(2019)
    assert_equal '2019', year.to_string
    assert_equal '2019年', year.to_full_string
    assert_equal 2019, year.get_year
  end

  def test_next_year
    year = Lunar::SolarYear.from_year(2019)
    assert_equal '2020', year.next(1).to_string
    assert_equal '2020年', year.next(1).to_full_string
    
    assert_equal '2018', year.next(-1).to_string
    assert_equal '2021', year.next(2).to_string
  end

  def test_get_months
    year = Lunar::SolarYear.from_year(2020)
    months = year.get_months
    assert_equal 12, months.length
    assert_equal '2020-1', months[0].to_string
    assert_equal '2020-12', months[11].to_string
  end
end
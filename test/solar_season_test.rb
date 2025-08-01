require_relative 'test_helper'
require 'lunar/solar_season'

class SolarSeasonTest < Minitest::Test
  def test_basic_creation
    season = Lunar::SolarSeason.from_ym(2019, 5)
    assert_equal '2019.2', season.to_string
    assert_equal '2019年2季度', season.to_full_string
  end

  def test_next_season
    season = Lunar::SolarSeason.from_ym(2019, 5)
    assert_equal '2019.3', season.next(1).to_string
    assert_equal '2019年3季度', season.next(1).to_full_string
  end

  def test_get_months
    season = Lunar::SolarSeason.from_ym(2019, 5)
    months = season.get_months
    assert_equal 3, months.length
    assert_equal '2019-4', months[0].to_string
    assert_equal '2019-5', months[1].to_string
    assert_equal '2019-6', months[2].to_string
  end

  def test_index_calculation
    # Q1
    assert_equal 1, Lunar::SolarSeason.from_ym(2019, 1).get_index
    assert_equal 1, Lunar::SolarSeason.from_ym(2019, 2).get_index
    assert_equal 1, Lunar::SolarSeason.from_ym(2019, 3).get_index
    
    # Q2
    assert_equal 2, Lunar::SolarSeason.from_ym(2019, 4).get_index
    assert_equal 2, Lunar::SolarSeason.from_ym(2019, 5).get_index
    assert_equal 2, Lunar::SolarSeason.from_ym(2019, 6).get_index
    
    # Q3
    assert_equal 3, Lunar::SolarSeason.from_ym(2019, 7).get_index
    assert_equal 3, Lunar::SolarSeason.from_ym(2019, 8).get_index
    assert_equal 3, Lunar::SolarSeason.from_ym(2019, 9).get_index
    
    # Q4
    assert_equal 4, Lunar::SolarSeason.from_ym(2019, 10).get_index
    assert_equal 4, Lunar::SolarSeason.from_ym(2019, 11).get_index
    assert_equal 4, Lunar::SolarSeason.from_ym(2019, 12).get_index
  end
end
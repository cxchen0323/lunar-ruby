require_relative 'test_helper'
require 'lunar/nine_star'

class NineStarTest < Minitest::Test
  def test_basic_properties
    star = Lunar::NineStar.from_index(0)
    assert_equal '一', star.get_number
    assert_equal '白', star.get_color
    assert_equal '水', star.get_wu_xing
    assert_equal '坎', star.get_position
    assert_equal '正北', star.get_position_desc
    assert_equal '天枢', star.get_name_in_bei_dou
    assert_equal '贪狼', star.get_name_in_xuan_kong
    assert_equal '天蓬', star.get_name_in_qi_men
  end

  def test_to_string
    star = Lunar::NineStar.from_index(0)
    assert_equal '一白水天枢', star.to_string
  end

  def test_all_stars
    (0..8).each do |i|
      star = Lunar::NineStar.from_index(i)
      assert_equal Lunar::NineStar::NUMBER[i], star.get_number
      assert_equal Lunar::NineStar::COLOR[i], star.get_color
      assert_equal Lunar::NineStar::WU_XING[i], star.get_wu_xing
    end
  end
end
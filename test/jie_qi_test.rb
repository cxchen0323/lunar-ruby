require_relative 'test_helper'
require 'lunar/jie_qi'

class JieQiTest < Minitest::Test
  def test_jie_and_qi
    # 冬至 is at index 0, which is even, so it should be qi
    jie_qi = Lunar::JieQi.new('冬至', nil)
    assert jie_qi.is_qi?
    refute jie_qi.is_jie?
    assert_equal '冬至', jie_qi.get_name
    
    # 小寒 is at index 1, which is odd, so it should be jie
    jie_qi = Lunar::JieQi.new('小寒', nil)
    refute jie_qi.is_qi?
    assert jie_qi.is_jie?
    assert_equal '小寒', jie_qi.get_name
  end

  def test_to_string
    jie_qi = Lunar::JieQi.new('立春', nil)
    assert_equal '立春', jie_qi.to_string
  end
end
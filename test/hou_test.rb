# -*- coding: utf-8 -*-
require 'test_helper'


class HouTest < Test::Unit::TestCase

  def test1
    solar = Solar.fromYmd(2021, 12, 21)
    assert_equal("冬至 初候", solar.getLunar.getHou)
  end

  def test2
    solar = Solar.fromYmd(2021, 12, 26)
    assert_equal("冬至 二候", solar.getLunar.getHou)
  end

  def test3
    solar = Solar.fromYmd(2021, 12, 31)
    assert_equal("冬至 三候", solar.getLunar.getHou)
  end

  def test4
    solar = Solar.fromYmd(2022, 1, 5)
    assert_equal("小寒 初候", solar.getLunar.getHou)
  end
end
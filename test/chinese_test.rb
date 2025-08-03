# -*- coding: utf-8 -*-
require 'test_helper'


class ChineseTest < Test::Unit::TestCase
  def test
    gz = "甲午"
    g = gz[0, 1]
    z = gz[1..-1]
    assert_equal("甲", g)
    assert_equal("午", z)
  end
end
# -*- coding: utf-8 -*-
require 'test_helper'


class NineStarTest < Test::Unit::TestCase

  def test1
    lunar = Solar.fromYmd(1985, 2, 19).getLunar
    assert_equal("六", lunar.getYearNineStar.getNumber)
  end

  def test23
    lunar = Lunar.fromYmd(2022, 1, 1)
    assert_equal('六白金开阳', lunar.getYearNineStar.toString)
  end

  def test24
    lunar = Lunar.fromYmd(2033, 1, 1)
    assert_equal('四绿木天权', lunar.getYearNineStar.toString)
  end
end
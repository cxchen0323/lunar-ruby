# -*- coding: utf-8 -*-
require 'test_helper'


class JieQiTest < Test::Unit::TestCase
  def test7
    lunar = Lunar.fromYmd(2012, 9, 1)
    assert_equal("2012-09-07 13:29:01", lunar.getJieQiTable["白露"].toYmdHms)
  end

  def test8
    lunar = Lunar.fromYmd(2050, 12, 1)
    assert_equal("2050-12-07 06:40:53", lunar.getJieQiTable["DA_XUE"].toYmdHms)
  end

  def test1
    solar = Solar.fromYmd(2021, 12, 21)
    lunar = solar.getLunar
    assert_equal("冬至", lunar.getJieQi)
    assert_equal("", lunar.getJie)
    assert_equal("冬至", lunar.getQi)
  end

  def test2
    lunar = Lunar.fromYmd(2023, 6, 1)
    assert_equal("2022-12-22 05:48:01", lunar.getJieQiTable["冬至"].toYmdHms)
  end
end
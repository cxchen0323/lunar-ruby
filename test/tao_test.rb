# -*- coding: utf-8 -*-
require 'test_helper'


class TaoTest < Test::Unit::TestCase
  def test
    tao = Tao.fromLunar(Lunar.fromYmdHms(2021, 10, 17, 18, 0, 0))
    assert_equal("四七一八年十月十七", tao.toString)
    assert_equal("道歷四七一八年，天運辛丑年，己亥月，癸酉日。十月十七日，酉時。", tao.toFullString)
  end

  def test1
    tao = Tao.fromYmd(4718, 10, 18)
    assert_equal("地母娘娘圣诞", tao.getFestivals[0].toString)

    tao = Lunar.fromYmd(2021, 10, 18).getTao
    assert_equal("四时会", tao.getFestivals[1].toString)
  end
end
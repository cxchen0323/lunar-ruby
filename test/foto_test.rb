# -*- coding: utf-8 -*-
require 'test_helper'


class FotoTest < Test::Unit::TestCase
  def test
    foto = Foto.fromLunar(Lunar.fromYmd(2021, 10, 14))
    assert_equal("二五六五年十月十四 (三元降) (四天王巡行)", foto.toFullString)
  end

  def test1
    foto = Foto.fromLunar(Lunar.fromYmd(2020, 4, 13))
    assert_equal("氐", foto.getXiu)
    assert_equal("土", foto.getZheng)
    assert_equal("貉", foto.getAnimal)
    assert_equal("东", foto.getGong)
    assert_equal("青龙", foto.getShou)
  end

  def test2
    foto = Foto.fromLunar(Lunar.fromYmd(2021, 3, 16))
    assert_equal(["准提菩萨圣诞"], foto.getOtherFestivals)
  end
end
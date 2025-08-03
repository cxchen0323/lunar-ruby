# -*- coding: utf-8 -*-
require 'test_helper'


class ShuJiuTest < Test::Unit::TestCase

  def test1
    solar = Solar.fromYmd(2020, 12, 21)
    lunar = solar.getLunar
    shu_jiu = lunar.getShuJiu
    assert_equal("一九", shu_jiu.toString)
    assert_equal("一九第1天", shu_jiu.toFullString)
  end

  def test2
    solar = Solar.fromYmd(2020, 12, 22)
    lunar = solar.getLunar
    shu_jiu = lunar.getShuJiu
    assert_equal("一九", shu_jiu.toString)
    assert_equal("一九第2天", shu_jiu.toFullString)
  end

  def test3
    solar = Solar.fromYmd(2020, 1, 7)
    lunar = solar.getLunar
    shu_jiu = lunar.getShuJiu
    assert_equal("二九", shu_jiu.toString)
    assert_equal("二九第8天", shu_jiu.toFullString)
  end

  def test4
    solar = Solar.fromYmd(2021, 1, 6)
    lunar = solar.getLunar
    shu_jiu = lunar.getShuJiu
    assert_equal("二九", shu_jiu.toString)
    assert_equal("二九第8天", shu_jiu.toFullString)
  end

  def test5
    solar = Solar.fromYmd(2021, 1, 8)
    lunar = solar.getLunar
    shu_jiu = lunar.getShuJiu
    assert_equal("三九", shu_jiu.toString)
    assert_equal("三九第1天", shu_jiu.toFullString)
  end

  def test6
    solar = Solar.fromYmd(2021, 3, 5)
    lunar = solar.getLunar
    shu_jiu = lunar.getShuJiu
    assert_equal("九九", shu_jiu.toString)
    assert_equal("九九第3天", shu_jiu.toFullString)
  end

  def test7
    solar = Solar.fromYmd(2021, 7, 5)
    lunar = solar.getLunar
    shu_jiu = lunar.getShuJiu
    assert_nil(shu_jiu)
  end
end
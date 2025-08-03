# -*- coding: utf-8 -*-
require 'test_helper'


class HolidayTest < Test::Unit::TestCase
  def test
    holiday = HolidayUtil.getHoliday(2010, 1, 1)
    assert_equal("元旦节", holiday.getName)

    HolidayUtil.fix(nil, "20100101~000000000000000000000000000")
    holiday = HolidayUtil.getHoliday(2010, 1, 1)
    assert_nil(holiday)
  end
end
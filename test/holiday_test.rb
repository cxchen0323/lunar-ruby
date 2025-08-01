require_relative 'test_helper'
require 'lunar/util/holiday_util'

class HolidayTest < Minitest::Test
  def setup
    # Reset to default data before each test
    Lunar::HolidayUtil.names_in_use = Lunar::HolidayUtil::NAMES
    Lunar::HolidayUtil.data_in_use = Lunar::HolidayUtil::DATA
  end

  def test_get_holiday
    holiday = Lunar::HolidayUtil.get_holiday(2010, 1, 1)
    refute_nil holiday, "Holiday should not be nil for 2010-01-01"
    assert_equal '元旦节', holiday.get_name
  end

  def test_fix
    # Get original holiday
    holiday = Lunar::HolidayUtil.get_holiday(2010, 1, 1)
    assert_equal '元旦节', holiday.get_name
    
    # Remove holiday
    Lunar::HolidayUtil.fix(nil, '20100101~000000000000000000000000000')
    holiday = Lunar::HolidayUtil.get_holiday(2010, 1, 1)
    assert_nil holiday
  end
end
require_relative 'util/lunar_util'
require_relative 'solar'
require_relative 'nine_star'

module Lunar
  class LunarMonth
    attr_reader :year, :month, :day_count, :first_julian_day, :index, :zhi_index
    
    def initialize(lunar_year, lunar_month, day_count, first_julian_day, index)
      @year = lunar_year
      @month = lunar_month
      @day_count = day_count
      @first_julian_day = first_julian_day
      @index = index
      @zhi_index = (index - 1 + LunarUtil::BASE_MONTH_ZHI_INDEX) % 12
    end
    
    def self.from_ym(lunar_year, lunar_month)
      require_relative 'lunar_year'
      LunarYear.from_year(lunar_year).get_month(lunar_month)
    end
    
    def get_year
      @year
    end
    
    def get_month
      @month
    end
    
    def get_index
      @index
    end
    
    def get_zhi_index
      @zhi_index
    end
    
    def get_gan_index
      require_relative 'lunar_year'
      offset = (LunarYear.from_year(@year).get_gan_index + 1) % 5 * 2
      (@index - 1 + offset) % 10
    end
    
    def get_gan
      LunarUtil::GAN[get_gan_index + 1]
    end
    
    def get_zhi
      LunarUtil::ZHI[get_zhi_index + 1]
    end
    
    def get_gan_zhi
      "#{get_gan}#{get_zhi}"
    end
    
    def get_position_xi
      LunarUtil::POSITION_XI[get_gan_index + 1]
    end
    
    def get_position_xi_desc
      LunarUtil::POSITION_DESC[get_position_xi]
    end
    
    def get_position_yang_gui
      LunarUtil::POSITION_YANG_GUI[get_gan_index + 1]
    end
    
    def get_position_yang_gui_desc
      LunarUtil::POSITION_DESC[get_position_yang_gui]
    end
    
    def get_position_yin_gui
      LunarUtil::POSITION_YIN_GUI[get_gan_index + 1]
    end
    
    def get_position_yin_gui_desc
      LunarUtil::POSITION_DESC[get_position_yin_gui]
    end
    
    def get_position_fu(sect = 2)
      (sect == 1 ? LunarUtil::POSITION_FU : LunarUtil::POSITION_FU_2)[get_gan_index + 1]
    end
    
    def get_position_fu_desc(sect = 2)
      LunarUtil::POSITION_DESC[get_position_fu(sect)]
    end
    
    def get_position_cai
      LunarUtil::POSITION_CAI[get_gan_index + 1]
    end
    
    def get_position_cai_desc
      LunarUtil::POSITION_DESC[get_position_cai]
    end
    
    def leap?
      @month < 0
    end
    
    alias is_leap leap?
    
    def get_day_count
      @day_count
    end
    
    def get_first_julian_day
      @first_julian_day
    end
    
    def get_position_tai_sui
      m = @month.abs % 4
      p = case m
          when 0
            '巽'
          when 1
            '艮'
          when 3
            '坤'
          else
            LunarUtil::POSITION_GAN[Solar.from_julian_day(get_first_julian_day).get_lunar.get_month_gan_index]
          end
      p
    end
    
    def get_position_tai_sui_desc
      LunarUtil::POSITION_DESC[get_position_tai_sui]
    end
    
    def get_nine_star
      require_relative 'lunar_year'
      index = LunarYear.from_year(@year).get_zhi_index % 3
      m = @month.abs
      month_zhi_index = (13 + m) % 12
      n = 27 - (index * 3)
      n -= 3 if month_zhi_index < LunarUtil::BASE_MONTH_ZHI_INDEX
      offset = (n - month_zhi_index) % 9
      NineStar.from_index(offset)
    end
    
    def to_string
      "#{@year}年#{leap? ? '闰' : ''}#{LunarUtil::MONTH[@month.abs]}月(#{@day_count}天)"
    end
    
    alias to_s to_string
    
    def next(n)
      return LunarMonth.from_ym(@year, @month) if n == 0
      
      require_relative 'lunar_year'
      
      if n > 0
        rest = n
        ny = @year
        iy = ny
        im = @month
        index = 0
        months = LunarYear.from_year(ny).get_months
        
        loop do
          size = months.length
          size.times do |i|
            m = months[i]
            if m.get_year == iy && m.get_month == im
              index = i
              break
            end
          end
          
          more = size - index - 1
          break if rest < more
          
          rest -= more
          last_month = months[size - 1]
          iy = last_month.get_year
          im = last_month.get_month
          ny += 1
          months = LunarYear.from_year(ny).get_months
        end
        
        months[index + rest]
      else
        rest = -n
        ny = @year
        iy = ny
        im = @month
        index = 0
        months = LunarYear.from_year(ny).get_months
        
        loop do
          size = months.length
          size.times do |i|
            m = months[i]
            if m.get_year == iy && m.get_month == im
              index = i
              break
            end
          end
          
          break if rest <= index
          
          rest -= index
          first_month = months[0]
          iy = first_month.get_year
          im = first_month.get_month
          ny -= 1
          months = LunarYear.from_year(ny).get_months
        end
        
        months[index - rest]
      end
    end
  end
end
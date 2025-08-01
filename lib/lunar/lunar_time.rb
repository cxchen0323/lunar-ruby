require_relative 'util/lunar_util'

module Lunar
  class LunarTime
    attr_reader :lunar

    def initialize(lunar_year, lunar_month, lunar_day, hour, minute, second)
      require_relative 'lunar'
      @lunar = Lunar.from_ymd_hms(lunar_year, lunar_month, lunar_day, hour, minute, second)
      @zhi_index = LunarUtil.get_time_zhi_index(format('%02d:%02d', hour, minute))
      @gan_index = (@lunar.get_day_gan_index_exact % 5 * 2 + @zhi_index) % 10
    end

    def self.from_ymd_hms(lunar_year, lunar_month, lunar_day, hour, minute, second)
      new(lunar_year, lunar_month, lunar_day, hour, minute, second)
    end

    def get_gan
      LunarUtil::GAN[@gan_index + 1]
    end

    def get_zhi
      LunarUtil::ZHI[@zhi_index + 1]
    end

    def get_gan_zhi
      "#{get_gan}#{get_zhi}"
    end

    def get_sheng_xiao
      LunarUtil::SHENGXIAO[@zhi_index + 1]
    end

    def get_position_xi
      LunarUtil::POSITION_XI[@gan_index + 1]
    end

    def get_position_xi_desc
      LunarUtil::POSITION_DESC[get_position_xi]
    end

    def get_position_yang_gui
      LunarUtil::POSITION_YANG_GUI[@gan_index + 1]
    end

    def get_position_yang_gui_desc
      LunarUtil::POSITION_DESC[get_position_yang_gui]
    end

    def get_position_yin_gui
      LunarUtil::POSITION_YIN_GUI[@gan_index + 1]
    end

    def get_position_yin_gui_desc
      LunarUtil::POSITION_DESC[get_position_yin_gui]
    end

    def get_position_fu(sect = 2)
      (sect == 1 ? LunarUtil::POSITION_FU : LunarUtil::POSITION_FU_2)[@gan_index + 1]
    end

    def get_position_fu_desc(sect = 2)
      LunarUtil::POSITION_DESC[get_position_fu(sect)]
    end

    def get_position_cai
      LunarUtil::POSITION_CAI[@gan_index + 1]
    end

    def get_position_cai_desc
      LunarUtil::POSITION_DESC[get_position_cai]
    end

    def get_chong
      LunarUtil::CHONG[@zhi_index]
    end

    def get_chong_gan
      LunarUtil::CHONG_GAN[@gan_index]
    end

    def get_chong_gan_tie
      LunarUtil::CHONG_GAN_TIE[@gan_index]
    end

    def get_chong_sheng_xiao
      chong = get_chong
      LunarUtil::ZHI.each_with_index do |zhi, i|
        return LunarUtil::SHENGXIAO[i] if zhi == chong
      end
      ''
    end

    def get_chong_desc
      "(#{get_chong_gan}#{get_chong})#{get_chong_sheng_xiao}"
    end

    def get_sha
      LunarUtil::SHA[get_zhi]
    end

    def get_na_yin
      LunarUtil::NAYIN[get_gan_zhi]
    end

    def get_tian_shen
      LunarUtil::TIAN_SHEN[(@zhi_index + LunarUtil::ZHI_TIAN_SHEN_OFFSET[@lunar.get_day_zhi_exact]) % 12 + 1]
    end

    def get_tian_shen_type
      LunarUtil::TIAN_SHEN_TYPE[get_tian_shen]
    end

    def get_tian_shen_luck
      LunarUtil::TIAN_SHEN_TYPE_LUCK[get_tian_shen_type]
    end

    def get_yi
      LunarUtil.get_time_yi(@lunar.get_day_in_gan_zhi_exact, get_gan_zhi)
    end

    def get_ji
      LunarUtil.get_time_ji(@lunar.get_day_in_gan_zhi_exact, get_gan_zhi)
    end

    def get_nine_star
      require_relative 'nine_star'
      solar_ymd = @lunar.get_solar.to_ymd
      jie_qi = @lunar.get_jie_qi_table
      asc = false
      asc = true if jie_qi['冬至'] <= solar_ymd && solar_ymd < jie_qi['夏至']
      
      start = asc ? 7 : 3
      day_zhi = @lunar.get_day_zhi
      
      if %w[子 午 卯 酉].include?(day_zhi)
        start = asc ? 1 : 9
      elsif %w[辰 戌 丑 未].include?(day_zhi)
        start = asc ? 4 : 6
      end
      
      index = asc ? start + @zhi_index - 1 : start - @zhi_index - 1
      
      index -= 9 if index > 8
      index += 9 if index < 0
      
      NineStar.from_index(index)
    end

    def get_gan_index
      @gan_index
    end

    def get_zhi_index
      @zhi_index
    end

    def to_string
      get_gan_zhi
    end

    alias to_s to_string

    def get_xun
      LunarUtil.get_xun(get_gan_zhi)
    end

    def get_xun_kong
      LunarUtil.get_xun_kong(get_gan_zhi)
    end

    def get_min_hm
      hour = @lunar.get_hour
      return '00:00' if hour < 1
      return '23:00' if hour > 22
      format('%02d:00', hour.even? ? hour - 1 : hour)
    end

    def get_max_hm
      hour = @lunar.get_hour
      return '00:59' if hour < 1
      return '23:59' if hour > 22
      format('%02d:59', hour.odd? ? hour + 1 : hour)
    end
  end
end
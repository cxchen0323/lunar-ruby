require_relative 'util/lunar_util'

module Lunar
  class EightChar
    MONTH_ZHI = ['', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥', '子', '丑'].freeze
    CHANG_SHENG = %w[长生 沐浴 冠带 临官 帝旺 衰 病 死 墓 绝 胎 养].freeze
    
    CHANG_SHENG_OFFSET = {
      '甲' => 1, '丙' => 10, '戊' => 10, '庚' => 7, '壬' => 4,
      '乙' => 6, '丁' => 9, '己' => 9, '辛' => 0, '癸' => 3
    }.freeze

    attr_reader :lunar
    attr_accessor :sect

    def initialize(lunar)
      @sect = 2
      @lunar = lunar
    end

    def self.from_lunar(lunar)
      new(lunar)
    end

    def to_string
      "#{get_year} #{get_month} #{get_day} #{get_time}"
    end

    alias to_s to_string

    def get_sect
      @sect
    end

    def set_sect(sect)
      @sect = sect
    end

    def get_year
      @lunar.get_year_gan_zhi_exact
    end

    def get_year_gan
      @lunar.get_year_gan_exact
    end

    def get_year_zhi
      @lunar.get_year_zhi_exact
    end

    def get_year_hide_gan
      LunarUtil::ZHI_HIDE_GAN[get_year_zhi]
    end

    def get_year_wu_xing
      "#{LunarUtil::WU_XING_GAN[get_year_gan]}#{LunarUtil::WU_XING_ZHI[get_year_zhi]}"
    end

    def get_year_na_yin
      LunarUtil::NAYIN[get_year]
    end

    def get_year_shi_shen_gan
      LunarUtil::SHI_SHEN_GAN[get_day_gan + get_year_gan]
    end

    def get_year_shi_shen_zhi
      get_year_hide_gan.map { |gan| LunarUtil::SHI_SHEN_GAN[get_day_gan + gan] }
    end


    def get_month
      @lunar.get_month_gan_zhi_exact
    end

    def get_month_gan
      @lunar.get_month_gan_exact
    end

    def get_month_zhi
      @lunar.get_month_zhi_exact
    end

    def get_month_hide_gan
      LunarUtil::ZHI_HIDE_GAN[get_month_zhi]
    end

    def get_month_wu_xing
      "#{LunarUtil::WU_XING_GAN[get_month_gan]}#{LunarUtil::WU_XING_ZHI[get_month_zhi]}"
    end

    def get_month_na_yin
      LunarUtil::NAYIN[get_month]
    end

    def get_month_shi_shen_gan
      LunarUtil::SHI_SHEN_GAN[get_day_gan + get_month_gan]
    end

    def get_month_shi_shen_zhi
      get_month_hide_gan.map { |gan| LunarUtil::SHI_SHEN_GAN[get_day_gan + gan] }
    end


    def get_day
      @sect == 2 ? @lunar.get_day_gan_zhi_exact2 : @lunar.get_day_gan_zhi_exact
    end

    def get_day_gan
      @sect == 2 ? @lunar.get_day_gan_exact2 : @lunar.get_day_gan_exact
    end

    def get_day_zhi
      @sect == 2 ? @lunar.get_day_zhi_exact2 : @lunar.get_day_zhi_exact
    end

    def get_day_hide_gan
      LunarUtil::ZHI_HIDE_GAN[get_day_zhi]
    end

    def get_day_wu_xing
      "#{LunarUtil::WU_XING_GAN[get_day_gan]}#{LunarUtil::WU_XING_ZHI[get_day_zhi]}"
    end

    def get_day_na_yin
      LunarUtil::NAYIN[get_day]
    end

    def get_day_shi_shen_gan
      '日主'
    end

    def get_day_shi_shen_zhi
      get_day_hide_gan.map { |gan| LunarUtil::SHI_SHEN_GAN[get_day_gan + gan] }
    end


    def get_time
      @lunar.get_time_gan_zhi
    end

    def get_time_gan
      @lunar.get_time_gan
    end

    def get_time_zhi
      @lunar.get_time_zhi
    end

    def get_time_hide_gan
      LunarUtil::ZHI_HIDE_GAN[get_time_zhi]
    end

    def get_time_wu_xing
      "#{LunarUtil::WU_XING_GAN[get_time_gan]}#{LunarUtil::WU_XING_ZHI[get_time_zhi]}"
    end

    def get_time_na_yin
      LunarUtil::NAYIN[get_time]
    end

    def get_time_shi_shen_gan
      LunarUtil::SHI_SHEN_GAN[get_day_gan + get_time_gan]
    end

    def get_time_shi_shen_zhi
      get_time_hide_gan.map { |gan| LunarUtil::SHI_SHEN_GAN[get_day_gan + gan] }
    end


    def get_tai_yuan
      gan_index = @lunar.get_month_gan_index_exact
      zhi_index = @lunar.get_month_zhi_index_exact
      LunarUtil::GAN[(gan_index + 3) % 10] + LunarUtil::ZHI[(zhi_index + 3) % 12]
    end

    def get_tai_yuan_na_yin
      LunarUtil::NAYIN[get_tai_yuan]
    end

    def get_tai_xi
      gan_index = (@sect == 2 ? @lunar.get_day_gan_index_exact2 : @lunar.get_day_gan_index_exact) % 5
      zhi_index = (@sect == 2 ? @lunar.get_day_zhi_index_exact2 : @lunar.get_day_zhi_index_exact) % 6
      LunarUtil::HE_GAN_5[gan_index] + LunarUtil::HE_ZHI_6[zhi_index]
    end

    def get_tai_xi_na_yin
      LunarUtil::NAYIN[get_tai_xi]
    end

    def get_ming_gong
      month_zhi_index = LunarUtil.find(@lunar.get_month_zhi_exact, MONTH_ZHI, 0)
      time_zhi_index = LunarUtil.find(@lunar.get_time_zhi, MONTH_ZHI, 0)
      offset = month_zhi_index + time_zhi_index
      offset = offset >= 14 ? 26 - offset : 14 - offset
      gan_index = (@lunar.get_year_gan_index_exact + 1) * 2 + offset
      LunarUtil::GAN[gan_index % 10] + MONTH_ZHI[offset]
    end

    def get_ming_gong_na_yin
      LunarUtil::NAYIN[get_ming_gong]
    end

    def get_shen_gong
      month_zhi_index = LunarUtil.find(@lunar.get_month_zhi_exact, MONTH_ZHI, 0)
      time_zhi_index = LunarUtil.find(@lunar.get_time_zhi, LunarUtil::ZHI, 0)
      offset = month_zhi_index + time_zhi_index
      offset = offset >= 12 ? 10 + offset - 12 : 10 + offset
      gan_index = (@lunar.get_year_gan_index_exact + 1) * 2 + (offset % 12)
      LunarUtil::GAN[gan_index % 10] + MONTH_ZHI[offset]
    end

    def get_shen_gong_na_yin
      LunarUtil::NAYIN[get_shen_gong]
    end

    def get_yun(gender)
      from_eightchar = require_relative('eightchar/yun')
      EightChar::Yun.new(self, gender)
    end
  end
end
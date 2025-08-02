require_relative 'solar'
require_relative 'nine_star'
require_relative 'eight_char'
require_relative 'jie_qi'
require_relative 'shu_jiu'
require_relative 'fu'
require_relative 'lunar_time'
require_relative 'lunar_year'
require_relative 'lunar_month'
require_relative 'util/lunar_util'
require_relative 'util/solar_util'

module Lunar
  class Lunar
    JIE_QI = %w[冬至 小寒 大寒 立春 雨水 惊蛰 春分 清明 谷雨 立夏 小满 芒种 夏至 小暑 大暑 立秋 处暑 白露 秋分 寒露 霜降 立冬 小雪 大雪].freeze
    JIE_QI_IN_USE = %w[DA_XUE 冬至 小寒 大寒 立春 雨水 惊蛰 春分 清明 谷雨 立夏 小满 芒种 夏至 小暑 大暑 立秋 处暑 白露 秋分 寒露 霜降 立冬 小雪 大雪 DONG_ZHI XIAO_HAN DA_HAN LI_CHUN YU_SHUI JING_ZHE].freeze
    
    attr_reader :year, :month, :day, :hour, :minute, :second, :time_gan_index, :time_zhi_index,
                :day_gan_index, :day_zhi_index, :day_gan_index_exact, :day_zhi_index_exact,
                :day_gan_index_exact2, :day_zhi_index_exact2, :month_gan_index, :month_zhi_index,
                :month_gan_index_exact, :month_zhi_index_exact, :year_gan_index, :year_zhi_index,
                :year_gan_index_by_li_chun, :year_zhi_index_by_li_chun, :year_gan_index_exact,
                :year_zhi_index_exact, :week_index, :jie_qi, :jie_qi_list, :solar, :eight_char
    
    def initialize(lunar_year, lunar_month, lunar_day, hour = 0, minute = 0, second = 0)
      y = LunarYear.from_year(lunar_year)
      m = y.get_month(lunar_month)
      raise "wrong lunar year #{lunar_year} month #{lunar_month}" if m.nil?
      raise 'lunar day must bigger than 0' if lunar_day < 1
      
      days = m.get_day_count
      raise "only #{days} days in lunar year #{lunar_year} month #{lunar_month}" if lunar_day > days
      
      @year = lunar_year
      @month = lunar_month
      @day = lunar_day
      @hour = hour
      @minute = minute
      @second = second
      @jie_qi = {}
      @jie_qi_list = []
      @eight_char = nil
      
      noon = Solar.from_julian_day(m.get_first_julian_day + lunar_day - 1)
      @solar = Solar.from_ymd_hms(noon.get_year, noon.get_month, noon.get_day, hour, minute, second)
      
      y = LunarYear.from_year(noon.get_year) if noon.get_year != lunar_year
      
      compute(y)
    end
    
    private
    
    def compute(y)
      compute_jie_qi(y)
      compute_year
      compute_month
      compute_day
      compute_time
      compute_week
    end
    
    def compute_jie_qi(y)
      julian_days = y.get_jie_qi_julian_days
      JIE_QI_IN_USE.length.times do |i|
        name = JIE_QI_IN_USE[i]
        @jie_qi[name] = Solar.from_julian_day(julian_days[i])
        @jie_qi_list << name
      end
    end
    
    def compute_year
      # 以正月初一开始
      offset = @year - 4
      year_gan_index = offset % 10
      year_zhi_index = offset % 12
      
      year_gan_index += 10 if year_gan_index < 0
      year_zhi_index += 12 if year_zhi_index < 0
      
      # 以立春作为新一年的开始的干支纪年
      g = year_gan_index
      z = year_zhi_index
      
      # 精确的干支纪年，以立春交接时刻为准
      g_exact = year_gan_index
      z_exact = year_zhi_index
      
      solar_year = @solar.get_year
      solar_ymd = @solar.to_ymd
      solar_ymd_hms = @solar.to_ymd_hms
      
      # 获取立春的阳历时刻
      li_chun = @jie_qi['立春']
      li_chun = @jie_qi['LI_CHUN'] if li_chun.get_year != solar_year
      li_chun_ymd = li_chun.to_ymd
      li_chun_ymd_hms = li_chun.to_ymd_hms
      
      # 阳历和阴历年份相同代表正月初一及以后
      if @year == solar_year
        # 立春日期判断
        if solar_ymd < li_chun_ymd
          g -= 1
          z -= 1
        end
        # 立春交接时刻判断
        if solar_ymd_hms < li_chun_ymd_hms
          g_exact -= 1
          z_exact -= 1
        end
      elsif @year < solar_year
        if solar_ymd >= li_chun_ymd
          g += 1
          z += 1
        end
        if solar_ymd_hms >= li_chun_ymd_hms
          g_exact += 1
          z_exact += 1
        end
      end
      
      @year_gan_index = year_gan_index
      @year_zhi_index = year_zhi_index
      @year_gan_index_by_li_chun = (g < 0 ? g + 10 : g) % 10
      @year_zhi_index_by_li_chun = (z < 0 ? z + 12 : z) % 12
      @year_gan_index_exact = (g_exact < 0 ? g_exact + 10 : g_exact) % 10
      @year_zhi_index_exact = (z_exact < 0 ? z_exact + 12 : z_exact) % 12
    end
    
    def compute_month
      ymd = @solar.to_ymd
      time = @solar.to_ymd_hms
      size = JIE_QI_IN_USE.length
      
      # 序号：大雪以前-3，大雪到小寒之间-2，小寒到立春之间-1，立春之后0
      index = -3
      start = nil
      (0...size).step(2) do |i|
        end_jq = @jie_qi[JIE_QI_IN_USE[i]]
        symd = start.nil? ? ymd : start.to_ymd
        break if symd <= ymd && ymd < end_jq.to_ymd
        start = end_jq
        index += 1
      end
      
      # 干偏移值（以立春当天起算）
      g_offset = (((@year_gan_index_by_li_chun + (index < 0 ? 1 : 0)) % 5 + 1) * 2) % 10
      @month_gan_index = ((index < 0 ? index + 10 : index) + g_offset) % 10
      @month_zhi_index = ((index < 0 ? index + 12 : index) + LunarUtil::BASE_MONTH_ZHI_INDEX) % 12
      
      index = -3
      start = nil
      (0...size).step(2) do |i|
        end_jq = @jie_qi[JIE_QI_IN_USE[i]]
        stime = start.nil? ? time : start.to_ymd_hms
        break if stime <= time && time < end_jq.to_ymd_hms
        start = end_jq
        index += 1
      end
      
      # 干偏移值（以立春交接时刻起算）
      g_offset = (((@year_gan_index_exact + (index < 0 ? 1 : 0)) % 5 + 1) * 2) % 10
      @month_gan_index_exact = ((index < 0 ? index + 10 : index) + g_offset) % 10
      @month_zhi_index_exact = ((index < 0 ? index + 12 : index) + LunarUtil::BASE_MONTH_ZHI_INDEX) % 12
    end
    
    def compute_day
      noon = Solar.from_ymd_hms(@solar.get_year, @solar.get_month, @solar.get_day, 12, 0, 0)
      offset = noon.get_julian_day.to_i - 11
      day_gan_index = offset % 10
      day_zhi_index = offset % 12
      
      @day_gan_index = day_gan_index
      @day_zhi_index = day_zhi_index
      
      day_gan_exact = day_gan_index
      day_zhi_exact = day_zhi_index
      
      # 八字流派2，晚子时（夜子/子夜）日柱算当天
      @day_gan_index_exact2 = day_gan_exact
      @day_zhi_index_exact2 = day_zhi_exact
      
      # 八字流派1，晚子时（夜子/子夜）日柱算明天
      hm = format('%02d:%02d', @hour, @minute)
      if hm >= '23:00' && hm <= '23:59'
        day_gan_exact += 1
        day_gan_exact -= 10 if day_gan_exact >= 10
        day_zhi_exact += 1
        day_zhi_exact -= 12 if day_zhi_exact >= 12
      end
      @day_gan_index_exact = day_gan_exact
      @day_zhi_index_exact = day_zhi_exact
    end
    
    def compute_time
      time_zhi_index = LunarUtil.get_time_zhi_index(format('%02d:%02d', @hour, @minute))
      @time_zhi_index = time_zhi_index
      @time_gan_index = (@day_gan_index_exact % 5 * 2 + time_zhi_index) % 10
    end
    
    def compute_week
      @week_index = @solar.get_week
    end
    
    public
    
    # Class methods
    def self.from_ymd_hms(lunar_year, lunar_month, lunar_day, hour, minute, second)
      new(lunar_year, lunar_month, lunar_day, hour, minute, second)
    end
    
    def self.from_ymd(lunar_year, lunar_month, lunar_day)
      new(lunar_year, lunar_month, lunar_day, 0, 0, 0)
    end
    
    def self.from_date(date)
      from_solar(Solar.from_date(date))
    end
    
    def self.from_solar(solar)
      year = 0
      month = 0
      day = 0
      
      ly = LunarYear.from_year(solar.get_year)
      ly.get_months.each do |m|
        days = solar.subtract(Solar.from_julian_day(m.get_first_julian_day))
        if days < m.get_day_count
          year = m.get_year
          month = m.get_month
          day = days + 1
          break
        end
      end
      
      new(year, month, day, solar.get_hour, solar.get_minute, solar.get_second)
    end
    
    # Getters
    def get_year
      @year
    end
    
    def get_month
      @month
    end
    
    def get_day
      @day
    end
    
    def get_hour
      @hour
    end
    
    def get_minute
      @minute
    end
    
    def get_second
      @second
    end
    
    def get_solar
      @solar
    end
    
    def get_year_gan
      LunarUtil::GAN[@year_gan_index + 1]
    end
    
    def get_year_gan_by_li_chun
      LunarUtil::GAN[@year_gan_index_by_li_chun + 1]
    end
    
    def get_year_gan_exact
      LunarUtil::GAN[@year_gan_index_exact + 1]
    end
    
    def get_year_zhi
      LunarUtil::ZHI[@year_zhi_index + 1]
    end
    
    def get_year_zhi_by_li_chun
      LunarUtil::ZHI[@year_zhi_index_by_li_chun + 1]
    end
    
    def get_year_zhi_exact
      LunarUtil::ZHI[@year_zhi_index_exact + 1]
    end
    
    def get_year_in_gan_zhi
      "#{get_year_gan}#{get_year_zhi}"
    end
    
    def get_year_in_gan_zhi_by_li_chun
      "#{get_year_gan_by_li_chun}#{get_year_zhi_by_li_chun}"
    end
    
    def get_year_in_gan_zhi_exact
      "#{get_year_gan_exact}#{get_year_zhi_exact}"
    end
    
    def get_month_gan
      LunarUtil::GAN[@month_gan_index + 1]
    end
    
    def get_month_gan_exact
      LunarUtil::GAN[@month_gan_index_exact + 1]
    end
    
    def get_month_zhi
      LunarUtil::ZHI[@month_zhi_index + 1]
    end
    
    def get_month_zhi_exact
      LunarUtil::ZHI[@month_zhi_index_exact + 1]
    end
    
    def get_month_in_gan_zhi
      "#{get_month_gan}#{get_month_zhi}"
    end
    
    def get_month_in_gan_zhi_exact
      "#{get_month_gan_exact}#{get_month_zhi_exact}"
    end
    
    def get_day_gan
      LunarUtil::GAN[@day_gan_index + 1]
    end
    
    def get_day_gan_exact
      LunarUtil::GAN[@day_gan_index_exact + 1]
    end
    
    def get_day_gan_exact2
      LunarUtil::GAN[@day_gan_index_exact2 + 1]
    end
    
    def get_day_zhi
      LunarUtil::ZHI[@day_zhi_index + 1]
    end
    
    def get_day_zhi_exact
      LunarUtil::ZHI[@day_zhi_index_exact + 1]
    end
    
    def get_day_zhi_exact2
      LunarUtil::ZHI[@day_zhi_index_exact2 + 1]
    end
    
    def get_day_in_gan_zhi
      "#{get_day_gan}#{get_day_zhi}"
    end
    
    def get_day_in_gan_zhi_exact
      "#{get_day_gan_exact}#{get_day_zhi_exact}"
    end
    
    def get_day_in_gan_zhi_exact2
      "#{get_day_gan_exact2}#{get_day_zhi_exact2}"
    end
    
    def get_time_gan
      LunarUtil::GAN[@time_gan_index + 1]
    end
    
    def get_time_zhi
      LunarUtil::ZHI[@time_zhi_index + 1]
    end
    
    def get_time_in_gan_zhi
      "#{get_time_gan}#{get_time_zhi}"
    end
    
    def get_year_sheng_xiao
      LunarUtil::SHENGXIAO[@year_zhi_index + 1]
    end
    
    def get_year_sheng_xiao_by_li_chun
      LunarUtil::SHENGXIAO[@year_zhi_index_by_li_chun + 1]
    end
    
    def get_year_sheng_xiao_exact
      LunarUtil::SHENGXIAO[@year_zhi_index_exact + 1]
    end
    
    def get_month_sheng_xiao
      LunarUtil::SHENGXIAO[@month_zhi_index + 1]
    end
    
    def get_month_sheng_xiao_exact
      LunarUtil::SHENGXIAO[@month_zhi_index_exact + 1]
    end
    
    def get_day_sheng_xiao
      LunarUtil::SHENGXIAO[@day_zhi_index + 1]
    end
    
    def get_time_sheng_xiao
      LunarUtil::SHENGXIAO[@time_zhi_index + 1]
    end
    
    def get_year_in_chinese
      y = @year.to_s
      s = ''
      y.each_char do |c|
        s += LunarUtil::NUMBER[c.to_i]
      end
      s
    end
    
    def get_month_in_chinese
      LunarUtil::MONTH[@month.abs]
    end
    
    def get_day_in_chinese
      LunarUtil::DAY[@day]
    end
    
    def get_season
      LunarUtil::SEASON[@month.abs]
    end
    
    def get_jie
      JIE_QI_IN_USE.each_with_index do |key, i|
        next if i.even?
        d = @jie_qi[key]
        return i / 2 if d.get_year == @solar.get_year && d.get_month == @solar.get_month && d.get_day == @solar.get_day
      end
      ''
    end
    
    def get_qi
      JIE_QI_IN_USE.each_with_index do |key, i|
        next if i.odd?
        d = @jie_qi[key]
        return i / 2 if d.get_year == @solar.get_year && d.get_month == @solar.get_month && d.get_day == @solar.get_day
      end
      ''
    end
    
    def get_week
      LunarUtil::WEEK[@week_index]
    end
    
    def get_week_in_chinese
      LunarUtil::WEEK[@week_index]
    end
    
    def to_string
      "#{get_year_in_chinese}年#{get_month_in_chinese}月#{get_day_in_chinese}"
    end
    
    def to_full_string
      s = to_string
      s = '闰' + s if leap_month?
      return s unless festival.empty?
      s + ' ' + festival
    end
    
    def leap_month?
      @month < 0
    end
    
    def get_festivals
      # TODO: Implement festival logic
      []
    end
    
    def festival
      # TODO: Implement festival logic
      ''
    end
    
    # Index accessors
    def get_year_gan_index
      @year_gan_index
    end
    
    def get_year_zhi_index
      @year_zhi_index
    end
    
    def get_month_gan_index
      @month_gan_index
    end
    
    def get_month_zhi_index
      @month_zhi_index
    end
    
    def get_day_gan_index
      @day_gan_index
    end
    
    def get_day_zhi_index
      @day_zhi_index
    end
    
    def get_time_gan_index
      @time_gan_index
    end
    
    def get_time_zhi_index
      @time_zhi_index
    end
  end
end
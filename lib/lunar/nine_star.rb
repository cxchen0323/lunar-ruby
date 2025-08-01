require_relative 'util/lunar_util'

module Lunar
  class NineStar
    NUMBER = %w[一 二 三 四 五 六 七 八 九].freeze
    COLOR = %w[白 黑 碧 绿 黄 白 赤 白 紫].freeze
    WU_XING = %w[水 土 木 木 土 金 金 土 火].freeze
    POSITION = %w[坎 坤 震 巽 中 乾 兑 艮 离].freeze
    NAME_BEI_DOU = %w[天枢 天璇 天玑 天权 玉衡 开阳 摇光 洞明 隐元].freeze
    NAME_XUAN_KONG = %w[贪狼 巨门 禄存 文曲 廉贞 武曲 破军 左辅 右弼].freeze
    NAME_QI_MEN = %w[天蓬 天芮 天冲 天辅 天禽 天心 天柱 天任 天英].freeze
    BA_MEN_QI_MEN = ['休', '死', '伤', '杜', '', '开', '惊', '生', '景'].freeze
    NAME_TAI_YI = %w[太乙 摄提 轩辕 招摇 天符 青龙 咸池 太阴 天乙].freeze
    TYPE_TAI_YI = %w[吉神 凶神 安神 安神 凶神 吉神 凶神 吉神 吉神].freeze
    SONG_TAI_YI = [
      '门中太乙明，星官号贪狼，赌彩财喜旺，婚姻大吉昌，出入无阻挡，参谒见贤良，此行三五里，黑衣别阴阳。',
      '门前见摄提，百事必忧疑，相生犹自可，相克祸必临，死门并相会，老妇哭悲啼，求谋并吉事，尽皆不相宜，只可藏隐遁，若动伤身疾。',
      '出入会轩辕，凡事必缠牵，相生全不美，相克更忧煎，远行多不利，博彩尽输钱，九天玄女法，句句不虚言。',
      '招摇号木星，当之事莫行，相克行人阻，阴人口舌迎，梦寐多惊惧，屋响斧自鸣，阴阳消息理，万法弗违情。',
      '五鬼为天符，当门阴女谋，相克无好事，行路阻中途，走失难寻觅，道逢有尼姑，此星当门值，万事有灾除。',
      '神光跃青龙，财气喜重重，投入有酒食，赌彩最兴隆，更逢相生旺，休言克破凶，见贵安营寨，万事总吉同。',
      '吾将为咸池，当之尽不宜，出入多不利，相克有灾情，赌彩全输尽，求财空手回，仙人真妙语，愚人莫与知，动用虚惊退，反复逆风吹。',
      '坐临太阴星，百祸不相侵，求谋悉成就，知交有觅寻，回风归来路，恐有殃伏起，密语中记取，慎乎莫轻行。',
      '迎来天乙星，相逢百事兴，运用和合庆，茶酒喜相迎，求谋并嫁娶，好合有天成，祸福如神验，吉凶甚分明。'
    ].freeze
    LUCK_XUAN_KONG = %w[吉 凶 凶 吉 凶 吉 凶 吉 吉].freeze
    LUCK_QI_MEN = %w[大凶 大凶 小吉 大吉 大吉 大吉 小凶 小吉 小凶].freeze
    YIN_YANG_QI_MEN = %w[阳 阴 阳 阳 阳 阴 阴 阳 阴].freeze

    attr_reader :index

    def initialize(index)
      @index = index
    end

    def self.from_index(index)
      new(index)
    end

    def get_number
      NUMBER[@index]
    end

    def get_color
      COLOR[@index]
    end

    def get_wu_xing
      WU_XING[@index]
    end

    def get_position
      POSITION[@index]
    end

    def get_position_desc
      LunarUtil::POSITION_DESC[get_position]
    end

    def get_name_in_xuan_kong
      NAME_XUAN_KONG[@index]
    end

    def get_name_in_bei_dou
      NAME_BEI_DOU[@index]
    end

    def get_name_in_qi_men
      NAME_QI_MEN[@index]
    end

    def get_name_in_tai_yi
      NAME_TAI_YI[@index]
    end

    def get_luck_in_qi_men
      LUCK_QI_MEN[@index]
    end

    def get_luck_in_xuan_kong
      LUCK_XUAN_KONG[@index]
    end

    def get_yin_yang_in_qi_men
      YIN_YANG_QI_MEN[@index]
    end

    def get_type_in_tai_yi
      TYPE_TAI_YI[@index]
    end

    def get_ba_men_in_qi_men
      BA_MEN_QI_MEN[@index]
    end

    def get_song_in_tai_yi
      SONG_TAI_YI[@index]
    end

    def get_index
      @index
    end

    def to_string
      get_number + get_color + get_wu_xing + get_name_in_bei_dou
    end

    def to_full_string
      s = get_number
      s += get_color
      s += get_wu_xing
      s += ' '
      s += get_position
      s += '('
      s += get_position_desc
      s += ') '
      s += get_name_in_bei_dou
      s += ' 玄空['
      s += get_name_in_xuan_kong
      s += ' '
      s += get_luck_in_xuan_kong
      s += '] 奇门['
      s += get_name_in_qi_men
      s += ' '
      s += get_luck_in_qi_men
      unless get_ba_men_in_qi_men.empty?
        s += ' '
        s += get_ba_men_in_qi_men
        s += '门'
      end
      s += ' '
      s += get_yin_yang_in_qi_men
      s += '] 太乙['
      s += get_name_in_tai_yi
      s += ' '
      s += get_type_in_tai_yi
      s += ']'
      s
    end

    alias to_s to_string
  end
end
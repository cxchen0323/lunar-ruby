require_relative 'util/lunar_util'

module Lunar
  class JieQi
    attr_reader :name, :solar
    attr_accessor :jie, :qi

    def initialize(name, solar)
      @name = name
      @jie = false
      @qi = false
      @solar = solar
      set_name(name)
    end

    def get_name
      @name
    end

    def set_name(name)
      @name = name
      LunarUtil::JIE_QI.each_with_index do |jq, i|
        if name == jq
          if i.even?
            @qi = true
          else
            @jie = true
          end
          return
        end
      end
    end

    def get_solar
      @solar
    end

    def set_solar(solar)
      @solar = solar
    end

    def is_jie?
      @jie
    end

    def is_qi?
      @qi
    end

    def to_string
      @name
    end

    alias to_s to_string
  end
end
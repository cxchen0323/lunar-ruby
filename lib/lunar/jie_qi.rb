module Lunar
  class JieQi
    attr_reader :name, :solar
    
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
      Lunar::JIE_QI.each_with_index do |jq, i|
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
    
    def jie?
      @jie
    end
    
    alias is_jie jie?
    
    def qi?
      @qi
    end
    
    alias is_qi qi?
    
    def to_string
      @name
    end
    
    alias to_s to_string
  end
end
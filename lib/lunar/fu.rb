module Lunar
  # 三伏
  # 从夏至后第3个庚日算起，初伏为10天，中伏为10天或20天，末伏为10天。
  # 当夏至与立秋之间出现4个庚日时中伏为10天，出现5个庚日则为20天。
  class Fu
    attr_accessor :name, :index

    def initialize(name, index)
      @name = name
      @index = index
    end

    def get_name
      @name
    end

    def set_name(name)
      @name = name
    end

    def get_index
      @index
    end

    def set_index(index)
      @index = index
    end

    def to_string
      @name
    end

    def to_full_string
      "#{@name}第#{@index}天"
    end

    alias to_s to_string
  end
end
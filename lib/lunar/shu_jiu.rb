module Lunar
  class ShuJiu
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
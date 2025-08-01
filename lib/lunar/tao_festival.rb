module Lunar
  class TaoFestival
    attr_reader :name, :remark

    def initialize(name, remark = nil)
      @name = name
      @remark = remark || ''
    end

    def get_name
      @name
    end

    def get_remark
      @remark
    end

    def to_string
      @name
    end

    def to_full_string
      s = @name
      s += "[#{@remark}]" if @remark && !@remark.empty?
      s
    end

    alias to_s to_string
  end
end
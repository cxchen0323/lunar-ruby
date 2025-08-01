module Lunar
  class FotoFestival
    attr_reader :name, :result, :every_month, :remark

    def initialize(name, result = nil, every_month = false, remark = nil)
      @name = name
      @result = result || ''
      @every_month = every_month
      @remark = remark || ''
    end

    def get_name
      @name
    end

    def get_result
      @result
    end

    def is_every_month?
      @every_month
    end

    def get_remark
      @remark
    end

    def to_string
      @name
    end

    def to_full_string
      s = @name
      s += " #{@result}" if @result && !@result.empty?
      s += " #{@remark}" if @remark && !@remark.empty?
      s
    end

    alias to_s to_string
  end
end
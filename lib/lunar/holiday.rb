module Lunar
  class Holiday
    attr_reader :day, :name, :work, :target

    def initialize(day, name, work, target)
      @day = self.class.ymd(day)
      @name = name
      @work = work
      @target = self.class.ymd(target)
    end

    def self.ymd(s)
      s.include?('-') ? s : "#{s[0...4]}-#{s[4...6]}-#{s[6..-1]}"
    end

    def get_day
      @day
    end

    def get_name
      @name
    end

    def is_work?
      @work
    end

    def get_target
      @target
    end

    def set_day(day)
      @day = self.class.ymd(day)
    end

    def set_name(name)
      @name = name
    end

    def set_work(work)
      @work = work
    end

    def set_target(target)
      @target = self.class.ymd(target)
    end

    def to_string
      "#{@day} #{@name}#{@work ? '调休' : ''} #{@target}"
    end

    alias to_s to_string
  end
end
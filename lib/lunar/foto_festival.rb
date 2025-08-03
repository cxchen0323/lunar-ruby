# -*- coding: utf-8 -*-


class FotoFestival
  # 佛历因果犯忌

  def initialize(name, result = nil, every_month = false, remark = nil)
    @name = name
    @result = result.nil? ? "" : result
    @everyMonth = every_month
    @remark = remark.nil? ? "" : remark
  end

  def getName
    @name
  end

  def getResult
    @result
  end

  def isEveryMonth
    @everyMonth
  end

  def getRemark
    @remark
  end

  def to_s
    toString
  end

  def toString
    @name
  end

  def toFullString
    s = @name
    if !@result.nil? && @result.length > 0
      s += " " + @result
    end
    if !@remark.nil? && @remark.length > 0
      s += " " + @remark
    end
    s
  end
end
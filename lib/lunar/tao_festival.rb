# -*- coding: utf-8 -*-


class TaoFestival
  # 道历节日

  def initialize(name, remark = nil)
    @name = name
    @remark = remark.nil? ? "" : remark
  end

  def getName
    @name
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
    if !@remark.nil? && @remark.length > 0
      s += "[" + @remark + "]"
    end
    s
  end
end
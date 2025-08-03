# -*- coding: utf-8 -*-


class Fu
  # 三伏
  # <p>从夏至后第3个庚日算起，初伏为10天，中伏为10天或20天，末伏为10天。当夏至与立秋之间出现4个庚日时中伏为10天，出现5个庚日则为20天。</p>

  def initialize(name, index)
    @name = name
    @index = index
  end

  def getName
    @name
  end

  def setName(name)
    @name = name
  end

  def getIndex
    @index
  end

  def setIndex(index)
    @index = index
  end

  def to_s
    toString
  end

  def toString
    @name
  end

  def toFullString
    "%s第%d天" % [@name, @index]
  end
end
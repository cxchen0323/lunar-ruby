# -*- coding: utf-8 -*-


class ShuJiu
  # 数九

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
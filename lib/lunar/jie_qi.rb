# -*- coding: utf-8 -*-


class JieQi
  # 节气

  def initialize(name, solar)
    @name = name
    @jie = false
    @qi = false
    @solar = solar
    setName(name)
  end

  def getName
    # 获取名称
    # :return: 名称
    @name
  end

  def setName(name)
    # 设置名称
    # :param name: 名称
    require_relative 'lunar'
    @name = name
    (0...Lunar::JIE_QI.length).each do |i|
      if name == Lunar::JIE_QI[i]
        if i % 2 == 0
          @qi = true
        else
          @jie = true
        end
        return
      end
    end
  end

  def getSolar
    # 获取阳历日期
    # :return: 阳历日期
    @solar
  end

  def setSolar(solar)
    # 设置阳历日期
    # :param solar: 阳历日期
    @solar = solar
  end

  def isJie
    # 是否节令
    # :return: true/false
    @jie
  end

  def isQi
    # 是否气令
    # :return: true/false
    @qi
  end

  def toString
    @name
  end

  def to_s
    toString
  end
end

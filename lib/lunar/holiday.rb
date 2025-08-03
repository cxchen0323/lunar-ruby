# -*- coding: utf-8 -*-
class Holiday
  # 节假日

  def initialize(day, name, work, target)
    # 初始化
    # :param day: 日期，YYYY-MM-DD格式
    # :param name: 名称，如：国庆
    # :param work: 是否调休，即是否要上班
    # :param target: 关联的节日，YYYY-MM-DD格式
    @day = Holiday.ymd(day)
    @name = name
    @work = work
    @target = Holiday.ymd(target)
  end

  def self.ymd(s)
    s.include?("-") ? s : (s[0, 4] + "-" + s[4, 2] + "-" + s[6, 2])
  end

  def getDay
    @day
  end

  def getName
    @name
  end

  def isWork
    @work
  end

  def getTarget
    @target
  end

  def setDay(day)
    @day = Holiday.ymd(day)
  end

  def setName(name)
    @name = name
  end

  def setWork(work)
    @work = work
  end

  def setTarget(target)
    @target = Holiday.ymd(target)
  end

  def toString
    "%s %s%s %s" % [@day, @name, @work ? "调休" : "", @target]
  end

  def to_s
    toString
  end
end
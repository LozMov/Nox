#==============================================================================
# ■ Light
#------------------------------------------------------------------------------
# 　Sprite的子类，专用于表示游戏中的“灯”。
#==============================================================================

class Light < Sprite
  attr_accessor :column #所在列
  attr_accessor :row    #所在行
  attr_accessor :on #打开状态
  
  def initialize(column,row,on=false,*viewport)
    @column = column
    @row = row
    @on = on
    super(*viewport)
  end
  
  def on?
    @on
  end
  
  def switch #切换灯的开关状态
    @on = !@on
  end
end
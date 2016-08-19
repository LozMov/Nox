#==============================================================================
# ■ Mouse
#------------------------------------------------------------------------------
# 　运用Win32API提供简单的鼠标功能的模块。
#==============================================================================

module Mouse
  #常数（鼠标左、右、中键）
  LEFT   = 0x01
  RIGHT  = 0x02
  MIDDLE = 0x04
  #需要用到的Windows API 函数
  STC = Win32API.new('user32', 'ScreenToClient', 'lp', 'i')
  SC = Win32API.new('user32', 'ShowCursor', 'i', 'i')
  CP = Win32API.new('user32', 'GetCursorPos', 'p', 'i')
  HWND = Win32API.new('user33', 'GetHWND', 'v', 'i').call
  GAKS = Win32API.new('user32', 'GetAsyncKeyState', 'i', 'i')
  #生成光标的Sprite对象
  $cursor = Sprite.new
  $cursor.z = 999999
  $cursor.bitmap = RPG::Cache.picture('cursor') #鼠标位图
  @key_hash = {} 
  def self.update
    pos = "\0" * 8 #pos = [0, 0].pack('ll')
    CP.call(pos)
    STC.call(HWND, pos)
    $cursor.x, $cursor.y = pos.unpack('ll')
  end
  
  def self.hide_system_cursor
    SC.call(0)
  end
  
  def self.show_system_cursor
    SC.call(1)
  end
  
  def self.pos
    return $cursor.x, $cursor.y
  end
  
  def self.trigger?(key = LEFT) 
    result = GAKS.call(key) 
    if @key_hash[key] == 1 and result != 0 
      return false 
    end 
    if result != 0 
      @key_hash[key] = 1 
      return true 
    else 
      @key_hash[key] = 0 
      return false 
    end
  end
end

module Input
  
  class << self
    alias __update update unless $@
  end
  
  def self.update
    Mouse.update
    __update
  end
end

#在显示对话框时暂时恢复系统鼠标
module Kernel
  alias __print print
  
  def print(str)
    Mouse.show_system_cursor
    __print(str)
    Mouse.hide_system_cursor
  end
end

#隐藏系统鼠标并刷新光标位置
$cursor.visible = false
Mouse.hide_system_cursor
Mouse.update
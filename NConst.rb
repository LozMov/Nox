#==============================================================================
# ■ NConst
#------------------------------------------------------------------------------
# 　存储游戏各项可设定参数的模块。同时存储了游戏自带的关卡数据。
#==============================================================================

module NConst
  #获取窗口的高度与宽度（依赖于IniFile）
  INI_FILE = IniFile.new(".\\Game.ini")
  WIDTH = INI_FILE[:Window][:width].to_i
  HEIGHT = INI_FILE[:Window][:height].to_i
  LOGO = INI_FILE[:Config][:logo] == "1" ? true : false
  
  COLUMNS = 5 #列数
  ROWS = 7 #行数
  SIZE = 60 #灯长、宽度
  GAP = 5 #灯四周的留白
  INFO_RECT_HEIGHT = 40 #底部信息区高度
  INFO_RECT_COLOR = Color.new(0,0,0) #底部信息区颜色
  INFO_TEXT_COLOR = Color.new(152,153,155) #信息文字颜色
  LIGHT_COLOR_OFF = Color.new(152,153,155) #灯关闭时的颜色
  LIGHT_COLOR_ON  = Color.new(254,255,86) #灯开启时的颜色
  POINTED_COLOR = Color.new(123,123,123) #光标指向方格的突出显示颜色
  LIGHT_UP_SPEED = 10 #灯亮起、变暗的速度（帧数）
  LEVELS_CHANGING_SPEED = 40 #每关之间切换的速度（帧数）
  LEVELS_TRANSITION = "Graphics/Transitions/1" # 关卡切换的渐变图形
  
  #内置关卡数据（格式：LEVELS[关卡序号][0-N号点亮方格][0/1]）
  LEVELS = [
    [], #0号 系统保留
    [ [0,1],[1,1],[2,1],[1,0],[1,2] ],
    [ [0,5],[0,6],[1,6],[2,1],[3,1],[3,2],[4,0] ],
    [ [0,4],[0,6],[2,0],[2,6],[4,0],[4,2] ],
    [ [0,0],[0,2],[1,0],[1,2],[3,0],[3,2],[4,0],[4,2] ],
    [ [0,2],[1,1],[2,0],[2,2],[3,3],[4,4],[4,5] ]
    
    ]
    
  #制作者信息
  CREDITS = <<EOS
  
  Nox V1.0
  卫星游戏工作室出品
  谨以此作纪念工作室成立五周年
  网站：http://www.s-gs.net
  
  程序：失落的乐章
  图标素材：Freecons
  制作工具：RPG Maker XP 1.03
  插件脚本：紫苏 ForeverZer0 EngShun
  
EOS

end
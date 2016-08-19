#==============================================================================
# ■ Title
#------------------------------------------------------------------------------
# 　游戏的标题界面。
#==============================================================================

class Title
  include NConst
  def initialize(columns = 2,rows = 3)
    @columns = columns
    @rows = rows
    @size = WIDTH / columns
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    $cursor.visible = true
    @pointed = nil #光标指向的方格
    #初始化棋盘
    @board = Array.new(@columns).collect { [] } #二维数组，形如 @board[3][4] 即
      #坐标为（3，4），从左上角起第4纵列，第5横行。
    (0...@columns).each do |column|
      (0...@rows).each do |row|
        @temp = Light.new(column,row)
        @temp.x = column * @size
        @temp.y = row * @size
        @temp.z = 2
        @temp.bitmap = Bitmap.new(@size,@size)
        @temp.bitmap.fill_rect(@temp.bitmap.rect.x + GAP,
                               @temp.bitmap.rect.y + GAP,
                               @size - 2 * GAP,
                               @size - 2 * GAP,
                               LIGHT_COLOR_OFF)
        @board[column][row] = @temp
      end
    end
    #生成高亮标记（在标题画面下仅有一格）
    @point = Sprite.new
    @point.bitmap = Bitmap.new(@size,@size)
    @point.bitmap.fill_rect(@point.bitmap.rect.x,
                            @point.bitmap.rect.y,
                            @size,
                            @size,
                            POINTED_COLOR)
    #生成选项图标
    @new = Sprite.new
    @new.bitmap = RPG::Cache.picture("new.png")
    @new.z = 3
    @new.ox = @new.bitmap.width / 2
    @new.oy = @new.bitmap.height / 2
    @new.x = @size / 2
    @new.y = @size / 2
    @select = Sprite.new
    @select.bitmap = RPG::Cache.picture("select.png")
    @select.z = 3
    @select.ox = @select.bitmap.width / 2
    @select.oy = @select.bitmap.height / 2
    @select.x = @size + @size / 2
    @select.y = @size / 2
    @open = Sprite.new
    @open.bitmap = RPG::Cache.picture("open.png")
    @open.z = 3
    @open.ox = @open.bitmap.width / 2
    @open.oy = @open.bitmap.height / 2
    @open.x = @size / 2
    @open.y = @size + @size / 2
    @create = Sprite.new
    @create.bitmap = RPG::Cache.picture("create.png")
    @create.z = 3
    @create.ox = @create.bitmap.width / 2
    @create.oy = @create.bitmap.height / 2
    @create.x = @size + @size / 2
    @create.y = @size + @size / 2
    @credits = Sprite.new
    @credits.bitmap = RPG::Cache.picture("credits.png")
    @credits.z = 3
    @credits.ox = @credits.bitmap.width / 2
    @credits.oy = @credits.bitmap.height / 2
    @credits.x = @size / 2
    @credits.y = @size * 2 + @size / 2
    @exit = Sprite.new
    @exit.bitmap = RPG::Cache.picture("exit.png")
    @exit.z = 3
    @exit.ox = @exit.bitmap.width / 2
    @exit.oy = @exit.bitmap.height / 2
    @exit.x = @size + @size / 2
    @exit.y = @size * 2 + @size / 2
    Graphics.transition
    loop do #主循环
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    @point.bitmap.dispose
    @point.dispose
    @new.bitmap.dispose
    @new.dispose
    @select.bitmap.dispose
    @select.dispose
    @open.bitmap.dispose
    @open.dispose
    @create.bitmap.dispose
    @create.dispose
    @credits.bitmap.dispose
    @credits.dispose
    @exit.bitmap.dispose
    @exit.dispose
    @board.flatten.each do |light|
      light.bitmap.dispose
      light.dispose
    end

  end
  
  def command_new_game
    $scene = Nox.new({:level => 1})
  end
  
  def command_select_levels
    $scene = Scene_Name.new(0)
  end
  
  def command_read_data
    Mouse.show_system_cursor #暂时恢复系统鼠标
    sleep 0.1 #有时光标不能正常恢复显示，加上这句似乎能解决（？）
    data = Win32API.new('Rpg.NET.dll', 'OpenFileDlg', 'p', 'p').call("Lumos File|*.lumos")
    sleep 0.1
    Mouse.hide_system_cursor
    $scene = Nox.new({:load_file => data}) unless data == ''
  end
  
  def command_create_mode
    $scene = Lumos.new
  end
  
  def command_credits
    print CREDITS
  end
  
  def command_exit
    $scene = nil
  end
  
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    #依据鼠标位置刷新高亮方块坐标
    mx,my = Mouse.pos
    @point.x,@point.y = (mx / @size) * @size, (my / @size) * @size
    @pointed = [mx / @size,my / @size]
    #若鼠标单击则切换灯的开关状态
    if Mouse.trigger?
      # 防止点击越界
      if mx > @columns * @size || my > @rows * @size || mx <= 0 || my <= 0
        return
      end
      light = @board[@pointed[0]][@pointed[1]]
      light.switch
      Graphics.freeze #准备渐变
      light.bitmap.fill_rect(light.bitmap.rect.x + GAP,
                             light.bitmap.rect.y + GAP,
                             @size - 2 * GAP,
                             @size - 2 * GAP,
                             light.on? ? LIGHT_COLOR_ON : LIGHT_COLOR_OFF)
      Graphics.transition(LIGHT_UP_SPEED) #进行渐变
      if @board[@pointed[0]][@pointed[1]].on?
        case @pointed
        when [0,0] #开始新游戏
          command_new_game
        when [1,0] #选择自带关卡
          command_select_levels
        when [0,1] #读取外部关卡
          command_read_data
        when [1,1] #编辑模式
          command_create_mode
        when [0,2] #制作信息
          command_credits
        when [1,2] #退出游戏
          command_exit
        end
      end  
    end
  end
end
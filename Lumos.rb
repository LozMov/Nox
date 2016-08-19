#==============================================================================
# ■ Lumos（荧光闪烁！）
#------------------------------------------------------------------------------
# 　关卡编辑界面。
#==============================================================================

class Lumos
  include NConst
  def initialize(columns = COLUMNS,rows = ROWS)
    @columns = columns
    @rows = rows
    @size = WIDTH / columns
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
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
    #生成高亮标记（在编辑模式下仅有一格）
    @point = Sprite.new
    @point.bitmap = Bitmap.new(@size,@size)
    @point.bitmap.fill_rect(@point.bitmap.rect.x,
                            @point.bitmap.rect.y,
                            @size,
                            @size,
                            POINTED_COLOR)
    #生成底部信息区
    @info_rect = Sprite.new
    @info_rect.z = 8
    @info_rect.x = 0
    @info_rect.y = HEIGHT - INFO_RECT_HEIGHT
    @info_rect.bitmap = Bitmap.new(WIDTH,INFO_RECT_HEIGHT)
    @info_rect.bitmap.fill_rect(@info_rect.bitmap.rect.x,
                                @info_rect.bitmap.rect.y,
                                WIDTH,
                                INFO_RECT_HEIGHT,
                                INFO_RECT_COLOR)
    #生成底部信息文字
    text = "S:测试并保存当前数据"
    @info = Sprite.new
    @info.z = 9
    @info.bitmap = Bitmap.new(WIDTH,40)
    #@info.bitmap.font.name = "Arial"
    @info.bitmap.font.size = 26
    @info.x = 0
    @info.y = HEIGHT - INFO_RECT_HEIGHT
    @info.bitmap.font.color = INFO_TEXT_COLOR
    @info.bitmap.draw_text(@info.bitmap.rect, text, 1)
    
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
    @board.flatten.each { |light| light.bitmap.dispose ; light.dispose }
    [@point,@info_rect,@info,@temp].each { |i| i.bitmap.dispose ; i.dispose }
  end
    
  def save(file_name)
    new_level = []
    #存储灯的开启数据
    @board.flatten.each do |light|
      new_level << [light.column,light.row] if light.on?
    end
    #存储其余数据
    new_level << [@columns,@rows] << "Editor's name"
    
    File.open("#{file_name}.lumos","w+b") do |file|
      file.write Marshal.dump(new_level)
    end
    
  end
  
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    if Input.trigger?(Input::Y) #保存(S)
      #临时存储（防止重名）
      $file_index = 0
      $file_index += 1 while File.exist?("#{$file_index}.lumos")
      save($file_index.to_s)
      $scene = Nox.new({:test => true, :load_file => "#{$file_index}.lumos" })
      #$scene = Scene_Name.new
    end
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
    end
  end
end
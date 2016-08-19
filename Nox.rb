#==============================================================================
# ■ Nox
#------------------------------------------------------------------------------
# 　游戏界面。
#==============================================================================

class Nox
  include NConst
  def initialize(arg = {})
    @level = arg[:level]
    @test = arg[:test]
    load_file = arg[:load_file]
    @columns = COLUMNS
    @rows = ROWS
    @size = WIDTH / @columns
    if load_file #指定了关卡文件的情况下
      raise "找不到文件 #{load_file}." unless File.exist? load_file
      File.open(load_file,"rb") do |file|
        @data = Marshal.load(file)
        @creator = @data.pop
        @columns,@rows = @data.pop
      end
      @load_file = true
      @level = "N/A"
    else
      @data = LEVELS[@level]
    end
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @step  = 0 #初始化步数
    @score = 0 #初始化得分
    @pointed = nil #光标指向的方格
    #初始化棋盘
    @board = Array.new(@columns).collect { [] } #二维数组，形如 @board[3][4] 即
      #坐标为（3，4），从左上角起第4纵列，第5横行。
    arrange(@data)
    #生成高亮标记（形如十字）
    #中
    @point_m = Sprite.new
    @point_m.bitmap = Bitmap.new(@size,@size)
    @point_m.bitmap.fill_rect(@point_m.bitmap.rect.x,
                              @point_m.bitmap.rect.y,
                              @size,
                              @size,
                              POINTED_COLOR)
    #左
    @point_l = Sprite.new
    @point_l.bitmap = Bitmap.new(@size,@size)
    @point_l.bitmap.fill_rect(@point_m.bitmap.rect.x,
                            @point_m.bitmap.rect.y,
                            @size,
                            @size,
                            POINTED_COLOR)
    #右
    @point_r = Sprite.new
    @point_r.bitmap = Bitmap.new(@size,@size)
    @point_r.bitmap.fill_rect(@point_r.bitmap.rect.x,
                            @point_r.bitmap.rect.y,
                            @size,
                            @size,
                            POINTED_COLOR)
    #上
    @point_u = Sprite.new
    @point_u.bitmap = Bitmap.new(@size,@size)
    @point_u.bitmap.fill_rect(@point_u.bitmap.rect.x,
                            @point_u.bitmap.rect.y,
                            @size,
                            @size,
                            POINTED_COLOR)
    #下
    @point_d = Sprite.new
    @point_d.bitmap = Bitmap.new(@size,@size)
    @point_d.bitmap.fill_rect(@point_d.bitmap.rect.x,
                            @point_d.bitmap.rect.y,
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
    text = "Level:#{@level}  Step:#{@step}"
    @info = Sprite.new
    @info.z = 9
    @info.bitmap = Bitmap.new(WIDTH,40)
    @info.bitmap.font.name = "Arial"
    @info.bitmap.font.size = 32
    @info.x = 0
    @info.y = HEIGHT - INFO_RECT_HEIGHT
    @info.bitmap.font.color = INFO_TEXT_COLOR
    @info.bitmap.draw_text(@info.bitmap.rect, text, 1)

    Graphics.transition(LEVELS_CHANGING_SPEED,LEVELS_TRANSITION)
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
    [@point_m,@point_l,@point_r,@point_u,@point_d,@info_rect,
    @info,@temp].each { |i| i.bitmap.dispose ; i.dispose }

  end
  
  def arrange(data) #按照预先设定的关卡数据排布棋局
    (0...@columns).each do |column|
      (0...@rows).each do |row|
        @temp = Light.new(column,row)
        @temp.switch if data.include?([column,row])
        @temp.x = column * @size
        @temp.y = row * @size
        @temp.z = 2
        @temp.bitmap = Bitmap.new(@size,@size)
        @temp.bitmap.fill_rect(@temp.bitmap.rect.x + GAP,
                               @temp.bitmap.rect.y + GAP,
                               @size - 2 * GAP,
                               @size - 2 * GAP,
                               @temp.on? ? LIGHT_COLOR_ON : LIGHT_COLOR_OFF)
        @board[column][row] = @temp
      end
    end
  end
  
  def all_off? #判断是否所有灯都处于关闭状态
    all = @board.flatten
    all.delete_if { |i| i.on? == false }
    all.empty?
  end
  
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    #依据鼠标位置刷新高亮方块坐标
    mx,my = Mouse.pos
    @point_m.x,@point_m.y = (mx / @size) * @size, (my / @size) * @size
    @point_l.x,@point_l.y = (mx / @size) * @size - @size, (my / @size) * @size
    @point_r.x,@point_r.y = (mx / @size) * @size + @size, (my / @size) * @size
    @point_u.x,@point_u.y = (mx / @size) * @size, (my / @size) * @size - @size
    @point_d.x,@point_d.y = (mx / @size) * @size, (my / @size) * @size + @size
    @pointed = [mx / @size,my / @size]
    #若鼠标单击则切换灯的开关状态
    if Mouse.trigger?
      # 防止点击越界
      if mx > @columns * @size || my > @rows * @size || mx <= 0 || my <= 0
        return
      end
      changed = Array.new
      c,r = @pointed
      @board[c][r].switch
      changed << @board[c][r]
      unless r == @rows - 1
        @board[c][r+1].switch
        changed << @board[c][r+1]
      end
      unless r == 0
        @board[c][r-1].switch
        changed << @board[c][r-1]
      end
      unless c == @columns - 1
        @board[c+1][r].switch
        changed << @board[c+1][r]
      end
      unless c == 0
        @board[c-1][r].switch
        changed << @board[c-1][r]
      end
      #刷新画面
      Graphics.freeze #准备渐变
      changed.each do |light|
        light.bitmap.fill_rect(light.bitmap.rect.x + GAP,
                               light.bitmap.rect.y + GAP,
                               @size - 2 * GAP,
                               @size - 2 * GAP,
                               light.on? ? LIGHT_COLOR_ON : LIGHT_COLOR_OFF)
      end
      Graphics.transition(LIGHT_UP_SPEED) #进行渐变
      #刷新底部数据
      @step += 1
      text = "Level:#{@level}  Step:#{@step}"
      @info.bitmap.clear
      @info.bitmap.draw_text(@info.bitmap.rect, text, 1)
      #过关判定
      if all_off?
        Graphics.freeze #准备渐变

        @board.flatten.each { |light| light.bitmap.dispose ; light.dispose }
        if @test #测试模式下进入保存界面；载入模式下返回标题；否则进入下一关
          $scene = Scene_Name.new(1)
        elsif @load_file
          print "恭喜通关！"
          $scene = Title.new
        else
          if @level == LEVELS.size - 1 #是否已经全通
            print "恭喜通关！"
            $scene = Title.new
          else
            @step = 0 #步数统计归零
            @level += 1
            text = "Level:#{@level}  Step:#{@step}"
            @info.bitmap.clear
            @info.bitmap.draw_text(@info.bitmap.rect, text, 1)
            arrange(LEVELS[@level])
          end
        end
          #进行渐变
          Graphics.transition(LEVELS_CHANGING_SPEED,LEVELS_TRANSITION)
      end
    end
  end
end
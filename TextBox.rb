#==============================================================================
# ■ TextBox by 英顺的马甲
#------------------------------------------------------------------------------
# 　输入框的类。为适用于游戏而做了部分修改。
#   原版：http://rm.66rpg.com/thread-243422-1-1.html
#==============================================================================

class TextBox
  #--------------------------------------------------------------------------
  # ● 设置API
  #--------------------------------------------------------------------------
  CreateWindow = Win32API.new('user32','CreateWindowEx','lpplllllllll','l')
  ShowWindow = Win32API.new('user32','ShowWindow','ll','l')
  DestroyWindow = Win32API.new('user32','DestroyWindow','l','l')
  GetWindowText = Win32API.new('user32','GetWindowText','lpl','l')
  SetWindowText = Win32API.new("user32", "SetWindowText", "lp", "l")
  GetWindowTextLength = Win32API.new('user32','GetWindowTextLength','l','l')
  UpdateWindow = Win32API.new('user32','UpdateWindow','l','i')
  SetFocus = Win32API.new('user32','SetFocus','l','l')
  SendMessage = Win32API.new('user32','SendMessage','llll','l')
  MultiByteToWideChar = Win32API.new('kernel32', 'MultiByteToWideChar', 'ilpipi', 'i')
  WideCharToMultiByte = Win32API.new('kernel32', 'WideCharToMultiByte', 'ilpipipp', 'i')
  GetKeyState = Win32API.new("user32","GetAsyncKeyState",'I','I')
  HWND = Win32API.new('user33', 'GetHWND', 'v', 'i').call
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :focus
  #--------------------------------------------------------------------------
  # ● 初始化
  #--------------------------------------------------------------------------
  def initialize(text = "",limit = 8,number=false)
    c = 0x40011000
    c = (c|0x00001000) if number
    
    @window = CreateWindow.call(0, 'EDIT', u2s(text), c, 0, 480-22, 640, 22, HWND, 0, 0, 0)
    SendMessage.call(@window,0xC5,limit,0)
    @focus = true
    @disposed = false
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    @disposed = true
    DestroyWindow.call(@window)
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def update
    return if !@focus or @disposed
    UpdateWindow.call(@window)
    SetFocus.call(@window)
  end
  #--------------------------------------------------------------------------
  # ● 获取内容
  #--------------------------------------------------------------------------
  def text
    return if @disposed
    l = GetWindowTextLength.call(@window)
    str = "\0" * (l + 1)
    GetWindowText.call(@window, str, l+1)
    return s2u(str.delete("\0"))
  end
  #--------------------------------------------------------------------------
  # ● 更改内容
  #--------------------------------------------------------------------------
  def text=(str)
    SetWindowText.call(@window, u2s(str))
    return if @disposed
  end
  #--------------------------------------------------------------------------
  # ● 获取光标位置
  #--------------------------------------------------------------------------
  def sel_pos
    return if @disposed
    return (SendMessage.call(@window,0xB0,0,0) % 65535) / 2
  end
  #--------------------------------------------------------------------------
  # ● 设置光标位置
  #--------------------------------------------------------------------------
  def sel_pos=(i)
    return if @disposed
    SendMessage.call(@window,0xB1,i,i)
  end
  #--------------------------------------------------------------------------
  # ● 获取光标位置
  #--------------------------------------------------------------------------
  def limit
    return if @disposed
    return SendMessage.call(@window,0xD5,0,0)
  end
  #--------------------------------------------------------------------------
  # ● 设置光标位置
  #--------------------------------------------------------------------------
  def limit=(i)
    return if @disposed
    SendMessage.call(@window,0xC5,i,0)
  end
  #--------------------------------------------------------------------------
  # ● 是否按下回车键
  #--------------------------------------------------------------------------
  def press_enter?
    return if @disposed
    return (@focus and (GetKeyState.call(13) != 0))
  end
  #--------------------------------------------------------------------------
  # ● 转码：系统转UTF-8
  #--------------------------------------------------------------------------
  def s2u(text)
    len = MultiByteToWideChar.call(0, 0, text, -1, nil, 0);
    buf = "\0" * (len*2)
    MultiByteToWideChar.call(0, 0, text, -1, buf, buf.size/2);
    len = WideCharToMultiByte.call(65001, 0, buf, -1, nil, 0, nil, nil);
    ret = "\0" * len
    WideCharToMultiByte.call(65001, 0, buf, -1, ret, ret.size, nil, nil);
    return ret.delete("\000")
  end
  #--------------------------------------------------------------------------
  # ● 转码：UTF-8转系统
  #--------------------------------------------------------------------------
  def u2s(text)
    len = MultiByteToWideChar.call(65001, 0, text, -1, nil, 0);
    buf = "\0" * (len*2)
    MultiByteToWideChar.call(65001, 0, text, -1, buf, buf.size/2);
    len = WideCharToMultiByte.call(0, 0, buf, -1, nil, 0, nil, nil);
    ret = "\0" * len
    WideCharToMultiByte.call(0, 0, buf, -1, ret, ret.size, nil, nil);
    return ret.delete("\000")
  end
  private :u2s ,:s2u # 定义私有功能
end

#==============================================================================
# ■ Sprite_TextBox  by EngShun
#------------------------------------------------------------------------------
# 　显示输入框用的活动块。
#==============================================================================

class Sprite_TextBox < Sprite
  #--------------------------------------------------------------------------
  # ● 设置缓存的类
  #--------------------------------------------------------------------------
  Cache = Struct.new(:bc ,:fc ,:fs ,:text ,:sel_pos)
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  attr_accessor :textbox
  attr_accessor :back_color
  #--------------------------------------------------------------------------
  # ● 初始化
  #--------------------------------------------------------------------------
  def initialize(x = 0,y = 0,w = 128,h = 32,bc = Color.new(255,255,255),fc = Color.new(0,0,0),tb = TextBox.new)
    super(nil)
    self.x = x
    self.y = y
    self.bitmap = Bitmap.new(w,h)
    self.bitmap.font.color = fc
    @back_color = bc
    @textbox = tb
    @cache = Cache.new
    refresh
  end
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def update
    super
    return unless @textbox.focus
    @textbox.update
    if (self.bitmap.font.color != @cache.fc) or
       (self.bitmap.font.size != @cache.fs) or
       (@textbox.sel_pos != @cache.sel_pos) or
       (@textbox.text != @cache.text) or
       (@back_color != @cache.bc)
      refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    @textbox.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● 内容刷新
  #--------------------------------------------------------------------------
  def refresh
    @cache.fc = self.bitmap.font.color
    @cache.fs = self.bitmap.font.size
    @cache.sel_pos = @textbox.sel_pos
    @cache.text = @textbox.text
    @cache.bc = @back_color
    w = self.bitmap.width
    h = self.bitmap.height
    self.bitmap.fill_rect(0,0,w,h,@back_color)
    self.bitmap.draw_text(4,0,w-4,h,@textbox.text)
    t = @textbox.text.scan(/./)[0,@textbox.sel_pos].join("")
    s = self.bitmap.text_size(t).width
    self.bitmap.draw_text((4 + s)-16,0,32,h,"|",1)
  end
  private :refresh # 设置私有功能
end

#==============================================================================
# ■ Window_Base
#------------------------------------------------------------------------------
# 　游戏中全部窗口的超级类。
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● 初始化对像
  #     x      : 窗口的 X 坐标
  #     y      : 窗口的 Y 坐标
  #     width  : 窗口的宽
  #     height : 窗口的高
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super()
    @windowskin_name = "skinblack"
    self.windowskin = RPG::Cache.windowskin(@windowskin_name)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.z = 100
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    # 如果窗口的内容已经被设置就被释放
    if self.contents != nil
      self.contents.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    super
    # 如果窗口的外观被变更了、再设置
    if $game_system.windowskin_name != @windowskin_name
      @windowskin_name = $game_system.windowskin_name
      self.windowskin = RPG::Cache.windowskin(@windowskin_name)
    end
  end
end

#==============================================================================
# ■ Scene_Name
#------------------------------------------------------------------------------
# 　处理名称输入画面的类。
#==============================================================================

class Scene_Name
  def initialize(type = 0) #0：选关 1：编辑文件名
    @type = type
    @text = type == 0 ? "选择关卡(1-#{NConst::LEVELS.size-1})" : "请输入文件名："
  end
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    @window = Window_Base.new(0,200,400,128)
    @window.contents = Bitmap.new(380,96)
    @window.contents.draw_text(0,0,480,32,@text)
    @sprite_tb = Sprite_TextBox.new(30,250,350)
    @sprite_tb.z = 500
    @sprite_tb.textbox.limit = 500
    @sprite_tb.textbox.text = $cons==nil ? "" : $cons
    @sprite_tb.textbox.sel_pos = $cons==nil ? "".length : $cons.length
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    Graphics.freeze
    @sprite_tb.dispose
    @window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 刷新画面
  #--------------------------------------------------------------------------
  def update
    @sprite_tb.update
    $scene = Title.new if @type == 0 && Input.trigger?(Input::B)
    if @sprite_tb.textbox.press_enter?
      if @type == 0
        #检查参数范围
        i = @sprite_tb.textbox.text.to_i
        if (1...(NConst::LEVELS.size)).include? i
          $scene = Nox.new({:level => i})
        else
          @sprite_tb.textbox.text = ""
          return
        end
      elsif @type == 1 #重命名文件
        File.rename($file_index.to_s + ".lumos",@sprite_tb.textbox.text + ".lumos")
        $scene = Title.new
      end
    end
  end
end
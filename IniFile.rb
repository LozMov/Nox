#==============================================================================
# ■ IniFile
#------------------------------------------------------------------------------
# 　提供简单的INI文件读写功能。
#------------------------------------------------------------------------------
# 　作者：失落的乐章
# 　来源：https://www.s-gs.net/ini_script
#==============================================================================

class IniFile
  def initialize(file)
    @file = file
  end
  
  def [](app)
    IniKey.new(@file, app.to_s)
  end
end

class IniKey
  WriteString = Win32API.new('kernel32', 'WritePrivateProfileString', 'pppp', 'l')
  GetString = Win32API.new('kernel32', 'GetPrivateProfileString', 'pppplp', 'l')
  
  def initialize(file, app)
    @file = file
    @app = app
  end
  
  def [](key, default = "", size = 64)
    buff = "\0" * size
    GetString.call(@app, key.to_s, default, buff, size, @file)
    return buff.delete("\0")
  end
  
  def []=(key, value)
    WriteString.call(@app, key.to_s, value.to_s, @file)
  end
end
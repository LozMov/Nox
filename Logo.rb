#==============================================================================
# ■ Logo
#------------------------------------------------------------------------------
# 　用于在游戏开头展示工作室标志。
#==============================================================================

class Logo
  #--------------------------------------------------------------------------
  # ● 主处理
  #--------------------------------------------------------------------------
  def main
    # 生成游戏结束图形
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.picture("Logo.png")
    # 执行过渡
    Graphics.transition(20)
    40.times do 
      Graphics.update
      Input.update
      break if Input.trigger?(Input::C)
    end
    $scene = Title.new
    # 准备过渡
    Graphics.freeze
    # 释放图形
    @sprite.bitmap.dispose
    @sprite.dispose
    # 执行过度
    Graphics.transition(20)
    # 准备过渡
    Graphics.freeze
    $cursor.visible = true
  end
end
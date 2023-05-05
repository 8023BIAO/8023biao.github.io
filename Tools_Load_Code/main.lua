import "res.config.func"--功能封装函数
import "res/config/func2"--功能封装函数
import "res/config/func3"--功能封装函数
import "res/config/func4"--功能封装函数
import "res/config/func5"--功能封装函数
import"res/config/fun_api"--网络api功能
import "android.widget.ArrayExpandableListAdapter"
import "android.widget.ExpandableListView"
import "android.widget.ScrollView"


NameData={} -- 储存函数事件表

local 分类表={"助手","程序","工具","网络","其他"}

local 内容表={
  {
    {name="代码手册", func=function() activity.newActivity("res/module/manual") end};
    {name="布局助手", func=function() activity.newActivity("res/module/Layout_Assistant") end};
    {name="java api", func=function() 储存权限检测(function() activity.newActivity("res/module/api") end) end};
  } ;
  {
    {name="exec", func=function() Rexexc() end};
    {name="运行Lua代码", func=function()
        储存权限检测(function()
          activity.newActivity("res/module/manual/edit",{"运行Lua代码","",true})
        end)
    end};
  } ;
  {

    {name="尺子", func=function() activity.newActivity("res/lua/rule")end};
    {name="RC4", func=function() RC4加解密() end};
    {name="HSV色板",func=function()
        import "com.rarepebble.colorpicker.ColorDialog"
        --默认选中颜色,背景,边框,棋盘格
        local dia = ColorDialog.init(this,0xffffffff,0xFF3A3A69,0xFF000000,0xff34badb).
        addOnColorListener{
          onColor=function(color)
          end
        }.
        setButton1("关闭",{onColorClick=function(dia,colorview)
            dia.dismiss()
          end
        })

        .setButton2("复制",{onColorClick=function(dia,colorview)
            提示(colorview.getHexColor())
            复制文本(colorview.getHexColor())
            dia.dismiss()
          end
        })
        --setButton3....
        dia.show()
    end};
    {name="进制转换", func=function() dec2hex() end};
    {name="图片取色", func=function()
        储存权限检测(function()
          activity.newActivity("res/lua/BitmapGetColor")
        end)
    end};
    {name="屏幕文字", func=function() activity.newActivity("res/lua/pmtext")end};
    {name="简易画板", func=function()
        储存权限检测(function()
          activity.newActivity("res/lua/DrawingBoard")
        end)
    end};
    {name="空文件清理", func=function()
        储存权限检测(function()
          路径净化()
        end)
    end};
    {name="TTS语音播报",func=function()
        TTS语音播报()
    end};
    {name="视频提取音频", func=function()
        储存权限检测(function()
          视频转音频()
        end)
    end};
    {name="纯色图片生成", func=function()
        储存权限检测(function()
          纯色生成()
        end)
    end};
    {name="特殊文字生成",func=function() 特殊文字()end};

    {name="App转位&提取", func=function()
        储存权限检测(function()
          app_x()
        end)
    end};
    {name="图片base64互转", func=function()
        储存权限检测(function()
          图片base64()
        end)
    end};

  } ;
  {
    {name="追番",func=function()追番()end},
    {name="翻译", func=function()文字翻译() end};
    {name="ping", func=function() ping1() end};
    {name="get/post", func=function() get_post() end};
    {name="二维码生成",func=function()储存权限检测(function() 二维码生成()end) end},
    {name="B站视频详情",func=function()B站视频详情() end},
  };
  {
    {name="设置", func=function() 设置() end};
  } ;
}

local mAdapter=ArrayExpandableListAdapter(activity)

for k,v in ipairs(分类表) do
  local items_table = {}
  for i=1, #内容表[k] do
    table.insert(items_table, 内容表[k][i].name)
    NameData[内容表[k][i].name] = 内容表[k][i].func
  end
  mAdapter.add(v, items_table)
end

local el=ExpandableListView(activity)
el.dividerHeight=0
el.setAdapter(mAdapter)
el.setOverScrollMode(ScrollView.OVER_SCROLL_NEVER);
el.textStyle="bold";

activity.setTitle("Tools")
activity.setContentView(el)

--点击
el.onChildClick=function(l,v,p,i)
  local name=v.text
  for n,v in pairs(NameData) do
    if name==n then
      try
        v()
       catch(e)
        提示(e)
      end
    end
  end
end

function onCreateOptionsMenu(menu)
  menu.add("搜索").setShowAsActionFlags(1)
end

function onOptionsItemSelected(item)
  local t=item.getTitle()
  if t=="搜索" then
    搜索()
  end
end

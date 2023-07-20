import "android.app.AlertDialog"
import "android.net.Uri"
import "android.os.*"
import "android.widget.*"
import "com.androlua.*"
import "java.lang.*"
import "java.util.*"
import "java.io.*"
import "android.view.*"
import "android.provider.Settings"
import "android.graphics.Color"
import "android.content.res.Configuration"
import "android.content.Context"
import "android.content.Intent"
import "android.util.DisplayMetrics"
import "android.text.format.Formatter"
import "android.app.Dialog"
import "android.Manifest"
import "android.app.DownloadManager"
import "android.webkit.WebSettings"
import "android.content.pm.PackageManager"
import "android.graphics.Bitmap"


--[[
 biao 个人(辣鸡)快捷封装函数库

代码来源:
百度,chatgpt,cnds,各大QQ群(友)
Alua手册重制版(烧风),muk手册,夜色未央lua手册


感谢开源 开源万岁 2023.7.20
https://8023biao.github.io/lua/mod.lua
]]


----------------------------基本配置-------------------------------
function 设置主题()
  -- 获取 Android 系统版本号
  local version = tonumber(Build.VERSION.SDK_INT)

  if (version == nil) then
    -- 如果版本号无效，则使用默认主题
    activity.setTheme(android.R.style.Theme)
    return
  end

  if (version >= 29) then -- 大等于安卓10
    xpcall(function()
      -- 获取系统当前主题
      local uiMode = tonumber(activity.getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK)

      if (uiMode == Configuration.UI_MODE_NIGHT_NO) then -- 浅色主题
        activity.setTheme(android.R.style.Theme_DeviceDefault_Light)
        activity.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR)
        -- 设置状态栏颜色为浅色
       elseif (uiMode == Configuration.UI_MODE_NIGHT_YES) then -- 暗黑主题
        activity.setTheme(android.R.style.Theme_DeviceDefault)
       else -- 未知主题
        activity.setTheme(android.R.style.Theme)
      end
      end, function(e)
      activity.setTheme(android.R.style.Theme)
      -- 发生错误时，使用默认主题
      error("Failed to set theme: " .. e)
    end)
   elseif (version >= 21) and version < 29 then -- 大等于安卓5小于安卓10
    activity.setTheme(android.R.style.Theme_DeviceDefault)
   elseif (version < 21) then -- 小于安卓5
    xpcall(function()
      activity.setTheme(android.R.style.Theme_Black)
      end, function()
      activity.setTheme(android.R.style.Theme)
      -- 发生错误时，使用默认主题
      error("Failed to set theme")
    end)
  end
end

function 隐藏ActionBar图标()
  activity.getActionBar().setDisplayShowHomeEnabled(false)
end

function 去除ActionBar()
  if activity.ActionBar then
    activity.ActionBar.hide()
  end
end


----------------------------基本函数封装-------------------------------

function 自动主题()
  -- 设置自动主题
  local version = tonumber(Build.VERSION.SDK_INT)
  if (version >= 29) then--大等于安卓10
    xpcall(function()
      --import "android.content.res.Configuration"
      local uiMode = tonumber(activity.getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK)
      if (uiMode) == 16 then--浅色
        return(android.R.style.Theme_DeviceDefault_Light)
       elseif (uiMode) == 32 then--暗黑
        return(android.R.style.Theme_DeviceDefault)
      end
      end,function(e)
      return(android.R.style.Theme_Material_NoActionBar)
    end)
   elseif (version >= 21) and version < 29 then --大等于安卓5小于安卓10
    return(android.R.style.Theme_DeviceDefault_NoActionBar)
   elseif (version < 21) then --小于安卓5
    xpcall(function()
      return(android.R.style.Theme_Black_NoTitleBar)
      end,function()
      return(android.R.style.Theme)--默认主题
    end)
  end
end

function mDialog(t,b,fun,z)--自定义对话框
  local dlg=Dialog(activity,自动主题())

  if z then
    dlg.getWindow().setSoftInputMode(0x10)
  end

  if t then
    dlg.setTitle(t)
  end

  if b then
    dlg.setContentView(loadlayout(b))
  end

  dlg.show()

  if fun then
    fun()
  end

end

function 提示(t)
  Toast.makeText(activity,tostring(t),Toast.LENGTH_SHORT).show()
end

function 对话框(标题,内容,布局,按钮1,按钮2,按钮3,强制,消失事件)
  local ab=AlertDialog.Builder(this)

  if 标题 then
    ab.setTitle(tostring(标题))
  end

  if 内容 then
    ab.setMessage(tostring(内容))
  end

  if 布局 then
    ab.setView(loadlayout(布局))--设置自定义视图
  end

  if 按钮1 then
    ab.setPositiveButton(按钮1[1],{onClick=function(v) 按钮1[2]() end})
  end

  if 按钮2 then
    ab.setNeutralButton(按钮2[1],{onClick=function(v) 按钮2[2]() end})
  end

  if 按钮3 then
    ab.setNegativeButton(按钮3[1],{onClick=function(v) 按钮3[2]() end})
  end

  if 强制 then
    ab.setCancelable(false)
  end

  if 消失事件 then
    -- 设置 OnDismissListener，以监听 AlertDialog 是否消失
    ab.setOnDismissListener({
      onDismiss=function(dialog)
        -- 在 AlertDialog 消失时执行的操作
        消失事件()
      end
    })

  end

  ab.show()

end

function 路径是否存在(path)
  return File(path).exists()
end

--也可以创建文件夹
function 创建文件(路径)
  local f=File(tostring(File(tostring(路径)).getParentFile())).mkdirs()
  io.open(路径,'w')
end

function 读取文件(路径)
  local 文件内容=io.open(路径):read("*a")
  return 文件内容
end

--注意是重新写入
function 写入文件(路径,内容)
  local f=File(tostring(File(tostring(路径)).getParentFile())).mkdirs()
  io.open(tostring(路径),"w+b"):write(tostring(内容)):close()
end

function 续写文件(路径,内容)
  local f=File(tostring(File(tostring(路径)).getParentFile())).mkdirs()
  io.open(路径,"w"):write(内容):close()
end

function 写入缓存(name,str)
  return this.setSharedData(name,str)
end

function 读取缓存(name)
  return this.getSharedData(name)
end

function dp2px(dpValue)
  local scale = activity.getResources().getDisplayMetrics().scaledDensity
  return dpValue * scale + 0.5
end

function px2dp(pxValue)
  local scale = activity.getResources().getDisplayMetrics().scaledDensity
  return pxValue / scale + 0.5
end

function px2sp(pxValue)
  local scale = activity.getResources().getDisplayMetrics().scaledDensity;
  return pxValue / scale + 0.5
end

function sp2px(spValue)
  local scale = activity.getResources().getDisplayMetrics().scaledDensity
  return spValue * scale + 0.5
end

function 申请悬浮窗权限()
  local intent=Intent()
  intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
  intent.setData(Uri.parse("package:" .. activity.getPackageName()));
  activity.startActivity(Intent(intent))
end

function 申请储存权限()
  local intent=Intent()
  intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
  intent.setData(Uri.parse("package:".. activity.getPackageName()));
  activity.startActivity(Intent(intent))
end

function 屏幕高()
  local dm = DisplayMetrics();
  activity.getWindowManager().getDefaultDisplay().getRealMetrics(dm);

  local a = dm.widthPixels;
  local b = dm.heightPixels;
  if tonumber(a)>tonumber(b) then
    b=a
   else
    b=b
  end
  return tonumber(b)
end

function 屏幕宽()
  local dm = DisplayMetrics();
  activity.getWindowManager().getDefaultDisplay().getRealMetrics(dm);

  local a = dm.widthPixels;
  local b = dm.heightPixels;
  if tonumber(a)>tonumber(b) then
    a=b
   else
    a=a
  end
  return tonumber(a)
end

function 浏览器打开(pageurl)
  pcall(function()
    local viewIntent = Intent("android.intent.action.VIEW",Uri.parse(pageurl))
    activity.startActivity(viewIntent)
  end)
end

function 文件下载(url,path,name)
  --调用系统下载
  local downloadManager=activity.getSystemService(Context.DOWNLOAD_SERVICE);
  url=Uri.parse(url);
  local request=DownloadManager.Request(url);
  request.setAllowedNetworkTypes(DownloadManager.Request.NETWORK_MOBILE|DownloadManager.Request.NETWORK_WIFI);
  request.setDestinationInExternalPublicDir(path,name);
  request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
  downloadManager.enqueue(request);
end

function 网络判断(a,b)
  xpcall(function()
    local wl=activity.getApplicationContext().getSystemService(Context.CONNECTIVITY_SERVICE).getActiveNetworkInfo();
    if wl==nil then
      xpcall(function()
        a()
        end,function(e)
        提示(e)
      end)
     else
      if b then
        xpcall(function()
          b()
          end,function(e)
          提示(e)
        end)
      end
    end
    end,function(e)
    提示(e)
  end)
end

function 复制文本(a)
  activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(tostring(a))
end

--点击某一个视图
function 点击视图(view,ti, x, y)
  pcall(function()
    local downTime = SystemClock.uptimeMillis();--系统开机时间
    local downEvent = MotionEvent.obtain(downTime, downTime,MotionEvent.ACTION_DOWN, x, y, 0);
    local upEvent = MotionEvent.obtain(downTime+ti, downTime+ti,MotionEvent.ACTION_UP, x, y, 0);
    view.onTouchEvent(downEvent);--按下
    view.onTouchEvent(upEvent);--抬起
    downEvent,upEvent,downTime=nil
  end)
end
--点击视图(activity.getWindow().getDecorView(),100,50,50)

function mRuntime(code,callback,fun)
  thread(function(code,callback,fun)
    xpcall(function()
      local pro = Runtime.getRuntime().exec(String(code))
      local buf = BufferedReader(InputStreamReader(pro.getInputStream()))
      local e,c

      e=buf.readLine()
      c=pro.waitFor(); --0正常，其他异常

      if (e and c==0 and callback) then
        call(callback,e)
      end

      while (e and c==0 and callback) do
        local dbfr=buf.readLine()
        if dbfr then
          call(callback,dbfr)
         else
          break
        end
      end

      buf.close();

      if fun then
        fun()
      end

      end,function(e)
      --call("提示",e:match(".*ption:(.*)"))
      local s=e:match(".*ption:(.*)")
      call("网络判断",function()
        call("对话框","error",s)
        end,function()
        call("翻译",s,function(c)
          call("对话框","error",s.."\n\n"..c)
        end)
      end)
    end)
  end,code,callback,fun)
end


function ping(ipAddress,ci,callback)
  thread(function(ipAddress,ci,callback)
    local pro = Runtime.getRuntime().exec("ping -c "..ci.." " .. ipAddress)
    local buf = BufferedReader( InputStreamReader(pro.getInputStream()))
    local ege = Runtime.getRuntime().exec("ping -c 3 "..ipAddress)
    local bfo=ege.waitFor(); --0正常，其他异常
    callback(buf.readLine ().." "..bfo)
    while (true) do
      local dbfr=buf.readLine ()
      if dbfr then
        callback(dbfr)
       else
        break
      end
    end
    buf.close();
  end,ipAddress,ci,callback)
end

----------------------------root函数封装-------------------------------

function Rexec(str)
  Runtime.getRuntime().exec(tostring(str))
end

--判断并申请root
function ifRoot()--return bool
  local path="/data/roottest_biao.txt"

  if not (File(path).exists()) then
    local cmd = "touch "..path;
    local process = Runtime.getRuntime().exec("su");
    local os = DataOutputStream(process.getOutputStream());
    os.writeBytes(cmd .."\n");
    os.writeBytes("exit\n");
    os.flush();
    process.waitFor();

    if (File(path).exists()) then
      Runtime.getRuntime().exec("su -c rm -r " .. path)
      if (File(path).exists()) then
        Runtime.getRuntime().exec("rm -r " .. path)
        if (File(path).exists()) then
          return true--第一次获取成功但是不能删除文件，待改进
         else
          return true
        end
       else
        return true
      end
     else
      return false
    end

   else

    Runtime.getRuntime().exec("su -c rm -r " .. path)
    if (File(path).exists()) then
      Runtime.getRuntime().exec("rm -r " .. path)
      if (File(path).exists()) then
        return false--有文件，但是删除不了,说明用户取消授权或者代码不行
       else
        return true
      end
     else
      return true
    end

  end
end

----------------------------其他函数封装-------------------------------


function 翻译(str,cl)
  local systenTime=System.currentTimeMillis();
  local data="from=auto&to=zh-CHS&text="..tostring(str).."&fr=fanyiapp_android_text&index="..systenTime.."&uuid=&requestId="..systenTime.."&isReturnPhonetic=on"
  Http.post("http://fanyi.sogou.com/reventondc/multiLangTranslate",tostring(data),function(code,con)
    if code==200 and con then
      local jieg=con:match([[dit":"(.-)","]])
      cl(jieg)
     else
      cl(str)
    end
  end)
end

function 检测代码(fun)
  xpcall(fun,function(e)
    local s=e
    网络判断(function()
      对话框("错误",s)
      end,function()
      翻译(s,function(c)
        对话框("错误",s.."\n\n"..c)
      end)
    end)
  end)
end

function 权限检测(title,nr,str,fun)
  local pm = activity.getPackageManager();
  --读取
  local permission_readStorage = (PackageManager.PERMISSION_GRANTED ==
  pm.checkPermission(str, activity.getPackageName()));

  if not permission_readStorage then

    对话框(title,nr,nil,{"给予", function()
        local intent=Intent()
        intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.parse("package:".. activity.getPackageName()));
        activity.startActivity(Intent(intent))
    end})

   else
    fun()
  end
end

function 储存权限检测(fun)
  local pm = activity.getPackageManager();
  --读取
  local permission_readStorage = (PackageManager.PERMISSION_GRANTED ==
  pm.checkPermission("android.permission.READ_EXTERNAL_STORAGE", activity.getPackageName()));
  --写入
  local permission_writeStorage = (PackageManager.PERMISSION_GRANTED ==
  pm.checkPermission("android.permission.WRITE_EXTERNAL_STORAGE", activity.getPackageName()));

  if (not(permission_readStorage and permission_writeStorage )) then

    对话框("申请权限","需要储存权限储存文件",nil,{"给予", function()
        local intent=Intent()
        intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.parse("package:".. activity.getPackageName()));
        activity.startActivity(Intent(intent))
    end})

   else
    fun()
  end
end

function 提示文字(title,str,funname,fun)
  str=tostring(str)
  local layout= {
    LinearLayout,
    layout_width="-1",
    layout_height="-1",
    orientation="center",
    {
      ScrollView;
      layout_width="-1";
      layout_weight="1";
      VerticalScrollBarEnabled=false;
      OverScrollMode=2;
      {
        LinearLayout,
        layout_width="-1",
        layout_height="-1",
        orientation="center",
        layout_margin="6dp",
        {
          TextView,
          text=str,
          textSize="16sp",
          layout_width="-1",
          layout_weight="1",
          gravity="center|left",
          layout_marginBottom="2dp",
          textIsSelectable=true,
          padding="10dp"
        };
      };
    };
  };
  if funname and fun then
    对话框(title,nil,layout,{funname,function()fun()end})
   else
    对话框(title,nil,layout)
  end
end

function 对话框浏览器(title,url,UA,屏蔽词表)
  网络判断(function() 提示("无网络") end,function()

    local layout={
      LinearLayout;
      orientation="vertical";
      layout_width="-1";
      layout_height="-1";
      {
        LuaWebView;
        layout_width="-1";
        layout_height="-1";
        id="wv";
        Focusable=true;
        FocusableInTouchMode=true;
      };
    };

    mDialog(title,layout)--自动焦点

    wv.loadUrl(url)
    --设置出现缩放工具
    wv.getSettings().setSupportZoom(true);
    --设置出现缩放工具
    wv.getSettings().setBuiltInZoomControls(true);
    --扩大比例的缩放
    wv.getSettings().setUseWideViewPort(true);
    wv.getSettings().setJavaScriptCanOpenWindowsAutomatically(false)
    wv.requestFocusFromTouch()--设置支持获取手势焦点
    local webSettings = wv.getSettings();
    wv.getSettings().setJavaScriptEnabled(true);
    wv.getSettings().setDisplayZoomControls(false);
    wv.getSettings().setUseWideViewPort(true);
    wv.getSettings().setLoadWithOverviewMode(true);
    wv.getSettings().setJavaScriptEnabled(true);
    wv.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
    wv.getSettings().setAllowFileAccess(true);
    wv.getSettings().setAppCacheEnabled(true);
    wv.getSettings().setDomStorageEnabled(true);
    wv.getSettings().setDatabaseEnabled(true);
    wv.getSettings().setSaveFormData(true);
    wv.getSettings().setLoadsImagesAutomatically(true);
    wv.getSettings().setDefaultTextEncodingName("utf-8");--设置编码格式
    wv.getSettings().setAppCacheEnabled(true)--h5缓存

    if not UA then
      --无广告UA
      local APP_NAME_UA="netdisk;5.2.7;PC;PC-Windows;6.2.9200;WindowsBaiduYunGuanJia"
      local acua="Mozilla/5.0 (Linux; Android 4.2.1; M040 Build/JOP40D) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.59 Mobile Safari/537.36"
      wv.getSettings().setUserAgentString(APP_NAME_UA);
     else
      wv.getSettings().setUserAgentString(UA);
    end

    local function 屏蔽(id,t)
      for c,v pairs(t) do
        local data=[[document.querySelector('.]]..v..[[').style.display="none";]]
        id.loadUrl([[
      javascript:(function()
        { ]]..data..[[ })()
      ]]);
      end
    end

    --web下载监听
    wv.setDownloadListener(function(url)

      local layout= {
        LinearLayout;
        orientation="vertical";
        layout_height="fill";
        layout_width="fill";
        {
          LinearLayout;
          layout_width="fill";

          {
            EditText;
            layout_width="fill";
            --background="0";
            textSize="14sp";
            id="edit2";
            Hint="名称与后缀",
            singleLine=true,
            padding="10dp";
            layout_marginLeft="6dp";
          };

        };
        {
          LinearLayout;
          layout_width="fill";
          {
            EditText;
            layout_width="fill";
            --background="0";
            textSize="14sp";
            id="edit3";
            Hint="绝对网址",
            singleLine=true,
            padding="10dp";
            layout_marginLeft="6dp";
          };
        };
      };

      local func=function()
        if edit2.Text ~="" and edit3.Text~="" then
          文件下载(edit3.Text,"Download",edit2.Text)
          提示("下载在 Download 路径下")
         else
          提示("下载失败")
        end
      end

      对话框("下载",nil,layout,{"下载",function()func()end},{"其他下载",function()
          local i = Intent(Intent.ACTION_VIEW)
          i.data = Uri.parse(url)
          activity. startActivity(i)
      end})

      edit2.setText(string.match(url,".*/(.*)"))
      edit3.setText(url)


    end)--下载监听结束

    --返回交互
    wv.setOnKeyListener(View.OnKeyListener{
      onKey=function (view,keyCode,event)
        if ((keyCode == event.KEYCODE_BACK) and view.canGoBack()) then
          view.goBack();
          return true;
        end
        return false
      end
    })

    --状态监听
    wv.setWebViewClient{
      shouldOverrideUrlLoading=function(view,url)
        --Url即将跳转

      end,
      onPageStarted=function(view,url,favicon)
        --网页加载

      end,
      onPageFinished=function(view,url)
        --网页加载完成
        if 屏蔽词表 then
          屏蔽(view,屏蔽词表)
        end
    end}

  end)

end

function 选择文件(StartPath,callback)
  储存权限检测(function()
    local ls,项目,路径
    --创建ListView作为文件列表
    local lv=ListView(activity).setFastScrollEnabled(true)
    --创建路径标签
    local cp=TextView(activity)
    local lay=LinearLayout(activity).setOrientation(1).addView(cp).addView(lv)
    local ChoiceFile_dialog=AlertDialog.Builder(activity)--创建对话框
    .setTitle("选择文件")
    .setView(lay)
    .show()
    local adp=ArrayAdapter(activity,android.R.layout.simple_list_item_1)
    lv.setAdapter(adp)
    local function SetItem(path)
      path=tostring(path)
      adp.clear()--清空适配器
      cp.Text=tostring(path)--设置当前路径
      if path~="/" then--不是根目录则加上../
        adp.add("../")
      end
      ls=File(path).listFiles()
      if ls~=nil then
        ls=luajava.astable(File(path).listFiles()) --全局文件列表变量
        table.sort(ls,function(a,b)
          return (a.isDirectory()~=b.isDirectory() and a.isDirectory()) or ((a.isDirectory()==b.isDirectory()) and a.Name<b.Name)
        end)
       else
        ls={}
      end
      for index,c in ipairs(ls) do
        if c.isDirectory() then--如果是文件夹则
          adp.add(c.Name.."/")
         else--如果是文件则
          adp.add(c.Name)
        end
      end
    end
    lv.onItemClick=function(l,v,p,s)--列表点击事件
      项目=tostring(v.Text)
      if tostring(cp.Text)=="/" then
        路径=ls[p+1]
       else
        路径=ls[p]
      end

      if 项目=="../" then
        SetItem(File(cp.Text).getParentFile())
       elseif 路径.isDirectory() then
        SetItem(路径)
       elseif 路径.isFile() then
        callback(tostring(路径))
        ChoiceFile_dialog.hide()
      end

    end

    SetItem(StartPath)
  end)
end

--[[
--chatgpt
function dec2hex(dec)
    local b,k,out,i,d=16,"0123456789ABCDEF","",0
    while dec>0 do
        i=i+1
        dec,d=math.floor(dec/b),math.fmod(dec,b)+1
        out=string.sub(k,d,d)..out
    end
    return out
end


function hex_to_dec(hex)
    return tonumber(hex, 16)
end

print(dec2hex(8023))
print(hex_to_dec("1f57"))]]


-- 数字进制转换
---@param num number 十进制数字
---@param hex number 转换的目标进制数（2-16）
---@return string
function Dec2Hex(num,hex)--10进制转2-16
  local hexMap = {0,1,2,3,4,5,6,7,8,9,'A','B',"C",'D','E','F'}
  local v = {}
  local s = math.floor(num / hex)
  local y = num % hex
  table.insert(v,1,y)
  while s >= hex do
    y = s % hex
    table.insert(v,1,y)
    s = math.floor(s / hex)
  end
  table.insert(v,1,s)
  local r = ""
  for _,k in ipairs(v) do
    r = r .. hexMap[k + 1]
  end
  return r
end

function 进制转换(str,num)
  pcall(function()
    local function dec2num (dec,num)--16-2,2-16
      dec=utf8.upper(dec)
      if not dec:match("^%d*$") and (utf8.sub(dec,0,2)=="0X") and type(dec)=="string" and num==16 then
        dec=tostring(tonumber(string.format("0x%06x",dec)))--16to10
      end
      return Dec2Hex(dec,num)
    end

    --str=8023
    --print(string.format("%x",str))--10-16
    --print(tonumber(string.format("0x%06x",str)))--16-10
    --代码来源csdn
    return tostring(dec2num (str,num))--16-2
  end)
end

function SavePicture(name,bm)
  if bm then
    name=tostring(name)
    local f = File(name)
    local out = FileOutputStream(f)
    bm.compress(Bitmap.CompressFormat.PNG,100, out)
    out.flush()
    out.close()
    return true
   else
    return false
  end
end

function 对话框浏览器(title,url,UA,屏蔽词表,删除元素表)
  网络判断(function() 提示("无网络") end,function()

    local layout={
      LinearLayout;
      orientation="vertical";
      layout_width="-1";
      layout_height="-1";
      {
        LuaWebView;
        layout_width="-1";
        layout_height="-1";
        id="wv";
        Focusable=true;
        FocusableInTouchMode=true;
      };
    };

    --对话框(title,nil,layout,{"外部打开",function() 浏览器打开(url) end})--需要获取焦点
    mDialog(title,layout)--自动焦点

    wv.loadUrl(url)
    --设置出现缩放工具
    wv.getSettings().setSupportZoom(true);
    --设置出现缩放工具
    wv.getSettings().setBuiltInZoomControls(true);
    --扩大比例的缩放
    wv.getSettings().setUseWideViewPort(true);
    wv.getSettings().setJavaScriptCanOpenWindowsAutomatically(false)
    wv.requestFocusFromTouch()--设置支持获取手势焦点
    local webSettings = wv.getSettings();
    wv.getSettings().setJavaScriptEnabled(true);
    wv.getSettings().setDisplayZoomControls(false);
    wv.getSettings().setUseWideViewPort(true);
    wv.getSettings().setLoadWithOverviewMode(true);
    wv.getSettings().setJavaScriptEnabled(true);
    wv.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
    wv.getSettings().setAllowFileAccess(true);
    wv.getSettings().setAppCacheEnabled(true);
    wv.getSettings().setDomStorageEnabled(true);
    wv.getSettings().setDatabaseEnabled(true);
    wv.getSettings().setSaveFormData(true);
    wv.getSettings().setLoadsImagesAutomatically(true);
    wv.getSettings().setDefaultTextEncodingName("utf-8");--设置编码格式
    wv.getSettings().setAppCacheEnabled(true)--h5缓存

    if not UA then
      --无广告UA
      local APP_NAME_UA="netdisk;5.2.7;PC;PC-Windows;6.2.9200;WindowsBaiduYunGuanJia"
      local acua="Mozilla/5.0 (Linux; Android 4.2.1; M040 Build/JOP40D) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.59 Mobile Safari/537.36"
      wv.getSettings().setUserAgentString(APP_NAME_UA);
     else
      wv.getSettings().setUserAgentString(UA);
    end

    local function 屏蔽(id,t)
      for c,v ipairs(t) do
        local data=[[document.querySelector('.]]..v..[[').style.display="none";]]
        id.loadUrl([[
      javascript:(function()
        { ]]..data..[[ })()
      ]]);
      end
    end

    --web下载监听
    wv.setDownloadListener(function(url)

      local layout= {
        LinearLayout;
        orientation="vertical";
        layout_height="fill";
        layout_width="fill";
        {
          LinearLayout;
          layout_width="fill";

          {
            EditText;
            layout_width="fill";
            --background="0";
            textSize="14sp";
            id="edit2";
            Hint="名称与后缀",
            singleLine=true,
            padding="10dp";
            layout_marginLeft="6dp";
          };

        };
        {
          LinearLayout;
          layout_width="fill";
          {
            EditText;
            layout_width="fill";
            --background="0";
            textSize="14sp";
            id="edit3";
            Hint="绝对网址",
            singleLine=true,
            padding="10dp";
            layout_marginLeft="6dp";
          };
        };
      };

      local func=function()
        if edit2.Text ~="" and edit3.Text~="" then
          文件下载(edit3.Text,"Download",edit2.Text)
          提示("下载在 Download 路径下")
         else
          提示("下载失败")
        end
      end

      对话框("下载",nil,layout,{"下载",function()func()end},{"其他下载",function()
          local i = Intent(Intent.ACTION_VIEW)
          i.data = Uri.parse(url)
          activity. startActivity(i)
          end},{"复制链接",function()
          复制文本(url)
          提示("已复制链接:\n"..url)
      end})

      edit2.setText(string.match(url,".*/(.*)"))
      edit3.setText(url)


    end)--下载监听结束

    --状态监听
    wv.setWebViewClient{
      shouldOverrideUrlLoading=function(view,url)
        --Url即将跳转

      end,
      onPageStarted=function(view,url,favicon)
        --网页加载

      end,
      onPageFinished=function(view,url)
        --网页加载完成
        if 屏蔽词表 then
          屏蔽(view,屏蔽词表)
        end

    end}

  end)

end

--chatgpt提供
function 表排序(arr)
  -- 定义一个临时变量
  local temp
  -- 循环遍历数组
  for i = 1, #arr do
    for j = i + 1, #arr do
      -- 如果前一个元素比后一个元素大，则交换位置
      if arr[i] > arr[j] then
        temp = arr[i]
        arr[i] = arr[j]
        arr[j] = temp
      end
    end
  end
  -- 返回排序后的数组
  return arr
end

--获取默认的主题背景颜色(--chatgpt提供
function 默认颜色()
  local colorDrawable = activity.getWindow().getDecorView().getBackground();
  local colorCode = colorDrawable.getColor();
  return colorCode
end

function 统计字符(str)
  local len = #str;
  local left = len;
  local cnt = 0;
  local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
  while left ~= 0 do
    local tmp=string.byte(str,-left);
    local i=#arr;
    while arr[i] do
      if tmp>=arr[i] then left=left-i;break
      end
      i=i-1;
    end
    cnt=cnt+1;
  end
  return cnt;
end

function 获取文件最后修改时间(path)
  local f = File(path);
  local cal = Calendar.getInstance();
  local time = f.lastModified()
  cal.setTimeInMillis(time);
  return cal.getTime().toLocaleString()
end

function 获取文件大小(path)
  local size=File(tostring(path)).length()
  local Sizes=Formatter.formatFileSize(activity, size)
  return Sizes
end

--判断路径或者文件夹是否可用读取
function isReadable(path)
  local file = File(path)
  if file.exists() and file.canRead() then
    return true
   else
    return false
  end
end

--lua多线程
function 多线程运行(fun,c)
  thread(function()
    local co = coroutine.create(function()
      call(function()
        xpcall(function()
          if c then
            fun(c)
           else
            fun()
          end
          end,function(e)
          提示(e)
        end)
      end)
    end)
    coroutine.resume(co)
  end)
end

--java ui 多线程
function ui多线程(fun,c)
  activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
    run = function()
      if c then
        fun(c)
       else
        fun()
      end
    end
  }))
end

-- 获取网页源代码
function getHtml(url)
  import "java.io.BufferedReader"
  import "java.io.InputStreamReader"
  import "java.net.URL"
  url = URL(url)
  local connection = url.openConnection()
  connection.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3")
  local reader = BufferedReader(InputStreamReader(connection.getInputStream()))
  local html = ""
  local line = reader.readLine()
  while line do
    html = html .. line.."\n"
    line = reader.readLine()
  end
  return html
end

function timestamp_to_time(timestamp)
  local date = os.date("*t", timestamp)
  local year = date.year
  local month = date.month
  local day = date.day
  local hour = date.hour
  local minute = date.min
  local second = date.sec
  local current_time = os.time()
  local current_date = os.date("*t", current_time)
  local current_year = current_date.year
  local current_month = current_date.month
  local current_day = current_date.day
  local current_hour = current_date.hour
  local current_minute = current_date.min
  local current_second = current_date.sec
  local time_diff = current_time - timestamp
  if time_diff < 60 then
    return "刚刚"
   elseif time_diff < 3600 then
    return math.floor(time_diff / 60) .. "分钟前"
   elseif time_diff < 86400 then
    return math.floor(time_diff / 3600) .. "小时前"
   elseif time_diff < 2592000 then
    return math.floor(time_diff / 86400) .. "天前"
   else
    return string.format("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)
  end
end

function 检测代码(fun,fun2)
  return xpcall(fun,function(e)
    local s=e
    网络判断(function()
      提示文字("错误",s)
      if fun2 then
        fun2()
      end
      return false
      end,function()
      翻译(s,function(c)
        提示文字("错误",s.."\n\n"..c)
      end)
      if fun2 then
        fun2()
      end
    end)
  end)
end


function getFileMD5(filePath)
  import "java.io.File"
  import "java.security.MessageDigest"
  import "java.io.FileInputStream"
  local file = File(filePath)
  if not file.exists() or not file.isFile() then
    --print("文件不存在或不是一个文件")
    return nil
  end

  local digest = MessageDigest.getInstance("MD5")
  local fis = FileInputStream(file)
  local buffer = byte[8192]
  local bytesRead = -1

  repeat
    bytesRead = fis.read(buffer)
    if bytesRead > 0 then
      digest.update(buffer, 0, bytesRead)
    end
  until bytesRead == -1

  fis.close()

  local md5Bytes = digest.digest()
  local md5Str = ""

  for i = 0, #md5Bytes-1 do
    local hex = string.format("%02x", md5Bytes[i] & 0xFF)
    md5Str = md5Str .. hex
  end
  return md5Str
end


function getFileSHA1(filePath)
  import "java.io.File"
  import "java.security.MessageDigest"
  import "java.io.FileInputStream"
  local file = File(filePath)
  if not file.exists() or not file.isFile() then
    --print("文件不存在或不是一个文件")
    return nil
  end

  local digest = MessageDigest.getInstance("SHA-1")
  local fis = FileInputStream(file)
  local buffer = byte[8192]
  local bytesRead = -1

  repeat
    bytesRead = fis.read(buffer)
    if bytesRead > 0 then
      digest.update(buffer, 0, bytesRead)
    end
  until bytesRead == -1

  fis.close()

  local sha1Bytes = digest.digest()
  local sha1Str = ""

  for i = 0, #sha1Bytes-1 do
    local hex = string.format("%02x", sha1Bytes[i] & 0xFF)
    sha1Str = sha1Str .. hex
  end

  return sha1Str
end

function getFileSHA256(filePath)
  import "java.io.File"
  import "java.security.MessageDigest"
  import "java.io.FileInputStream"
  local file = File(filePath)
  if not file.exists() or not file.isFile() then
    --print("文件不存在或不是一个文件")
    return nil
  end

  local digest = MessageDigest.getInstance("SHA-256")
  local fis = FileInputStream(file)
  local buffer = byte[8192]
  local bytesRead = -1

  repeat
    bytesRead = fis.read(buffer)
    if bytesRead > 0 then
      digest.update(buffer, 0, bytesRead)
    end
  until bytesRead == -1

  fis.close()

  local sha1Bytes = digest.digest()
  local sha1Str = ""

  for i = 0, #sha1Bytes-1 do
    local hex = string.format("%02x", sha1Bytes[i] & 0xFF)
    sha1Str = sha1Str .. hex
  end

  return sha1Str
end

function getFileCRC32(filePath)
  import "java.io.File"
  import "java.io.FileInputStream"
  import "java.util.zip.CRC32"
  local file = File(filePath)
  if not file.exists() or not file.isFile() then
    --print("文件不存在或不是一个文件")
    return nil
  end

  local crc32 = CRC32()
  local fis = FileInputStream(file)
  local buffer = byte[8192]
  local bytesRead = -1

  repeat
    bytesRead = fis.read(buffer)
    if bytesRead > 0 then
      crc32.update(buffer, 0, bytesRead)
    end
  until bytesRead == -1

  fis.close()

  local crc32Value = crc32.getValue()
  local crc32Str = string.format("%08x", crc32Value)

  return crc32Str
end

--获取公网ip地址
function getPublicIPAddress()
  import "java.io.BufferedReader"
  import "java.io.InputStreamReader"
  import "java.net.URL"
  local publicIpAddress = ""
  xpcall(function()
    local url = URL("https://api.ipify.org/")
    local connection = url.openConnection()
    local inputStream = InputStreamReader(connection.getInputStream())
    local bufferedReader = BufferedReader(inputStream)
    publicIpAddress = bufferedReader.readLine()
    bufferedReader.close()
    end,function (e)
    publicIpAddress = "无法获取公网IP地址"
  end)
  return publicIpAddress
end


function 系统下载监听(链接,目录名,文件名,下载完成事件)
  -- 导入包
  import "android.content.Context"
  import "android.net.Uri"
  import "android.content.IntentFilter"
  import "android.content.BroadcastReceiver"
  import "android.app.DownloadManager"
  import "android.widget.Toast"
  -- 创建广播接收器
  local receiver = BroadcastReceiver{
    onReceive = function(context, intent)
      local action = intent.getAction()
      if action == DownloadManager.ACTION_DOWNLOAD_COMPLETE then
        -- 下载完成，弹出提示-也可以在这个地方加入下载提示音等，具体自己灵活操作使用。
        Toast.makeText(context, "下载完成", Toast.LENGTH_SHORT).show()
        if 下载完成事件 then
          下载完成事件()
        end
      end
    end
  }
  -- 注册广播接收器
  local filter = IntentFilter()
  filter.addAction(DownloadManager.ACTION_DOWNLOAD_COMPLETE)
  activity.registerReceiver(receiver, filter)
  -- 获取DownloadManager
  local downloadManager = activity.getSystemService(Context.DOWNLOAD_SERVICE)
  -- 创建下载请求
  local url = Uri.parse(链接)
  local request = DownloadManager.Request(url)
  request.setAllowedNetworkTypes(DownloadManager.Request.NETWORK_MOBILE|DownloadManager.Request.NETWORK_WIFI)
  request.setDestinationInExternalPublicDir(目录名,文件名)
  request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
  -- 将下载请求加入下载队列
  downloadManager.enqueue(request)
end

function 自动更新下载mod文件(path)
  ui多线程(function()
    local url="https://8023biao.github.io/lua/mod.lua"
    local 储存路径=tostring(activity.getLuaDir().. tostring(path))--工程路径下的/mod.lua
    网络判断(function()end,function()
      Http.get(url,function(a,code)
        if a==200 and code then
          if 检测代码(function()return loadstring(code)end) then
            if 路径是否存在(储存路径) then
              if 读取文件(储存路径)~=code then
                写入文件(储存路径,code)
                提示("已更新mod.lua")
              end
             else
              写入文件(储存路径,code)
              提示("已下载mod.lua到工程路径下\n导入使用即可")
            end
          end
        end
      end)
    end)
  end)
end


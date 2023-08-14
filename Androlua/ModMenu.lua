require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

import "android.content.Context"
import "android.view.WindowManager"
import "android.graphics.PixelFormat"
import "android.view.Gravity"
import "android.view.MotionEvent"
import "android.provider.Settings"
import "android.content.res.Configuration"
import "android.net.Uri"
import "android.content.Intent"

local firstX,firstY,isMax,wmX,wmY,Permission
local REQUEST_CODE_OVERLAY_PERMISSION = 1000

local version = tonumber(Build.VERSION.SDK_INT)

if not (version) then
  activity.setTheme(android.R.style.Theme)
end

if (version >= 29) then
  xpcall(function()
    local uiMode = tonumber(activity.getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK)
    if (uiMode == Configuration.UI_MODE_NIGHT_NO) then
      activity.setTheme(android.R.style.Theme_DeviceDefault_Light)
      activity.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR)
     elseif (uiMode == Configuration.UI_MODE_NIGHT_YES) then
      activity.setTheme(android.R.style.Theme_DeviceDefault)
     else
      activity.setTheme(android.R.style.Theme)
    end
    end, function(e)
    activity.setTheme(android.R.style.Theme)
  end)
 elseif (version >= 21) and version < 29 then
  activity.setTheme(android.R.style.Theme_DeviceDefault)
 elseif (version < 21) then
  xpcall(function()
    activity.setTheme(android.R.style.Theme_Black)
    end, function()
    activity.setTheme(android.R.style.Theme)
  end)
end

pcall(function()
  if activity.ActionBar then
    activity.ActionBar.hide()
  end
end)

function toast(str)
  Toast.makeText(activity,tostring(str),Toast.LENGTH_SHORT).show()
end

function ROOT(path)
  local data = activity.getLuaDir().."/files/"
  os.execute("su -c chmod 777 " .. data .. path)
  Runtime.getRuntime().exec("su -c " .. data .. path)
end

function no_ROOT(path)
  local data = activity.getLuaDir().."/files/"
  os.execute("chmod 777 " .. data .. path)
  Runtime.getRuntime().exec(data .. path)
end

function execute(a)
  if Permission then
    ROOT(a)
   else
    no_ROOT(a)
  end
end

function Rexec(str)
  if Permission then
    Runtime.getRuntime().exec(tostring("su -c "..str))
   else
    Runtime.getRuntime().exec(tostring(str))
  end
end

function icon()
  local appInfo = activity.getApplicationInfo();
  local icon=appInfo.loadIcon(activity.getPackageManager());
  return icon
end

local minlay={
  LinearLayout,
  layout_width="-2",
  layout_height="-2",
  {
    ImageView;
    layout_width="36dp";
    layout_height="36dp";
    id="Win_minWindow",
  };
}

local layout = {
  LinearLayout;
  layout_width="-2";
  layout_height="-2";
  {
    CardView;
    CardElevation="0";
    backgroundColor="0xff868686";
    layout_height="-2";
    radius="50";
    layout_width="-2";
    {
      CardView;
      CardElevation="0";
      layout_height="-2";
      radius="50";
      layout_width="-2";
      layout_margin="1dp";
      {
        LinearLayout;
        orientation="vertical";
        layout_width="-2";
        layout_height="-2";
        {
          LinearLayout;
          layout_width="-1";          
          layout_height="36dp";          
          {
            LinearLayout;
            layout_gravity="center";
            layout_width="-2";
            layout_height="-2";
            {
              TextView;
              layout_margin="8dp";
              layout_marginLeft="8dp";
              layout_width="26dp";
              Text="―";
              gravity="center";
              onClick="changeWindow";
              textSize="14sp";
            };
          };
          {
            LinearLayout;
            layout_weight="1";
            layout_height="-1";
            id="win_move";
          };
          {
            LinearLayout;
            layout_gravity="center";
            layout_width="-2";
            layout_height="-2";
            {
              TextView;
              layout_margin="8dp";
              layout_marginRight="8dp";
              textSize="14sp";
              Text="╳";
              gravity="center";
              onClick="win_remove";
              layout_width="26dp";
            };
          };
        };
        {
          ScrollView;
          layout_marginBottom="8dp";
          layout_marginLeft="8dp";
          layout_height="-2";
          layout_marginTop="2dp";
          layout_marginRight="8dp";
          layout_width="-2";
          VerticalScrollBarEnabled=false;
          {
            LinearLayout;
            layout_height="-1";
            gravity="center";
            id="Lin";
            layout_width="-1";
            orientation="vertical";
            {
              Switch;
              text="Func1";
              id="Switch_1";
              gravity="center";
              textSize="14sp";
            };
            {
              Switch;
              layout_marginTop="8dp";
              id="Switch_2";
              textSize="14sp";
              text="Func2";
            };
            {
              Switch;
              layout_marginTop="8dp";
              id="Switch_3";
              textSize="14sp";
              text="Func3";
            };
          };
        };
      };
    };
  };
};

local mainWindow=loadlayout(layout)
local minWindow=loadlayout(minlay)

_G["Win_minWindow"].setImageDrawable(icon())

local wmManager=activity.getSystemService(Context.WINDOW_SERVICE)
local wmParams =WindowManager.LayoutParams()

if tonumber(Build.VERSION.SDK) >= 26 then
  wmParams.type =WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
 else
  wmParams.type =WindowManager.LayoutParams.TYPE_SYSTEM_ALERT
end

wmParams.format =PixelFormat.RGBA_8888
wmParams.flags=WindowManager.LayoutParams().FLAG_NOT_FOCUSABLE|WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN
wmParams.gravity = Gravity.LEFT| Gravity.TOP
wmParams.width =WindowManager.LayoutParams.WRAP_CONTENT
wmParams.height =WindowManager.LayoutParams.WRAP_CONTENT
wmParams.x = 0
wmParams.y = 0
wmParams.alpha = 0.5;

function showWindow()
  isMax=false
  wmManager.addView(mainWindow,wmParams)
end

function start()
  if Build.VERSION.SDK_INT >= 23 and Settings.canDrawOverlays(this)~=true then
    local intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
    intent.setData(Uri.parse("package:" .. activity.getPackageName()))
    activity.startActivityForResult(intent, REQUEST_CODE_OVERLAY_PERMISSION)
   else
    Permission=os.execute("su")
    showWindow()
    task(500,function()
      local home=Intent(Intent.ACTION_MAIN);
      home.addCategory(Intent.CATEGORY_HOME);
      activity.startActivity(home);
    end)
  end
end

function closes(v)
  isMax=false
  wmManager.removeView(mainWindow,wmParams)
end

function win_remove()
  pcall(function()
    if not(isMax) then
      wmManager.removeView(mainWindow)
     else
      wmManager.removeView(minWindow)
    end
    activity.finish()
  end)
end

function changeWindow()
  if isMax==true then
    isMax=false
    wmManager.removeView(minWindow)
    wmManager.addView(mainWindow,wmParams)
   else
    isMax=true
    wmManager.removeView(mainWindow)
    wmManager.addView(minWindow,wmParams)
  end
end

function Win_minWindow.onClick(v)
  changeWindow()
end

function Win_minWindow.OnTouchListener(v,event)
  if event.getAction()==MotionEvent.ACTION_DOWN then
    firstX=event.getRawX()
    firstY=event.getRawY()
    wmX=wmParams.x
    wmY=wmParams.y
   elseif event.getAction()==MotionEvent.ACTION_MOVE then
    wmParams.x=wmX+(event.getRawX()-firstX)
    wmParams.y=wmY+(event.getRawY()-firstY)
    wmManager.updateViewLayout(minWindow,wmParams)
   elseif event.getAction()==MotionEvent.ACTION_UP then

  end
  return false
end

function win_move.OnTouchListener(v,event)
  if event.getAction()==MotionEvent.ACTION_DOWN then
    firstX=event.getRawX()
    firstY=event.getRawY()
    wmX=wmParams.x
    wmY=wmParams.y
   elseif event.getAction()==MotionEvent.ACTION_MOVE then
    wmParams.x=wmX+(event.getRawX()-firstX)
    wmParams.y=wmY+(event.getRawY()-firstY)
    wmManager.updateViewLayout(mainWindow,wmParams)
   elseif event.getAction()==MotionEvent.ACTION_UP then
  end
  return true
end

for i=1,_G["Lin"].getChildCount() do
  _G["Switch_"..i].OnCheckedChangeListener=function(view,boolean)
    switch i
     case 1;
      if boolean then
        --execute("gm3d")
       else
        --Rexec("killall gm3d")
      end
     case 2;
      if boolean then

       else

      end
     case 3;
      if boolean then

       else
        toast("Can't close")
        view.setChecked(true)
      end
    end
  end
end

function onPermissionResult(requestCode, resultCode, data)
  if requestCode == REQUEST_CODE_OVERLAY_PERMISSION then
    if resultCode == Activity.RESULT_OK then
      start()
     else
      start()
    end
  end
end

function onActivityResult(requestCode, resultCode, data)
  if requestCode == REQUEST_CODE_OVERLAY_PERMISSION then
    onPermissionResult(requestCode, resultCode, data)
  end
end

function onDestroy()
  win_remove()
  activity.finish()
end

function onCreate()
  xpcall(start,start)
end

local lastclick=0
function onKeyDown(code,event)
  if string.find(tostring(event),"KEYCODE_BACK") ~= nil then
    if lastclick+2 > tonumber(os.time()) then
      win_remove()
      activity.finish()
     else
      Toast.makeText(activity,"Press again to exit",Toast.LENGTH_SHORT).show()
      lastclick=tonumber(os.time())
    end
    return true
  end
end


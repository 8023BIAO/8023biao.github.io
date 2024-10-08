
import "android.webkit.WebSettings"

--local url = "http://x4jdm.top/"
local url = "https://bing.com/"

local wv=LuaWebView(activity)
wv.setBackgroundColor(0xff000000);

--删除加载
wv.removeView(wv.getChildAt(0))

--初始化,加载网页
wv.loadUrl(url)
--设置出现缩放工具
wv.getSettings().setSupportZoom(true);
--设置出现缩放工具
wv.getSettings().setBuiltInZoomControls(true);
--扩大比例的缩放
wv.getSettings().setUseWideViewPort(true);
--硬件加速
wv.setLayerType(View.LAYER_TYPE_HARDWARE, nil)
--启用混合内容
wv.getSettings().setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW)
--DOM存储
wv.getSettings().setDomStorageEnabled(true)

wv.requestFocusFromTouch()--设置支持获取手势焦点

--支持JS(建议无论如何加上)
--local webSettings = wv.getSettings();
wv.Settings.setJavaScriptEnabled(true);
wv.getSettings().setDisplayZoomControls(false);
wv.getSettings().setUseWideViewPort(true);
wv.getSettings().setLoadWithOverviewMode(true);
wv.getSettings().setJavaScriptEnabled(true);
wv.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
--wv.getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK)
wv.getSettings().setAllowFileAccess(true);
wv.getSettings().setAppCacheEnabled(true);
wv.getSettings().setDomStorageEnabled(true);
wv.getSettings().setDatabaseEnabled(true);
wv.getSettings().setTextZoom(125)
wv.getSettings().setUserAgentString("netdisk;5.2.7;PC;PC-Windows;6.2.9200;WindowsBaiduYunGuanJia");

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

  end,

}

--全屏事件监听
pcall(function()
  import "com.lua.*"
  wv.setWebChromeClient(LuaWebChrome(LuaWebChrome.IWebChrine{
    onShowCustomView=function(view, callback)
      local decorView = activity.getWindow().getDecorView()
      local uiOptions = View.SYSTEM_UI_FLAG_FULLSCREEN
      decorView.setSystemUiVisibility(uiOptions)
      local fullScreenContainer = FrameLayout(activity)
      fullScreenContainer.addView(view, ViewGroup.LayoutParams.MATCH_PARENT)
      activity.setContentView(fullScreenContainer)
    end,
    onHideCustomView=function(view)
      local decorView = activity.getWindow().getDecorView()
      decorView.setSystemUiVisibility(0)
      activity.setContentView(wv)
    end,
  }))
end)

activity.setContentView(wv)
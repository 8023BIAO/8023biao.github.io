--GG sky Custom image quality script

local gg=_G["gg"]

local quality={
  [0]={
    l=896,
    w=400
  },
  [1]={
    l=1040,
    w=464
  },
  [2]={
    l=1040,
    w=464
  },
  [3]={
    l=1216,
    w=544
  }
}

local function modify(address,type,value,freeze,name)
  local tg={}
  tg[1]={}
  tg[1].address = address
  tg[1].flags = type
  tg[1].value = value
  tg[1].freeze = freeze
  if name then
    tg[1].name = name
  end
  gg.addListItems(tg)
  gg.setValues(tg)
end

local function searchNumber(...)
  gg.searchNumber(...)
  local n=gg.getResultsCount()
  if n >0 then
    local table=gg.getResults(tonumber(n))
    table=gg.getValues(table)
    return table
   else
    return false
  end
end

local function Custom_image_quality()
  local list= gg.choice({
    "0格","1格","2格","3格",
  },nil,"现在的画质是?")

  if not list then
    return
  end

  list=list-1

  local _p=gg.prompt({"长:","宽:"},{"1920","1080",},{"number","number"})
  gg.setVisible(false)
  gg.clearResults()
  gg.setRanges(-2080896)
  gg.setConfig(2131427463,102)
  local Search_value=quality[list].l ..";".. quality[list].w .."::9"
  local t=searchNumber(Search_value,16)
  if t then
    local l
    for i=1,#t/2 do
      local v=i%2
      if v~=1 then
        l="宽"
        v=2
       else
        l="长"
      end
      modify(t[i].address,16,_p[v],true,l)
    end
    gg.clearResults()
    gg.alert("自定义成功\n再调一下画质即可生效\n后续想更改请到保存列表查看")
   else
    gg.alert("没有搜索到值\n可能设置错误的画质格\n换其他的试试看")
  end
end

local warn=gg.alert("脚本只修改画质\n无影响其他玩家游戏体验\n因为要修改内存达到效果\n修改后果需自行承担\n由于智商不够，脚本为半自动化","同意","不同意")
if warn and warn==1 then
  Custom_image_quality()
end

--[[
关于我和脚本:
我较笨所以脚本只能这样了，见谅。
本来还想添加自定义帧率的，奈何抓不到定位没办法。
特征码和基址方法都无法定位只能这样写了(我找不到其他方法
脚本不影响其他玩家游戏体验，后续也不会出现影响其他玩家游戏体验的功能(如果我这个猪脑壳抓到的话...)
后续待优化(这句话大概率不会再写sky脚本了，个人太菜了。如果后续有其他功能的话也是开源)

其他:

挂****(你要修改就修改别废话。你不想改也没有人逼你改。不改也可以玩。随便你怎么说，你是对的。)

不会有人拿这个辣鸡脚本去圈钱吧？(不会吧无语脸)
不会有人来喷我吧？(肯定有)

辣鸡东西还放这里开源？(虽然辣鸡但是我要放这里更新啊，不好意思打扰到你了。)

]]
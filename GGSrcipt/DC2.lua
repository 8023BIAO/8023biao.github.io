
--AndroidGame DC2[x32&x64] GGScript
--Game:皇帝成长计划2(DC2)

local gg=_G["gg"]
local _fun={}
local _name={}
local config
local Menu
local Xmod

local TYPE={
  B=gg.TYPE_BYTE,--1
  W=gg.TYPE_WORD,--2
  D=gg.TYPE_DWORD,--4
  X=gg.TYPE_XOR,--8
  F=gg.TYPE_FLOAT,--16
  Q=gg.TYPE_QWORD,--32
  E=gg.TYPE_DOUBLE,--64
  A=gg.TYPE_AUTO,--127
}

local REGION={
  JH=gg.REGION_JAVA_HEAP, -- 2
  CH=gg.REGION_C_HEAP, -- 1
  CA=gg.REGION_C_ALLOC, -- 4
  CD=gg.REGION_C_DATA, -- 8
  CB=gg.REGION_C_BSS, -- 16
  PS=gg.REGION_PPSSPP, -- 262144
  A=gg.REGION_ANONYMOUS, -- 32
  J=gg.REGION_JAVA, --  65536
  S=gg.REGION_STACK, -- 64
  AS=gg.REGION_ASHMEM, -- 524288
  V=gg.REGION_VIDEO, -- 1048576
  O=gg.REGION_OTHER, -- -2080896
  B=gg.REGION_BAD, -- 131072
  XA=gg.REGION_CODE_APP, -- 16384
  XS=gg.REGION_CODE_SYS, -- 32768
}

-----------------------------------------
--Custom function encapsulation
-----------------------------------------

local function dec_to_hex(decimal_num)
  return string.format("%X", decimal_num)
end

function M(str)
  if not Menu and not str then
    Menu=_G["main"]
    Menu()
   elseif Menu and not str then
    Menu()
   elseif str then
    Menu=_G[str]
    Menu()
  end
end

local function func(expression, table)
  for k, v in pairs(table) do
    if expression == k then
      return v
    end
  end
  return nil
end

local function choice(...)
  local _n = {...}
  local _name = {}
  local _fun = {}
  for i = 1, #_n, 2 do
    table.insert(_name, _n[i])
    table.insert(_fun, _n[i + 1])
  end
  local _m = gg.choice(_name)
  local result = func(_m, _fun)
  if result then
    result()
  end
  return _m
end

local function XSGA(...)
  local _tt = {}
  local _t = {...}
  gg.clearResults()
  gg.setRanges(_t[1][3])
  gg.searchNumber(_t[1][1], _t[1][2])
  if gg.getResultCount() >0 then
    gg.refineNumber(_t[1][1], _t[1][2])
    local _r = gg.getResults(gg.getResultCount())
    gg.clearResults()
    if #_r > 0 then
      for i = 2, #_t do
        local _offset_address = {}
        local _offset_flags = {}
        for j = 1, #_r do
          _offset_address[j] = _r[j].address + _t[i][2]
          _offset_flags[j] = {address = _offset_address[j], flags = _t[i][3]}
        end
        local _offset_values = gg.getValues(_offset_flags)
        for j = #_r, 1, -1 do
          if _offset_values[j].value ~= _t[i][1] then
            table.remove(_r, j)
           else
            _tt[dec_to_hex(_r[j].address)] = i - 1
          end
        end
      end
    end
    for k, v in pairs(_tt) do
      if v == #_t - 1 then
        table.insert(_r,k)
      end
    end
    if #_r > 0 then
      return _r
     else
      return nil
    end
  end
end

local function bate_getAddress(config)
  if config then
    for k,v in pairs(config)do
      if type(v)~="table" then
        local t={[1]={
            address = tostring("0x"..v),
            flags = TYPE.D,
        }}
        gg.addListItems(t)
       else
        gg.addListItems({v})
      end
    end
  end
end

-----------------------------------------
--Compatible function
-----------------------------------------

local function x32(num)
  if Xmod==true then
    return num*2
   else
    return num
  end
end

local function x64(num)
  if Xmod==true then
    return num
   else
    return num*2
  end
end

local function xmodfiy(num,types,freezes,offset,table)
  xpcall(function()
    for i=1,#table do
      if type(table[i])~="table" then
        local _t={[1]={
            address = tonumber("0x"..table[i])+tonumber(offset),
            flags = types,
            value = num,
            freeze = freezes
        }}
        gg.setValues(_t)
      end
    end
    end,function(e)
    gg.alert(tostring(e))
  end)
end

-----------------------------------------
--Mod Function
-----------------------------------------

local function IFCA()
  local address_list=XSGA(
  {-x64(2), 4, 32},
  {-x64(1), -x32(36), 4},
  {-x64(1), -x32(32), 4},
  {-x64(1), -x32(28), 4},
  {-x64(1), -x32(24), 4},
  {-x64(1), -x32(20), 4},
  {-x64(1), x32(4), 4},
  {-x64(1), x32(8), 4},
  {-x64(1), x32(12), 4})
  if address_list then
    return address_list
   else
    return nil
  end
end

local _data_name = {
  "文学",
  "武术",
  "才艺",
  "道德",
  "体能",
  "年龄",
  "体力",
  "体力上限",
  "健康",
  "快乐",
  "国库",
  "皇威",
  "厨艺",
  "寿命",
  "工匠",
  "建筑工匠",
  "士兵",
  "甲胄",
  "朴刀",
  "战马",
  "火炮",
  "长枪",
  "重甲",
  "弓箭",
  "蒙古战马",
  "明光凯",
  "陌刀",
  "神臂弩",
  "汗血马",
  "弓箭战车",
  "钢刀",
  "链甲",
  "大象",
  "大盾",
  "骆驼",
  "强弓",
  "标枪",
  "钩镶",
  "环首刀",
  "劲弩",
  "长戈",
  "战车",
  "胡服",
  "佛郎机炮",
  "铜剑",
  "余皇",
  "大翼",
  "楼船",
  "虎皮",
  "长戟",
  "匕首",
  "床弩",
  "木牛流马",
  "诸葛连弩",
  "火铳",
  "拍竿",
  "女墙",
  "重楼大舰",
  "密探经费",
  "调查经费",
  "炼药经费",
  "训练度",
}

local function getOffsetTabl()
  local addr_offset = {
    x32(-596),
    x32(-608),
    x32(-600),
    x32(-604),
    x32(-536),
    x32(-592),
    x32(-544),
    x32(-540),
    x32(-556),
    x32(-560),
    x32(-532),
    x32(-584),
    x32(268),
    x32(-552),
    x32(-464),
    x32(-460),
    x32(-472),
    x32(-436),
    x32(-432),
    x32(-428),
    x32(-424),
    x32(-448),
    x32(-444),
    x32(-440),
    x32(-420),
    x32(-416),
    x32(-412),
    x32(-408),
    x32(-404),
    x32(-400),
    x32(-396),
    x32(-392),
    x32(-388),
    x32(-384),
    x32(-380),
    x32(-376),
    x32(-372),
    x32(-368),
    x32(-364),
    x32(-360),
    x32(-356),
    x32(-352),
    x32(-348),
    x32(-344),
    x32(-340),
    x32(-336),
    x32(-332),
    x32(-328),
    x32(-324),
    x32(-320),
    x32(-316),
    x32(-312),
    x32(-308),
    x32(-304),
    x32(-300),
    x32(-296),
    x32(-292),
    x32(-288),
    x32(336),
    x32(-280),
    x32(-236),
    x32(-284),
    x32(-476),
  }
  return addr_offset
end

local function list_modfiy()
  local GFT=getOffsetTabl()
  local address_list=config
  if address_list and #address_list >=1 then
    for i=1,#_data_name do
      table.insert(_name, _data_name[i])
      table.insert(_fun,function()
        local _l=gg.prompt({_data_name[i]..":"},{""},{"number"})
        if _l and not tostring(_l[1]):match("^%s*$") then
          xpcall(function()
            _l[1]=x64(_l[1])
            for j=1,#address_list do
              if type(address_list[j])~="table" then
                local _t={[1]={
                    address = tonumber("0x"..address_list[j])+tonumber(GFT[i]),
                    flags = TYPE.D,
                    value = _l[1],
                }}
                gg.setValues(_t)
              end
            end
            end,function(e)
            gg.alert(e)
          end)
        end
      end)
    end
    return true
   else
    return false
  end
end

local function Option_modification()
  if #_fun>0 and #_name>0 then
    local _name2={}
    for i=15,#_name do
      table.insert(_name2, _data_name[i])
    end
    local _m = gg.choice(_name2)
    if not _m then
      M("main")
     else
      local result = func(tonumber(_m)+14, _fun)
      if result then
        result()
      end
    end
   else
    list_modfiy()
    Option_modification()
  end
end

local function panel_modification()
  if #_fun>0 and #_name>0 then
    local _name2={}
    for i=1,14 do
      table.insert(_name2, _data_name[i])
    end
    local _m = gg.choice(_name2)
    if not _m then
      M("main")
     else
      local result = func(tonumber(_m), _fun)
      if result then
        result()
      end
    end
   else
    list_modfiy()
    panel_modification()
  end
end

local function one_key_modfiy_panel()
  if #_fun>0 and #_name>0 then
    local _t={}
    local GFT=getOffsetTabl()
    for i=1,14 do
      for j=1,#config do
        if type(config[j])~="table" then
          local num
          if i == 6 then
            num = x64(18)
           elseif i == 11 then
            num = x64(999999999)
           elseif i == 12 then
            num = x64(1000)
           else
            num = x64(100)
          end
          table.insert(_t,{
            address = tonumber("0x"..config[j])+tonumber(GFT[i]),
            flags = TYPE.D,
            value = num,
          })
        end
      end
    end
    gg.setValues(_t)
   else
    list_modfiy()
    one_key_modfiy_panel()
  end
end

local function Name_Modfiy()
  gg.setRanges(REGION.A)
  local _p=gg.prompt({"文本:","修改为:"},{"",""},{"text","text"})
  if _p and not _p[1]:match("^%s*$") and not _p[2]:match("^%s*$") then
    local _s=gg.searchNumber(";".._p[1],TYPE.W)
    if _s then
      gg.editAll(";".._p[2],TYPE.W)
      gg.clearResults()
    end
   elseif not _p then
    M("main")
  end
end

-----------------------------------------
--Menu function
-----------------------------------------

function Modify_list()
  Option_modification()
end

function Pane_list()
  panel_modification()
end

function Pane_list2()
  local _m=choice("一键修改",function()
    one_key_modfiy_panel()
    end,"自定义",function()
    M("Pane_list")
  end)
  if not _m then
    M("main")
  end
end

function TimeModify()
  local _m=choice("年",function()
    local _p=gg.prompt({"年份:"},{""},{"number"})
    if _p and _p[1] then
      xmodfiy(x64(_p[1]),TYPE.D,false,x32(-528),config)
    end
  end,
  "月",function()
    local _p=gg.prompt({"月:[0;12]"},{"6"},{"number"})
    if _p and _p[1] then
      xmodfiy(x64(_p[1]),TYPE.D,false,x32(-520),config)
    end
  end,
  "时辰",function()
    local _p=gg.prompt({"时辰(0早,1昼,2晚,3夜):[0;3]"},{""},{"number"})
    if _p and _p[1] then
      xmodfiy(x64(_p[1]),TYPE.D,false,x32(-516),config)
    end
  end)
  if not _m then
    M("main")
  end
end

function main()
  choice(
  "面板修改",function()
    M("Pane_list2")
  end,
  "时间修改",function()
    M("TimeModify")
  end,
  "其他修改",function()
    M("Modify_list")
  end,
  "文本修改",function()
    Name_Modfiy()
  end,
  "调试选项",function()
    choice("添加特征码地址",function()
      bate_getAddress(config)
    end)
  end,
  "关于脚本",function()
    gg.alert([[
       
    兼容:32位&64位
    
    来源(不分先后顺序):
    
    坤坤:2992113240 (提供特征码和功能偏移量)
   
    67:2115906232 (提供交流群以及信息帮助)
    
     ]])
  end,
  "结束脚本",function()
    os.exit()
  end)
end

-----------------------------------------
--Start Code
-----------------------------------------

Xmod=gg.getTargetInfo()["x64"]
config=IFCA()

if config then
  gg.showUiButton()
  M()
  while true do
    if gg.isClickedUiButton() then
      M()
    end
  end
 else
  gg.alert("没有选择游戏进程或其他错误，试试先选择进程再启动脚本？如果还不行请等待更新")
  os.exit()
end
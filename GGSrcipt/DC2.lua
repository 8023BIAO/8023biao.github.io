
-----------------------------------------
--全局变量
-----------------------------------------

local gg=_G["gg"]--个人习惯
local _fun={}----61项列表事件存放
local _name={}--61项列表名字存放
local config--特征码地址表存放
local Menu --储存现在菜单
local Xmod--存放x32&64位变量

--简写类型
local TYPE={
  --字母赋值 gg类型 数字对应
  B=gg.TYPE_BYTE,--1
  W=gg.TYPE_WORD,--2
  D=gg.TYPE_DWORD,--4
  X=gg.TYPE_XOR,--8
  F=gg.TYPE_FLOAT,--16
  Q=gg.TYPE_QWORD,--32
  E=gg.TYPE_DOUBLE,--64
  A=gg.TYPE_AUTO,--127
}

--简写内存
local REGION={
  --字母赋值 gg内存类型 数字对应
  JH=gg.REGION_JAVA_HEAP, --Jh内存 2
  CH=gg.REGION_C_HEAP, --Ch内存 1
  CA=gg.REGION_C_ALLOC, --Ca内存 4
  CD=gg.REGION_C_DATA, --Cd内存 8
  CB=gg.REGION_C_BSS, --Cb内存 16
  PS=gg.REGION_PPSSPP, --PS内存 262144
  A=gg.REGION_ANONYMOUS, --A内存 32
  J=gg.REGION_JAVA, --J内存  65536
  S=gg.REGION_STACK, --S内存 64
  AS=gg.REGION_ASHMEM, --AS内存 524288
  V=gg.REGION_VIDEO, --V内存 1048576
  O=gg.REGION_OTHER, --O内存 -2080896
  B=gg.REGION_BAD, --B内存 131072
  XA=gg.REGION_CODE_APP, --Xa内存 16384
  XS=gg.REGION_CODE_SYS, --Xs内存 32768
}

-----------------------------------------
--函数封装与自定义
-----------------------------------------

--弹窗
local function Alert(...)
  return gg.alert(...)
end

--复制
local function copyText(str)
  gg.copyText(str)
end

--10进制转16进制
local function dec_to_hex(decimal_num)
  return string.format("%X", decimal_num)
end

--设置搜索内存
local function setRanges(...)
  gg.setRanges(...)
end

--修改写入
local function modify(address,type,value,freeze,name)
  local tg={}
  tg[1]={}
  tg[1].address = address--地址
  tg[1].flags = type --类型
  tg[1].value = value --值
  tg[1].freeze = freeze --冻结
  if name then
    tg[1].name = name --自定义名称
  end
  --添加到保存数据
  --gg.addListItems(tg)
  --设置列表
  gg.setValues(tg)
end

--搜索数值
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

--改善数值
local function refineNumber(...)
  gg.refineNumber(...)
  local n=gg.getResultsCount()
  if n >0 then
    local table=gg.getResults(tonumber(n))
    table=gg.getValues(table)
    return table
   else
    return false
  end
end

--个人习惯
local function prompt(...)
  return gg.prompt(...)
end

-- 自定义函数
local function func(expression, table)
  for k, v in pairs(table) do
    if expression == k then
      return v
    end
  end
  return nil
end

--菜单导航
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

-- 自定义 choice
local function choice(...)
  local _n = {...} -- 参数
  local _name = {} -- 名称
  local _fun = {} -- 函数

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

--xs写法获取特征码地址 v1版后续待改进
local function XSGA(...)
  local _tt={}
  local _t={...}
  setRanges(_t[1][3])
  searchNumber(_t[1][1],_t[1][2])
  if gg.getResultCount() ~= 0 then
    refineNumber(_t[1][1],_t[1][2])
    local _n=gg.getResultCount()
    local _r=gg.getResults(_n)
    gg.clearResults()
    if _n~= 0 then
      for i=2,#_t do
        for ii=1,_n do
          if _r[ii] then
            local _offset_address=_r[ii].address + _t[i][2]
            local _offset_value=gg.getValues({[1]={address=_offset_address,flags=_t[i][3]}})[1].value
            if _offset_value ~= _t[i][1] then
              _r[ii]=nil
             else
              _tt[dec_to_hex(_r[ii].address)]=i-1
            end
          end
        end
      end
    end

    for k,v in pairs(_tt)do
      if v==#_t-1 then
        table.insert(_r,k)
      end
    end

    if #_r>0 then
      return _r
     else
      return nil
    end

  end
end

-----------------------------------------
--x32&x64函数封装
-----------------------------------------

--32&64数字自动转换
local function x32(num)
  if Xmod==true then
    return num*2
   else
    return num
  end
end

--32&64数字自动转换
local function x64(num)
  if Xmod==true then
    return num
   else
    return num*2
  end
end

--32&64修改(修改输,类型,冻结,偏移量,特征码基址表 用XAGA函数获取)
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
  end,Alert)
end

-----------------------------------------
--修改功能封装
-----------------------------------------

--初始获取特征码表地址
local function IFCA()
  setRanges(REGION.A)
  gg.clearResults()
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

--坤坤提供代码
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
  "回合",
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
  local address_list=config
  if address_list and #address_list >=1 then
    for i=1,#_data_name do
      table.insert(_name, _data_name[i])
      table.insert(_fun,function()
        local _l=gg.prompt({_data_name[i]..":","冻结"},{"",false},{"number","checkbox"})
        if _l and not tostring(_l[1]):match("^%s*$") then
          xpcall(function()
            _l[1]=x64(_l[1])
            for ii=1,#address_list do
              if type(address_list[ii])~="table" then
                local ty
                if i==11 then--国库改为f类
                  ty=TYPE.F
                 else
                  ty=TYPE.D
                end
                local _t={[1]={
                    address = tonumber("0x"..address_list[ii])+tonumber(getOffsetTabl()[i]),
                    flags = ty,
                    value = _l[1],
                    freeze = _l[2],
                }}
                gg.setValues(_t)
              end
            end
            end,function(e)
            Alert(e)
            --copyText(e)
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
    local _m = gg.choice(_name)
    if not _m then
      M("main")
    end
    local result = func(_m, _fun)
    if result then
      result()
    end
   else
    list_modfiy()
    Option_modification()
  end
end

--修改文本
local function Name_Modfiy()
  setRanges(REGION.A)
  local _p=prompt({"文本:","修改为:"},{"",""},{"text","text"})
  if _p and not _p[1]:match("^%s*$") and not _p[2]:match("^%s*$") then
    local _s=searchNumber(";".._p[1],TYPE.W)
    if _s then
      gg.editAll(";".._p[2],TYPE.W)
      gg.clearResults()
    end
   elseif not _p then
    M("main")
  end
end

local function Childbirth()--下一回合生孩子
  setRanges(REGION.A)
  local _s=searchNumber(x64(97024),TYPE.D)--值bili UID:1831131893
  if _s then
    gg.editAll(x64(2),TYPE.D)
    gg.clearResults()
    Alert("和ta花前月下然后回去睡一觉就行了")
  end
end

-----------------------------------------
--菜单
-----------------------------------------
function Modify_list()
  Option_modification()
end

function TimeModify()
  local _m=choice("年",function()
    local _p=prompt({"年份:","冻结"},{"",false},{"number","checkbox"})
    if _p and _p[1] then
      xmodfiy(x64(_p[1]),TYPE.D,_p[2],x32(-528),config)
    end
  end,
  "月",function()
    local _p=prompt({"月:[0;12]","冻结"},{"5",false},{"number","checkbox"})
    if _p and _p[1] then
      xmodfiy(x64(_p[1]),TYPE.D,_p[2],x32(-520),config)
    end
  end,
  "时辰",function()
    local _p=prompt({"时辰(0早,1昼,2晚,3夜):[0;3]","冻结"},{"",false},{"number","checkbox"})
    if _p and _p[1] then
      xmodfiy(x64(_p[1]),TYPE.D,_p[2],x32(-516),config)
    end
  end)
  if not _m then
    M("main")
  end
end

function other_modfiy()
  local _m=choice("生猴子",function()
    Childbirth()
  end)
  if not _m then
    M("main")
  end
end

function main()
  choice("单项修改",function()
    M("Modify_list")
    end,"时间修改",function()
    M("TimeModify")
  end,
  "文本修改",function()
    Name_Modfiy()
  end,
  "其他修改",function()
    M("other_modfiy")
  end,
  "关于脚本",function()
    Alert([[
       
    兼容:32位&64位(建议使用64位)
    
    感谢(不分先后顺序):
    
    坤坤:2992113240 (提供特征码和功能偏移量)
   
    67:2115906232 (提供交流群以及信息帮助)
    
     ]])
  end,
  "结束脚本",function()
    os.exit()
  end)
end

-----------------------------------------
--启动
-----------------------------------------

Xmod=gg.getTargetInfo()["x64"]--判断位数
config=IFCA()--初始化获取特征码地址

if config then
  gg.showUiButton()
  M()
  while true do
    if gg.isClickedUiButton() then
      M()
    end
  end
 else
  Alert("没有选择游戏进程或其他错误，试试先选择进程再启动脚本？如果还不行请等待更新")
  os.exit()
end

-----------------------------------------
--结束
-----------------------------------------


--[[
请来源注明
复制时请留下67,坤坤来源，你可以不留我的，
但是请注明他们，感谢他们无私奉献。不然你玩个屁，我们都没得玩。

--这个逼游戏我抓特征码抓了一天没抓到，无动态基址可言。无奈最后用了 坤坤 的偏移量和特征码(你肯定说我菜，我承认，我就是一个啥都不会的小白
--67帝成1群。在里面查看了许多修改教程和资料和67帮助

再注明一次:
坤坤:2992113240 (提供特征码和功能偏移量)
67:2115906232 (提供交流群以及信息帮助)

--酒入辅助网已复制，不留来源还改成自己的信息，麻了。(没想到这么狗
--

]]
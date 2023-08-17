
local gg=_G["gg"]

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
  gg.addListItems(tg)
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

-- 自定义函数
local function func(expression, table)
  for k, v in pairs(table) do
    if expression == k then
      return v
    end
  end
  return nil
end

local Menu --储存现在菜单

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

local Xmod

--32&64数字偏移量自动转换
local function xoffset(num)--输入32位数字
  if Xmod==true then
    return num*2
   else
    return num
  end
end

--32&64数字自动转换
local function xnum(num)--输入64位默认值
  if Xmod==true then
    return num
   else
    return num*2
  end
end

-----------------------------------------
--函数封装结束
-----------------------------------------

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
  -- "训练度",
}

local function getOffsetTabl()
  local addr_offset = {
    xoffset(-596),
    xoffset(-608),
    xoffset(-600),
    xoffset(-604),
    xoffset(-536),
    xoffset(-592),
    xoffset(-544),
    xoffset(-540),
    xoffset(-556),
    xoffset(-560),
    xoffset(-532),
    xoffset(-584),
    xoffset(268),
    xoffset(-552),
    xoffset(-464),
    xoffset(-460),
    xoffset(-472),
    xoffset(-436),
    xoffset(-432),
    xoffset(-428),
    xoffset(-424),
    xoffset(-448),
    xoffset(-444),
    xoffset(-440),
    xoffset(-420),
    xoffset(-416),
    xoffset(-412),
    xoffset(-408),
    xoffset(-404),
    xoffset(-400),
    xoffset(-396),
    xoffset(-392),
    xoffset(-388),
    xoffset(-384),
    xoffset(-380),
    xoffset(-376),
    xoffset(-372),
    xoffset(-368),
    xoffset(-364),
    xoffset(-360),
    xoffset(-356),
    xoffset(-352),
    xoffset(-348),
    xoffset(-344),
    xoffset(-340),
    xoffset(-336),
    xoffset(-332),
    xoffset(-328),
    xoffset(-324),
    xoffset(-320),
    xoffset(-316),
    xoffset(-312),
    xoffset(-308),
    xoffset(-304),
    xoffset(-300),
    xoffset(-296),
    xoffset(-292),
    xoffset(-288),
    xoffset(336),
    xoffset(-280),
    xoffset(-236),
    xoffset(-284),
  }
  return addr_offset
end

local _fun={}
local _name={}

local function init()
  setRanges(REGION.A)
  local address_list=XSGA(
  {-xnum(2), 4, 32},
  {-xnum(1), -xoffset(36), 4},
  {-xnum(1), -xoffset(32), 4},
  {-xnum(1), -xoffset(28), 4},
  {-xnum(1), -xoffset(24), 4},
  {-xnum(1), -xoffset(20), 4},
  {-xnum(1), xoffset(4), 4},
  {-xnum(1), xoffset(8), 4},
  {-xnum(1), xoffset(12), 4})

  if address_list and #address_list >=1 then
    for i=1,#_data_name do
      table.insert(_name, _data_name[i])
      table.insert(_fun,function()
        local _l=gg.prompt({_data_name[i]..":","冻结"},{"",false},{"number","checkbox"})
        if _l and not tostring(_l[1]):match("^%s*$") then
          xpcall(function()
            if not Xmod then
              _l[1]=_l[1]*2
            end
            for ii=1,#address_list do
              if type(address_list[ii])~="table" then

                local ty

                if i==11 then
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
  local _m = gg.choice(_name)
  if not _m then
    M("main")
  end
  local result = func(_m, _fun)
  if result then
    result()
  end
end

-----------------------------------------
--自定义功能结束
-----------------------------------------

gg.clearResults()
gg.showUiButton()

Xmod=gg.getTargetInfo()["x64"]
local config=init()

function Modify_list()
  if config then
    Option_modification()
  end
end

function main()
  choice("选项修改",function()
    M("Modify_list")
    end,"关于/帮助",function()
    Alert([[
       
    兼容:32位&64位(建议使用64位)
    
    感谢(不分先后顺序):
    
    坤坤:2992113240 (提供特征码和功能偏移量)
   
    67:2115906232 (提供交流群以及信息帮助)
    
     ]])
  end)
end

if config then
  while true do
    if gg.isClickedUiButton() then
      M()
    end
  end
 else
  Alert("没有选择游戏进程或其他错误，试试先选择进程再启动脚本？如果还不行请等待更新")
end


--[[
已知问题:
XAGA函数感觉太拉胯，又不会其他写法
为什么64位游戏获取特征码基址有两个？没办法两个一起改了。。。。
转32位修改国库闪退了。。。。


其他:我就是一个啥都不会的小白，大佬见笑了
]]
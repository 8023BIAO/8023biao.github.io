
local gg=_G["gg"]
local Menu

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

--类型使用:
--searchNumber， refineNumber， startFuzzy， searchFuzzy，
-- searchAddress， refineAddress， getResults， editAll，
-- removeResults， loadResults， getSelectedResults， setValues，
--getValues， addListItems， getListItems， getSelectedListItems

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

--标志使用:
--setRanges,getRanges

--弹窗
local function Alert(...)
  return gg.alert(...)
end

--提示
local function Toast(str)
  gg.toast(str)
end

--复制
local function copyText(str)
  gg.copyText(str)
end

--编辑所有搜索的数据
local function editAll(...)
  return gg.editAll(...)
end

--16进制转10进制
local function hex_to_dec(hex_str)
  return tonumber(hex_str, 16)
end

--10进制转16进制
local function dec_to_hex(decimal_num)
  return string.format("%X", decimal_num)
end

--获取地址头
local function SoAddr(str)
  return gg.getRangesList(str)[1].start
end

--地址跳跃
local function addrjump(a, b)
  local address = gg.getValues({ [1] = { address = a + b, flags = TYPE.Q } })[1].value
  return address--返回跳转的地址
end

--设置搜索内存
local function setRanges(...)
  gg.setRanges(...)
end

--修改写入
local function modify(address,type,value,freeze)
  local tg={}
  tg[1]={}
  tg[1].address = address--地址
  tg[1].flags = type --类型
  tg[1].value = value --值
  tg[1].freeze = freeze --冻结
  --添加到保存数据
  --gg.addListItems(tg)
  --设置列表
  gg.setValues(tg)
  --清除搜索数据
  --gg.clearResults()
end

--搜索数值
local function searchNumber(...)
  --搜索数值
  gg.searchNumber(...)
  --获取搜索结果数量
  local n=gg.getResultsCount()
  if n >0 then
    --获取全部搜索结果
    local table=gg.getResults(tonumber(n))
    --转成获取值(table)
    table=gg.getValues(table)
    return table
   else
    return false
  end
end

--改善数值
local function refineAddress(...)
  --搜索数值
  gg.refineAddress(...)
  --获取搜索结果数量
  local n=gg.getResultsCount()
  if n >0 then
    --获取全部搜索结果
    local table=gg.getResults(tonumber(n))
    --转成获取值(table)
    table=gg.getValues(table)
    return table
   else
    return false
  end
end

--地址搜索
local function searchAddr(addr,type)
  gg.searchAddress(addr,-1,type, gg.SIGN_EQUAL, 0, -1)
  --获取搜索结果数量
  local n=gg.getResultsCount()
  if n ==1 then
    --获取全部搜索结果
    local table=gg.getResults(tonumber(n))
    --转成获取值(table)
    table=gg.getValues(table)
    return table
   else
    return false
  end
end

--多级偏移获取地址
local function offset(so,...)
  local addr=SoAddr(so)
  local t={...}
  for i=1,#t do
    addr=addrjump(addr,t[i])
  end
  return addr
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

local function XSGA(...) -- 特征码获取地址 v2版(优化搜索速度)
  local _tt = {}
  local _t = {...}
  gg.clearResults()
  gg.setRanges(_t[1][3])
  gg.searchNumber(_t[1][1], _t[1][2])
  if gg.getResultCount() ~= 0 then
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

local function XAM(...)--xs特征码或地址修改数据
  local _t={...}
  local _m={}
  if type(_t[1])=="table" then
    for i=1,#_t[1] do
      if type(_t[1][i])~="table" then
        for ii=2,#_t do
          _m[ii-1]={
            address = tonumber(_t[1][i])+tonumber(_t[ii][2]),
            flags = _t[ii][3],
            value = _t[ii][1],
            freeze = _t[ii][4]
          }
        end
      end
      gg.setValues(_m)
    end
   elseif type(_t[1])=="string" or type(_t[1])=="number" then
    for ii=2,#_t do
      _m[ii-1]={
        address = tonumber(_t[1])+tonumber(_t[ii][2]),
        flags = _t[ii][3],
        value = _t[ii][1],
        freeze = _t[ii][4]
      }
    end
    gg.setValues(_m)
   else
    return nil
  end
end

local function bate_getAddress(config)--调试函数 添加主特征码地址
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
--函数封装结束
-----------------------------------------

--清除搜索数据
gg.clearResults()
--显示按钮
gg.showUiButton()

function main()
  local main_menu= gg.choice({
    "菜单2",
    "Exit",
  })
  if main_menu== 1 then
    M("main2")
   elseif main_menu==2 then
    os.exit()
  end
end

function main2()
  local _m=choice("这个是第二个菜单",function()
    Toast("没有设置事件")
    end,"返回",function()
    M("main")
  end)
  --[[
if not _m then
M("main")
end
]]
end

while true do
  if gg.isClickedUiButton() then
    M()
  end
end
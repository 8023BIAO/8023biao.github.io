
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

-----------------------------------------
--函数封装结束
-----------------------------------------



--清除搜索数据
gg.clearResults()
--显示按钮
gg.showUiButton()

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

function main()
  --菜单显示(GG单选择列表)
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
  --菜单显示(GG单选择列表)
  local main_menu= gg.choice({
    "这个是第二个菜单",
    "返回",
  })
  if main_menu== 1 then
    Alert("点击了第一个按钮")
   elseif main_menu==2 then
    M("main")
  end
end

while true do
  --判断按钮点击和包名
  if gg.isClickedUiButton() then
    if gg.getTargetPackage()=="包名" then
      M()
     else
      Alert("没有选择进程")
    end
  end
end

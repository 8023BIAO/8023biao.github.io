
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

--10&16字符串或数字转16进制
local function num_to_hex(num)
  num=tostring(num)
  num=string.upper(num)
  if not num:match("^[A-F 0-9 X]+$") then
    return nil
  end
  if not num:match("^%d+$") then
    if not num:find("0X") then
      num="0x"..num
    end
  end
  return string.format("0x%X",tonumber(num))
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

local function choice(t)
  local name = {}
  local fun = {}
  for i = 1, #t, 2 do
    name[#name+1] = t[i]
    fun[#fun+1] = t[i + 1]
  end
  local m = gg.choice(name)
  for k, v in pairs(fun) do
    if m == k then
      v()
    end
  end
end

local function loadResults(skip,loadNum,parameter,data)

  local result

  if skip==0 then
    result = gg.getResults(loadNum)
   else
    result = gg.getResults(skip,loadNum)
  end

  for i, v in ipairs(result) do
    v.isUseful = true
  end

  for i = 2, #parameter do
    local offset_table = {}
    local num=parameter[i][1]
    local offset=tonumber(parameter[i][2])
    local flag= parameter[i][3]
    for i, v in ipairs(result) do
      offset_table[#offset_table+1]={
        address = result[i].address + offset,
        flags = flag
      }
    end

    local tmp = gg.getValues(offset_table)

    for i, v in ipairs(tmp) do
      if (v.value ~= num)then
        result[i].isUseful = false
      end
    end

  end

  for i, v in ipairs(result) do
    if (v.isUseful) then
      data[#data+1] = v.address
    end
  end

end

local function getaddress(...)--优化:biao,改至:云云

  local c={...}
  local parameter=c[1]

  if type(parameter)~="table" then
    return
  end

  gg.clearResults()
  gg.setVisible(false)
  gg.setRanges(parameter[1][3])
  gg.searchNumber(parameter[1][1], parameter[1][2])

  local data = {}
  local quantity=gg.getResultCount()

  if quantity== 0 then
    return nil
  end

  local blockSize=9999
  local numBlocks

  if quantity>blockSize then
    numBlocks=math.ceil(quantity/blockSize)
  end

  if numBlocks then
    for blockIndex = 1, numBlocks do
      local startIdx=(blockIndex-1)*blockSize
      local endIdx=math.min(startIdx+blockSize,quantity)
      if blockIndex==numBlocks then
        blockSize=endIdx-startIdx
      end
      loadResults(startIdx,blockSize,parameter,data)
    end
   else
    loadResults(0,blockSize,parameter,data)
  end

  gg.clearResults()

  if (#data > 0) then
    return data
   else
    return nil
  end
end

local function modfiy(address,...)
  if not address or not ... then
    return
  end

  local c,t={...},{}

  if type(address)=="table" then
    if (#address > 0) then
      for i=1, #address do
        for ii=1,#c do
          t[#t+1]={}
          t[#t].address = address[i]+(c[ii][2])
          t[#t].flags = c[ii][3]
          t[#t].value = c[ii][1]
          local n=c[ii][5]
          if n then
            t[#t].name = n
          end
          if c[ii][4] then
            local item = {}
            item[#item+1] = t[#t]
            item[#item].freeze = true
            gg.addListItems(item)
          end
        end
      end
      gg.setValues(t)
      return true
    end

   elseif type(address)=="string" or type(address)=="number" then

    for ii=1,#c do
      t[#t+1]={}
      t[#t].address = tonumber(address)+(c[ii][2])
      t[#t].flags = c[ii][3]
      t[#t].value = c[ii][1]
      local n=c[ii][5]
      if n then
        t[#t].name = n
      end
      if c[ii][4] then
        local item = {}
        item[#item+1] = t[#t]
        item[#item].freeze = true
        gg.addListItems(item)
      end
    end
    gg.setValues(t)
    return true
  end
end

local function m(t,...)
  return xpcall(function(t,...) modfiy(getaddress(t),...) end,function(e) gg.alert(e) end,t,...)
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
  local _m=choice({"这个是第二个菜单",function()
      Toast("没有设置事件")
      end,"返回",function()
      M("main")
  end})
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
  gg.sleep(100)
end
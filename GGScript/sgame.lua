
--简写类型
local TYPE={
  A=gg.TYPE_AUTO,
  F=gg.TYPE_FLOAT,
  D=gg.TYPE_DWORD,
  E=gg.TYPE_DOUBLE,
  B=gg.TYPE_BYTE,
  Q=gg.TYPE_QWORD,
  W=gg.TYPE_WORD
}

--简写内存
local REGION={
  A=gg.REGION_ANONYMOUS,
  CA=gg.REGION_C_ALLOC,
  B=gg.REGION_BAD,
  Xs=gg.REGION_CODE_SYS,
  Xa=gg.REGION_CODE_APP,
  O=gg.REGION_OTHER,
  Ch=gg.REGION_C_HEAP,
  Jh=gg.REGION_JAVA_HEAP,
  J=gg.REGION_JAVA,
  Cd=gg.REGION_C_DATA,
  S=gg.REGION_STACK
}

--提示
local function Toast(str)
  gg.toast(str)
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
  local address = gg.getValues({ [1] = { address = a + b, flags = 32 } })[1].value
  return address--返回跳转的地址
end

--设置搜索内存
local function setRanges(type)
  gg.setRanges(type)
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
  gg.addListItems(tg)
  --设置列表
  gg.setValues(tg)
  --清除搜索数据
  gg.clearResults()
end

--搜索数值
local function searchNumber(value,type)
  --搜索数值
  gg.searchNumber(value,type)
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

--动态基址(搬运
local function S_Pointer(t_So, t_Offset, _bit)
  local function getRanges()
    local ranges = {}
    local tt = {}
    local t = gg.getRangesList('^/data/*.so*$')
    for i in pairs(t) do
      if t[i].type:sub(2, 2) == 'w' then
        if not tt[t[i].internalName] then
          tt[t[i].internalName] = {}
        end
        if not tt[t[i].internalName][t[i].state] then
          tt[t[i].internalName][t[i].state] = 0
        end
        tt[t[i].internalName][t[i].state] = tt[t[i].internalName][t[i].state] + 1
        t[i].So_Count = tt[t[i].internalName][t[i].state]
        table.insert(ranges, t[i])
      end
    end
    return ranges
  end
  local function Get_Address(N_So, Offset, ti_bit)
    local ti = gg.getTargetInfo()
    local S_list = getRanges()
    local t = {}
    local _t
    local _S = nil
    if ti_bit then
      _t = 32
     else
      _t = 4
    end
    for i in pairs(S_list) do
      local _N = S_list[i].internalName:gsub('^.*/', '')
      if N_So[1] == _N and N_So[2] == S_list[i].state and N_So[3] == S_list[i].So_Count then
        _S = S_list[i]
        break
      end
    end
    if _S then
      t[#t + 1] = {}
      t[#t].address = _S.start + Offset[1]
      t[#t].flags = _t
      if #Offset ~= 1 then
        for i = 2, #Offset do
          local S = gg.getValues(t)
          t = {}
          for _ in pairs(S) do
            if not ti.x64 then
              S[_].value = S[_].value & 0xFFFFFFFF
            end
            t[#t + 1] = {}
            t[#t].address = S[_].value + Offset[i]
            t[#t].flags = _t
          end
        end
      end
      _S = t[#t].address
    end
    return _S
  end
  local _A = string.format('0x%X', Get_Address(t_So, t_Offset, _bit))
  return _A
end

--[[local t = {"libunity.so", "Cd", 1}
local tt = { 0x15F58, 0x128, 0x1D0, 0x38, 0x4, 0x20}
local ttt = S_Pointer(t, tt)
gg.setValues({{address = ttt, flags = 4, value = -993,486,475}})
]]

-----------------------------------------
--函数封装结束
-----------------------------------------

--清除搜索数据
gg.clearResults()
--显示按钮
gg.showUiButton()

Vaddr=false--视角地址储存
Menu=false --储存现在菜单

--现在菜单
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

--视角
function view()
  local menu= gg.choice({
    "3D",
    "底下",
    "天上",
    "正常",
    "返回"
  })
  if menu== 1 then
    setRanges(REGION.O)
    local t=searchNumber("1097285734",TYPE.D)
    if t then
      local addr=t[1].address--主地址
      Vaddr=addr
      --高度
      modify(addr,TYPE.F,0.5,true)
      --远近
      modify(addr+dec_to_hex(4),TYPE.F,-5,true)
      --角度
      modify(addr+dec_to_hex(8),TYPE.F,0.1,true)
     else
      if not Vaddr then gg.alert("发生错误了") else
        local addr=Vaddr
        --高度
        modify(addr,TYPE.F,0.5,true)
        --远近
        modify(addr+dec_to_hex(4),TYPE.F,-5,true)
        --角度
        modify(addr+dec_to_hex(8),TYPE.F,0.1,true)
      end
    end

   elseif menu==2 then
    setRanges(REGION.O)
    local t=searchNumber("1097285734",TYPE.D)
    if t then
      local addr=t[1].address--主地址
      Vaddr=addr
      --高度
      modify(addr,TYPE.F,-3,true)
      --远近
      modify(addr+dec_to_hex(4),TYPE.F,-3,true)
      --角度
      modify(addr+dec_to_hex(8),TYPE.F,-0.37,true)
     else
      if not Vaddr then gg.alert("发生错误了") else
        local addr=Vaddr
        --高度
        modify(addr,TYPE.F,-3,true)
        --远近
        modify(addr+dec_to_hex(4),TYPE.F,-30,true)
        --角度
        modify(addr+dec_to_hex(8),TYPE.F,-0.37,true)
      end
    end

   elseif menu==3 then
    setRanges(REGION.O)
    local t=searchNumber("1097285734",TYPE.D)
    if t then
      local addr=t[1].address--主地址
      Vaddr=addr
      --高度
      modify(addr,TYPE.F,37,true)
      --远近
      modify(addr+dec_to_hex(4),TYPE.F,-37,true)
      --角度
      modify(addr+dec_to_hex(8),TYPE.F,0.37,true)
     else
      if not Vaddr then gg.alert("发生错误了") else
        local addr=Vaddr
        --高度
        modify(addr,TYPE.F,30,true)
        --远近
        modify(addr+dec_to_hex(4),TYPE.F,-30,true)
        --角度
        modify(addr+dec_to_hex(8),TYPE.F,0.37,true)
      end
    end

   elseif menu==4 then
    setRanges(REGION.O)
    local t=searchNumber("1097285734",TYPE.D)
    if t then
      local addr=t[1].address--主地址
      Vaddr=addr
      --高度
      modify(addr,TYPE.F,14.45322227478,false)
      --远近
      modify(addr+dec_to_hex(4),TYPE.F,-16.05192565918,false)
      --角度
      modify(addr+dec_to_hex(8),TYPE.F,0.35836800933,false)

     else
      if not Vaddr then gg.alert("发生错误了") else
        local addr=Vaddr
        --高度
        modify(addr,TYPE.F,14.45322227478,false)
        --远近
        modify(addr+dec_to_hex(4),TYPE.F,-16.05192565918,false)
        --角度
        modify(addr+dec_to_hex(8),TYPE.F,0.35836800933,false)
      end
    end
   elseif menu==5 then
    M("main")
  end
end

function main()
  --菜单显示(GG单选择列表)
  local main_menu= gg.choice({
    "视角",
    "Exit",
  })
  if main_menu== 1 then
    M("view")
   elseif main_menu==2 then
    os.exit()
  end
end

while true do
  --判断按钮点击和包名
  if gg.isClickedUiButton() then
    if gg.getTargetPackage()=="com.tencent.tmgp.sgame" then
      M()
     else
      gg.alert("没有选择进程")
    end
  end
end


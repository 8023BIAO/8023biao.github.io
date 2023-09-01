
--GG特征码脚本工具

local Template_code=[[local function loadResults(skip,loadNum,parameter,data) local result if skip==0 then result = gg.getResults(loadNum) else result = gg.getResults(skip,loadNum) end for i, v in ipairs(result) do v.isUseful = true end for i = 2, #parameter do local offset_table = {} local num=parameter[i][1] local offset=tonumber(parameter[i][2]) local flag= parameter[i][3] for i, v in ipairs(result) do offset_table[#offset_table+1]={ address = result[i].address + offset, flags = flag } end local tmp = gg.getValues(offset_table) for i, v in ipairs(tmp) do if (v.value ~= num)then result[i].isUseful = false end end end for i, v in ipairs(result) do if (v.isUseful) then data[#data+1] = v.address end end end local function getaddress(...) local c={...} local parameter=c[1] if type(parameter)~="table" then return end gg.clearResults() gg.setVisible(false) gg.setRanges(parameter[1][3]) gg.searchNumber(parameter[1][1], parameter[1][2]) local data = {} local quantity=gg.getResultCount() if quantity== 0 then return nil end local blockSize=9999 local numBlocks if quantity>blockSize then numBlocks=math.ceil(quantity/blockSize) end if numBlocks then for blockIndex = 1, numBlocks do local startIdx=(blockIndex-1)*blockSize local endIdx=math.min(startIdx+blockSize,quantity) if blockIndex==numBlocks then blockSize=endIdx-startIdx end loadResults(startIdx,blockSize,parameter,data) end else loadResults(0,blockSize,parameter,data) end gg.clearResults() if (#data > 0) then return data else return nil end end local function modfiy(address,...) if not address or not ... then return end local c,t={...},{} if type(address)=="table" then if (#address > 0) then for i=1, #address do for ii=1,#c do t[#t+1]={} t[#t].address = address[i]+(c[ii][2]) t[#t].flags = c[ii][3] t[#t].value = c[ii][1] local n=c[ii][5] if n then t[#t].name = n end if c[ii][4] then local item = {} item[#item+1] = t[#t] item[#item].freeze = true gg.addListItems(item) end end end gg.setValues(t) return true end elseif type(address)=="string" or type(address)=="number" then for ii=1,#c do t[#t+1]={} t[#t].address = tonumber(address)+(c[ii][2]) t[#t].flags = c[ii][3] t[#t].value = c[ii][1] local n=c[ii][5] if n then t[#t].name = n end if c[ii][4] then local item = {} item[#item+1] = t[#t] item[#item].freeze = true gg.addListItems(item) end end gg.setValues(t) return true end end local function m(t,...) return xpcall(function(t,...) modfiy(getaddress(t),...) end,function(e) gg.alert(e) end,t,...) end--优化:biao,改至:云云

m({
  {8023,4,32},--主特征码,类型，内存
  {1,-4,16}, --副特征码,偏移，类型
  {2,4,4},--可以无限添加
  {3,-8,4}
},第一个参数为table就是定位主特征码地址，也可以是地址(字符串，数字)

{1,-32,4,true,"name"},--修改 修改值 主特征码偏移 类型 冻结(布尔值) 名字(字符串)
{0,12,16})--可以无限添加
--第一个表寻找特征码地址，后面的都是修改表 {{}},{},{}...
]]

local gg=_G["gg"]
local path=gg.EXT_STORAGE.."/"

local function output(path,str)
  local file = io.open(path, "w+")
  if file then
    file:write(str)
    file:close()
    gg.alert("输出路径:\n"..path)
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

local function Get_search_list()
  local t= gg.getResults(gg.getResultsCount())
  local t2=gg.getListItems()
  if #t>0 then
    return t
   elseif #t2>0 then
    return t2
   elseif #t==0 and #t2==0 then
    gg.alert("列表没有选项")
    return nil
  end
end

local function Select_list_item(t)
  if not t then
    return
  end
  local name={}
  for i=1,#t do
    table.insert(name,tostring(num_to_hex(t[i].address)..":"..t[i].value))
  end
  local _m= gg.choice(name)
  if _m then
    return num_to_hex(t[_m].address)
  end
end

local function Option_offset_search(address)
  if not address then
    return
  end

  local file_name=path..gg.getTargetInfo()["label"].."_特征码.txt"
  local _p=gg.prompt(
  {"地址:","范围:","输出路径:","D类","F类","过滤0"},
  {address,"0xFFF",file_name,true,true,true},
  {"text","text","text","checkbox","checkbox","checkbox"})

  address=num_to_hex(_p[1])

  if not address then
    return
  end

  if not _p or not _p[4] and not _p[5] then
    return
  end

  local time=os.clock()
  local range = num_to_hex(_p[2])

  if not range then
    return
  end

  io.open(_p[3], "w+"):close()
  local file = io.open(_p[3], "a")

  local pyt = {
    D = {},
    F = {},
    up = {
      D = {},
      F = {}
    }
  }

  local D, F, _D, _F

  for i = 0, range, 4 do
    if _p[4] then
      pyt.D[i/4] = {
        address = address + i,
        flags = 4
      }
      pyt.up.D[i/4] = {
        address = address - i,
        flags = 4
      }
    end
    if _p[5] then
      pyt.F[i/4] = {
        address = address + i,
        flags = 16
      }
      pyt.up.F[i/4] = {
        address = address - i,
        flags = 16
      }
    end
  end

  if _p[4] then
    D = gg.getValues(pyt.D)
    _D = gg.getValues(pyt.up.D)
  end

  if _p[5] then
    _F = gg.getValues(pyt.up.F)
    F = gg.getValues(pyt.F)
  end

  if _p[4] and _p[5] then
    for i = #D, 1, -1 do
      local _d, _f = _D[i].value, _F[i].value
      if _p[6] and _d ~= 0 and _f ~= 0 and _f~="nan" then
        file:write(string.format("%-4d D:%d F:%s\n", -i * 4, _d, _f))
       elseif not _p[6] then
        file:write(string.format("%-4d D:%d F:%s\n", -i * 4, _d, _f))
      end
    end

    file:write( "0 D:" .. D[0].value .. " F:" .. F[0].value .. "\n")
    for i = 1, #D do
      local _d, _f = D[i].value, F[i].value
      if _p[6] and _d ~= 0 and _f ~= 0 and _f~="nan" then
        file:write(string.format("%d D:%d F:%s\n", i * 4, _d, _f))
       elseif not _p[6] then
        file:write(string.format("%d D:%d F:%s\n", i * 4, _d, _f))
      end
    end

   elseif _p[4] then

    for i = #D, 1, -1 do
      local _d = _D[i].value
      if _p[6] and _d ~= 0 then
        file:write(string.format("%-4d D:%d\n", -i * 4, _d))
       elseif not _p[6] then
        file:write(string.format("%-4d D:%d\n", -i * 4, _d))
      end
    end

    file:write( "0 D:" .. D[0].value .. "\n")
    for i = 1, #D do
      local _d = D[i].value
      if _p[6] and _d ~= 0 then
        file:write(string.format("%d D:%d\n", i * 4, _d))
       elseif not _p[6] then
        file:write(string.format("%d D:%d\n", i * 4, _d))
      end
    end

   elseif _p[5] then

    for i = #F, 1, -1 do
      local _f = _F[i].value
      if _p[6] and _f ~= 0 then
        file:write(string.format("%-4d F:%s\n", -i * 4, _f))
       elseif not _p[6] then
        file:write(string.format("%-4d F:%s\n", -i * 4, _f))
      end
    end

    file:write( "0 F:" .. F[0].value .. "\n")
    for i = 1, #F do
      local _f = F[i].value
      if _p[6] and _f ~= 0 then
        file:write(string.format("%d F:%s\n", i * 4, _f))
       elseif not _p[6] then
        file:write(string.format("%d F:%s\n", i * 4, _f))
      end
    end

  end

  file:close()
  time=os.clock()-time
  gg.alert("输出完成\n耗时:"..time)
end

local function Feature_code_comparison(address)
  if not address then
    return
  end

  address=num_to_hex(address)

  if not address then
    return
  end

  local _p=gg.prompt({"加载配置文件:"},{path},{"file"})
  if not _p or not (io.open(_p[1],"r")) then
    return
  end

  local num=0
  local time=os.clock()
  local correlation_table={}
  local D,F,_D,_F
  local range,iD,iF
  local line=0
  local pyt={
    D={},
    F={},
    up={
      D={},
      F={}
    }
  }

  local config_file=io.lines(_p[1])

  for c in config_file do
    if c:match("^%s*$")then
      break
    end
    line=line+1
    if line==1 then
      range=math.abs(tonumber(c:match("^(%p?%d+)")))
      if c:match("%sD:") then
        iD=true
      end
      if c:match("%sF:") then
        iF=true
      end
    end
    if line ==2 then
      break
    end
  end

  if not range then
    return gg.alert("文件配置错误 必须是此脚本输出的文件")
  end

  for i=0,range,4 do
    if iD then
      pyt["D"][i/4] = {
        address=address + i,
        flags=4
      }
      pyt["up"]["D"][i/4] = {
        address=address - i,
        flags=4
      }
    end
    if iF then
      pyt["F"][i/4] = {
        address=address + i,
        flags=16
      }
      pyt["up"]["F"][i/4] = {
        address=address - i,
        flags=16
      }
    end
  end

  if iD then
    D=gg.getValues(pyt["D"])
    _D=gg.getValues(pyt["up"]["D"])
    if #D==0 then
      return
    end
  end

  if iF then
    _F=gg.getValues(pyt["up"]["F"])
    F=gg.getValues(pyt["F"])
    if #F==0 then
      return
    end
  end

  local _offset_address = {}
  local _offset_flags = {}
  local _offset_value={}
  local _offset_offset={}
  local j=0

  for l in config_file do
    j=j+1
    local o=l:match("^(.-)%s")
    local d,f=l:match("D:%-?(%d+)"),l:match("F:(.*)")
    if d and f then
      _offset_address[j] = address+o
      _offset_flags[j] = {address = _offset_address[j], flags = 16}
      _offset_value[j] = f
      _offset_offset[j] = o
     elseif d then
      _offset_address[j] = address+o
      _offset_flags[j] = {address = _offset_address[j], flags = 4}
      _offset_value[j] = d
      _offset_offset[j] = o
     elseif f then
      _offset_address[j] = address+o
      _offset_flags[j] = {address = _offset_address[j], flags = 16}
      _offset_value[j] = f
      _offset_offset[j] = o
    end
  end

  local _offset_values = gg.getValues(_offset_flags)

  local data_type
  if _offset_values[1].flags== 16 then
    data_type="F"
   elseif _offset_values[1].flags== 4 then
    data_type="D"
  end

  io.open(_p[1], "w+"):close()
  local file = io.open(_p[1], "a")
  for i = #_offset_address, 1, -1 do
    if _offset_values[i].value == _offset_value[i] then
      num=num+1
      file:write(_offset_offset[i].." "..data_type..":".. _offset_values[i].value.."\n")
    end
  end

  file:close()
  time=os.clock()-time
  gg.alert("对比完成\n已保留"..num.."条数据\n耗时:"..time)
end

local function main()
  xpcall(function()
    choice(
    "列表",function()
      choice("输出",function()
        Option_offset_search(Select_list_item(Get_search_list()))
        end,"对比",function()
        Feature_code_comparison(Select_list_item(Get_search_list()))
      end)
    end,
    "地址",function()
      choice(
      "输出",function()
        Option_offset_search("0x8023")
      end,
      "对比",function()
        local _p=gg.prompt({"地址:"},{"0x8023"},{"text"})
        if not _p then
          return
        end
        Feature_code_comparison(_p[1])
      end)
    end,
    "模板",function()
      output(path.."特征码使用模板.lua",Template_code)
    end,
    "帮助",function()
      gg.alert("特征码工具 by:biao\n\n支持10&16进制数字\n\n对比文件存在D,F类时默认F类输出")
    end)
    end,function(e)
    local _e=gg.alert(e,"复制","取消")
    if _e==1 then
      gg.copyText(tostring(e))
    end
  end)
end

gg.showUiButton()
while true do
  if gg.isClickedUiButton() then
    main()
  end
  gg.sleep(100)
end

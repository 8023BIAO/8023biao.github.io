
--GG Feature Code Tool Script

local Template_code=[[local function m(...) local c={...} local parameter=c[1] if type(parameter)~="table" then return end gg.clearResults() gg.setRanges(parameter[1][3]) gg.searchNumber(parameter[1][1], parameter[1][2]) local result = gg.getResults(gg.getResultCount()) gg.clearResults() local data = {} if #result > 0 then for i, v in ipairs(result) do v.isUseful = true end for i = 2, #parameter do local offset_table = {} local num=parameter[i][1] local offset=tonumber(parameter[i][2]) local flag= parameter[i][3] for i, v in ipairs(result) do offset_table[#offset_table+1]={ address = result[i].address + offset, flags = flag } end local tmp = gg.getValues(offset_table) for i, v in ipairs(tmp) do if v.value ~= num then result[i].isUseful = false end end end end for i, v in ipairs(result) do if (v.isUseful) then data[#data+1] = v.address end end if (#data > 0) then local t = {} for i=1, #data do for ii=2,#c do t[#t+1]={} t[#t].address = data[i]+(c[ii][2]) t[#t].flags = c[ii][3] t[#t].value = c[ii][1] local n=c[ii][5] if n then t[#t].name = n end if c[ii][4] then local item = {} item[#item+1] = t[#t] item[#item].freeze = true gg.addListItems(item) end end end gg.setValues(t) return true else return nil end end--by:云云

m({
  {8023,4,32},--主特征码,类型，内存
  {1,-4,16}, --副特征码,偏移，类型
  {2,4,4},--可以无限添加
  {3,-8,4}
},

{1,-32,4,true,"name"},--修改 修改值 主特征码偏移 类型 冻结(布尔值) 名字(字符串)
{0,12,16})--可以无限添加
--第一个表寻找特征码地址，后面的都是修改表 {{}},{},{}...
]]

local gg=_G["gg"]

local function output(path,str)
  local file = io.open(path, "w+")
  if file then
    file:write(str)
    file:close()
    gg.alert("output path:"..path.."\nOutput:".. string.len(str).."bytes")
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

local function dec_to_hex(decimal_num)
  return string.format("%X", decimal_num)
end

local function Get_search_list()
  local t= gg.getResults(gg.getResultsCount())
  if #t>0 then
    return t
   else
    gg.alert("Search list has no options.")
    return nil
  end
end

local function Select_list_item(t)
  if not t then
    return
  end
  local name={}
  for i=1,#t do
    table.insert(name,tostring(dec_to_hex(t[i].address)..":"..t[i].value))
  end
  local _m= gg.choice(name)
  if _m then
    return t[_m]
  end
end

local function Option_offset_search(t)
  if not t then
    return
  end

  local file_name="/sdcard/"..gg.getTargetInfo()["label"].."_Feature_code.txt"
  local _p=gg.prompt(
  {"address:","range:","output path:","D","F"},
  {dec_to_hex(tonumber(t.address)),"0xFFF",file_name,true,true},
  {"text","text","text","checkbox","checkbox"})

  if not _p or not _p[4] and not _p[5] then
    return
  end

  local range=tonumber(_p[2])
  local pyt={
    D={},
    F={},
    up={
      D={},
      F={}
    }
  }

  local str
  local str2=""
  local str3=""
  local D,F,_D,_F

  for i=0,range,4 do
    if _p[4] then
      pyt["D"][i/4] = {
        address=t.address + i,
        flags=4
      }
      pyt["up"]["D"][i/4] = {
        address=t.address - i,
        flags=4
      }
    end
    if _p[5] then
      pyt["F"][i/4] = {
        address=t.address + i,
        flags=16
      }
      pyt["up"]["F"][i/4] = {
        address=t.address - i,
        flags=16
      }
    end
  end

  if _p[4] then
    D=gg.getValues(pyt["D"])
    _D=gg.getValues(pyt["up"]["D"])
  end

  if _p[5] then
    _F=gg.getValues(pyt["up"]["F"])
    F=gg.getValues(pyt["F"])
  end

  if _p[4] and _p[5] then
    for i=#D,1,-1 do
      str2=str2 .. -i*4 .. " D:" .. _D[i].value .. " F:" .. _F[i].value .."\n"
    end
    for i=1,#D do
      str3=str3 .. i*4 .. " D:" .. D[i].value .. " F:" .. F[i].value .."\n"
    end
    str=str2.."0".." D:"..D[0].value.." F:"..F[0].value.."\n"..str3
   elseif _p[4] then
    for i=#D,1,-1 do
      str2=str2 .. -i*4 .. " D:" .. _D[i].value .. "\n"
    end
    for i=1,#D do
      str3=str3 .. i*4 .. " D:" .. D[i].value .. "\n"
    end
    str=str2.."0".." D:"..D[0].value.. "\n" .. str3
   elseif _p[5] then
    for i=#F,1,-1 do
      str2=str2 .. -i*4 .. " F:" .. _F[i].value .. "\n"
    end
    for i=1,#F do
      str3=str3 .. i*4 .. " F:" .. F[i].value .. "\n"
    end
    str=str2.."0".." F:"..F[0].value.. "\n" .. str3
  end

  output(_p[3],str)
end

local function Feature_code_comparison(t)
  if not t then
    return
  end

  local _p=gg.prompt({"loadflie:"},{"/sdcard/"},{"file"})
  if not _p then
    return
  end

  local correlation_table={}
  local D,F,_D,_F
  local range,iD,iF
  local address=t.address
  local line=0
  local code=""
  local pyt={
    D={},
    F={},
    up={
      D={},
      F={}
    }
  }

  for c in io.lines(_p[1]) do
    if c:match("^%s*$") then
      break
    end
    line=line+1
    if line==1 then
      range=tonumber(c:match("^(%p?%d+)"))
      if c:match("%sD:") then
        iD=true
      end
      if c:match("%sF:") then
        iF=true
      end
    end
    code=code..c.."\n"
  end

  for i=0,math.abs(range),4 do
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

  for l in string.gmatch(code,".-\n") do
    j=j+1
    local o=tonumber(l:match("^(.-)%s"))
    local d,f=l:match("D:%-?(%d+)"),l:match("F:(.-)\n")
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
  local result=""
  local data_type

  if _offset_values[1].flags== 16 then
    data_type="F"
   elseif _offset_values[1].flags== 4 then
    data_type="D"
  end

  for i = #_offset_address, 1, -1 do
    if _offset_values[i].value ~= _offset_value[i] then
      table.remove(_offset_address, i)
     else
      result=result.._offset_offset[i].." "..data_type..":".. _offset_values[i].value.."\n"
    end
  end

  local _m=gg.alert(result,"copy","output","cancel")
  if _m==1 then
    gg.copyText(result)
    gg.toast("copy")
   elseif _m==2 then
    local p=gg.prompt({"output path:"},{_p[1]},{"file"})
    if not p then
      return
    end
    output(p[1],result)
  end
end

local function main()
  xpcall(function()
    choice(
    "option",function()
      choice("output",function()
        Option_offset_search(Select_list_item(Get_search_list()))
        end,"contrast",function()
        Feature_code_comparison(Select_list_item(Get_search_list()))
      end)
    end,
    "address",function()
      choice(
      "output",function()
        Option_offset_search({address=tonumber("0x8023")})
      end,
      "contrast",function()
        local _p=gg.prompt({"address:"},{"0x8023"},{"text"})
        if not _p then
          return
        end
        Feature_code_comparison({address=tonumber(_p[1])})
      end)
    end,"template",function()output("/sdcard/Template.lua",Template_code)end)
    end,function(e)
    local _e=gg.alert(e,"copy","cancel")
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
end
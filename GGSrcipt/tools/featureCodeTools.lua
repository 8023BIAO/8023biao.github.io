--特征码工具 by:biao
local Template_code = [[local function loadResults(skip,loadNum,parameter,data) local result if skip==0 then result = gg.getResults(loadNum) else result = gg.getResults(skip,loadNum) end for i, v in ipairs(result) do v.isUseful = true end for i = 2, #parameter do local offset_table = {} local num=parameter[i][1] local offset=tonumber(parameter[i][2]) local flag= parameter[i][3] for i, v in ipairs(result) do offset_table[#offset_table+1]={ address = result[i].address + offset, flags = flag } end local tmp = gg.getValues(offset_table) for i, v in ipairs(tmp) do if (v.value ~= num)then result[i].isUseful = false end end end for i, v in ipairs(result) do if (v.isUseful) then data[#data+1] = v.address end end end local function getaddress(...) local c={...} local parameter=c[1] if type(parameter)~="table" then return end gg.clearResults() gg.setVisible(false) gg.setRanges(parameter[1][3]) gg.searchNumber(parameter[1][1], parameter[1][2]) local data = {} local quantity=gg.getResultCount() if quantity== 0 then return nil end local blockSize=9999 local numBlocks if quantity>blockSize then numBlocks=math.ceil(quantity/blockSize) end if numBlocks then for blockIndex = 1, numBlocks do local startIdx=(blockIndex-1)*blockSize local endIdx=math.min(startIdx+blockSize,quantity) if blockIndex==numBlocks then blockSize=endIdx-startIdx end loadResults(startIdx,blockSize,parameter,data) end else loadResults(0,blockSize,parameter,data) end gg.clearResults() if (#data > 0) then return data else return nil end end local function modfiy(address,...) if not address or not ... then return end local c,t={...},{} if type(address)=="table" then if (#address > 0) then for i=1, #address do for ii=1,#c do t[#t+1]={} t[#t].address = address[i]+(c[ii][2]) t[#t].flags = c[ii][3] t[#t].value = c[ii][1] local n=c[ii][5] if n then t[#t].name = n end if c[ii][4] then local item = {} item[#item+1] = t[#t] item[#item].freeze = true gg.addListItems(item) end end end gg.setValues(t) return true end elseif type(address)=="string" or type(address)=="number" then for ii=1,#c do t[#t+1]={} t[#t].address = tonumber(address)+(c[ii][2]) t[#t].flags = c[ii][3] t[#t].value = c[ii][1] local n=c[ii][5] if n then t[#t].name = n end if c[ii][4] then local item = {} item[#item+1] = t[#t] item[#item].freeze = true gg.addListItems(item) end end gg.setValues(t) return true end end local function m(t,...) return xpcall(function(t,...) modfiy(getaddress(t),...) end,function(e) gg.alert(e) end,t,...) end--改至:云云

--函数说明
--getaddress({寻找地址表})--只接受一个table 返回地址table(也可以改为 return data[1] 或 直接获取 data[1] ) 为什么这样写呢因为某些游戏需要，你可以自行修改需求。
--modfiy({地址表},...)--第一个是地址 后面可以添加n个修改table详情看下面
--m({寻找地址表},{修改表})--只接受两个table 
--详情看代码 请根据自己的需求更改 代码于2023.8.20编写 因为懒没有更新(23.9.15)

--使用说明
m({
  {8023,4,32},--主特征码,类型，内存
  {1,-4,16}, --副特征码,偏移，类型
  {2,4,4},--可以无限添加
  {3,-8,4}--...
},第一个参数为table就是定位主特征码地址，也可以是地址(字符串，数字)

{1,-32,4,true,"name"},--修改 修改值 主特征码偏移 类型 冻结(布尔值) 名字(字符串)
{0,12,16})--可以无限添加

]]

local gg = _G["gg"]
local path = gg.EXT_STORAGE.."/"

local function read(path)
  local file = io.open(path, "r")
  io.input(file)
  local data = io.read("*a")
  io.close(file)
  return data
end

local function choice(t)
  local n,f = {},{}
  for i = 1,#t,2 do
    n[#n + 1] = t[i]
    f[#f + 1] = t[i + 1]
  end
  local m = gg.choice(n)
  m = m and f[m]()
end

local function num_to_hex(num)
  num = tostring(num)
  num = string.upper(num)
  if not num:match("^[A-F 0-9 X]+$") then
    return nil
  end
  if not num:match("^%d+$") then
    if not num:find("0X") then
      num = "0x" .. num
    end
  end
  return string.format("0x%X",tonumber(num))
end

local function get_search_list()
  local t = gg.getResults(gg.getResultsCount())
  local t2 = gg.getListItems()
  if #t > 0 then
    return t
   elseif #t2 > 0 then
    return t2
   elseif #t == 0 and #t2 == 0 then
    print("两个列表都没有选项")
  end
end

local function select_list_item(t)
  if not t then return end
  local name={}
  for i=1,#t do
    table.insert(name,tostring(num_to_hex(t[i].address) .. ":" .. t[i].value))
  end
  local _m = gg.choice(name)
  if _m then
    return num_to_hex(t[_m].address)
  end
end

local function file_output(address)
  if not address then return end
  local file_name = path .. gg.getTargetInfo()["label"] .. "_特征码_" .. os.date("%Y.%m.%d.%H.%M.%S") .. ".txt"
  local _p=gg.prompt({"地址:", "获取:", "类型(B1,W2,D4,X8,F16,Q32,E64,A127)", "输出:", "过滤0"}, {address, "5000", "", file_name, true}, {"number", "number", "number", "text", "checkbox",})
  if not _p or _p[1]:match("^%s*$") or _p[2]:match("^%s*$") or _p[3]:match("^%s*$") or _p[4]:match("^%s*$") then return end
  address = num_to_hex(_p[1])
  local time, range, numType, offsetTable, up, un, getUp, getUn, memory_type_distance = os.clock(), num_to_hex(_p[2]), tonumber(_p[3]), { up = {}, un ={} }, {}, {}
  if numType == 1 then memory_type_distance = 1 elseif numType == 2 then memory_type_distance = 2 else memory_type_distance = 4 end
  for i = 0, (math.ceil(_p[2]/2)), memory_type_distance do
    offsetTable.up[i/memory_type_distance] = { address = address - i, flags = numType }
    offsetTable.un[i/memory_type_distance] = { address = address + i, flags = numType }
  end
  getUp, getUn = gg.getValues(offsetTable.up), gg.getValues(offsetTable.un)
  io.open(_p[4], "w+"):close()
  local file = io.open(_p[4], "a")
  file:write(string.format("类型:%d \n",_p[3]))
  for i = #getUp, 1, -1 do
    local value = getUp[i].value
    if _p[5] and value ~= 0 then
      file:write(string.format("-%d %s\n", i * memory_type_distance, value))
     elseif not _p[5] then
      file:write(string.format("-%d %s\n", i * memory_type_distance, value))
    end
  end
  file:write("0 " .. getUp[0].value .. "\n")
  for i = 1, #getUn do
    local value = getUn[i].value
    if _p[5] and value ~= 0 then
      file:write(string.format("%d %s\n", i * memory_type_distance, value))
     elseif not _p[5] then
      file:write(string.format("%d %s\n", i * memory_type_distance, value))
    end
  end
  file:close()
  print("输出完成\n耗时:" .. os.clock() - time)
end

local function file_comparison()
  local _p = gg.prompt({ "文件1:", "文件2:", "输出:", "对比不同"}, { path, path, path .."对比结果_" .. os.date("%Y.%m.%d.%H.%M.%S") .. ".txt", false}, { "file", "file", "file", "checkbox"})
  if not _p or not io.open(_p[1], "r") or not io.open(_p[2], "r") then return end
  local time, data, file1, file2, newFile = os.clock(), {}, read(_p[1]), read(_p[2]), _p[3]
  for v in file1:gmatch("(.-)\n") do
    data[v] = true
  end
  io.open(newFile, "w+"):close()
  local new_file = io.open(newFile, "a")
  new_file:write(string.format("对比%s\n", _p[4] and "不同" or "相同"))
  for v in file2:gmatch("(.-)\n") do
    if data[v] and not _p[4] then
      new_file:write(v .. "\n")
     elseif not data[v] and _p[4] then
      new_file:write(v .. "\n")
    end
  end
  new_file:close()
  print("对比完成\n耗时:" .. os.clock() - time)
end

local function main()
  choice({
    "输出",function()
      file_output(select_list_item(get_search_list()))
    end,
    "对比",function()
      file_comparison()
    end,
    "模板",function()
      local p = path .. "特征码使用模板.lua"
      local file = io.open(p, "w+")
      file:write(Template_code)
      file:close()
      print("输出路径:\n" .. p .. "")
  end})
end

xpcall(main,print)

local path = gg.EXT_STORAGE .. "/"
local zhStringTable = {"获取","对比","模板","地址","类型","输出","过滤0","耗时","文件","对比不同","不同","相同"}
local enStringTable = {"get","contrast","template","address","type","output","filter 0","time","file","contrast is different","different","same"}
local stringTable = (gg.getLocale() == "zh_CN") and zhStringTable or enStringTable
local instructions = [=[ 

--[[
local searchTable = ({
{搜索值(searchValue),类型(gg.TYPE常量),内存(gg.REGION常量)},--三个参数(主特征码)
{值(filterValue),距离搜索值偏移(number),类型(gg.TYPE常量)},--三个参数(副特征码，过滤筛选用)
{值(filterValue),距离搜索值偏移(number),类型(gg.TYPE常量)},
})

local editTable = ({
  {修改值(editValue)，距离主特征码偏移(number),类型(gg.TYPE常量),冻结(boolean),标签名(string)},--修改表，五个参数，前面三个必填，后两个可选，自定义标签名添加到保持列表
 -- {修改值(editValue)，距离主特征码偏移(number),类型(gg.TYPE常量),冻结(boolean),标签名(string)},
  })

searchEdit(searchTable,editTable)--(搜索主特征码表[必填],编辑表[可选]) --没有第二个参数返回主特征码地址表

]]
]=]

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
    n[#n + 1], f[#f + 1] = t[i], t[i + 1]
  end
  local m = gg.choice(n)
  m = m and f[m]()
end

local function numToHex(num)
  num = string.upper(tostring(num))
  if not num:match("^[A-F0-9X]+$") then return nil end
  if not num:match("^%d+$") and not num:find("0X") then num = "0x" .. num end
  return string.format("0x%X", tonumber(num))
end

local function getSearchList()
  local t, t2 = gg.getResults(gg.getResultsCount()), gg.getListItems()
  return (#t > 0) and t or (#t2 > 0 and t2)
end

local function selectListItem(t)
  if not t then return end
  local name = {}
  for i, item in ipairs(t) do
    table.insert(name, tostring(numToHex(item.address) .. ":" .. item.value))
  end
  local n = gg.choice(name)
  return n and numToHex(t[n].address)
end

local function fileOutput()
  local address = selectListItem(getSearchList())
  if not address then return end
  local fileName = path .. gg.getTargetInfo()["label"] .. "." .. os.date("%Y.%m.%d.%H.%M.%S") .. ".txt"
  local promptValue = gg.prompt(
  {stringTable[4] .. ":", stringTable[1] .. ":", stringTable[5] .. "(B1,W2,D4,X8,F16,Q32,E64,A127)", stringTable[6] .. ":", stringTable[7]},
  {address, "5000", "127", fileName, true},
  {"number", "number", "number", "text", "checkbox"})
  if not promptValue or promptValue[1]:match("^%s*$")or
    promptValue[2]:match("^%s*$") or promptValue[3]:match("^%s*$") or
    promptValue[4]:match("^%s*$") then
    return
  end
  address = numToHex(promptValue[1])
  local time, range, numType, offsetTable, memoryTypeDistance = os.clock(), numToHex(promptValue[2]), tonumber(promptValue[3]), { up = {}, un = {} }
  if numType == 1 then
    memoryTypeDistance = 1
   elseif numType == 2 then
    memoryTypeDistance = 2
   else memoryTypeDistance = 4
  end
  for i = 0, math.ceil((promptValue[2] / 2) * memoryTypeDistance), memoryTypeDistance do
    offsetTable.up[i / memoryTypeDistance] = { address = address - i, flags = numType }
    offsetTable.un[i / memoryTypeDistance] = { address = address + i, flags = numType }
  end
  local getUp, getUn = gg.getValues(offsetTable.up), gg.getValues(offsetTable.un)
  local file = io.open(promptValue[4], "w+")
  file:write(string.format(stringTable[5] .. ":%d \n", promptValue[3]))
  for i = #getUp, 1, -1 do
    local value = getUp[i].value
    if promptValue[5] and value ~= 0 or not promptValue[5] then
      file:write(string.format("-0x%X %s\n", i * memoryTypeDistance, value))
    end
  end
  file:write("0x0 " .. getUp[0].value .. "\n")
  for i = 1, #getUn do
    local value = getUn[i].value
    if promptValue[5] and value ~= 0 or not promptValue[5] then
      file:write(string.format("0x%X %s\n", i * memoryTypeDistance, value))
    end
  end
  file:close()
  print( stringTable[8] .. ":" .. os.clock() - time)
end

local function fileComparison()
  local promptValue = gg.prompt(
  { stringTable[9] .. "1:", stringTable[9] .. "2:", stringTable[6] .. ":", stringTable[10]},
  { path, path, path .. stringTable[2] .. "_" .. os.date("%Y.%m.%d.%H.%M.%S") .. ".txt", false },
  { "file", "file", "file", "checkbox" })
  if not promptValue or not io.open(promptValue[1], "r") or
    not io.open(promptValue[2], "r") then
    return
  end
  local time, data, file1, file2, newFilePath = os.clock(), {}, read(promptValue[1]), read(promptValue[2]), promptValue[3]
  for v in file1:gmatch("(.-)\n") do
    data[v] = true
  end
  local file = io.open(newFilePath, "w+")
  file:write(string.format(stringTable[2] .. "%s\n", promptValue[4] and stringTable[11] or stringTable[12]))
  for v in file2:gmatch("(.-)\n") do
    if (data[v] and not promptValue[4]) or (not data[v] and promptValue[4]) then
      file:write(v .. "\n")
    end
  end
  file:close()
  print(stringTable[8] .. ":" .. os.clock() - time)
end

local function searchEdit(searchLocation,modifyData)
  gg.clearResults()
  gg.setVisible(false)
  gg.setRanges(searchLocation[1][3])
  gg.searchNumber(searchLocation[1][1], searchLocation[1][2])
  local data,getNum = {},100000
  local count = gg.getResultCount()
  if count == 0 then return end
  while (gg.getResultCount() ~= 0) do
    local result = gg.getResults(getNum)
    for _, v in ipairs(result) do
      v.isUseful = true
    end
    for i = 2, #searchLocation do
      local offsetTable = {}
      local num = searchLocation[i][1]
      local offset = tonumber(searchLocation[i][2])
      local flag = searchLocation[i][3]
      for i, v in ipairs(result) do
        offsetTable[#offsetTable + 1] = { address = v.address + offset, flags = flag }
      end
      local tmp = gg.getValues(offsetTable)
      for i, v in ipairs(tmp) do
        if (v.value ~= num) then
          result[i].isUseful = false
        end
      end
    end
    for _, v in ipairs(result) do
      if (v.isUseful) then
        data[#data + 1] = v.address
      end
    end
    gg.removeResults(result)
  end
  if not modifyData and #data == 0 then
    return
   elseif #data > 0 and not modifyData then
    return data
  end
  local set, saveList = {}, {}
  for _, v in ipairs(data) do
    for i = 1, #modifyData do
      local tb = (modifyData[i][5]) and saveList or set
      tb[#tb + 1] = {}
      tb[#tb].address = v + modifyData[i][2]
      tb[#tb].flags = modifyData[i][3]
      tb[#tb].value = modifyData[i][1]
      tb[#tb].name = modifyData[i][5]
      tb[#tb].freeze = modifyData[i][4]
    end
  end
  if #saveList > 0 then
    gg.setValues(saveList)
    gg.addListItems(saveList)
  end
  gg.setValues(set)
end

local function getFunctionCode(func)
  local file = io.open(gg.getFile(),"r")
  local lines = {}
  for line in file:lines() do
    lines[#lines + 1] = line
  end
  file:close()
  local code = ""
  local info = debug.getinfo(func,"S")
  for i = info.linedefined,info.lastlinedefined do
    code = code .. lines[i] .. " "
  end
  return code:gsub("%s+"," ")
end

local function exportTemplate()
  local path, code = path .. "FeatureCodeTemplate.lua",getFunctionCode(searchEdit) .. instructions
  io.open(path,"w+"):write(code):close()
  print(path)
end

local function main()
  choice({stringTable[1],fileOutput,stringTable[2],fileComparison,stringTable[3],exportTemplate})
end

xpcall(main,print)
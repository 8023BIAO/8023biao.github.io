--GG特征码对比&获取工具 by:biao
local path = gg.EXT_STORAGE .. "/"

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

local function num_to_hex(num)
  num = string.upper(tostring(num))
  if not num:match("^[A-F0-9X]+$") then return nil end
  if not num:match("^%d+$") and not num:find("0X") then num = "0x" .. num end
  return string.format("0x%X", tonumber(num))
end

local function get_search_list()
  local t, t2 = gg.getResults(gg.getResultsCount()), gg.getListItems()
  return #t > 0 and t or (#t2 > 0 and t2)
end

local function select_list_item(t)
  if not t then return end
  local name = {}
  for i, item in ipairs(t) do
    table.insert(name, tostring(num_to_hex(item.address) .. ":" .. item.value))
  end
  local _m = gg.choice(name)
  return _m and num_to_hex(t[_m].address)
end

local function file_output(address)
  if not address then return end
  local file_name = path .. gg.getTargetInfo()["label"] .. "_特征码_" .. os.date("%Y.%m.%d.%H.%M.%S") .. ".txt"
  local promptValue = gg.prompt({"地址:", "获取:", "类型(B1,W2,D4,X8,F16,Q32,E64,A127)", "输出:", "过滤0"}, {address, "5000", "127", file_name, true}, {"number", "number", "number", "text", "checkbox"})
  if not promptValue or promptValue[1]:match("^%s*$") or promptValue[2]:match("^%s*$") or promptValue[3]:match("^%s*$") or promptValue[4]:match("^%s*$") then return end
  address = num_to_hex(promptValue[1])
  local time, range, numType, offsetTable, memory_type_distance = os.clock(), num_to_hex(promptValue[2]), tonumber(promptValue[3]), { up = {}, un = {} }
  if numType == 1 then memory_type_distance = 1 elseif numType == 2 then memory_type_distance = 2 else memory_type_distance = 4 end
  for i = 0, math.ceil((promptValue[2] / 2) * memory_type_distance), memory_type_distance do
    offsetTable.up[i / memory_type_distance] = { address = address - i, flags = numType }
    offsetTable.un[i / memory_type_distance] = { address = address + i, flags = numType }
  end
  local getUp, getUn = gg.getValues(offsetTable.up), gg.getValues(offsetTable.un)
  local file = io.open(promptValue[4], "w+")
  file:write(string.format("类型:%d \n", promptValue[3]))
  for i = #getUp, 1, -1 do
    local value = getUp[i].value
    if promptValue[5] and value ~= 0 or not promptValue[5] then
      file:write(string.format("-%d %s\n", i * memory_type_distance, value))
    end
  end
  file:write("0 " .. getUp[0].value .. "\n")
  for i = 1, #getUn do
    local value = getUn[i].value
    if promptValue[5] and value ~= 0 or not promptValue[5] then
      file:write(string.format("%d %s\n", i * memory_type_distance, value))
    end
  end
  file:close()
  print("输出完成\n耗时:" .. os.clock() - time)
end

local function file_comparison()
  local promptValue = gg.prompt({ "文件1:", "文件2:", "输出:", "对比不同" }, { path, path, path .. "对比结果_" .. os.date("%Y.%m.%d.%H.%M.%S") .. ".txt", false }, { "file", "file", "file", "checkbox" })
  if not promptValue or not io.open(promptValue[1], "r") or not io.open(promptValue[2], "r") then return end
  local time, data, file1, file2, newFile = os.clock(), {}, read(promptValue[1]), read(promptValue[2]), promptValue[3]
  for v in file1:gmatch("(.-)\n") do data[v] = true end
  local new_file = io.open(newFile, "w+")
  new_file:write(string.format("对比%s\n", promptValue[4] and "不同" or "相同"))
  for v in file2:gmatch("(.-)\n") do
    if (data[v] and not promptValue[4]) or (not data[v] and promptValue[4]) then
      new_file:write(v .. "\n")
    end
  end
  new_file:close()
  print("对比完成\n耗时:" .. os.clock() - time)
end

local function main()
  choice({
    "输出", function() file_output(select_list_item(get_search_list())) end,
    "对比", function() file_comparison() end
  })
end

xpcall(main,print)
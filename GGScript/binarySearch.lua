
local function binarySearch()
  local promptValues, IncrementalValue
  local zhStringTable = {"改值", "冻结", "增量", "选择", "过滤", "唯一", "数字类型", "改为"}
  local enStringTable = {"changeValue", "freeze", "increment", "select", "filter", "only", "numberType", "revised"}
  local stringTable = (gg.getLocale() == "zh_CN") and zhStringTable or enStringTable
  local model = gg.choice({stringTable[1],stringTable[2],stringTable[3]})
  if not model then return end
  local rlc = gg.getResultsCount() if rlc <2 then return end
  local saveList = gg.getListItems()
  if model == 1 then
    promptValues = gg.prompt({stringTable[7] .. "(B1,W2,D4,X8,F16,Q32,E64,A127):",stringTable[8] .. ":",stringTable[2]},{"","",false},{"number","number","checkbox"})
    if not promptValues then return end
    promptValues[1], promptValues[2] = tonumber(promptValues[1]),tonumber(promptValues[2])
   elseif model == 3 then
    IncrementalValue = gg.prompt({stringTable[3] .. ":",stringTable[2]},{"",false},{"number","checkbox"})
    if not IncrementalValue then return end
    IncrementalValue[1] = tonumber(IncrementalValue[1])
  end
  gg.setVisible(false)
  local is,low,high,mid,backup,set,get,select = true,0,rlc
  while (low < high) do
    if is then is=false
      mid = math.floor((low + high) / 2)
      get = gg.getResults(high,mid)
      backup,set = {}, {}
      for c, v in ipairs(get) do
        backup[#backup+1] = v
        if model == 1 then
          set[#set+1] = { address = v.address, flags = promptValues[1], value = promptValues[2], freeze = promptValues[3] }
         elseif model == 2 then
          set[#set+1] = v
          set[#set]['freeze'] = true
          backup[#backup]['freeze'] = false
         elseif model == 3 then
          set[#set+1] = v
          set[#set]['value'] = set[#set]['value'] + IncrementalValue[1]
          set[#set]['freeze'] = set[#set]['freeze'] + IncrementalValue[2]
        end
      end
      gg.setValues(set)
      gg.addListItems(set)
    end
    if gg.isVisible() then is=true gg.setVisible(false)
      local select_range = high - mid
      local choice=gg.choice({stringTable[4],stringTable[5]},nil,mid .. "~" .. high .. ":" .. select_range)
      if choice == 1 then
        select = true
        low = mid + 1
       elseif choice == 2 then
        high = mid
      end
      gg.setValues(backup)
      gg.addListItems(backup)
      gg.removeListItems(backup)
      if (high - low == 0) and select_range == 1 and select then
        local key = choice == 1 and mid + 1 or mid
        local onlyTable = gg.getResults(rlc)[key]
        onlyTable.name = stringTable[6]
        if model == 1 then
          onlyTable.freeze = promptValues[3]
         elseif model == 2 then
          onlyTable.freeze = true
        end
        saveList[#saveList+1] = onlyTable
        gg.addListItems(saveList)
       elseif (high - low == 0) and select_range == 1 and not select then
        gg.addListItems(saveList)
      end
     else
      gg.sleep(100)
    end
  end
end

binarySearch()
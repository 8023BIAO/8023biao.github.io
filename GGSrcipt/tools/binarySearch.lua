--GG二分修改筛选 by:biao
local gg = _G["gg"]
local function binarySearch()
  local rlc = gg.getResultsCount() if rlc <2 then return end
  local promptValues = gg.prompt({"类型(B1,W2,D4,X8,F16,Q32,E64):","改为:","冻结"},{"","",false},{"number","number","checkbox"})
  if not promptValues then return end gg.setVisible(false) promptValues[1],promptValues[2] = tonumber(promptValues[1]),tonumber(promptValues[2])
  local is,low,high,mid,backup,set,get,select = true,0,rlc
  while (low < high) do
    if is then is=false
      mid = math.floor((low + high) / 2)
      get = gg.getResults(high,mid)
      backup,set = {},{}
      for c,v in ipairs(get) do
        backup[#backup+1] = v
        set[#set+1] = {flags = promptValues[1],value = promptValues[2],freeze = promptValues[3],address = v.address}
      end
      gg.setValues(set)
    end
    if gg.isVisible() then is=true gg.setVisible(false)
      local select_range = high - mid
      local choice=gg.choice({"选择","过滤"},nil,mid .. "~" .. high .. ":" .. select_range)
      if choice == 1 then
        select = true
        low = mid + 1
       elseif choice == 2 then
        high = mid
      end
      gg.setValues(backup)
      if high == low and select_range == 1 and select then
        local save = {gg.getResults(rlc)[high]}
        save[1].name="only"
        gg.addListItems(save)
      end
     else
      gg.sleep(100)
    end
  end
end
binarySearch()
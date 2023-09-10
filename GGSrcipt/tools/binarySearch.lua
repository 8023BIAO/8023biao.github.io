--GG二分搜索法 by:biao

local gg = _G["gg"]

local function showChoiceDialog(t,s)
  local name,fun = {},{}
  for i = 1, #t, 2 do
    name[#name+1] = t[i]
    fun[#fun+1] = t[i + 1]
  end
  local m = gg.choice(name,nil,s)
  for k, v in pairs(fun) do
    if m == k then
      v()
    end
  end
end

local function binarySearch()
  local rlc = gg.getResultsCount()
  if rlc <2 then
    return
  end
  local promptValues = gg.prompt({"类型(B1,W2,D4,X8,F16,Q32,E64):","改为:","冻结"},{"","",false},{"number","number","checkbox"})
  if promptValues then
    gg.setVisible(false)
    promptValues[1],promptValues[2] = tonumber(promptValues[1]),tonumber(promptValues[2])
   else
    return
  end
  local is = true
  local low = 0
  local high = rlc
  local mid,backup,set,get,select
  while low < high do
    if is then
      is=false
      mid = math.floor((low + high) / 2)
      get = gg.getResults(high,mid)
      backup,set = {},{}
      for c,v in ipairs(get) do
        backup[#backup+1] = v
        set[#set+1] = {
          flags = promptValues[1],
          value = promptValues[2],
          freeze = promptValues[3],
          address = v.address
        }
      end
      gg.setValues(set)
    end
    if gg.isVisible() then
      local select_range = high - mid
      is=true
      gg.setVisible(false)
      showChoiceDialog({
        "选择",function()
          select=true
          low = mid + 1
        end,
        "过滤",function()
          high = mid
        end,
      },mid .. "~" .. high .. ":" .. select_range)
      gg.setValues(backup)
      if low == high and select_range == 1 and select then
        local set2 = {gg.getResults(rlc)[high]}
        set2[1].name="过滤地址"
        gg.addListItems(set2)
        break
      end
     else
      gg.sleep(100)
    end
  end
end

binarySearch()
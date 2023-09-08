--gg BinarySearch by:biao

local gg = _G["gg"]

local function showChoiceDialog(t,s)
  local name = {}
  local fun = {}
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
  local promptValues = gg.prompt({"type(B1,W2,D4,X8,F16,Q32,E64):","modify:","freeze"},{"","",false},{"number","number","checkbox"})
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
      mid = math.floor((low + high) / 2)
      get = gg.getResults(high,mid)
      backup = {}
      set = {}
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
      is=false
    end
    if gg.isVisible() and high-mid > 1 then
      gg.setVisible(false)
      showChoiceDialog({
        "select",function()
          select=true
          low = mid + 1
        end,
        "filter",function()
          high = mid
        end,
        "serve",function()
          local set2 = {}
          for i = mid,high-1 do
            local value = gg.getResults(rlc)[i]
            value.freeze = promptValues[3]
            value.value = promptValues[2]
            set2[#set2+1] = value
          end
          gg.addListItems(set2)
        end
      },mid .. "~" .. high .. ":" .. high - mid)
      gg.setValues(backup)
      is=true
     elseif high-mid == 1 then
      if select then
        local set2 = {gg.getResults(rlc)[mid]}
        set2[1].name="only"
        gg.addListItems(set2)
      end
      gg.setValues(backup)
      break
     else
      gg.sleep(200)
    end
  end
end

binarySearch()
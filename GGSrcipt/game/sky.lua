local gg = _G["gg"]
local menu_selection,grass,darkness,energy_address1,energy_address2
local lwm,lwm_4,lwm_8,quality_address,fps_address,lwm_address,musical_instrument_switch_address

local function choice(t)
  local n,f = {},{}
  for i = 1,#t,2 do
    n[#n + 1] = t[i]
    f[#f + 1] = t[i + 1]
  end
  local m = gg.choice(n)
  m = m and f[m]()
end

local function memory_menu(str)
  if not menu_selection and not str then
    menu_selection=_G["main_menu"]
    menu_selection()
   elseif menu_selection and not str then
    menu_selection()
   elseif str then
    menu_selection=_G[str]
    menu_selection()
  end
end

local function loadResults(skip,loadNum,parameter,data)
  local result = skip == 0 and gg.getResults(loadNum) or gg.getResults(skip,loadNum)
  for i, v in ipairs(result) do v.isUseful = true end
  for i = 2, #parameter do
    local offset_table = {}
    local num = parameter[i][1]
    local offset = parameter[i][2]
    local flag = parameter[i][3]
    for i, v in ipairs(result) do
      offset_table[#offset_table+1] = {
        address = result[i].address + offset,
        flags = flag
      }
    end
    local tmp = gg.getValues(offset_table)
    for i, v in ipairs(tmp) do
      if (v.value ~= num)then
        result[i].isUseful = false
      end
    end
  end
  for i, v in ipairs(result) do
    if (v.isUseful) then
      data[#data+1] = v.address
    end
  end
end

local function getAddress(...)
  local parameter,data,blockSize,numBlocks = {...},{},10000
  gg.clearResults()
  gg.setVisible(false)
  gg.setRanges(parameter[1][3])
  gg.searchNumber(parameter[1][1], parameter[1][2])
  local quantity = gg.getResultCount()
  if quantity == 0 then return nil end
  if quantity > blockSize then
    numBlocks = math.ceil(quantity/blockSize)
   else
    numBlocks = 1
  end
  for blockIndex = 1, numBlocks do
    local startIdx = (blockIndex-1)*blockSize
    local endIdx = math.min(startIdx+blockSize,quantity)
    if blockIndex == numBlocks then
      blockSize = endIdx-startIdx
    end
    loadResults(startIdx,blockSize,parameter,data)
  end
  gg.clearResults()
  if (#data > 0) then
    return data[1]
  end
end

local function getValue(addres,flag)
  return gg.getValues({{address = addres,flags = flag}})[1].value
end

local function modify(...)
  local t,set = {...},{}
  for i = 1,#t do
    set[#set + 1] = {}
    set[#set].address = t[i][1]
    set[#set].flags = t[i][2]
    set[#set].value = t[i][3]
    set[#set].freeze = t[i][4]
    set[#set].name = t[i][5] and t[i][5]
  end
  gg.addListItems(set)
  gg.setValues(set)
end

local function prompt_modify(...)
  local parameter = {...}
  local valueTable = gg.getValues({{address = parameter[1],flags = parameter[2]}})
  local _p = gg.prompt({parameter[3]},{valueTable[1].value},{parameter[4]})
  if _p and _p[1] then
    modify({valueTable[1].address,valueTable[1].flags,_p[1],parameter[5],parameter[6]})
  end
end

local function fun_quality()
  local y,x,p = getValue(quality_address-36,16),getValue(quality_address-32,16),getValue(fps_address,16)
  local _p = gg.prompt({"长","宽","帧率","暗度[0;10]","草"},{y,x,p,"2",true},{"number","number","number","number","checkbox"})
  if _p and _p[1] and _p[2] and _p[3] then
    modify({quality_address,16,_p[1],true,"长"},
    {quality_address + 0x4,16,_p[2],true,"宽"},
    {fps_address,16,_p[3],true,"帧率"},
    {darkness,16,_p[4],false,"暗度"},
    {grass,16, _p[5] and 1 or 0 ,false,"草"})
    if y ~= _p[1] or x ~= _p[2] then
      gg.alert("点击拍照即可生效")
    end
  end
end

local function fun_energy()
  local value = getValue(energy_address1,16) == 3.5 and 2.5 or 3.5
  modify({energy_address1,16,value,false,"飞行充能"},{energy_address2,16,value,false,"飞行充能"})
end

local function fun_lwm()
  prompt_modify(lwm_address,4,"光翼:[0;300]","number",true,"光翼")
end

local function fun_no_wings()
  local value1 = getValue(lwm_address - 4,4) == 0 and lwm_4 or 0
  local value2 = getValue(lwm_address - 8,4) == 0 and lwm_8 or 0
  local value3 = getValue(lwm_address,4) == 0 and lwm or 0
  modify({lwm_address - 4,4,value1,true,"无翼参数"},{lwm_address - 8,4,value2,true,"无翼参数"},{lwm_address,4,value3,true,"光翼"})
end

local function init()
  local range = -2080896 | 4
  local so = gg.getRangesList("libBootloader.so")[3].start
  quality_address = getAddress({1466,4,range},{6,4,4},{1,8,4},{2,12,4})-0x1cc
  lwm_address = getAddress({81,4,range},{8,4,4},{10200,8,4})-32
  fps_address = getAddress({1919172865,4,range},{544173669,4,4},{692933672,8,4},{808859168,12,4})+0x118
  musical_instrument_switch_address= getAddress(
  {979,4,range},
  {65536,-0xf38,4},
  {257,-0xf20,4},
  {1,-0xf2c,4}
  )-0xf50
  lwm = lwm getValue(lwm_address,4)
  lwm_4 = getValue(lwm_address - 4,4)
  lwm_8 = getValue(lwm_address - 8,4)
  grass,darkness,energy_address1,energy_address2=so + 0x21274,so + 0x3014, so + 0x14624,so + 0x27AA0
  gg.showUiButton()
  memory_menu()
end

local function test()
  local parameter,data,blockSize,numBlocks = {

    {65536,4,-2080896 | 4},
    {1,12,4},
    {257,24,4},
    {979,696,4}

  },{},10000
  gg.clearResults()
  gg.setVisible(false)
  gg.setRanges(parameter[1][3])
  gg.searchNumber(parameter[1][1], parameter[1][2])
  local quantity = gg.getResultCount()
  if quantity == 0 then return nil end
  if quantity > blockSize then
    numBlocks = math.ceil(quantity/blockSize)
   else
    numBlocks = 1
  end
  for blockIndex = 1, numBlocks do
    local startIdx = (blockIndex-1)*blockSize
    local endIdx = math.min(startIdx+blockSize,quantity)
    if blockIndex == numBlocks then
      blockSize = endIdx-startIdx
    end
    loadResults(startIdx,blockSize,parameter,data)
  end
  gg.clearResults()
  if (#data > 0) then
    for c,v in ipairs(data) do
      gg.addListItems(v)
    end
  end
end

function musical_menu()
  local musical_instrument_type_address=musical_instrument_switch_address+0x38
  local function m(n)
    modify({musical_instrument_type_address,4,n,nil,"乐器类型"},{musical_instrument_switch_address,4,0,nil,"乐器开关地址"},{musical_instrument_switch_address,4,1,nil,"乐器开关地址"})
  end
  choice({
    "琴",function()choice({
        "风琴",function() m(515) end,
        "钢琴",function() m(512) end,
        "木琴",function() m(258) end,
        "木琴2",function() m(1280) end,
        "电子琴",function() m(256) end,
        "指姆琴",function() m(2048) end,
        "竖琴",function() m(0) end,
    }) end,

    "吉他",function() choice({
        "吉他",function() m(768) end,
        "圆吉他",function() m(1) end,
        "尤克里里",function() m(1024) end,
        "红色吉他",function() m(67072) end,
        "重金属吉他",function() m(1) end,
    }) end,

    "其他",function()
      choice({
        "笛",function() m(259) end,
        "鼓",function() m(2) end,
        "号角",function() m(3) end,
        "清钟",function() m(514) end,
        "琵芭",function() m(1792) end,
        "沙克斯",function() m(67331) end,
      })
    end,

    "自定义",function()
      local _p = gg.prompt({"乐器代码:"},{getValue(musical_instrument_type_address,4)},{"number"})
      if _p and _p[1] then
        m(_p[1])
      end
    end,
    "返回",function() memory_menu("main_menu") end})
end

function main_menu()
  choice({
    "画质",fun_quality,
    "能量",fun_energy,
    "光翼",fun_lwm,
    "无翼",fun_no_wings,
    "乐器",function() memory_menu("musical_menu") end,
    "test",test})
end

if not pcall(init) then return end

while true do
  if gg.isClickedUiButton() then
    memory_menu()
   else
    gg.sleep(100)
  end
end
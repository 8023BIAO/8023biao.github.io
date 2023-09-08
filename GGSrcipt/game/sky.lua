--sky gg script

local gg=_G["gg"]
local range=-2080896
local energy_address={}
local size_addtess,lwm_address,quality_address,fps_address

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

local function getValue(addres,flag)
  local val_t= gg.getValues({{address=addres,flags=flag}})
  return val_t[1].value
end

local function modify(address,type,value,freeze,name)
  local tg={}
  tg[1]={}
  tg[1].address = address
  tg[1].flags = type
  tg[1].value = value
  tg[1].freeze = freeze
  if name then
    tg[1].name = name
  end
  gg.addListItems(tg)
  gg.setValues(tg)
end

local function searchNumber(...)
  gg.clearResults()
  gg.searchNumber(...)
  local n=gg.getResultsCount()
  if n >0 then
    local table=gg.getResults(tonumber(n))
    table=gg.getValues(table)
    return table
   else
    return false
  end
end

local function refineNumber(...)
  gg.refineNumber(...)
  local n=gg.getResultsCount()
  if n >0 then
    local table=gg.getResults(tonumber(n))
    table=gg.getValues(table)
    gg.clearResults()
    return table
   else
    return false
  end
end

local function jsa(...)
  local parameter={...}
  gg.setVisible(false)
  gg.setRanges(parameter[1][3])
  if searchNumber(parameter[1][1],parameter[1][2]) then
    local t = refineNumber(parameter[2][1],parameter[2][2])
    if t then
      local val =gg.getValues({{address=(t[1].address+parameter[3][1]),flags=parameter[3][2]}})
      return val[1].address
    end
  end
end

local function jsm(...)
  local parameter={...}
  local val,address
  if not _G[parameter[5]] then
    gg.setVisible(false)
    gg.setRanges(parameter[1][3])
    if searchNumber(parameter[1][1],parameter[1][2]) then
      local t = refineNumber(parameter[2][1],parameter[2][2])
      if t then
        address =t[1].address
        val =gg.getValues({{address=(address+parameter[3][1]),flags=parameter[3][2]}})
        local _p = gg.prompt({parameter[4][1]},{val[1].value},{parameter[4][2]})
        if _p and _p[1] then
          modify(val[1].address,val[1].flags,_p[1],parameter[4][3],parameter[4][4])
        end
        _G[parameter[5]] = val[1].address
      end
    end
   else
    address = _G[parameter[5]]
    val =gg.getValues({{address=(address),flags=parameter[3][2]}})
    local _p = gg.prompt({parameter[4][1]},{val[1].value},{parameter[4][2]})
    if _p and _p[1] then
      modify(val[1].address,val[1].flags,_p[1],parameter[4][3],parameter[4][4])
    end
  end
end

local function fun_energy()
  if #energy_address>0 then
    local save_list= gg.getListItems()
    for c,v in ipairs(save_list) do
      local value=v.value
      if value==3.5 then
        modify(v.address,16,2.5,false,"飞行充能")
       elseif value==2.5 then
        modify(v.address,16,3.5,false,"飞行充能")
      end
    end
    return
  end
  gg.setVisible(false)
  gg.setRanges(8)
  local t= searchNumber(2.5,16)
  gg.clearResults()
  if not t then
    return
  end
  for i=1,2 do
    energy_address[#energy_address+1]={}
    energy_address[#energy_address]={address=t[i].address,value="3.5"}
    modify(t[i].address,16,3.5,false,"飞行充能")
  end
end

local function fun_size()
  if size_addtess then
    local val=gg.getValues({{address=size_addtess,flags=16}})
    local _p=gg.prompt({"大小:(建议-4.5到12.0)"},{val[1].value},{"number"})
    if _p and _p[1] then
      modify(size_addtess,16,_p[1],true,"大小(建议-4.5到12.0)")
    end
    return
  end
  local code="2055146880;1;1;1;1;1;1::101"
  gg.setVisible(false)
  gg.setRanges(range)
  if searchNumber(code,16) then
    local t= refineNumber(1,16)
    local val,address
    if t then
      address =t[1].address
      for i=1,0x30 do
        val=gg.getValues({{address=(address-i*0x4),flags=16}})
        if val[1].value ~= 1 and val[1].value ~= 0 then
          size_addtess=val[1].address
          break
        end
      end
      local _p=gg.prompt({"大小:(建议-4.5到12.0)"},{val[1].value},{"number"})
      if _p and _p[1] then
        modify(size_addtess,16,_p[1],true,"大小(建议-4.5到12.0)")
      end
    end
  end
end

local function fun_lwm()
  local code="1;-1275068302;403;113;81;8::41"
  local p,l="光翼:[0;300]","number"
  jsm({code,4,range},
  {1,4},
  {0x4,4},
  {p,l,true,"光翼"},"lwm_address")
end

local function fun_quality()
  local quality_code="-1275068302D;355D;1466D;6D;1D;2D:25"
  local fps_code="1D;1D;3D;-1275068302D;1919172865D;544173669D:53"
  if not fps_address or not quality_address then
    quality_address=jsa({quality_code,4,range},{-1275068302,4},{-0x1c0,16})
    fps_address=jsa({fps_code,4,range},{1,4},{0x148,16})
    local y,x,p=getValue(quality_address-36,16),getValue(quality_address-32,16),getValue(fps_address,16)
    local _p=gg.prompt({"长","宽","帧率"},{y,x,p},{"number","number","number"})
    if _p and _p[1] and _p[2] and _p[3] then
      modify(quality_address,16,_p[1],true,"长")
      modify(quality_address+0x4,16,_p[2],true,"宽")
      modify(fps_address,16,_p[3],true,"帧率")
      gg.alert("点击拍照即可生效")
    end
   else
    local y,x,p=getValue(quality_address,16),getValue(quality_address+4,16),getValue(fps_address,16)
    local _p=gg.prompt({"长","宽","帧率"},{y,x,p},{"number","number","number"})
    if _p and _p[1] and _p[2] and _p[3] then
      modify(quality_address,16,_p[1],true,"长")
      modify(quality_address+0x4,16,_p[2],true,"宽")
      modify(fps_address,16,_p[3],true,"帧率")
      gg.alert("点击拍照即可生效")
    end
  end
end

local function about()
  local info=[[
  sky gg script by:biao 
  
  使用此脚本修改内存后果自负
  此脚本无影响其他玩家游戏体验
  后续更新也不会添加对其他玩家影响游戏体验的功能
  
  功能来源:
  飞行充能:bili UID:472209835视频
  改变大小:bili UID:155740141专栏
  改变光翼:自己手抓
  改分辨率与帧率:自己手抓
  
  脚本开源更新地址:
  https://8023biao.github.io/GGSrcipt/sky.lua
  
  ]]
  gg.alert(info)
end

local _pm=gg.getTargetPackage()
local path=gg.EXT_CACHE_DIR.."/sky"

if _pm~="com.tgc.sky.android" then
  local _m=gg.alert("检测包名为:".._pm.."\n仅支持sky国际服(com.tgc.sky.android)\n\n\n如果包名选择错误请重新选择\n如果在虚拟空间运行检测到包名不一样可以点击继续","继续","退出")
  if _m~=1 then
    return
  end
end

if not io.open(path,"r") then
  local info="首次执行此脚本\n仅支持国际服\n无影响其他玩家游戏体验\n\n环境配置:\nroot优先，其次虚拟机，不推荐虚拟空间\n游戏隐藏2和3\n\n注意:\n因需修改内存\n修改后果自负\n"
  local _m=gg.alert(info,"同意","退出")
  if _m and _m==1 then
    io.open(path,"w"):close()
   else
    return
  end
end

local function main()
  choice(
  "飞行充能",fun_energy,
  "改变大小",fun_size,
  "改变光翼",fun_lwm,
  "自定义分辨率",fun_quality,
  "关于脚本",about)
end

gg.showUiButton()
while true do
  if gg.isClickedUiButton() then
    main()
  end
  gg.sleep(200)
end


--[[
地址定位为什么这样写？
不用常见的特征码写法，因o内存数据太大
目前无法抓到有效基址，无奈用联合搜索+偏移获取地址
地址定位速度与方法待优化

功能来源:
飞行充能:bili UID:472209835视频
改变大小:bili UID:155740141用户专栏
改变光翼:自己手抓
改分辨率与帧率:自己手抓

]]

--提示
function Toast(str)
  gg.toast(str)
end

--弹窗
function Alert(...)
  return gg.alert(...)
end

--复制
function copyText(str)
  gg.copyText(str)
end

--路径改后缀
function PathMatch(path,l)
  return path:match("(.*)%.lua").."_"..l..".lua"
end

--写出文件
function Writer(path,data)
  if path and data then
    local file = io.open(path,"w+b")
    io.output(file)
    io.write(data)
    io.close(file)
  end
end

--读取文件
function Reader(path)
  if path then
    local file = io.open(path, "r")
    io.input(file)
    local data = io.read("*a")
    io.close(file)
    return data
  end
end

--字符替换(bilibili小鳄鱼)
function func_env(code,cok)
  for k,v in pairs(_ENV) do
    local t=type(v)
    if t == "table" then
      for kk,vv in pairs(v) do
        code=code:gsub(k .."%s+%.%s+" .. kk, "_ENV['"..k .."']['" .. kk .."']")
      end
     elseif t == "function" then
      if cok then
        --这一行有错误
        code=code:gsub(k .."%s*%(", "_ENV['" ..k .."'](")
      end
    end
  end
  return code
end

function stringToChars(inputString)
  local data=table.concat({string.byte(inputString,1,-1)},',')
  data= "string.char("..data..")"
  return data
end

function ASCLL(code)
  code=string.gsub(code,"\39(.-)\39",stringToChars)
  code=string.gsub(code,"\34(.-)\34",stringToChars)
  return code
end

--混淆代码(Lua手册用户上传 没留名)
function Tabgsub(str,tab_in,tab_from)
  str = tostring(str)
  for k,v in ipairs(tab_in) do
    v = tostring(v)
    if type(tab_from)=="table" then
      str = str:gsub(v,tab_from[k])
     else
      str = str:gsub(v,tab_from)
    end
  end
  return str
end

math.randomseed(os.time())
math.random(1)
function Rand(num)--生成混淆码
  local tab={"O","o","0"}
  local str=tab[math.random(1,#tab-1)]
  for i=1,num-1 do
    str = str..tab[math.random(1,#tab)]
  end
  return str
end

local inf={
  "=","= +=",
  " +",
  "%. +"," +%.",
  "%[ +"," +]","%] +%["

}

local from={
  " = ","==",
  " ",
  ".",".",
  "[","]","]["

}

function getInt(code)--获得变量
  local str=""
  local tab={}
  for k in code:gmatch("(%S+) = ") do
    if not str:find(k) and not k:find("%[") and not k:find("%.")and not k:find("%-%-") then
      tab[#tab+1]=k
      str = str..k.." "
    end
  end
  return tab
end

function table_find(t, value)
  for k, v in pairs(t) do
    if v == value then
      return k
    end
  end
  return nil
end

local Man={}
function IntForm(code)--调用此函数用于更新混淆
  if Man[code]==nil then
    local hx
    while true do
      hx=Rand(8)
      if not table_find(Man,hx) then
        break
      end
    end
    Man[code]=hx
  end
  return Man[code]
end

function Hxgsub(code,tab)
  code = "<"..code..">"--此处负责执行替换动作
  for k,v in ipairs(tab) do
    code = code:gsub("(.)("..v..")(.)",function(r1,r2,r3)
      -- r1,r2,r3=tostring(r1),tostring(r2),tostring(r3)
      if r1:find("[%w_]") or r3:find("[%w_]") and not r1:find("=") then
        return r1..r2..r3
       else
        return r1..IntForm(r2)..r3
      end
    end)
  end
  return code:gsub("^<",""):gsub(">$","")
end

function Automatic_encryption()
  local list=gg.prompt({"请选择文件"},{"/sdcard/"},{"file"})
  if list and list[1] then
    local path=list[1]
    if loadfile(path) then
      local code="\n"..Reader(path)
      local NewFilePath=PathMatch(path,"encryption")
      local new_code=code
      local fail=""

      for l in string.gmatch(code,".-\n") do
        if string.find(l,"gg%.[%w_]+") then
          local ff=(l:match("(gg%.[%w_]+)%s?%p?"))
          code=code:gsub(ff,"_ENV".."[\"gg\"]".."[\""..ff:match("^.*%.(.*)$").."\"]")
        end
      end

      if load(code) then
        new_code=code
       else
        new_code=new_code
        code=new_code
        fail="ENV[gg_function]失败\n"
      end

      new_code=func_env(new_code,true)

      if load(new_code) then
        new_code=new_code
        code=new_code
       else
        new_code=code
        fail=fail.."ENV[function]失败\n"
      end

      new_code=func_env(new_code)

      if load(new_code) then
        new_code=new_code
        code=new_code
       else
        new_code=code
        fail=fail.."ENV[table]失败\n"
      end

      new_code=ASCLL(new_code)

      if load(new_code) then
        new_code=new_code
        code=new_code
       else
        new_code=code
        fail=fail.."字符转数字失败\n"
      end

      local rcode=Tabgsub(new_code,inf,from)
      new_code=Hxgsub(new_code,getInt(rcode))

      if load(new_code) then
        new_code=new_code
        code=new_code
       else
        new_code=code
        fail=fail.."混淆变量失败\n"
      end

      Writer(NewFilePath,new_code)

      local str=loadfile(NewFilePath)
      if str then
        local uncode=string.dump(str)
        Writer(NewFilePath,uncode)
        Alert("完成\n"..fail)
       else
        Alert("文件无法运行，编译失败\n"..fail)
      end

     else
      Toast("这个文件无法运行")
    end
  end
end

gg.showUiButton()
while true do
  if gg.isClickedUiButton() then
    Automatic_encryption()
  end
end
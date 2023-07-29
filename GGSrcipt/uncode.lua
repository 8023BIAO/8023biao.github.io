
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

--选择文件
function Select_file()
  local path = gg.getFile() or "/sdcard/"
  local menu = gg.prompt({"请选择脚本"}, {path}, {"file"})
  if menu then
    return menu[1]--返回路径
  end
end

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

--编译代码
function compile_code(code)
  if code then
    code=load(code)
    code=string.dump(code)
    return code
  end
end

--编译文件
function compile_file(path)
  if path then
    local str=loadfile(path)
    local uncode=string.dump(str)
    Writer(path:match("(.*)%.lua").."_compile.lua",uncode)
    return true
  end
end

--一次性简易加密
local One_time_encryption={}

One_time_encryption.to_hex=function(str)
  return (string.gsub(str,'.', function(c)
    return string.format('%02X', string.byte(c))
  end))
end

One_time_encryption.mix_string=function(str, password)
  local mixed = {}
  for i = 1, #str do
    local c = string.char((string.byte(str, i) + string.byte(password, (i - 1) % #password + 1)) % 256)
    table.insert(mixed, c)
  end
  return table.concat(mixed)
end

One_time_encryption.encode=function(password, code)
  local mixed_code = One_time_encryption.mix_string(code, password)
  local hex_code = One_time_encryption.to_hex(mixed_code)
  return hex_code
end

One_time_encryption.readme=[=[--[[

适用版本：适用于 Lua 5.1 及以上版本。

通用性：这段代码实现了一个简单的加密和解密算法，可以在多种场景下使用。它通过混合字符串和密码来实现加密，并使用十六进制表示加密后的字符串。解密时，使用相同的密码进行反向操作。这使得该算法具有一定程度的通用性。

优点：
实现简单：这个算法的实现非常简单，不需要引入复杂的第三方库。
易于理解：代码结构清晰，容易理解其工作原理。

缺点：
安全性较低：由于算法本身较为简单，其安全性相对较低，可能容易被破解。
依赖 Lua 的 string 库：这段代码依赖于 Lua 的 string 库，因此在不支持该库的环境中无法使用。

意义：这段代码为 Lua 提供了一个简单的加密和解密方法，可以帮助开发者在不引入复杂第三方库的情况下实现基本的加密功能。这对于学习和实践 Lua 编程是有益的。

其他：虽然这个算法具有一定的通用性和易用性，但在实际生产环境中，建议使用更为成熟和安全的加密算法，如 AES、RSA 等。这些算法在安全性方面有更好的保障，且已经有成熟的第三方库可供使用。

用途:
这段代码的主要用途是在 Lua 程序中实现简单的字符串加密和解密功能。具体应用场景可能包括：
保护数据：对存储或传输的敏感数据进行加密，以防止未经授权的访问和篡改。例如，在文件存储、网络通信等场景中，可以使用此加密方法来保护文本数据。
验证信息：通过加密和解密过程，验证发送方和接收方是否拥有相同的密码。这可以用于简单的身份验证或授权操作。
学习和教学：这段代码可以作为学习和教学 Lua 编程的实例，帮助初学者了解字符串操作、函数定义和调用等基本概念。

注意:虽然这段代码具有一定的实用性，但由于其安全性较低，不建议在生产环境中用于处理高度敏感和安全性要求较高的数据。
]]

]=]

--要写入解密函数
One_time_encryption.code_config=[=[local function from_hex(hex)
  return (string.gsub(hex,'..', function(cc)
    return string.char(tonumber(cc, 16))
  end))
end

local function unmix_string(mixed, password)
  local unmixed = {}
  for i = 1, #mixed do
    local c = string.char((string.byte(mixed, i) - string.byte(password, (i - 1) % #password + 1)) % 256)
    table.insert(unmixed, c)
  end
  return table.concat(unmixed)
end

local function decode(hex_code, input_password)
  local mixed_code = from_hex(hex_code)
  local decrypted_code = unmix_string(mixed_code, input_password)
  return decrypted_code
end]=]

--直接加密(解密后显示源码)
One_time_encryption.Direct_encryption=function(password,code)
  local encode=(One_time_encryption.encode(password,code))
  local uncode=One_time_encryption.readme..One_time_encryption.code_config.."\n"..[[local code="]].. encode .. [[" return pcall(load(decode(code,"这里输入密码"))) ]]
  return uncode--返回加密后的字符串
end

--加密前再编译一次(解密后显示编译的代码)
One_time_encryption.compile_encode=function(password,code)
  local compile_encode=string.dump(load(code))
  local encode=(One_time_encryption.encode(password,compile_encode))
  local uncode=One_time_encryption.readme..One_time_encryption.code_config.."\n"..[[local code="]].. encode .. [[" return pcall(load(decode(code,"这里输入密码"))) ]]
  return uncode--返回加密后的字符串
end

One_time_encryption.Menu=function(mod)
  local path = "/sdcard/"
  local menu = gg.prompt({"请选择脚本","密码"}, {path,"这里输入密码"}, {"file","text"})
  if menu and menu[1] and menu[2]~="" then
    path=menu[1]
    if loadfile(path) then
      local password=menu[2]
      local code=Reader(path)
      mod(path,password,code)
    end
  end
end

--使用例子
--local code=[[print("测试成功")]]
--local c=One_time_encryption.compile_encode("这里输入密码",code)
--local c=One_time_encryption.Direct_encryption("这里输入密码",code)
--gg.alert(c)
--print(c)
--load(c)()

local uncode={}

function uncode.env(code,cok)
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

function uncode.stringToChars(inputString)
  local data=table.concat({string.byte(inputString,1,-1)},',')
  data= "string.char("..data..")"
  return data
end

function uncode.ASCLL(code)
  code=string.gsub(code,"\39(.-)\39",uncode.stringToChars)
  code=string.gsub(code,"\34(.-)\34",uncode.stringToChars)
  return code
end

--混淆2代码
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
    if not str:find(k) and not k:find("%[") and not k:find("%.") and not k:find("%-%-") then
      tab[#tab+1]=k
      str = str..k.." "
    end
  end
  return tab
end

function table.find(tbl, value)
  for key, val in pairs(tbl) do
    if val == value then
      return key
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
      if not table.find(Man,hx) then
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
      if r1:find"%a" or r3:find"%a" and not r1:find"=" then
        return r1..r2..r3
       else
        return r1..IntForm(r2)..r3
      end
    end)
  end
  return code:gsub("^<",""):gsub(">$","")
end


--显示按钮
gg.showUiButton()
local Menu --储存现在菜单

--现在菜单
function M(str)
  if not Menu and not str then
    Menu=_G["main"]
    Menu()
   elseif Menu and not str then
    Menu()
   elseif str then
    Menu=_G[str]
    Menu()
  end
end

function main()
  local list= gg.choice({
    "测试",
    "临时加密",
    "退出",
  });

  if list==1 then
    M("encryption")
   elseif list==2 then
    M("One_time_encryption_view")
   elseif list==3 then
    os.exit()
  end

end

function encryption()
  local list = gg.prompt(
  {
    [1]="请选择文件",
    [2]="替换变量",
    [3]="字符转数字",
    [4]="函数转数字",
    [5]="gg函数转数字",
    [6]="编译"},
  {
    [1]="/sdcard/",
    [2]=true,
    [3]=true,
    [4]=true,
    [5]=true,
    [6]=true,
  },
  {
    "file",
    "checkbox",
    "checkbox",
    "checkbox",
    "checkbox",
    "checkbox",
  })

  if list and list[1] then--确定了
    local path=list[1]--获取路径
    local test=loadfile(path)--检测是否没问题
    if test then
      local code="\n"..Reader(path)--读取文件内容
      local NewFilePath=PathMatch(path,"encryption")

      if list[5] then
        --gg函数混淆
        for l in string.gmatch(code,".-\n") do
          if string.find(l,"gg%.[%w_]+") then
            local ff=(l:match("(gg%.[%w_]+)%s?%p?"))
            code=code:gsub(ff,"_ENV".."[\"gg\"]".."[\""..ff:match("^.*%.(.*)$").."\"]")
          end
        end
      end

      if list[4] then
        --函数改env
        code=uncode.env(code,true)
       else
        code=uncode.env(code)
      end

      if list[3] then
        --字符串改char
        code=uncode.ASCLL(code)
      end

      if list[2] then
        --混淆变量
        local rcode=Tabgsub(code,inf,from)
        code=Hxgsub(code,getInt(rcode))
      end

      if list[6] then
        Writer(NewFilePath,code)
        xpcall(function()
          local str=loadfile(NewFilePath)
          if str then
            local uncode=string.dump(str)
            Writer(NewFilePath,uncode)
            Toast("编译完成")
           else
            os.remove(NewFilePath)
            Alert("失败了\n(未适配，目前bug和漏洞多)")
          end
          end,function(e)
          os.remove(NewFilePath)
          local t=Alert("出错了:\n"..e,"复制","确定")
          if t==1 then
            copyText(e)
          end
        end)
       else
        Writer(NewFilePath,code)
      end
      Toast("已完成")
     else
      Toast("这是一个不能执行的文件")
    end
   else
    M("main")
  end

end

function One_time_encryption_view()
  local list= gg.choice({
    "modle1(解密后显示源码)",
    "modle2(解密后显示编译的代码)",
    "返回",
  });
  if list==1 then
    One_time_encryption.Menu(function(path,password,code)
      local uncode=One_time_encryption.Direct_encryption(password,code)
      Writer(path:match("(.*)%.lua").."_Direct_encryption.lua",uncode)
      Alert("加密已完成")
    end)
   elseif list==2 then
    One_time_encryption.Menu(function(path,password,code)
      local uncode=One_time_encryption.compile_encode(password,code)
      Writer(path:match("(.*)%.lua").."_compile_encode.lua",uncode)
      Alert("加密已完成")
    end)
   elseif list==3 then
    M("main")
  end
end

while true do
  --判断按钮点击和包名
  if gg.isClickedUiButton() then
    M()
  end
end
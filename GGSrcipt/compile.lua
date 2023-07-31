
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

function to_hex(str)
  return (string.gsub(str,'.', function(c)
    return (string.format('%2X', string.byte(c)))
  end))
end

--ChatGPT 4 优化代码 lua手册用户上传代码 名字忘了
local reserved = {
  ["and"]=true, ["break"]=true,["do"]=true,["else"]=true,
  ["elseif"]=true,["end"]=true,["false"]=true, ["for"]=true,
  ["function"]=true, ["if"]=true,["in"]=true,["local"]=true,
  ["nil"]=true,["not"]=true, ["or"]=true,["repeat"]=true,
  ["return"]=true, ["then"]=true, ["true"]=true, ["until"]=true,
  ["while"]=true, --其他关键字

  ["_G"]=true, ["type"]=true, ["pairs"]=true, ["ipairs"]=true,
  ["tostring"]=true, ["tonumber"]=true, ["print"]=true, --系统全局变量

}

--不需要的匹配结果
local exclude={
  "^(%d+)$"
}

function getInt(code)
  local varList = {}
  for k in code:gmatch("([%w_]+)%s*[,=]") do
    if not reserved[k] then
      for c,v in pairs(exclude) do
        if not k:find(v) then
          varList[#varList+1] = k
        end
      end
    end
  end
  return varList
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

function obfuscateCode(code)
  local variables = getInt(code)
  local replacements = {}

  for _, variable in ipairs(variables) do
    local newVar
    repeat
      newVar = Rand(math.random(3,8))
    until not replacements[newVar]
    replacements[variable] = newVar
  end

  for variable, newVar in pairs(replacements) do
    local pattern = "([^%w_])(" .. variable .. ")([^%w_])"
    code = code:gsub(pattern, "%1" .. newVar .. "%3")
  end

  return code
end

--一次性简易加密(Chatgpt3.5)
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

--直接加密
One_time_encryption.Direct_encryption=function(password,code)
  local encode=(One_time_encryption.encode(password,code))
  local uncode=One_time_encryption.readme..One_time_encryption.code_config.."\n"..[[local xcode="]].. encode .. [[" return pcall(load(decode(xcode,"这里输入密码"))) ]]
  return uncode--返回加密后的字符串
end

function Automatic_encryption()
  local list=gg.prompt({"要编译的源文件","套壳层数[0;10]","密码(不设置就点 确定 )"},{"/sdcard/","3","这里输入密码"},{"file","number","text"})
  if list and list[1] then
    local path=tostring(list[1])
    if loadfile(path) then
      local code="\n"..Reader(path).." "
      if load(code) then
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
          fail="ENV[gg函数]失败\n"
        end

        new_code=func_env(new_code,true)

        if load(new_code) then
          new_code=new_code
          code=new_code
         else
          new_code=code
          fail=fail.."ENV[函数]失败\n"
        end

        new_code=func_env(new_code)

        if load(new_code) then
          new_code=new_code
          code=new_code
         else
          new_code=code
          fail=fail.."ENV[表]失败\n"
        end

        new_code=ASCLL(new_code)

        if load(new_code) then
          new_code=new_code
          code=new_code
         else
          new_code=code
          fail=fail.."字符转ASCLL失败\n"
        end

        new_code=obfuscateCode(new_code)

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
          local uncode=string.dump(str,false)
          Writer(NewFilePath,uncode)

          --重复刷16进制代码并执行
          if list[2] and tonumber(list[2])>=1 then
            for i=0,tonumber(list[2]) do
              local unc=Reader(NewFilePath)
              local xuncode="--防纯小白,其他啥都不防\n local Biao=\"".. to_hex(unc) .."\"\nfunction from_hex(hex)\nreturn (string.gsub(hex,'..', function(cc)\nreturn string.char(tonumber(cc, 16))\nend))\nend\nreturn pcall(load(from_hex(Biao))())"
              Writer(NewFilePath,xuncode)
            end
          end

          if list[3] and tostring(list[3])~="这里输入密码" then--not (tostring(list[3]):match("^%s*$")) then
            local xuncode=One_time_encryption.Direct_encryption(tostring(list[3]),Reader(NewFilePath))
            Writer(NewFilePath,xuncode)
          end

          if loadfile(NewFilePath) then
            Alert("完成\n"..fail)
           else
            Alert("失败了\n"..fail)
            os.remove(NewFilePath)
          end

         else
          Alert("文件无法运行，编译失败\n"..fail)
        end


       else
        Alert("不支持已编译文件")
      end
     else
      Toast("路径错误或文件无法运行")
    end
  end
end

gg.showUiButton()
while true do
  if gg.isClickedUiButton() then
    Automatic_encryption()
  end
end

--[[
biao(智障)学习之作(cv大法之作)，就是一个普通(辣鸡)的编译(都不能说加密，有辱这两个字)
防纯小白 其他啥都不防 代码上面自己看 

肯定会有人说“抄袭，不要脸!就是泛滥东西。学基础要去圈？辣鸡东西难道需要加密吗？”这类等等。
第一:我已注明来源或作者，尊重作者。
第二:我就不能学习了吗？虽然我很智障。
第三:没想过圈，倒是被圈不少于1000，我进厂不比这个来的快？还不费脑子，真看不上这个....
第四:开源(虽然是辣鸡，但是...没啥想说了，你说的对)
第五:有没有一种可能，就是说 我是说如果啊 我这样的小白写这个加密(就是一个编译)(或者说使用这个加密后的文件)想分享给使用gg修改器的朋友面前装个逼？就是不想让他看见源代码(朋友同小白)
第六:你说的都对，我已经表明所有想法和开源代码。你还要我怎么样？
第七:我这个盾已经套满了，如果你还想攻击我的话我也没辙了。

学习结果如下:
16进制储存数据:多层套壳就是浪费储存空间，内存，性能,感觉除了储存数据，没啥用。
字符串转ascll:加密基础，隐藏编译后显示。也就仅此了
变量混淆:加密基础,隐藏编译后显示，感觉还可以再加大混淆的学习
]]
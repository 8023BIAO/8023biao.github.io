
--弹窗
local function Alert(...)
  return gg.alert(...)
end

--路径改后缀
local function PathMatch(path,l)
  return path:match("(.*)%.?l?u?a?").."_"..l..".lua"
end

--写出文件
local function Writer(path,data)
  if path and data then
    local file = io.open(path,"w+b")
    io.output(file)
    io.write(data)
    io.close(file)
  end
end

--读取文件
local function Reader(path)
  if path then
    local file = io.open(path, "r")
    io.input(file)
    local data = io.read("*a")
    io.close(file)
    return data
  end
end

--字符替换
local func_env = function(code, cok)
  local new_code = code
  local env = _ENV

  for k,v in pairs(env) do
    local t = type(v)
    if t == "table" then
      for kk,vv in pairs(v) do
        new_code = string.gsub(new_code, k.."(%s+%.%s+"..kk, "_ENV['"..k.."']['"..kk.."]")
      end
     elseif t == "function" and cok then
      new_code = string.gsub(new_code, k.."%s*%(", "_ENV['"..k.."'](")
    end
  end

  return new_code
end

local function stringToChars(inputString)
  local data=table.concat({string.byte(inputString,1,-1)},',')
  data= "string.char("..data..")"
  return data
end

local function ASCLL(code)
  code=string.gsub(code,"\39(.-)\39",stringToChars)
  code=string.gsub(code,"\34(.-)\34",stringToChars)
  return code
end

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
  "^(%d+)$",
}

local function getInt(code)
  local varList = {}

  --变量
  for k in code:gmatch("([%w_]+)%s*[,=]") do
    if not reserved[k] then
      for c,v in pairs(exclude) do
        if not k:find(v) then
          varList[#varList+1] = k
        end
      end
    end
  end

  --goto 标签
  for k in code:gmatch("::%s*([%w_]+)%s*::") do
    if not reserved[k] then
      for c,v in pairs(exclude) do
        if not k:find(v) then
          varList[#varList+1] = k
        end
      end
    end
  end

  --函数
  for k in code:gmatch("function%s+([%w_]+)%s*%(.-%)") do
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

local function Rand(num)--生成混淆码
  local tab={"O","o","0"}
  local str=tab[math.random(1,#tab-1)]
  for i=1,num-1 do
    str = str..tab[math.random(1,#tab)]
  end
  return str
end

local function obfuscateCode(code)
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
  local uncode=One_time_encryption.code_config.."\n"..[[local xcode="]].. encode .. [[" return pcall(load(decode(xcode,"这里输入密码"))) ]]
  return uncode--返回加密后的字符串
end

local function Automatic_encryption()
  local list=gg.prompt({"源文件:","套壳层数:[0;10]","密码:"},{"/sdcard/","3","这里输入密码"},{"file","number","text"})
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
          fail="_ENV[gg函数]失败\n"
        end

        new_code=func_env(new_code,true)

        if load(new_code) then
          new_code=new_code
          code=new_code
         else
          new_code=code
          fail=fail.."_ENV[函数]失败\n"
        end

        new_code=func_env(new_code)

        if load(new_code) then
          new_code=new_code
          code=new_code
         else
          new_code=code
          fail=fail.."_ENV[表]失败\n"
        end

        new_code=ASCLL(new_code)

        if load(new_code) then
          new_code=new_code
          code=new_code
         else
          new_code=code
          fail=fail.."字符转Ascll失败\n"
        end

        new_code=obfuscateCode(new_code)

        if load(new_code) then
          new_code=new_code
          code=new_code
         else
          new_code=code
          fail=fail.."变量混淆失败\n"
        end

        Writer(NewFilePath,new_code)

        local str=loadfile(NewFilePath)
        if str then
          local uncode=string.dump(str,false)
          Writer(NewFilePath,uncode)

          --重复刷16进制代码并执行
          if tonumber(list[2])>=1 then
            for i=0,tonumber(list[2]) do
              local unc=Reader(NewFilePath)
              local xuncode="local Biao=\"".. One_time_encryption.to_hex(unc) .."\"\nfunction from_hex(hex)\nreturn (string.gsub(hex,'..', function(cc)\nreturn string.char(tonumber(cc, 16))\nend))\nend\nreturn pcall(load(from_hex(Biao))())"
              Writer(NewFilePath,xuncode)
            end
          end

          if not (tostring(list[3]):match("^%s*$")) then
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
      Alert("路径错误或文件无法运行")
    end
  end
end

gg.showUiButton()

while true do
  if gg.isClickedUiButton() then
    Automatic_encryption()
  end
end
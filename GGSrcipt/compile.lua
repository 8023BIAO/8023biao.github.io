
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

--ChatGPT 4 提供代码
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
    until not replacements[newVar] -- Ensure unique replacement names

    replacements[variable] = newVar
  end

  -- Create a pattern for each variable and replace it with the new name
  for variable, newVar in pairs(replacements) do
    local pattern = "([^%w_])(" .. variable .. ")([^%w_])"
    code = code:gsub(pattern, "%1" .. newVar .. "%3")
  end

  return code
end

function Automatic_encryption()
  local list=gg.prompt({"请选择要编译的源文件"},{"/sdcard/"},{"file"})
  if list and list[1] then
    local path=list[1]
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
          local uncode=string.dump(str)
          Writer(NewFilePath,uncode)
          Alert("完成\n"..fail)
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
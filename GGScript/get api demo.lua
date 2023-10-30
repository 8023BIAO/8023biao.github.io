
local function alertError(str)
  str = tostring(str)
  local e = gg.alert(str,"复制","关闭")
  if e and e == 1 then
    gg.copyText(str)
  end
end

--local text = {} -- 储存对话文本
local url = "http://ovoa.cc/api/Bing.php?msg="

::Request:: 

local prompt = gg.prompt({"输入内容:"},{""},{"text"})

if not prompt then
  return
 elseif prompt[1]:match("^%s*$") then
  goto Request
end

local result = gg.makeRequest(url .. prompt[1])
local code = result['code']
if code == 200 then
  local content = result['content']
  
  --可以使用json 这里选择简单的lua正则匹配
  local content2 = result['content']:match('"content":%s+"(.*)"')
  local code2 = result['content']:match('"code":%s+(.-),')
  local msg = result['content']:match('"msg":%s+"(.-)"')
  
  if msg:find("获取成功") and code2:find("200") and not content2:match("^%s*$") then
 
    -- local text = {} --单次对话显示
    text[#text+1] = "我:\n" .. prompt[1]
    text[#text+1] = "它:\n" .. content2:gsub("\\n","\n"):gsub("```"," "):gsub("\\\""," "):gsub("`"," ")
   else
    alertError(content)
  end
 else
  alertError(result)
end

::show::

local showcontent = table.concat(text,'\n\n')

local m = gg.alert(showcontent,"重问","复制","关闭")
if m then
  if m == 1 then
    goto Request 
   elseif m == 2 then
    gg.copyText(showcontent)
    goto show 
  end
end

--[[
gg get chatgpt api demo 


小虫api : http://ovoa.cc/api/
api无法连续对话 只能一问一答

]]
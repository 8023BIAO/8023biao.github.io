local code=gg.makeRequest('https://8023biao.github.io/GGSrcipt/sky.lua').content
if code then
  xpcall(load(code)(),function(e)
    gg.alert(e)
  end)
end
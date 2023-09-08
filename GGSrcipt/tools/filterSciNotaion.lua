local gg=_G["gg"]
local delTable={}
local r = gg.getResults(gg.getResultCount())
if #r > 0 then
  local blockSize = 1024*10
  local numBlocks = math.ceil(#r / blockSize)
  for blockIndex = 1, numBlocks do
    local startIdx = (blockIndex - 1) * blockSize + 1
    local endIdx = math.min(blockIndex * blockSize, #r)
    for j = startIdx, endIdx do
      local valueTable=r[j]
      local value=tostring(valueTable.value)
      if value:find("inf") or value:find("E") then
        delTable[#delTable+1]=valueTable
      end
    end
  end
end
gg.removeResults(delTable)
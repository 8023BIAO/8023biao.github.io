--清除搜索数据
gg.clearResults()
--显示按钮
gg.showUiButton()

KG=true
--无限循环
while KG do

  --判断按钮点击
  if gg.isClickedUiButton() then

::biao::--标签

    local bm=gg.getTargetPackage()
    local sj=os.date("%Y-%m-%d %H:%M:%S")
    local title="\n当前时间:"..sj.."\n当前进程包名："..bm

    --GG单选择列表
    local list=gg.choice({
      "选项1",
      "选项2",
      "测试",
      "多选择",
      "编辑框",
      "结束脚本",
    },nil,title)--参数({列表,Boolean值,字符串})

    if list ==1 then
      --弹出窗口
      local gga= gg.alert("提示内容","取消","返回","积极")--参数(小标题,"消极","中立","积极")

      if gga ==1 then
        --nil
       elseif gga == 2 then
        goto biao;--通过标签返回主页面
       elseif gga == 3 then
        --积极事件

      end

     elseif list == 2 then
      --弹出窗口
      local gga= gg.alert("提示2","取消","返回","积极")--参数(小标题,"消极","中立","积极")

      if gga ==1 then
        --nil
       elseif gga == 2 then
        goto biao;--通过标签返回主页面
       elseif gga == 3 then
        --积极事件
      end

     elseif list == 3 then
      local e ,er= pcall(function()

        gg.alert()

      end)

      if not e then
        gg.alert("发生错误:\n"..tostring(er))
      end

     elseif list== 4 then
      --multi=多种
      --Choice=选择
      --table=表、表格
      --selection=选择
      --message=消息、信息
      local gga= gg.multiChoice({
        "第一个",
        "第二个",
        "第三个",
        "第四个",
      },nil,"小标题")

      if gga then
        gg.alert(tostring(gga))
      end

     elseif list==5 then
      local t= gg.prompt(
      {"第一个","第二个"},--编辑框
      {[1]=185,[2]=10},--默认值
      {[1]='number',[2]='number'})--类型

      if t then
        --搜索参数
        local str,types=t[1].."D;"..t[2].."D::",gg.TYPE_DWORD
        --搜索数值--真
        if (gg.searchNumber(str,types)) then
          --[[
          搜索地址(地址,-1,类型,gg.SIGN_EQUAL, 0, -1)
          gg.searchAddress("B3BFA1BC",-1, gg.TYPE_DWORD, gg.SIGN_EQUAL, 0, -1)

          ]]
          --获取搜索结果数量
          local nc=gg.getResultsCount()

          if tonumber(nc)>0 then
            --获取全部搜索结果
            local tb=gg.getResults(tonumber(nc))
            --转成获取值
            tb=gg.getValues(tb)

            local diz,mz=tb[1].address,tb[1].value

            local tg={}
            tg[1]={}
            tg[1].address = diz--地址(tb[1].addrees)
            tg[1].flags = gg.TYPE_DWORD--类型
            --tg[1].freeze =  true --冻结
            tg[1].value =mz --值(tb[1].value)

            --添加到保存数据
            gg.addListItems(tg)
            --设置列表
            gg.setValues(tg)
            --清除搜索数据
            gg.clearResults()
          end


        end

      end

     elseif list==6 then
      KG=nil--通过赋值nil关闭无限循环
      -- os.exit()--这样也可以
    end --listend


  end
end

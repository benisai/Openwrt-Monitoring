local function scrape()
  wanip_metrics =  metric("wan_info", "gauge" )
  for e in io.lines("/tmp/wanip.out") do
    local fields = space_split(e)
    local wanip, publicip, internet;
    internet = 0;
    for _, field in ipairs(fields) do
      if wanip == nil and string.match(field, '^wanip') then
        wanip = string.match(field,"wanip=([^ ]+)");
      elseif publicip == nil and string.match(field, '^publicip') then
        publicip = string.match(field,"publicip=([^ ]+)");
      elseif string.match(field, '^internet') then
        local b = string.match(field, "internet=([^ ]+)");
        internet = internet + b;
      end

    end
     local labels = { wanip = wanip, publicip = publicip }
		    wanip_metrics(labels, internet )
  end
end

return { scrape = scrape }

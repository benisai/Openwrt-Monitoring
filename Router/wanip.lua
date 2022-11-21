local function scrape()
  local wantest = space_split(get_contents("/tmp/wanip.out"))
  metric("router_wan_ip", "gauge", nil, wantest[1])
  metric("router_public_ip", "gauge", nil, wantest[2])
  metric("router_internet_status", "gauge", nil, wantest[3])
end

return { scrape = scrape }

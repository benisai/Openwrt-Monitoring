local function scrape()
  local speedt = space_split(get_contents("/tmp/wanip.out"))

  metric("router_wan_ip", "gauge", nil, speedt[1])
  metric("router_public_ip", "gauge", nil, speedt[2])
  metric("router_internet_status", "gauge", nil, speedt[3])
end

return { scrape = scrape }

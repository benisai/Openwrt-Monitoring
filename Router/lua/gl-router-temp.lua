local function scrape()
  local routertemp = space_split(get_contents("/tmp/tempstats.out"))

  metric("router_temp", "gauge", nil, routertemp[1])
  metric("router_fan_speed", "gauge", nil, routertemp[2])
end

return { scrape = scrape }

local function scrape()
  local vnstatmonth = space_split(get_contents("/tmp/vnstatmonth.out"))

  metric("router_vnstat_month_download", "gauge", nil, vnstatmonth[1])
  metric("router_vnstat_month_upload", "gauge", nil, vnstatmonth[2])

end

return { scrape = scrape }

local function scrape()
  local speedt = space_split(get_contents("/tmp/speedtest.out"))

  metric("router_speedtest_download", "gauge", nil, speedt[1])
  metric("router_speedtest_upload", "gauge", nil, speedt[2])
end

return { scrape = scrape }

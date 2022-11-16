local function scrape()
  local speedt = space_split(get_contents("/tmp/speedtest.out"))

  metric("node_load1", "gauge", nil, speedt[1])
  metric("node_load5", "gauge", nil, speedt[2])
  metric("node_load15", "gauge", nil, speedt[3])
end

return { scrape = scrape }

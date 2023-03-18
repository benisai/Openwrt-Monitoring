local nlbwstat = {
    "mac",
    "ip",
    "conns",
    "download_bytes",
    "dl_pkts",
    "upload_bytes",
    "up_pkts"
}

local pattern = "(%w+:%w+:%w+:%w+:%w+:%w+)%s+(%d+.%d+.%d+.%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)"

local function scrape()
  local nlbw_table = {}
  for line in io.lines("/tmp/nlbwmon.out") do
    local t = {string.match(line, pattern)}
    if #t == 7 then
      nlbw_table[t[1]] = t
    end
  end
  
  -- create a new metric
  nlbw_metric = metric("nlbwmon_stats", "counter")
  
  -- iterate through the nlbw_table and add the values to the metric
  for mac, nlbw in pairs(nlbw_table) do
    nlbw_metric({
      mac = nlbw[1],
      ip = nlbw[2],
      conns = nlbw[3],
      download = nlbw[4],
      dl_pkts = nlbw[5],
      upload_bytes = nlbw[6],
      up_pkts = nlbw[7]
    }, nlbw[7])
  end
end

return { scrape = scrape }

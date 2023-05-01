local wanoutagestat = {
    "downdate",
    "downmsg",
    "update",
    "upmsg",
    "value"
}

local pattern = "(%d+-%d+-%d+%d+-+%d+:%d+:%d+)%s+(%S+)%s+(%d+-%d+-%d+%d+-+%d+:%d+:%d+)%s+(%S+)%s+(%d+)"

local function scrape()
  local wanoutage_table = {}
  for line in io.lines("/tmp/wan_monitor.log") do
    local t = {string.match(line, pattern)}
    if #t == 5 then
      wanoutage_table[t[1]] = t
    end
  end

  -- create a new metric
  wanoutage_metric = metric("wanoutage_stats", "counter")

  -- iterate through the wanoutage_table and add the values to the metric
  for downdate, wanoutage in pairs(wanoutage_table) do
    wanoutage_metric({
      downdate = wanoutage[1],
      downmsg = wanoutage[2],
      update = wanoutage[3],
      upmsg = wanoutage[4],
      value = wanoutage[5]
    }, wanoutage[5])
  end
end

return { scrape = scrape }

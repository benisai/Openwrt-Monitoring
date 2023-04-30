local wan_mon = {
    "date",
    "message",
    "value"
}

local function scrape()
    local wanmon_table = {}
    local last_two_lines = {}

    -- read the last two lines of the log file
    for line in io.lines("/tmp/wan_monitor.log") do
        table.insert(last_two_lines, line)
        if #last_two_lines > 2 then
            table.remove(last_two_lines, 1)
        end
    end

    -- parse the last two lines of the log file
    for _, line in ipairs(last_two_lines) do
        local t = {string.match(line, "(%d+-%d+-%d+%d+-+%d+:%d+:%d+)%s+(%S+)%s+(%d+)")}
        if #t == 3 then
            table.insert(wanmon_table, t)
        end
    end

    -- create a new metric
    wanmon_metric = metric("wanmon_stats", "counter")

    -- iterate through the wanmon_table and add the values to the metric
    for _, wanmon in ipairs(wanmon_table) do
        wanmon_metric({
            date = wanmon[1],
            message = wanmon[2],
            value = wanmon[3],
        }, wanmon[3])
    end
end

local ubus = require "ubus"

local function scrape_leasefile(leasefile)
  metric_dhcp_lease = metric("dhcp_lease", "gauge")
  local file = io.open(leasefile)
  if not file then return end

  local e
  repeat
    e = file:read()
    if e then
      local fields = space_split(e)
      if fields[4] ~= nil then
        local labels = {
          dnsmasq = leasefile,
          ip = fields[3],
          hostname = fields[4]
        }
        if string.match(fields[3], "^[0-9]+%.[0-9]+%.[0-9]+%.[0-9]+$") then
          labels['mac'] = fields[2]
        end
        metric_dhcp_lease(labels, fields[1])
      end
    end
  until not e
  file:close()
end


return { scrape = scrape }

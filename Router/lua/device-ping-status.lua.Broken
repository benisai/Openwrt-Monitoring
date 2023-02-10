local function scrape()
  device_status =  metric("router_device_status", "gauge" )
  for e in io.lines("/tmp/device-status.out") do
    local fields = space_split(e)
    local device, ip, status, bytes;
    bytes = 0;
    for _, field in ipairs(fields) do
      if device == nil and string.match(field, '^device') then
        device = string.match(field,"device=([^ ]+)");

          elseif mac == nil and string.match(field, '^mac') then
        mac = string.match(field,"mac=([^ ]+)");

          elseif ip == nil and string.match(field, '^ip') then
        ip = string.match(field,"ip=([^ ]+)");

          elseif status == nil and string.match(field, '^status') then
        status = string.match(field,"status=([^ ]+)");

          elseif string.match(field, '^bytes') then
        local b = string.match(field, "bytes=([^ ]+)");
        bytes = bytes + b;
      end

    end

    local labels = { device = device, mac = mac, ip = ip, status = status }
    device_status(labels, bytes )
  end
end

return { scrape = scrape }

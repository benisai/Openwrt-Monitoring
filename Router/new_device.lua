local function scrape()
  new_device =  metric("router_new_device", "gauge" )
  for e in io.lines("/tmp/new_device.out") do
    local fields = space_split(e)
    local date, device, ip, mac, bytes;
    bytes = 0;
    for _, field in ipairs(fields) do
      if date == nil and string.match(field, '^date') then
        date = string.match(field,"date=([^ ]+)");

          elseif device == nil and string.match(field, '^device') then
        device = string.match(field,"device=([^ ]+)");

          elseif ip == nil and string.match(field, '^ip') then
        ip = string.match(field,"ip=([^ ]+)");

          elseif mac == nil and string.match(field, '^mac') then
        mac = string.match(field,"mac=([^ ]+)");

          elseif string.match(field, '^bytes') then
        local b = string.match(field, "bytes=([^ ]+)");
        bytes = bytes + b;
      end

    end

    local labels = { date = date, device = device, ip = ip, mac = mac }
    new_device(labels, bytes )
  end
end

return { scrape = scrape }

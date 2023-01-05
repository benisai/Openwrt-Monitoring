local function scrape()
  router_netify =  metric("router_netify_traffic", "gauge" )
  for e in io.lines("/tmp/netify.out") do
    local fields = space_split(e)
    local detected_protocol_name, host_server_name, local_ip, local_mac, local_port, other_ip, other_port, client_sni, http, url, user_agent, interface, bytes;
    bytes = 0;
    for _, field in ipairs(fields) do

      if detected_protocol_name == nil and string.match(field, '^detected_protocol_name') then
           detected_protocol_name = string.match(field,"detected_protocol_name=([^ ]+)");
      
      elseif host_server_name == nil and string.match(field, '^host_server_name') then
        host_server_name = string.match(field,"host_server_name=([^ ]+)");
      
      elseif local_ip == nil and string.match(field, '^local_ip') then
        local_ip = string.match(field,"local_ip=([^ ]+)");
      
      elseif local_mac == nil and string.match(field, '^local_mac') then
        local_mac = string.match(field,"local_mac=([^ ]+)");

      elseif local_port == nil and string.match(field, '^local_port') then
        local_port = string.match(field,"local_port=([^ ]+)");
      
      elseif other_ip == nil and string.match(field, '^other_ip') then
        other_ip = string.match(field,"other_ip=([^ ]+)");
      
      elseif other_port == nil and string.match(field, '^other_port') then
        other_port = string.match(field,"other_port=([^ ]+)");

      elseif client_sni == nil and string.match(field, '^client_sni') then
        client_sni = string.match(field,"client_sni=([^ ]+)");
      
      elseif http == nil and string.match(field, '^http') then
        http = string.match(field,"http=([^ ]+)");
      
      elseif url == nil and string.match(field, '^url') then
        url = string.match(field,"url=([^ ]+)");

      elseif user_agent == nil and string.match(field, '^user_agent') then
        user_agent = string.match(field,"user_agent=([^ ]+)");
      
      elseif interface == nil and string.match(field, '^interface') then
        interface = string.match(field,"interface=([^ ]+)");
      
      elseif string.match(field, '^bytes') then
        local b = string.match(field, "bytes=([^ ]+)");
        bytes = bytes + b;
      end

    end
    
    local labels = { detected_protocol_name = detected_protocol_name, host_server_name = host_server_name, local_ip = local_ip, local_mac = local_mac, local_port = local_port, other_ip = other_ip, other_port = other_port, client_sni = client_sni, http = http, url = url, user_agent = user_agent, interface = interface }
    router_netify(labels, bytes )
  end
end

return { scrape = scrape }


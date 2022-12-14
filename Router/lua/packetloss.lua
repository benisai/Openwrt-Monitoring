local function scrape()
  local packetloss = space_split(get_contents("/tmp/packetloss.out"))

  metric("packet_loss", "gauge", nil, packetloss[1])

end

return { scrape = scrape }

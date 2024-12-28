-- Define the path to the device-status.out file
local file_path = "/tmp/device-status.out"

-- Function to parse a line and extract key-value pairs
local function parse_line(line)
    local data = {}
    for key, value in line:gmatch("(%w+)=(%S+)") do
        data[key] = value
    end
    return data
end

-- Function to read the device-status.out and process each line
local function process_file(path)
    local file, err = io.open(path, "r") -- Open the device-status.out in read mode
    if not file then
        print("Error opening file: " .. (err or "Unknown error"))
        return nil
    end

    for line in file:lines() do
        local device_data = parse_line(line)
        if device_data.device and device_data.status then
            print(string.format(
                "Device: %s | MAC: %s | IP: %s | Status: %s",
                device_data.device,
                device_data.mac or "N/A",
                device_data.ip or "N/A",
                device_data.status
            ))
            
            -- Dispatch data to collectd (example)
            if collectd then
                local status_value = (device_data.status == "online") and 1 or 0
                collectd.dispatch_values({
                    host = "openwrt",
                    plugin = "device_status",
                    type = "gauge",
                    type_instance = device_data.device,
                    values = {status_value},
                })
            end
        else
            print("Invalid line: " .. line)
        end
    end

    file:close() -- Close the file
end

-- Process the file
process_file(file_path)

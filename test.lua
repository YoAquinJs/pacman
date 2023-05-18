--Past run time in 0.01666 (60fps) for whole frame

local buttonsStr = "20,21,22,23,24"

io.popen("raspi-gpio set "..buttonsStr.." ip pd")
local popenTime = os.clock()

local handle, i = assert(io.popen("raspi-gpio get "..buttonsStr)), 1

for line in handle:lines() do --Char 16 is the value of the button value
    print("Button: "..i, line:sub(16,16) == "1")
    i = i + 1
end

handle:close()

print("POPEN: "..os.clock()-popenTime, ((os.clock()-popenTime)/(1/60))*100)

io.popen("raspi-gpio set "..buttonsStr.." ip pd")
local execTime = os.clock()

local handle, i = assert(os.execute("raspi-gpio get "..buttonsStr)), 1

for line in handle:gmatch("%s*(.-)%s*\n%s*") do --Char 16 is the value of the button value
    print("Button: "..i, line:sub(16,16) == "1")
    i = i + 1
end

print("EXEC: "..os.clock()-execTime, ((os.clock()-execTime)/(1/60))*100)
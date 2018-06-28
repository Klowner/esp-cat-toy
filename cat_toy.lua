-- Jack up the UART baud rate for faster subsequent uploads
-- You'll have to talk to the ESP8266 at 115200 after the first run of this file
uart.setup(0,115200,8,0,1,1,1)

-- Global constants
position_change_ms_fast = 250 -- How fast to wiggle in fast mode
position_change_ms_slow = 1000 -- How fast to wiggle in slow mode
wifi_ap = "fancymanse"
wifi_password = "wJ&!^KcPatB59H2d" -- Replace this with your password
ifttt_key = "0xDEADBEEF"

print("Initializing...\n")

-- You need to upload and save these files to your ESP8266 independently
-- dofile("hcsr501.lua")
-- dofile("button.lua")
dofile("httpserver.lua")
dofile("misc.lua")
-- dofile("servo.lua")
--dofile("ota.lua")
servo2 = require 'servo2'
servo = servo2.create(2) -- pin D2

connect_wifi(wifi_ap, wifi_password)
--setup_ota()

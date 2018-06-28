srv=net.createServer(net.TCP,10)
srv:listen(80, function(conn)

    conn:on("receive", function(client, request)
        local response = ""
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")

        if (method == nil) then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
        end

        local _GET = {}
        if (vars ~= nil) then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
                print("Processing HTTP command: "..k.."/"..v)
            end
        end

        local _on,_off = "",""

        -- XXX/clean up the old routines
        if (_GET.auto == "frenzy") then
            -- Change to only do this for 30 seconds
            servo:start_wiggle(position_change_ms_fast)
        elseif (_GET.auto == "tease") then
            -- Change to only do this for 30 seconds
            servo:start_wiggle(position_change_ms_slow)
		elseif (_GET.auto == "stop") then
			servo:stop_wiggle()
        elseif (_GET.auto == "fulltravel") then
            servo:stop_wiggle()
            servo:set_position(100)
        elseif (_GET.auto == "lower") then
            servo:stop_wiggle()
			servo:set_position(1)
        elseif (_GET.setposition ~= nil) then
            servo:stop_wiggle()
			servo:set_position(_GET.setposition)
		else
			-- send the page
			if file.open("webpage.html", "r") then
				response = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n"

				-- read 1K chunks to get around the socket buffer size limits
				while true do
					block = file.read(1024)
					if not block then break end

					response = response..block
				end

				file.close()
			end
			client:send(response, function ()
				client:close()
				collectgarbage()
			end)
			return
		end

		-- just respond with a simple JSON indicating everything is 'OK'
		response = 'HTTP/1.1 200 OK\r\nContent-Type: application/javascript\r\n\r\n{"status":"OK"}\r\n'
		client:send(response, function ()
			client:close()
			collectgarbage()
		end)
		return

--         if file.open("webpage.html", "r") then
--             reponse = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n"

--             -- read 1K chunks to get around the socket buffer size limits
--             while true do
--                 block = file.read(1024)
--                 if not block then break end

--                 response = response..block
--             end

--             file.close()
--         end

--         print("Response length: "..string.len(response))
--         -- XXX/fix the 1460 byte response size limit
--         client:send(response, function (res)
-- 			client:close()
-- 		end)
--         -- client:close()

--         collectgarbage()
    end)
end)

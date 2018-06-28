local _M = (function()

	local servo_mt = {}

	function stop_timer(t)
		local running, state = t:state()
		if running then
			t:stop()
			t:unregister()
		end
	end

	function servo_mt:delay_stop(delay)
		local t = self.timer
		local pin = self.pin
		stop_timer(t)
		if delay > 0 then
			t:alarm(delay, tmr.ALARM_SINGLE, function ()
				pwm.stop(self.pin)
			end)
		else
			pwm.stop(self.pin)
		end
	end

	function servo_mt:set_position(pct, keep_going)
		pct = tonumber(pct)
		local duty = self.duty_offset + (((self.duty_range*100) * pct) / 10000)
		print(pct, duty)
		pwm.setduty(self.pin, duty)
		pwm.start(self.pin)
		if not keep_going then
			self:delay_stop(500)
		end
	end

	function servo_mt:center()
		self:set_position(50)
	end

	function servo_mt:start_wiggle(every_ms, min_travel, max_travel)
		local ms = every_ms or 500
		min_travel = min_travel or 1
		max_travel = max_travel or 100

		local servo = self
		local t = self.timer
		stop_timer(t)
		t:alarm(ms, tmr.ALARM_AUTO, function ()
			local r = math.random(min_travel, max_travel)
			servo:set_position(r, true)
			return true
		end)
	end

	function servo_mt:stop_wiggle()
		self:delay_stop(0)
	end

	function servo_mt:init()
		pwm.setup(self.pin, 50, 256)
		pwm.start(self.pin)	
		self:delay_stop(500)
	end

	function create(pin)
		local s = {
			pin = pin,
			timer = tmr.create(),
			duty_offset = 30,
			duty_range = 100,
		}
		servo_mt.__index = servo_mt
		setmetatable(s, servo_mt)
		s:init()
		return s
	end

	return {
		create = create,
	}
end)()

return _M

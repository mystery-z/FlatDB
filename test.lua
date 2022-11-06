
local flatdb = require("flatdb")

local logger = flatdb("./log")

local count = 0

local function common_log(logger, level, message)
	local today = os.date("%Y-%m-%d")
	if logger[today] == nil then logger[today] = {} end
	if logger[today][level] == nil then logger[today][level] = {} end
	table.insert(logger[today][level], {
		timestamp = os.time(),
		level = level,
		message = message
	})
	count = (count+1)%10
	if count == 0 then
		logger:save()
	end
end

local levels = {"debug", "info", "warn", "error", "fatal"}

for _, level in ipairs(levels) do
	flatdb.hack[level] = function(logger, msg)
		common_log(logger, level, msg)
	end
end

flatdb.hack.find = function(logger, level, date)
	if logger[date or os.date("%Y-%m-%d")] then
		return logger[date or os.date("%Y-%m-%d")][level]
	end
end

for i = 1, 10 do
	logger:debug("This is a debug message.")
	logger:info("This is an info message.")
	logger:warn("This is a warn message.")
	logger:error("This is an error message.")
	logger:fatal("This is a fatal message.")
end

local pp = require("pp") -- https://github.com/luapower/pp
pp(logger:find("error"))


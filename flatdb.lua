local mp = require("MessagePack")

--a function to check if a file exists
--takes in the path as input
--outputs true/false
local function isFile(path) 
	local f = io.open(path, "r") --opens the file
	if f then
		f:close() --if the file is openable, file is closed without changing it, and thus returns True
		return true
	end
	return false --if the file cannot be opened, this means it doesn't exist (in this sense) and thus returns False
end

--a function to check if a directory exists
--takes in the path as input
--outputs true/false
local function isDir(path)
	path = string.gsub(path.."/", "//", "/") --adds "/" at the end of path, and then substitutes all "//"s for "/"s (prev. syntax errors)
	local ok, err, code = os.rename(path, path) --attempts to rename the path with the path (basically tries to access but not change anything)
	if ok or code == 13 then --"ok" means the os.rename worked, not sure about code 13 though...
		return true 
	end
	return false
end

local function load_page(path)
	local ret
	local f = io.open(path, "rb")
	if f then
		ret = mp.unpack(f:read("*a"))
		f:close()
	end
	return ret
end

local function store_page(path, page)
	if type(page) == "table" then
		local f = io.open(path, "wb")
		if f then
			f:write(mp.pack(page))
			f:close()
			return true
		end
	end
	return false
end

local pool = {}

local db_funcs = {
	save = function(db, p)
		if p then
			if type(p) == "string" and type(db[p]) == "table" then
				return store_page(pool[db].."/"..p, db[p])
			else
				return false
			end
		end
		for p, page in pairs(db) do
			if not store_page(pool[db].."/"..p, page) then
				return false
			end
		end
		return true
	end
}

local mt = {
	__index = function(db, k)
		if db_funcs[k] then return db_funcs[k] end
		if isFile(pool[db].."/"..k) then
			db[k] = load_page(pool[db].."/"..k)
		end
		return rawget(db, k)
	end
}

pool.hack = db_funcs

return setmetatable(pool, {
	__mode = "kv",
	__call = function(pool, path)
		assert(isDir(path), path.." is not a directory.")
		if pool[path] then return pool[path] end
		local db = {}
		setmetatable(db, mt)
		pool[path] = db
		pool[db] = path
		return db
	end
})

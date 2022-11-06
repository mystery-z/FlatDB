local flatdb = require('flatdb')
local db = flatdb('./db')

if not db.page2 then 
	db.page2 = {}
end

print(db.page2.jason)

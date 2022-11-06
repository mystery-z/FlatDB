local flatdb = require("flatdb")
local db = flatdb('./db')

if not db.page0 then 
	db.page0 = {}
end

db.page0.kelly = 'girl'
db.page0.jason = 'guy'

db:save(page0)


if not db.page1 then 
	db.page1 = {}
end

db.page1.kelly = 'girl'
db.page1.jason = 'guy'

db:save(page1)


if not db.page2 then 
	db.page2 = {}
end

db.page2.kelly = 'girl, g11'
db.page2.jason =  'guy, g10'

db:save(page2)


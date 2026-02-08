---@param num int
---@return [int]
function getLinearArray(num)
	local ret = {}
	for i = 1,num do
		ret[i] = i
	end
	return ret
end

---@generic E : any
---@param vals [E]
---@param num int
---@return [E]
function getArrayOf(vals, num)
	local ret = {}
	while #ret < num do
		for i,e in pairs(vals) do
			if #ret < num then
				table.insert(ret, e)
			end
		end
	end
	return ret
end

---@generic E : any
---@param val E
---@param num int
---@return [E]
function getArrayOfCopies(val, num)
	local ret = {}
		for i = 1,num do
			table.insert(ret, val)
		end
	return ret
end

---@generic E : any
---@param num int
---@param calc fun(): E
---@return [E]
function getArrayOfGenerated(num, calc)
	local ret = {}
		for i = 1,num do
			table.insert(ret, calc())
		end
	return ret
end

---@generic E : any
---@param arr [E]
---@param check fun(E): boolean
---@param limit? int
---@return [E]
function getAllMatching(arr, check, limit)
	local ret = {}
	local count = 0
		for k,v in pairs(arr) do
			if check(v) then
				table.insert(ret, v)
				count = count+1
				if limit and limit > 0 and count >= limit then break end
			end
		end
	return ret
end

---@param object LuaEntity|LuaTile|data.EntityPrototype|data.TilePrototype
---@param mask string
---@return boolean
function hasCollisionMask(object, mask)
	local proto = object.prototype and object.prototype or object
	return proto and proto.collision_mask and proto.collision_mask.layers[mask] ~= nil
end

---@param val table
---@return int
function getTableSize(val)
	if not val then return -1 end
	if type(val) ~= "table" then fmterror("Value '%s' is not a table!", val) end
	return table_size(val)
end

---@param t1 table
---@param t2 table
---@return boolean
function areTablesEqual(t1, t2)
	if getTableSize(t1) ~= getTableSize(t2) then return false end
	for i,e in ipairs(t1) do
		if type(e) == "table" then
			if not areTablesEqual(e, t2[i]) then return false end
		else
			if t2[i] ~= e then return false end
		end
	end
	return true
end

---@generic E : any
---@param list E[]
---@param randFunc fun(int, int): int
---@return E
function getRandomTableEntry(list, randFunc)
	local size = getTableSize(list)
	local idx = randFunc and randFunc(0, size-1) or math.random(0, size-1)
	--game.print(idx .. "/" .. size)
	local i = 0
	for key,val in pairs(list) do
		--game.print(i .. " >> " .. val)
		if i == idx then
			--game.print(val)
			return val
		end
		i = i+1
	end
end

---@param list table
---@param func function
function removeEntryFromListIf(list, func)
	for i = #list,1,-1 do
		if func(list[i]) then
			table.remove(list, i)
		end
	end
end

---@generic E : any
---@param list E[]
---@param val E
function removeEntryFromList(list, val)
	removeEntryFromListIf(list, function(param) return param == val end)
end

---@generic E : any
---@param list E[]
---@param val E
---@return boolean
function listHasValue(list, val)
	local tableCheck = type(val) == "table"
	for _,entry in pairs(list) do
		if tableCheck then
			--log("Checking tables in " .. serpent.block(list))
			if areTablesEqual(entry, val) then return true end
		else
			if entry == val then return true end
		end
	end
	return false
end

---@generic E : any
---@param list E[]
---@return {[E]: boolean}
function convertToSet(list)
	local ret = {}
	for _,e in pairs(list) do
		ret[e] = true
	end
	return ret
end

---@param list table
---@return table
function removeNilValues(list)
	local ret = {}
	for i,entry in pairs(list) do
		if entry then table.insert(entry) end
	end
	return ret
end

---@generic E : any
---@param list E[]
---@return E
function getHighestTableKey(list)
	local lim = -9999999
	local ret = nil
	for k,v in pairs(list) do
		if v > lim then
			lim = v
			ret = k
		end
	end
	return ret
end

---@param t table
---@return boolean
function isTableAnArray(t)
	return #t == getTableSize(t)
end

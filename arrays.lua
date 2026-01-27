---@param num int
---@return [int]
function getLinearArray(num)
	local ret = {}
	for i = 1,num do
		ret[i] = i
	end
	return ret
end

---@param vals table
---@param num int
---@return table
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

---@param object LuaEntity|LuaTile
---@param mask string
---@return boolean
function hasCollisionMask(object, mask)
	return object.prototype and object.prototype.collision_mask and object.prototype.collision_mask.layers[mask]
end

---@param val table
---@return int
function getTableSize(val)
	if not val then return -1 end
	if type(val) ~= "table" then error("Value '" .. serpent.block(val) .. "' is not a table!") end
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
---@param randFunc function
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

function hasCollisionMask(object, mask)
	return object.prototype and object.prototype.collision_mask[mask]
end

function areTablesEqual(t1, t2)
	if #t1 ~= #t2 then return false end
	for i,e in ipairs(t1) do
		if type(e) == "table" then
			if not areTablesEqual(e, t2[i]) then return false end
		else
			if t2[i] ~= e then return false end
		end
	end
	return true
end

function removeEntryFromListIf(list, func)
	for i = #list,1,-1 do
		if func(list[i]) then
			table.remove(list, i)
		end
	end
end

function removeEntryFromList(list, val)
	for i = #list,1,-1 do
		if list[i] == val then
			table.remove(list, i)
		end
	end
end

function listHasValue(list, val)
	for _,entry in pairs(list) do
		if type(val) == "table" then
			log("Checking tables in " .. serpent.block(list))
			if areTablesEqual(entry, val) then return end
		else
			if entry == val then return true end
		end
	end
end

function removeNilValues(list)
	local ret = {}
	for i,entry in pairs(list) do
		if entry then
			ret[#ret+1] = entry
		end
	end
	return ret
end

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

function getTableSize(val)
	local count = 0
	for key,num in pairs(val) do
		count = count+1
	end
	return count
end

function isTableAnArray(t)
	--are all indices numerical; count for later
	local count = 0
	for k,v in pairs(t) do
		if type(k) ~= "number" then
			return false
		else
			count = count+1
		end
	end
	
	--check if indices are 1->N in order
	for i = 1,count do
		if (not t[i]) and type(t[i]) ~= "nil" then --The value might be nil, have to check the type too
			return false
		end
	end
	return true
end

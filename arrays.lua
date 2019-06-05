function listHasValue(list, val)
	for _,entry in pairs(list) do
		if entry == val then return true end
	end
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

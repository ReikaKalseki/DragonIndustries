function splitString(str, seek)
	local ret = {}
	for s in str:gmatch("([^" .. seek .. "]+)") do
		table.insert(ret, s)
	end
	return ret
end

function literalReplace(str, seek, repl)
	if seek == repl then return str end
	local idx,idx2 = str:find(seek, 1, true)
	local ret = str
	while idx and idx2 do
		ret = ret:sub(1,idx-1) .. repl .. ret:sub(idx2+1, #ret)
		idx,idx2 = ret:find(seek, 1, true)
	end
	return ret
end
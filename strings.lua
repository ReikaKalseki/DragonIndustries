---@param str string
---@param seek string
---@return int,int
function lastIndexOf(str, seek)
	local flip = string.reverse(str)
	local s,e = string.find(str, seek, 1, true)
	--log(flip .. " > " .. (s and s or "nil"))
	if s and e then
		s = string.len(str)-s
		e = string.len(str)-e
		return s,e
	else
		return -1,-1
	end
end

---@param str string
---@param seek string
---@return [string]
function splitString(str, seek)
	local ret = {}
	for s in str:gmatch("([^" .. seek .. "]+)") do
		table.insert(ret, s)
	end
	return ret
end

---@param str string
---@param seek string
---@param repl string
---@return string
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

---@param str string
---@param seek string
---@return boolean
function stringStartsWith(str, seek)
	return string.sub(str, 1, string.len(seek)) == seek
end

---@param str string
---@param seek string
---@return boolean
function stringEndsWith(str, seek)
	return string.sub(str, -#seek) == seek
end
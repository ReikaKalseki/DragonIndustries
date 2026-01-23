---@param old table
---@param new table
---@return table
function createDerivative(old, new)
	if old == nil then error("Null table to merge into!") end
	if new == nil then error("Null table to merge from!") end
	local ret = table.deepcopy(old)

	for k, v in pairs(new) do
		if v == "nil" then
			ret[k] = nil
		elseif type(v) == "table" and type(ret[k]) == "table" and ret[k] and not isTableAnArray(ret[k]) then --if merging table into table, *merge* it, not just overwrite
			if v["*"] == "nil" then ret[k] = {} end --but allow overwrite too
			ret[k] = createDerivative(ret[k], v)
		else
			ret[k] = v
		end
	end

	return ret
end

---@param object any
---@return string
function stringify(object)
    if object == nil then
        return "nil"
    elseif type(object) == "table" then
        return serpent.block(object)
    else
        return tostring(object)
    end
end

---@param msg string
function fmtlog(msg, ...)
    local params = {}
    for i,v in ipairs({...}) do
       table.insert(params, stringify(v))
    end
    log(string.format(msg, table.unpack(params)))-- .. " at\n" .. debug.traceback())
end

---@param msg string
function fmterror(msg, ...)
    local params = {}
    for i,v in ipairs({...}) do
       table.insert(params, stringify(v))
    end
    error(string.format(msg, table.unpack(params)) .. " at\n" .. debug.traceback())
end
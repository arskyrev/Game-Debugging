local function beautifyTable(tbl)
    local indent = "    "
    local function tostring_custom(value)
        if type(value) == "string" then
            return string.format("%q", value)
        else
            return tostring(value)
        end
    end

    local function recurse(t, level)
        if type(t) ~= "table" then return tostring_custom(t) end
        
        local lines = {"{"}
        local keys = {}
        for k in pairs(t) do table.insert(keys, k) end
        table.sort(keys, function(a, b)
            if type(a) == "number" and type(b) == "number" then
                return a < b
            else
                return tostring(a) < tostring(b)
            end
        end)
        
        for _, k in ipairs(keys) do
            local v = t[k]
            local key = type(k) == "string" and k or "[" .. tostring(k) .. "]"
            local value = recurse(v, level + 1)
            table.insert(lines, string.rep(indent, level) .. key .. " = " .. value .. ",")
        end
        
        table.insert(lines, string.rep(indent, level - 1) .. "}")
        return table.concat(lines, "\n")
    end

    return recurse(tbl, 1)
end

return beautifyTable
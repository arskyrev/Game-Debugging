local function exploreModule(module)
    local function isFunction(value)
        return type(value) == "function"
    end
    
    local function isTable(value)
        return type(value) == "table"
    end
    
    local function explore(tbl, path)
        if not isTable(tbl) then
            return {type = type(tbl)}
        end
        
        local structure = {}
        for key, value in pairs(tbl) do
            local newPath = path and (path .. "." .. tostring(key)) or tostring(key)
            if isFunction(value) then
                structure[key] = {type = "function", path = newPath}
            elseif isTable(value) and key ~= "__index" and key ~= "__newindex" then
                structure[key] = {type = "table", value = explore(value, newPath)}
            else
                structure[key] = {type = type(value)}
            end
        end
        return structure
    end
    
    return explore(module)
end

local success, MyModule = pcall(function()
    return require(game:GetService("Players").LocalPlayer.PlayerScripts.Modules.ViewModels["Paintball Gun"])
end)

if not success then
    warn("Failed to load module:", MyModule)
    return
end

local moduleStructure = exploreModule(MyModule)

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

print(beautifyTable(moduleStructure)) --setclipboard(beautifyTable(moduleStructure))
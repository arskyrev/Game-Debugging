local function beautifyTable(tbl, maxDepth)
    maxDepth = maxDepth or 20  -- Default max depth
    local indent = "  "
    local visited = {}

    local function tostring_custom(value)
        if type(value) == "string" then
            return string.format("%q", value)
        else
            return tostring(value)
        end
    end

    local function recurse(t, level)
        if level > maxDepth then
            return "\"[Max Depth Reached]\""
        end

        if type(t) ~= "table" then 
            return tostring_custom(t) 
        end

        if visited[t] then
            return "\"[Circular Reference]\""
        end
        visited[t] = true

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

    local status, result = pcall(function() return recurse(tbl, 1) end)
    if status then
        return result
    else
        return "Error in beautifyTable: " .. tostring(result)
    end
end

local function monitorFunctionArgs(module, functionTable)    
    for name, data in pairs(functionTable) do
        if data["type"] == "function" then
            local old = module[name]
            module[name] = newcclosure(function(...)
                local args = {...}
                
                setclipboard(beautifyTable(args)) --setclipboard(beautifyTable(args))

                return old(...)
            end)

            print("Monitoring Function: "..name)
        end
    end    
end

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

monitorFunctionArgs(MyModule, moduleStructure)

print("Function monitoring set up. Call the monitored functions to see their arguments logged.")
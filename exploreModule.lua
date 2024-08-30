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
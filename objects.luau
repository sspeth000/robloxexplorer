-- objects.luau
-- Builds a serializable representation of the Workspace hierarchy.

local function getObjectData(object)
    local data = {
        Name = object.Name,
        ClassName = object.ClassName,
        Children = {}
    }

    local success, children = pcall(function()
        return object:GetChildren()
    end)

    if not success then
        return data
    end

    for _, child in ipairs(children) do
        table.insert(data.Children, getObjectData(child))
    end

    return data
end

return getObjectData(workspace)

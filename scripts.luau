-- scripts.luau
-- Handles script detection and source retrieval.

local scripts = {}

--------------------------------------------------
-- CHECK IF OBJECT IS A SCRIPT
--------------------------------------------------

function scripts.IsScript(object)

    return object:IsA("Script")
        or object:IsA("LocalScript")
        or object:IsA("ModuleScript")

end

--------------------------------------------------
-- GET SCRIPT SOURCE
--------------------------------------------------

function scripts.GetSource(object)

    if not scripts.IsScript(object) then
        return "-- This object is not a script."
    end

    local success, result = pcall(function()
        return object.Source
    end)

    if not success then
        return "-- Failed to read script source:\n\n" .. tostring(result)
    end

    if result == nil then
        return "-- Script source is nil."
    end

    if type(result) ~= "string" then
        return "-- Script source returned an unexpected value:\n\n"
            .. tostring(result)
    end

    if result == "" then
        return "-- This script is empty."
    end

    return result

end

return scripts

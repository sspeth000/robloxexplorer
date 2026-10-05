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
        return nil
    end

    local success, source = pcall(function()
        return object.Source
    end)

    if success and type(source) == "string" then
        return source
    end

    return "-- Unable to read script source."

end

return scripts

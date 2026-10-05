-- scripts.luau
-- Finds script objects in the game.

local scripts = {}

local function scan(object)

    for _, child in ipairs(object:GetChildren()) do

        if child:IsA("Script")
            or child:IsA("LocalScript")
            or child:IsA("ModuleScript") then

            table.insert(scripts, {
                Object = child,
                Name = child.Name,
                ClassName = child.ClassName
            })

        end

        scan(child)

    end

end

scan(game)

return scripts

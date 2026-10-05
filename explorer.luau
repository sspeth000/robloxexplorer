-- explorer.luau

local objectData = ...

if not objectData then
    warn("Explorer: no object data received")
    return
end

local CoreGui = game:GetService("CoreGui")

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "Explorer"
gui.Parent = CoreGui

local window = Instance.new("Frame")
window.Size = UDim2.fromOffset(700, 450)
window.Position = UDim2.fromOffset(100, 100)
window.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
window.BorderSizePixel = 1
window.BorderColor3 = Color3.fromRGB(80, 80, 80)
window.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.BorderSizePixel = 0
title.Text = "  Explorer"
title.TextColor3 = Color3.fromRGB(235, 235, 235)
title.TextSize = 16
title.Font = Enum.Font.SourceSans
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = window

--------------------------------------------------
-- OBJECT LIST
--------------------------------------------------

local list = Instance.new("ScrollingFrame")
list.Name = "ObjectList"
list.Size = UDim2.new(0, 300, 1, -32)
list.Position = UDim2.fromOffset(0, 32)
list.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = window

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 1)
layout.Parent = list

--------------------------------------------------
-- RENDER OBJECT
--------------------------------------------------

local rowCount = 0

local function renderObject(object, depth)

    rowCount += 1

    local row = Instance.new("TextButton")

    row.Name = "Object_" .. rowCount
    row.Size = UDim2.new(1, -6, 0, 24)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.AutoButtonColor = true
    row.Text = ""
    row.LayoutOrder = rowCount
    row.Parent = list

    local text = Instance.new("TextLabel")

    text.Size = UDim2.new(1, -8, 1, 0)
    text.Position = UDim2.fromOffset(8 + depth * 18, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(220, 220, 220)
    text.TextSize = 14
    text.Font = Enum.Font.SourceSans
    text.TextXAlignment = Enum.TextXAlignment.Left

    -- Simple Roblox-style tree indicator.
    if object.Children and #object.Children > 0 then
        text.Text = "▼  " .. object.Name
    else
        text.Text = "    " .. object.Name
    end

    text.Parent = row

    -- Temporary debugging:
    row.MouseButton1Click:Connect(function()
        print(
            "Selected:",
            object.Name,
            "(" .. tostring(object.ClassName) .. ")"
        )
    end)

    -- Render children.
    if object.Children then
        for _, child in ipairs(object.Children) do
            renderObject(child, depth + 1)
        end
    end
end

--------------------------------------------------
-- ROOT
--------------------------------------------------

print("Explorer received:", objectData.Name)
print("Class:", objectData.ClassName)
print("Children:", #objectData.Children)

-- Render Workspace itself.
renderObject(objectData, 0)

--------------------------------------------------
-- SCROLL SIZE
--------------------------------------------------

task.defer(function()
    list.CanvasSize = UDim2.fromOffset(
        0,
        layout.AbsoluteContentSize.Y + 10
    )
end)

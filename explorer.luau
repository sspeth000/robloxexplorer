local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Remove old Explorer if it exists
local oldGui = CoreGui:FindFirstChild("Explorer")
if oldGui then
    oldGui:Destroy()
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "Explorer"
gui.Parent = CoreGui

-- Main window
local window = Instance.new("Frame")
window.Size = UDim2.fromOffset(700, 450)
window.Position = UDim2.fromOffset(100, 100)
window.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
window.BorderSizePixel = 1
window.BorderColor3 = Color3.fromRGB(80, 80, 80)
window.Parent = gui

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = window

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "Workspace Explorer"
title.TextColor3 = Color3.fromRGB(235, 235, 235)
title.TextSize = 16
title.Font = Enum.Font.SourceSans
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Explorer panel
local explorer = Instance.new("ScrollingFrame")
explorer.Size = UDim2.new(0, 300, 1, -32)
explorer.Position = UDim2.fromOffset(0, 32)
explorer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
explorer.BorderSizePixel = 0
explorer.ScrollBarThickness = 6
explorer.CanvasSize = UDim2.new(0, 0, 0, 0)
explorer.Parent = window

-- Script viewer
local viewer = Instance.new("Frame")
viewer.Size = UDim2.new(1, -300, 1, -32)
viewer.Position = UDim2.fromOffset(300, 32)
viewer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
viewer.BorderSizePixel = 0
viewer.Parent = window

local viewerText = Instance.new("TextLabel")
viewerText.Size = UDim2.new(1, -20, 1, -20)
viewerText.Position = UDim2.fromOffset(10, 10)
viewerText.BackgroundTransparency = 1
viewerText.Text = "-- Select an object"
viewerText.TextColor3 = Color3.fromRGB(210, 210, 210)
viewerText.TextSize = 14
viewerText.Font = Enum.Font.Code
viewerText.TextXAlignment = Enum.TextXAlignment.Left
viewerText.TextYAlignment = Enum.TextYAlignment.Top
viewerText.Parent = viewer

-- Layout
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 2)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = explorer

-- Padding
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingLeft = UDim.new(0, 5)
padding.PaddingRight = UDim.new(0, 5)
padding.Parent = explorer

-- Render workspace
local objects = workspace:GetChildren()

print("Workspace children:", #objects)

local rowCount = 0

for _, object in ipairs(objects) do
    rowCount += 1

    local row = Instance.new("TextButton")

    row.Size = UDim2.new(1, -10, 0, 28)
    row.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    row.BorderSizePixel = 0

    row.Text = "  " .. object.Name .. " [" .. object.ClassName .. "]"
    row.TextColor3 = Color3.fromRGB(230, 230, 230)
    row.TextSize = 14
    row.Font = Enum.Font.SourceSans
    row.TextXAlignment = Enum.TextXAlignment.Left

    row.LayoutOrder = rowCount
    row.Parent = explorer

    row.MouseButton1Click:Connect(function()
        viewerText.Text =
            "Name: " .. object.Name ..
            "\nClass: " .. object.ClassName ..
            "\n\nChildren: " .. tostring(#object:GetChildren())
    end)
end

-- Give the ScrollingFrame enough space
explorer.CanvasSize = UDim2.new(
    0,
    0,
    0,
    rowCount * 30 + 10
)

-- Dragging
local dragging = false
local dragStart
local startPosition

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = window.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        window.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

print("Explorer loaded successfully.")
print("Rendered rows:", rowCount)

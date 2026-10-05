local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

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
title.Text = "Explorer"
title.TextColor3 = Color3.fromRGB(235, 235, 235)
title.TextSize = 16
title.Font = Enum.Font.SourceSans
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Explorer panel
local explorer = Instance.new("ScrollingFrame")
explorer.Size = UDim2.new(0, 250, 1, -32)
explorer.Position = UDim2.fromOffset(0, 32)
explorer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
explorer.BorderSizePixel = 0
explorer.ScrollBarThickness = 6
explorer.Parent = window

-- Script viewer
local viewer = Instance.new("Frame")
viewer.Size = UDim2.new(1, -250, 1, -32)
viewer.Position = UDim2.fromOffset(250, 32)
viewer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
viewer.BorderSizePixel = 0
viewer.Parent = window

local viewerText = Instance.new("TextLabel")
viewerText.Size = UDim2.new(1, -20, 1, -20)
viewerText.Position = UDim2.fromOffset(10, 10)
viewerText.BackgroundTransparency = 1
viewerText.Text = "-- Select a script from Explorer"
viewerText.TextColor3 = Color3.fromRGB(210, 210, 210)
viewerText.TextSize = 14
viewerText.Font = Enum.Font.Code
viewerText.TextXAlignment = Enum.TextXAlignment.Left
viewerText.TextYAlignment = Enum.TextYAlignment.Top
viewerText.Parent = viewer

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

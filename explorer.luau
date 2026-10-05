local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- CLEANUP OLD INSPECTOR
--------------------------------------------------

local oldGui = playerGui:FindFirstChild("ObjectPathInspector")
if oldGui then
	oldGui:Destroy()
end

local oldHighlight = workspace:FindFirstChild("InspectorHighlight")
if oldHighlight then
	oldHighlight:Destroy()
end

local oldMarker = workspace:FindFirstChild("InspectorTransparentMarker")
if oldMarker then
	oldMarker:Destroy()
end

--------------------------------------------------
-- STATE
--------------------------------------------------

local inspecting = true
local selectedObject = nil
local highlightEnabled = true

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "ObjectPathInspector"
gui.ResetOnSpawn = false
gui.Parent = playerGui

--------------------------------------------------
-- PANEL
--------------------------------------------------

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(500, 185)
panel.Position = UDim2.new(0.5, -250, 1, -215)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Active = true
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel

--------------------------------------------------
-- TITLE
--------------------------------------------------

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 25)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Text = "Object Inspector"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Active = true
title.Parent = panel

--------------------------------------------------
-- DRAGGING
--------------------------------------------------

local dragging = false
local dragStart = nil
local startPosition = nil

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = panel.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local delta = input.Position - dragStart

	panel.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end)

--------------------------------------------------
-- IDENTIFIER BOX
--------------------------------------------------

local pathBox = Instance.new("TextBox")
pathBox.Size = UDim2.new(1, -20, 0, 42)
pathBox.Position = UDim2.fromOffset(10, 40)
pathBox.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
pathBox.BorderSizePixel = 0
pathBox.Text = ""
pathBox.PlaceholderText = "No object selected"
pathBox.TextColor3 = Color3.fromRGB(220, 220, 225)
pathBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
pathBox.TextSize = 14
pathBox.Font = Enum.Font.Code
pathBox.ClearTextOnFocus = false
pathBox.TextEditable = true
pathBox.TextXAlignment = Enum.TextXAlignment.Left
pathBox.TextYAlignment = Enum.TextYAlignment.Center
pathBox.Parent = panel

local pathCorner = Instance.new("UICorner")
pathCorner.CornerRadius = UDim.new(0, 6)
pathCorner.Parent = pathBox

--------------------------------------------------
-- TOGGLE
--------------------------------------------------

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(145, 35)
toggle.Position = UDim2.fromOffset(10, 95)
toggle.BorderSizePixel = 0
toggle.TextSize = 14
toggle.Font = Enum.Font.GothamBold
toggle.Parent = panel

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 7)
toggleCorner.Parent = toggle

--------------------------------------------------
-- HIGHLIGHT BUTTON
--------------------------------------------------

local highlightButton = Instance.new("TextButton")
highlightButton.Size = UDim2.fromOffset(145, 35)
highlightButton.Position = UDim2.fromOffset(165, 95)
highlightButton.BorderSizePixel = 0
highlightButton.TextSize = 14
highlightButton.Font = Enum.Font.GothamBold
highlightButton.Parent = panel

local highlightCorner = Instance.new("UICorner")
highlightCorner.CornerRadius = UDim.new(0, 7)
highlightCorner.Parent = highlightButton

--------------------------------------------------
-- CLOSE BUTTON
--------------------------------------------------

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(120, 35)
closeButton.Position = UDim2.fromOffset(320, 95)
closeButton.BackgroundColor3 = Color3.fromRGB(150, 55, 55)
closeButton.BorderSizePixel = 0
closeButton.Text = "CLOSE"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = panel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = closeButton

--------------------------------------------------
-- STATUS
--------------------------------------------------

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 25)
status.Position = UDim2.fromOffset(10, 145)
status.BackgroundTransparency = 1
status.Text = "Highlight: OFF"
status.TextColor3 = Color3.fromRGB(160, 160, 170)
status.TextSize = 13
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = panel

--------------------------------------------------
-- HIGHLIGHT
--------------------------------------------------

local highlight = Instance.new("Highlight")
highlight.Name = "InspectorHighlight"
highlight.FillColor = Color3.fromRGB(255, 220, 50)
highlight.FillTransparency = 0.65
highlight.OutlineColor = Color3.fromRGB(255, 235, 100)
highlight.OutlineTransparency = 0
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Enabled = false
highlight.Parent = workspace

--------------------------------------------------
-- TRANSPARENT PART MARKER
--------------------------------------------------

local marker = nil

local function destroyMarker()
	if marker then
		marker:Destroy()
		marker = nil
	end
end

local function createMarker(part)
	destroyMarker()

	if not part:IsA("BasePart") then
		return
	end

	marker = Instance.new("Part")
	marker.Name = "InspectorTransparentMarker"
	marker.Anchored = true
	marker.CanCollide = false
	marker.CanTouch = false
	marker.CanQuery = false
	marker.CastShadow = false
	marker.Material = Enum.Material.Neon
	marker.Color = Color3.fromRGB(255, 220, 50)
	marker.Transparency = 0.75
	marker.CFrame = part.CFrame
	marker.Size = part.Size
	marker.Parent = workspace
end

--------------------------------------------------
-- KEEP TRANSPARENT MARKER UPDATED
--------------------------------------------------

RunService.RenderStepped:Connect(function()
	if not marker then
		return
	end

	if not selectedObject then
		destroyMarker()
		return
	end

	if not selectedObject.Parent then
		destroyMarker()

		highlight.Enabled = false
		highlight.Adornee = nil

		selectedObject = nil
		panel.Visible = false

		return
	end

	if not selectedObject:IsA("BasePart") then
		destroyMarker()
		return
	end

	marker.CFrame = selectedObject.CFrame
	marker.Size = selectedObject.Size
end)

--------------------------------------------------
-- STRUCTURAL PATH
--------------------------------------------------

local function getPath(instance)
	local parts = {}

	while instance and instance ~= game do
		table.insert(parts, 1, instance.Name)
		instance = instance.Parent
	end

	return "game." .. table.concat(parts, ".")
end

--------------------------------------------------
-- STRUCTURAL UNIQUE ID
--------------------------------------------------

local function getUniqueID(instance)
	local numbers = {}
	local current = instance

	while current and current ~= game do
		local parent = current.Parent

		if not parent then
			break
		end

		local index = 0

		for i, child in ipairs(parent:GetChildren()) do
			if child == current then
				index = i
				break
			end
		end

		table.insert(numbers, 1, tostring(index))

		current = parent
	end

	return table.concat(numbers, ".")
end

--------------------------------------------------
-- FINAL IDENTIFIER
--------------------------------------------------

local function getIdentifier(instance)
	local path = getPath(instance)
	local uniqueID = getUniqueID(instance)

	return "pathstring:[" .. path .. "]uniqueIDstring[" .. uniqueID .. "]"
end

--------------------------------------------------
-- HIGHLIGHT UPDATE
--------------------------------------------------

local function updateHighlight()
	highlight.Enabled = false
	highlight.Adornee = nil

	destroyMarker()

	if not selectedObject then
		status.Text = "Highlight: OFF"
		return
	end

	if not highlightEnabled then
		status.Text = "Highlight: OFF"
		return
	end

	status.Text = "Highlight: ON"

	if selectedObject:IsA("BasePart") then

		if selectedObject.Transparency > 0 then
			createMarker(selectedObject)
		else
			highlight.Adornee = selectedObject
			highlight.Enabled = true
		end

		return
	end

	highlight.Adornee = selectedObject
	highlight.Enabled = true
end

--------------------------------------------------
-- BUTTON STATES
--------------------------------------------------

local function updateToggle()
	if inspecting then
		toggle.Text = "INSPECTING: ON"
		toggle.BackgroundColor3 = Color3.fromRGB(55, 150, 80)
	else
		toggle.Text = "INSPECTING: OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(100, 100, 105)
	end
end

local function updateHighlightButton()
	if highlightEnabled then
		highlightButton.Text = "HIGHLIGHT: ON"
		highlightButton.BackgroundColor3 = Color3.fromRGB(55, 150, 80)
	else
		highlightButton.Text = "HIGHLIGHT: OFF"
		highlightButton.BackgroundColor3 = Color3.fromRGB(100, 100, 105)
	end

	updateHighlight()
end

updateToggle()
updateHighlightButton()

--------------------------------------------------
-- SELECT OBJECT
--------------------------------------------------

local function selectObject(object)
	if not object then
		return
	end

	selectedObject = object

	title.Text = object.Name

	-- NEW STRUCTURAL IDENTIFIER
	pathBox.Text = getIdentifier(object)

	panel.Visible = true

	updateHighlight()
end

--------------------------------------------------
-- CLICK INSPECTION
--------------------------------------------------

mouse.Button1Down:Connect(function()
	if not inspecting then
		return
	end

	local target = mouse.Target

	if not target then
		return
	end

	selectObject(target)
end)

--------------------------------------------------
-- INSPECT TOGGLE
--------------------------------------------------

toggle.MouseButton1Click:Connect(function()
	inspecting = not inspecting
	updateToggle()
end)

--------------------------------------------------
-- HIGHLIGHT TOGGLE
--------------------------------------------------

highlightButton.MouseButton1Click:Connect(function()
	highlightEnabled = not highlightEnabled
	updateHighlightButton()
end)

--------------------------------------------------
-- CLOSE
--------------------------------------------------

closeButton.MouseButton1Click:Connect(function()
	panel.Visible = false

	highlight.Enabled = false
	highlight.Adornee = nil

	destroyMarker()

	selectedObject = nil
end)

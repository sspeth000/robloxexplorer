```lua
--[[
    Explorer + Script Viewer
    Roblox/Luau-style UI

    Features:
      • Draggable window
      • Explorer hierarchy
      • Expand/collapse objects
      • Object icons
      • Search/filter
      • Script source viewer
      • Line numbers
      • Download button

    Clone-specific:
      Replace downloadSource() with your clone's file-writing/download API.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- CONFIG
--------------------------------------------------

local WINDOW_WIDTH = 900
local WINDOW_HEIGHT = 600

local EXPLORER_WIDTH = 300

local BACKGROUND = Color3.fromRGB(35, 35, 35)
local PANEL = Color3.fromRGB(45, 45, 45)
local PANEL_DARK = Color3.fromRGB(30, 30, 30)
local BORDER = Color3.fromRGB(70, 70, 70)
local TEXT = Color3.fromRGB(230, 230, 230)
local MUTED_TEXT = Color3.fromRGB(160, 160, 160)
local BLUE = Color3.fromRGB(0, 120, 215)

--------------------------------------------------
-- GUI CREATION
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "ExplorerScriptViewer"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local window = Instance.new("Frame")
window.Name = "Window"
window.Size = UDim2.fromOffset(WINDOW_WIDTH, WINDOW_HEIGHT)
window.Position = UDim2.new(0.5, -WINDOW_WIDTH / 2, 0.5, -WINDOW_HEIGHT / 2)
window.BackgroundColor3 = BACKGROUND
window.BorderSizePixel = 1
window.BorderColor3 = BORDER
window.Parent = gui

--------------------------------------------------
-- TITLE BAR
--------------------------------------------------

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = PANEL_DARK
titleBar.BorderSizePixel = 0
titleBar.Parent = window

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "Explorer"
title.TextColor3 = TEXT
title.TextSize = 14
title.Font = Enum.Font.SourceSans
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.fromOffset(32, 32)
closeButton.Position = UDim2.new(1, -32, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.Text = "×"
closeButton.TextColor3 = TEXT
closeButton.TextSize = 20
closeButton.Font = Enum.Font.SourceSans
closeButton.Parent = titleBar

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

--------------------------------------------------
-- DRAGGING
--------------------------------------------------

local dragging = false
local dragStart
local startPosition

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = window.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
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

    window.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

--------------------------------------------------
-- MAIN PANELS
--------------------------------------------------

local explorerPanel = Instance.new("Frame")
explorerPanel.Name = "ExplorerPanel"
explorerPanel.Size = UDim2.new(0, EXPLORER_WIDTH, 1, -32)
explorerPanel.Position = UDim2.fromOffset(0, 32)
explorerPanel.BackgroundColor3 = PANEL
explorerPanel.BorderSizePixel = 0
explorerPanel.Parent = window

local editorPanel = Instance.new("Frame")
editorPanel.Name = "EditorPanel"
editorPanel.Size = UDim2.new(1, -EXPLORER_WIDTH, 1, -32)
editorPanel.Position = UDim2.new(0, EXPLORER_WIDTH, 0, 32)
editorPanel.BackgroundColor3 = PANEL_DARK
editorPanel.BorderSizePixel = 0
editorPanel.Parent = window

--------------------------------------------------
-- SEARCH
--------------------------------------------------

local searchBox = Instance.new("TextBox")
searchBox.Name = "Search"
searchBox.Size = UDim2.new(1, -12, 0, 28)
searchBox.Position = UDim2.fromOffset(6, 6)
searchBox.BackgroundColor3 = PANEL_DARK
searchBox.BorderSizePixel = 1
searchBox.BorderColor3 = BORDER
searchBox.PlaceholderText = "Filter workspace..."
searchBox.PlaceholderColor3 = MUTED_TEXT
searchBox.Text = ""
searchBox.TextColor3 = TEXT
searchBox.TextSize = 14
searchBox.Font = Enum.Font.SourceSans
searchBox.ClearTextOnFocus = false
searchBox.Parent = explorerPanel

--------------------------------------------------
-- EXPLORER SCROLLING FRAME
--------------------------------------------------

local explorerScroll = Instance.new("ScrollingFrame")
explorerScroll.Name = "Explorer"
explorerScroll.Size = UDim2.new(1, -4, 1, -40)
explorerScroll.Position = UDim2.fromOffset(2, 38)
explorerScroll.BackgroundTransparency = 1
explorerScroll.BorderSizePixel = 0
explorerScroll.ScrollBarThickness = 8
explorerScroll.CanvasSize = UDim2.new()
explorerScroll.Parent = explorerPanel

local explorerLayout = Instance.new("UIListLayout")
explorerLayout.SortOrder = Enum.SortOrder.LayoutOrder
explorerLayout.Padding = UDim.new(0, 1)
explorerLayout.Parent = explorerScroll

explorerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    explorerScroll.CanvasSize = UDim2.fromOffset(
        0,
        explorerLayout.AbsoluteContentSize.Y + 8
    )
end)

--------------------------------------------------
-- EDITOR HEADER
--------------------------------------------------

local editorHeader = Instance.new("Frame")
editorHeader.Name = "EditorHeader"
editorHeader.Size = UDim2.new(1, 0, 0, 38)
editorHeader.BackgroundColor3 = PANEL
editorHeader.BorderSizePixel = 0
editorHeader.Parent = editorPanel

local fileName = Instance.new("TextLabel")
fileName.Name = "FileName"
fileName.Size = UDim2.new(1, -130, 1, 0)
fileName.Position = UDim2.fromOffset(10, 0)
fileName.BackgroundTransparency = 1
fileName.Text = "No script selected"
fileName.TextColor3 = TEXT
fileName.TextSize = 14
fileName.Font = Enum.Font.SourceSans
fileName.TextXAlignment = Enum.TextXAlignment.Left
fileName.Parent = editorHeader

local downloadButton = Instance.new("TextButton")
downloadButton.Name = "Download"
downloadButton.Size = UDim2.fromOffset(110, 28)
downloadButton.Position = UDim2.new(1, -116, 0, 5)
downloadButton.BackgroundColor3 = BLUE
downloadButton.BorderSizePixel = 0
downloadButton.Text = "Download"
downloadButton.TextColor3 = Color3.new(1, 1, 1)
downloadButton.TextSize = 14
downloadButton.Font = Enum.Font.SourceSans
downloadButton.Parent = editorHeader

--------------------------------------------------
-- CODE VIEW
--------------------------------------------------

local codeFrame = Instance.new("Frame")
codeFrame.Name = "CodeFrame"
codeFrame.Size = UDim2.new(1, 0, 1, -38)
codeFrame.Position = UDim2.fromOffset(0, 38)
codeFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
codeFrame.BorderSizePixel = 0
codeFrame.Parent = editorPanel

local lineNumbers = Instance.new("TextLabel")
lineNumbers.Name = "LineNumbers"
lineNumbers.Size = UDim2.fromOffset(45, 0)
lineNumbers.Position = UDim2.fromOffset(0, 0)
lineNumbers.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
lineNumbers.BorderSizePixel = 0
lineNumbers.TextColor3 = Color3.fromRGB(100, 100, 100)
lineNumbers.TextSize = 14
lineNumbers.Font = Enum.Font.Code
lineNumbers.TextXAlignment = Enum.TextXAlignment.Right
lineNumbers.TextYAlignment = Enum.TextYAlignment.Top
lineNumbers.Text = ""
lineNumbers.Parent = codeFrame

local codeBox = Instance.new("TextBox")
codeBox.Name = "Code"
codeBox.Size = UDim2.new(1, -55, 1, -10)
codeBox.Position = UDim2.fromOffset(55, 5)
codeBox.BackgroundTransparency = 1
codeBox.BorderSizePixel = 0
codeBox.ClearTextOnFocus = false
codeBox.MultiLine = true
codeBox.TextEditable = false
codeBox.Text = ""
codeBox.TextColor3 = Color3.fromRGB(220, 220, 220)
codeBox.TextSize = 14
codeBox.Font = Enum.Font.Code
codeBox.TextXAlignment = Enum.TextXAlignment.Left
codeBox.TextYAlignment = Enum.TextYAlignment.Top
codeBox.Parent = codeFrame

--------------------------------------------------
-- STATE
--------------------------------------------------

local selectedObject = nil
local expanded = {}

--------------------------------------------------
-- ICONS
--------------------------------------------------

local function getIcon(object)
    local className = object.ClassName

    if className == "Script" then
        return "📜"
    elseif className == "LocalScript" then
        return "📜"
    elseif className == "ModuleScript" then
        return "📦"
    elseif className == "Folder" then
        return "📁"
    elseif className == "Model" then
        return "◈"
    elseif className == "Part" then
        return "■"
    elseif className == "Camera" then
        return "◉"
    elseif className == "RemoteEvent" then
        return "↔"
    else
        return "◇"
    end
end

local function isScript(object)
    return object.ClassName == "Script"
        or object.ClassName == "LocalScript"
        or object.ClassName == "ModuleScript"
end

--------------------------------------------------
-- SOURCE READER
--------------------------------------------------

local function getSource(object)
    if not object then
        return nil
    end

    -- Your clone can expose Source exactly like Roblox Studio.
    local success, source = pcall(function()
        return object.Source
    end)

    if success and type(source) == "string" then
        return source
    end

    return nil
end

--------------------------------------------------
-- LINE NUMBERS
--------------------------------------------------

local function updateLineNumbers(source)
    if source == "" then
        lineNumbers.Text = "1"
        return
    end

    local count = 1

    for _ in source:gmatch("\n") do
        count += 1
    end

    local lines = {}

    for i = 1, count do
        lines[i] = tostring(i)
    end

    lineNumbers.Text = table.concat(lines, "\n")
end

--------------------------------------------------
-- OPEN SCRIPT
--------------------------------------------------

local function openScript(object)
    selectedObject = object

    local source = getSource(object)

    if not source then
        fileName.Text = object.Name
        codeBox.Text = "-- No source code available."
        lineNumbers.Text = "1"
        return
    end

    fileName.Text = object.Name .. ".luau"
    codeBox.Text = source

    updateLineNumbers(source)
end

--------------------------------------------------
-- DOWNLOAD
--------------------------------------------------

local function downloadSource(object, source)
    if not object or not source then
        return
    end

    local file = object.Name .. ".luau"

    --------------------------------------------------
    -- CLONE-SPECIFIC DOWNLOAD API
    --
    -- Replace this section with your clone's
    -- filesystem/download implementation.
    --------------------------------------------------

    if typeof(writefile) == "function" then
        writefile(file, source)
        return
    end

    if typeof(downloadfile) == "function" then
        downloadfile(file, source)
        return
    end

    warn(
        "No download API was provided by the clone.",
        "File:", file
    )
end

downloadButton.MouseButton1Click:Connect(function()
    if not selectedObject then
        return
    end

    local source = getSource(selectedObject)

    if source then
        downloadSource(selectedObject, source)
    end
end)

--------------------------------------------------
-- TREE HELPERS
--------------------------------------------------

local function hasChildren(object)
    local success, children = pcall(function()
        return object:GetChildren()
    end)

    return success and #children > 0
end

local function matchesFilter(object, filter)
    if filter == "" then
        return true
    end

    local name = string.lower(object.Name)
    local className = string.lower(object.ClassName)

    return string.find(name, filter, 1, true) ~= nil
        or string.find(className, filter, 1, true) ~= nil
end

--------------------------------------------------
-- CREATE TREE ROW
--------------------------------------------------

local function createRow(object, depth)
    local row = Instance.new("TextButton")

    row.Name = object.Name
    row.Size = UDim2.new(1, -4, 0, 24)
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.Parent = explorerScroll

    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.fromOffset(16, 24)
    arrow.Position = UDim2.fromOffset(depth * 16, 0)
    arrow.BackgroundTransparency = 1
    arrow.TextColor3 = MUTED_TEXT
    arrow.TextSize = 12
    arrow.Font = Enum.Font.SourceSans
    arrow.Text = hasChildren(object)
        and (expanded[object] and "▼" or "▶")
        or ""
    arrow.Parent = row

    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.fromOffset(22, 24)
    icon.Position = UDim2.fromOffset(depth * 16 + 16, 0)
    icon.BackgroundTransparency = 1
    icon.Text = getIcon(object)
    icon.TextSize = 14
    icon.Parent = row

    local name = Instance.new("TextLabel")
    name.Name = "Name"
    name.Size = UDim2.new(1, -(depth * 16 + 42), 1, 0)
    name.Position = UDim2.fromOffset(depth * 16 + 40, 0)
    name.BackgroundTransparency = 1
    name.Text = object.Name
    name.TextColor3 = TEXT
    name.TextSize = 14
    name.Font = Enum.Font.SourceSans
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = row

    if object == selectedObject then
        row.BackgroundColor3 = BLUE
        row.BackgroundTransparency = 0.65
    end

    row.MouseButton1Click:Connect(function()
        if hasChildren(object) then
            expanded[object] = not expanded[object]
        end

        if isScript(object) then
            openScript(object)
        end

        buildExplorer()
    end)

    return row
end

--------------------------------------------------
-- FILTER TREE
--------------------------------------------------

local function objectContainsMatch(object, filter)
    if matchesFilter(object, filter) then
        return true
    end

    for _, child in ipairs(object:GetChildren()) do
        if objectContainsMatch(child, filter) then
            return true
        end
    end

    return false
end

--------------------------------------------------
-- BUILD EXPLORER
--------------------------------------------------

function buildExplorer()
    for _, child in ipairs(explorerScroll:GetChildren()) do
        if child ~= explorerLayout then
            child:Destroy()
        end
    end

    local filter = string.lower(searchBox.Text)

    local function addObject(object, depth)
        if filter ~= "" and not objectContainsMatch(object, filter) then
            return
        end

        createRow(object, depth)

        if expanded[object] or filter ~= "" then
            local children = object:GetChildren()

            table.sort(children, function(a, b)
                return a.Name:lower() < b.Name:lower()
            end)

            for _, child in ipairs(children) do
                addObject(child, depth + 1)
            end
        end
    end

    -- Workspace root
    local workspaceObject = workspace

    expanded[workspaceObject] = true

    addObject(workspaceObject, 0)
end

--------------------------------------------------
-- SEARCH
--------------------------------------------------

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    buildExplorer()
end)

--------------------------------------------------
-- LIVE HIERARCHY UPDATES
--------------------------------------------------

workspace.DescendantAdded:Connect(function()
    task.defer(buildExplorer)
end)

workspace.DescendantRemoving:Connect(function()
    task.defer(buildExplorer)
end)

--------------------------------------------------
-- INITIAL BUILD
--------------------------------------------------

buildExplorer()
```

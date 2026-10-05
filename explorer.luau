local scripts = ...

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

--------------------------------------------------
-- REMOVE OLD EXPLORER
--------------------------------------------------

local oldGui = CoreGui:FindFirstChild("Explorer")

if oldGui then
    oldGui:Destroy()
end

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "Explorer"
gui.Parent = CoreGui

--------------------------------------------------
-- WINDOW
--------------------------------------------------

local window = Instance.new("Frame")
window.Size = UDim2.fromOffset(700, 450)
window.Position = UDim2.fromOffset(100, 100)
window.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
window.BorderSizePixel = 1
window.BorderColor3 = Color3.fromRGB(80, 80, 80)
window.Parent = gui

--------------------------------------------------
-- TITLE BAR
--------------------------------------------------

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

--------------------------------------------------
-- EXPLORER
--------------------------------------------------

local explorer = Instance.new("ScrollingFrame")
explorer.Size = UDim2.new(0, 300, 1, -32)
explorer.Position = UDim2.fromOffset(0, 32)
explorer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
explorer.BorderSizePixel = 0
explorer.ScrollBarThickness = 6
explorer.CanvasSize = UDim2.fromOffset(0, 0)
explorer.Parent = window

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 1)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = explorer

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingLeft = UDim.new(0, 5)
padding.PaddingRight = UDim.new(0, 5)
padding.Parent = explorer

--------------------------------------------------
-- CODE VIEWER
--------------------------------------------------

local viewer = Instance.new("ScrollingFrame")
viewer.Size = UDim2.new(1, -300, 1, -32)
viewer.Position = UDim2.fromOffset(300, 32)
viewer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
viewer.BorderSizePixel = 0
viewer.ScrollBarThickness = 6
viewer.CanvasSize = UDim2.fromOffset(0, 0)
viewer.Parent = window

local viewerText = Instance.new("TextBox")

viewerText.Size = UDim2.new(1, -20, 0, 0)
viewerText.Position = UDim2.fromOffset(10, 10)
viewerText.AutomaticSize = Enum.AutomaticSize.Y

viewerText.BackgroundTransparency = 1

viewerText.Text = "-- Select an object"

viewerText.TextColor3 = Color3.fromRGB(210, 210, 210)
viewerText.TextSize = 14
viewerText.Font = Enum.Font.Code

viewerText.TextXAlignment = Enum.TextXAlignment.Left
viewerText.TextYAlignment = Enum.TextYAlignment.Top

viewerText.TextWrapped = false

viewerText.ClearTextOnFocus = false
viewerText.MultiLine = true

viewerText.Parent = viewer

--------------------------------------------------
-- UPDATE VIEWER SIZE
--------------------------------------------------

local function updateViewer()

    task.wait()

    viewer.CanvasSize = UDim2.new(
        0,
        0,
        0,
        viewerText.AbsoluteSize.Y + 20
    )

end

--------------------------------------------------
-- TREE DATA
--------------------------------------------------

local nodes = {}

--------------------------------------------------
-- UPDATE TREE VISIBILITY
--------------------------------------------------

local function updateTree()

    for _, node in ipairs(nodes) do

        local visible = true

        for _, parentNode in ipairs(node.Parents) do

            if not parentNode.Expanded then
                visible = false
                break
            end

        end

        node.Row.Visible = visible

        --------------------------------------------------
        -- UPDATE ARROW
        --------------------------------------------------

        if node.HasChildren then

            local indent = string.rep("    ", node.Depth)

            if node.Expanded then

                node.Row.Text =
                    indent ..
                    "▼ " ..
                    node.Object.Name ..
                    " [" ..
                    node.Object.ClassName ..
                    "]"

            else

                node.Row.Text =
                    indent ..
                    "▶ " ..
                    node.Object.Name ..
                    " [" ..
                    node.Object.ClassName ..
                    "]"

            end

        end

    end

    task.wait()

    explorer.CanvasSize = UDim2.new(
        0,
        0,
        0,
        layout.AbsoluteContentSize.Y + 10
    )

end

--------------------------------------------------
-- CREATE NODE
--------------------------------------------------

local createNode

createNode = function(object, depth, parents)

    local children = object:GetChildren()
    local hasChildren = #children > 0

    --------------------------------------------------
    -- CREATE ROW
    --------------------------------------------------

    local row = Instance.new("TextButton")

    row.Size = UDim2.new(1, -10, 0, 26)

    row.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    row.BorderSizePixel = 0

    row.TextColor3 = Color3.fromRGB(230, 230, 230)
    row.TextSize = 14
    row.Font = Enum.Font.SourceSans
    row.TextXAlignment = Enum.TextXAlignment.Left

    row.LayoutOrder = #nodes + 1

    --------------------------------------------------
    -- NODE DATA
    --------------------------------------------------

    local node = {
        Object = object,
        Row = row,
        Depth = depth,
        Parents = parents,
        Children = {},
        HasChildren = hasChildren,
        Expanded = false
    }

    table.insert(nodes, node)

    --------------------------------------------------
    -- INITIAL TEXT
    --------------------------------------------------

    local indent = string.rep("    ", depth)

    if hasChildren then

        row.Text =
            indent ..
            "▶ " ..
            object.Name ..
            " [" ..
            object.ClassName ..
            "]"

    else

        row.Text =
            indent ..
            "   " ..
            object.Name ..
            " [" ..
            object.ClassName ..
            "]"

    end

    row.Parent = explorer

    --------------------------------------------------
    -- CLICK
    --------------------------------------------------

    row.MouseButton1Click:Connect(function()

        --------------------------------------------------
        -- SCRIPT SOURCE
        --------------------------------------------------

        if scripts
            and scripts.IsScript
            and scripts.IsScript(object) then

            local source = scripts.GetSource(object)

            viewerText.Text = source

            print(
                "Loaded script:",
                object:GetFullName(),
                "Characters:",
                #source
            )

        --------------------------------------------------
        -- NORMAL OBJECT
        --------------------------------------------------

        else

            viewerText.Text =
                "Name: " .. object.Name ..
                "\nClass: " .. object.ClassName ..
                "\nChildren: " .. tostring(#object:GetChildren())

        end

        --------------------------------------------------
        -- UPDATE VIEWER
        --------------------------------------------------

        updateViewer()

        --------------------------------------------------
        -- TOGGLE TREE
        --------------------------------------------------

        if node.HasChildren then

            node.Expanded = not node.Expanded

            updateTree()

        end

    end)

    --------------------------------------------------
    -- CREATE CHILDREN
    --------------------------------------------------

    local childParents = {}

    for _, parent in ipairs(parents) do
        table.insert(childParents, parent)
    end

    table.insert(childParents, node)

    for _, child in ipairs(children) do

        local childNode = createNode(
            child,
            depth + 1,
            childParents
        )

        table.insert(node.Children, childNode)

    end

    return node

end

--------------------------------------------------
-- BUILD WORKSPACE TREE
--------------------------------------------------

print("Building Workspace Explorer...")

for _, object in ipairs(workspace:GetChildren()) do

    createNode(
        object,
        0,
        {}
    )

end

--------------------------------------------------
-- INITIAL STATE
--------------------------------------------------

updateTree()

print("Explorer objects:", #nodes)

--------------------------------------------------
-- DRAGGING
--------------------------------------------------

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

    if dragging
        and input.UserInputType == Enum.UserInputType.MouseMovement then

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

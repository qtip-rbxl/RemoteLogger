local logTable = {}
local blacklistTable = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteLoggerGUI"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
mainFrame.Size = UDim2.new(0.5, 0, 0.7, 0)
mainFrame.Position = UDim2.new(0.25, 0, 0.15, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Draggable = true

local titleFrame = Instance.new("Frame")
titleFrame.Name = "TitleFrame"
titleFrame.Parent = mainFrame
titleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleFrame.Size = UDim2.new(1, 0, 0, 50)
titleFrame.Position = UDim2.new(0, 0, 0, 0)
titleFrame.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Parent = titleFrame
titleLabel.Text = "Remote Logger v1 BETA by Scythe"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local logListFrame = Instance.new("ScrollingFrame")
logListFrame.Name = "LogListFrame"
logListFrame.Parent = mainFrame
logListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
logListFrame.Size = UDim2.new(0.5, 0, 0.9, -50)
logListFrame.Position = UDim2.new(0, 0, 0, 50)
logListFrame.BorderSizePixel = 0
logListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logListFrame.ScrollBarThickness = 10

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = logListFrame
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 5)

local logDetailsFrame = Instance.new("ScrollingFrame")
logDetailsFrame.Name = "LogDetailsFrame"
logDetailsFrame.Parent = mainFrame
logDetailsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
logDetailsFrame.Size = UDim2.new(0.5, 0, 1, -50)
logDetailsFrame.Position = UDim2.new(0.5, 0, 0, 50)
logDetailsFrame.BorderSizePixel = 0
logDetailsFrame.ScrollBarThickness = 8
logDetailsFrame.ScrollingEnabled = true
logDetailsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
logDetailsFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

local logDetailsTextBox = Instance.new("TextBox")
logDetailsTextBox.Name = "LogDetailsTextBox"
logDetailsTextBox.Parent = logDetailsFrame
logDetailsTextBox.Size = UDim2.new(1, -20, 1, 0)
logDetailsTextBox.Position = UDim2.new(0, 0, 0, 0)
logDetailsTextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
logDetailsTextBox.Text = ""
logDetailsTextBox.PlaceholderText = "Logged arguments go here"
logDetailsTextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
logDetailsTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
logDetailsTextBox.TextXAlignment = Enum.TextXAlignment.Left
logDetailsTextBox.TextYAlignment = Enum.TextYAlignment.Top
logDetailsTextBox.Font = Enum.Font.SourceSans
logDetailsTextBox.TextSize = 18
logDetailsTextBox.TextWrapped = true
logDetailsTextBox.ClearTextOnFocus = false
logDetailsTextBox.MultiLine = true

local clearLogsButton = Instance.new("TextButton")
clearLogsButton.Name = "ClearLogsButton"
clearLogsButton.Parent = mainFrame
clearLogsButton.Text = "Clear Logs"
clearLogsButton.Font = Enum.Font.SourceSansBold
clearLogsButton.TextSize = 18
clearLogsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearLogsButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
clearLogsButton.Size = UDim2.new(0, 120, 0, 40)
clearLogsButton.Position = UDim2.new(0, 10, 1, -45)

local blacklistButton = Instance.new("TextButton")
blacklistButton.Name = "BlacklistButton"
blacklistButton.Parent = mainFrame
blacklistButton.Text = "Blacklist"
blacklistButton.Font = Enum.Font.SourceSansBold
blacklistButton.TextSize = 18
blacklistButton.TextColor3 = Color3.fromRGB(255, 255, 255)
blacklistButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
blacklistButton.Size = UDim2.new(0, 120, 0, 40)
blacklistButton.Position = UDim2.new(0, 140, 1, -45)

local function clearLogs()
    for _, child in pairs(logListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    logTable = {}
    logListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

clearLogsButton.MouseButton1Click:Connect(clearLogs)

local function blacklistEvent(eventPath)
    blacklistTable[eventPath] = true
end

blacklistButton.MouseButton1Click:Connect(function()
    local selectedLog = logDetailsTextBox.Text:match("Remote: ([^\n]+)")
    if selectedLog and selectedLog ~= "" then
        blacklistEvent(selectedLog)
    end
end)

local function isBlacklisted(eventPath)
    return blacklistTable[eventPath] or false
end

local function tableToString(tbl)
    if type(tbl) ~= "table" then
        return tostring(tbl)
    end

    local result = "{\n"
    local isFirst = true

    for k, v in pairs(tbl) do
        if not isFirst then
            result = result .. ",\n"
        end
        isFirst = false

        result = result .. "\t[" .. tostring(k) .. "] = "

        if type(v) == "table" then
            result = result .. tableToString(v)
        elseif type(v) == "string" then
            result = result .. "\"" .. tostring(v) .. "\""
        else
            result = result .. tostring(v)
        end
    end

    result = result .. "\n}"
    return result
end

local function getFireType(a:string)
    if a == "RemoteFunction" then
        return "InvokeServer"
    else
        return "FireServer"
    end
end

local function logRemoteCall(remoteName, callType, args)
    local eventPath = remoteName
    if isBlacklisted(eventPath) then
        return
    end

    local argsText = "local args = {\n"

    -- Iterate over arguments
    for i, arg in ipairs(args) do
        argsText = argsText .. "\t[" .. i .. "] = "

        if type(arg) == "table" then
            argsText = argsText .. tableToString(arg) .. ",\n"
        elseif type(arg) == "string" then
            argsText = argsText .. "\"" .. tostring(arg) .. "\",\n"
        else
            argsText = argsText .. tostring(arg) .. ",\n"
        end
    end

    argsText = argsText .. "}\n\n"

    local instancePath = remoteName:match("^(.*)%..*$") or "game"
    argsText = "Remote: ".. remoteName .. "\n" .. argsText .. "game." .. instancePath .. "." .. remoteName .. ":".. getFireType(callType) .. "(unpack(args))\n"

    local logEntry = {
        RemoteName = remoteName,
        CallType = callType,
        Arguments = args,
        ArgsText = argsText
    }
    table.insert(logTable, logEntry)

    local logButton = Instance.new("TextButton")
    logButton.Parent = logListFrame
    logButton.Text = remoteName .. " (" .. callType .. ")"
    logButton.Font = Enum.Font.SourceSans
    logButton.TextSize = 16
    logButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    logButton.TextScaled = true
    logButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    logButton.Size = UDim2.new(1, -10, 0, 30)
    logButton.BorderSizePixel = 0

    logListFrame.CanvasSize = UDim2.new(0, 0, 0, #logListFrame:GetChildren() * 35)

    logButton.MouseButton1Click:Connect(function()
        logDetailsTextBox.Text = argsText
    end)
end

local originalOnClientInvoke = {}

local function logRemoteEvent(remote)
    if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
        remote.OnClientEvent:Connect(function(...)
            local args = {...}
            logRemoteCall(remote:GetFullName(), remote.ClassName, args)
        end)
    elseif remote:IsA("RemoteFunction") then
        remote.OnClientInvoke = function(...)
            local args = {...}
            logRemoteCall(remote:GetFullName(), remote.ClassName, args)
        end
    end
end


local function GetInstanceFromFullName(fullName)
    local instance = game
    for name in fullName:gmatch("[^%.]+") do
        instance = instance:FindFirstChild(name)
        if not instance then
            error("Instance not found for path: " .. fullName)
        end
    end
    return instance
end

for _, remote in pairs(game:GetDescendants()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") or remote:IsA("UnreliableRemoteEvent") then
        logRemoteEvent(remote)
    end
end

game.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") or descendant:IsA("UnreliableRemoteEvent") then
        logRemoteEvent(descendant)
    end
end)

local Players = game:GetService('Players')
local UIS = game:GetService("UserInputService")

local UI = mainFrame

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Hovered = false
local Holding = false
local MoveCon = nil

local InitialX, InitialY, UIInitialPos

local function Drag()
    if Holding == false then MoveCon:Disconnect(); return end
    local distanceMovedX = InitialX - Mouse.X
    local distanceMovedY = InitialY - Mouse.Y

    UI.Position = UIInitialPos - UDim2.new(0, distanceMovedX, 0, distanceMovedY)
end

UI.MouseEnter:Connect(function()
    Hovered = true
end)

UI.MouseLeave:Connect(function()
    Hovered = false
end)

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Holding = Hovered
        if Holding then
            InitialX, InitialY = Mouse.X, Mouse.Y
            UIInitialPos = UI.Position

            MoveCon = Mouse.Move:Connect(Drag)
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Holding = false
    end
end)

print("RemoteLogger loaded.")

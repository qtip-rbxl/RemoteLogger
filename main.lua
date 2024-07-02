-- Table to hold the logs
local logTable = {}

-- Create the new GUI for logging
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

-- Title section with custom background
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
titleLabel.Text = "Remote Logger v1 ALPHA by Q-Tip"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Left section (log list)
local logListFrame = Instance.new("Frame")
logListFrame.Name = "LogListFrame"
logListFrame.Parent = mainFrame
logListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
logListFrame.Size = UDim2.new(0.5, 0, 1, -50)
logListFrame.Position = UDim2.new(0, 0, 0, 50)
logListFrame.BorderSizePixel = 0

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = logListFrame
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Right section (log details)
local logDetailsFrame = Instance.new("Frame")
logDetailsFrame.Name = "LogDetailsFrame"
logDetailsFrame.Parent = mainFrame
logDetailsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
logDetailsFrame.Size = UDim2.new(0.5, 0, 1, -50)
logDetailsFrame.Position = UDim2.new(0.5, 0, 0, 50)
logDetailsFrame.BorderSizePixel = 0

local logDetailsTextBox = Instance.new("TextBox")
logDetailsTextBox.Name = "LogDetailsTextBox"
logDetailsTextBox.Parent = logDetailsFrame
logDetailsTextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
logDetailsTextBox.Size = UDim2.new(1, -20, 1, -20)
logDetailsTextBox.Position = UDim2.new(0, 10, 0, 10)
logDetailsTextBox.BorderSizePixel = 0
logDetailsTextBox.Text = ""
logDetailsTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
logDetailsTextBox.TextScaled = true
logDetailsTextBox.ClearTextOnFocus = false
logDetailsTextBox.MultiLine = true
logDetailsTextBox.TextWrapped = true
logDetailsTextBox.Font = Enum.Font.SourceSans
logDetailsTextBox.TextXAlignment = Enum.TextXAlignment.Left

-- Function to log remote calls
local function logRemoteCall(remoteName, remoteType, args)
    print("Logging remote call:", remoteName, remoteType, args)
    table.insert(logTable, {remoteName, remoteType, args})
    updateLogList()
end

-- Function to log remote events
local function logRemoteEvent(remote)
    remote.OnClientEvent:Connect(function(...)
        local args = {...}
        logRemoteCall(remote.Name, "RemoteEvent", args)
    end)
end

-- Connect to all existing RemoteEvents
for _, remote in pairs(game:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        print("Connecting to existing RemoteEvent:", remote.Name)
        logRemoteEvent(remote)
    end
end

-- Connect to new RemoteEvents when they are added
game.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("RemoteEvent") then
        print("New RemoteEvent added:", descendant.Name)
        logRemoteEvent(descendant)
    end
end)

-- Create log list items
local function createLogListItem(remoteName, remoteType)
    local logItem = Instance.new("TextButton")
    logItem.Parent = logListFrame
    logItem.Text = remoteName
    logItem.Font = Enum.Font.SourceSans
    logItem.TextSize = 18
    logItem.TextColor3 = Color3.fromRGB(255, 255, 255)
    logItem.BackgroundTransparency = 0.5
    logItem.Size = UDim2.new(1, 0, 0, 50)
    logItem.BorderSizePixel = 0
    
    if remoteType == "RemoteFunction" then
        logItem.BackgroundColor3 = Color3.fromRGB(255, 192, 203) -- Pink
    elseif remoteType == "RemoteEvent" then
        logItem.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
    elseif remoteType == "BindableEvent" then
        logItem.BackgroundColor3 = Color3.fromRGB(255, 165, 0) -- Orange
    elseif remoteType == "UnreliableRemoteEvent" then
        logItem.BackgroundColor3 = Color3.fromRGB(211, 211, 211) -- Gray
    end
    
    logItem.MouseButton1Click:Connect(function()
        updateLogDetails(remoteName, remoteType)
    end)
end

-- Update log list
local function updateLogList()
    logListFrame:ClearAllChildren()
    for _, logEntry in pairs(logTable) do
        createLogListItem(logEntry[1], logEntry[2])
    end
end

-- Update log details textbox
local function updateLogDetails(remoteName, remoteType)
    logDetailsTextBox.Text = ""
    for _, logEntry in pairs(logTable) do
        if logEntry[1] == remoteName and logEntry[2] == remoteType then
            logDetailsTextBox.Text = string.format("local args = {%s}\n%s:FireServer(unpack(args))", table.concat(logEntry[3], ", "), remoteName)
            break
        end
    end
end

--// Services
local Players = game:GetService('Players')
local UIS = game:GetService("UserInputService")

--// Variables
local UI = mainFrame

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Hovered = false
local Holding = false
local MoveCon = nil

local InitialX, InitialY, UIInitialPos

--// Functions

local function Drag()
	if Holding == false then MoveCon:Disconnect(); return end
	local distanceMovedX = InitialX - Mouse.X
	local distanceMovedY = InitialY - Mouse.Y

	UI.Position = UIInitialPos - UDim2.new(0, distanceMovedX, 0, distanceMovedY)
end

--// Connections

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

print("Remote Logger GUI Setup Complete")

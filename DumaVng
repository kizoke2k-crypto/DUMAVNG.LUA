--========================================================--
--                    ⚡ DUMAVNG HUB
--       GAME FONT + RAINBOW + ESP + FULLBRIGHT + NO FOG
--              DISPLAY NAME + [DISTANCE]
--========================================================--

if not game:IsLoaded() then
	repeat
		task.wait()
	until game:IsLoaded()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GUI_NAME = "DUMAVNG_HUB"
local GAME_FONT = Enum.Font.Arcade
local INFO_FONT = Enum.Font.GothamBold

--========================================================--
-- CLEANUP PHIÊN CŨ KHI EXECUTE LẠI
--========================================================--
local GlobalEnv
pcall(function()
	GlobalEnv = getgenv()
end)

if GlobalEnv and GlobalEnv.DUMAVNG_CLEANUP then
	pcall(GlobalEnv.DUMAVNG_CLEANUP)
	GlobalEnv.DUMAVNG_CLEANUP = nil
end

local OldGui = PlayerGui:FindFirstChild(GUI_NAME)
if OldGui then
	OldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--========================================================--
-- RAINBOW
--========================================================--

local RainbowObjects = {}
local GameRainbowObjects = {}

local function AddRainbow(Object)
	if not table.find(RainbowObjects, Object) then
		table.insert(RainbowObjects, Object)
	end
end

local function AddGameRainbow(Object)
	if not table.find(GameRainbowObjects, Object) then
		table.insert(GameRainbowObjects, Object)
	end
end

local function StyleText(Object)
	if not (
		Object:IsA("TextLabel")
		or Object:IsA("TextButton")
		or Object:IsA("TextBox")
	) then
		return
	end

	Object.Font = GAME_FONT
	Object.TextStrokeTransparency = 0.4
	AddRainbow(Object)
end

RunService.RenderStepped:Connect(function()
	local Hue = (tick() % 3) / 3

	for i = #RainbowObjects, 1, -1 do
		local Object = RainbowObjects[i]

		if not Object or not Object.Parent then
			table.remove(RainbowObjects, i)
		else
			Object.TextColor3 = Color3.fromHSV(Hue, 0.9, 1)
		end
	end
end)

--========================================================--
-- GAME FONT + RAINBOW
--========================================================--

local GameFontEnabled = true

local function ApplyGameFont(Object)
	if not GameFontEnabled then
		return
	end

	if Object:IsDescendantOf(ScreenGui) then
		return
	end

	if Object:IsA("TextLabel")
		or Object:IsA("TextButton")
		or Object:IsA("TextBox") then

		Object.Font = GAME_FONT
		Object.TextStrokeTransparency = 0.4
		AddGameRainbow(Object)
	end
end

local function ScanGameGUI()
	if not GameFontEnabled then
		return
	end

	for _, Object in ipairs(PlayerGui:GetDescendants()) do
		if not Object:IsDescendantOf(ScreenGui) then
			ApplyGameFont(Object)
		end
	end
end

PlayerGui.DescendantAdded:Connect(function(Object)
	if not GameFontEnabled then
		return
	end

	task.defer(function()
		if not Object:IsDescendantOf(ScreenGui) then
			ApplyGameFont(Object)
		end
	end)
end)

-- Quét toàn bộ Game UI đã tồn tại ngay khi EXECUTE
task.defer(function()
	ScanGameGUI()
end)

RunService.RenderStepped:Connect(function()
	local Hue = (tick() % 3) / 3

	for i = #GameRainbowObjects, 1, -1 do
		local Object = GameRainbowObjects[i]

		if not Object or not Object.Parent then
			table.remove(GameRainbowObjects, i)
		else
			Object.TextColor3 = Color3.fromHSV(Hue, 0.9, 1)
		end
	end
end)

--========================================================--
-- DRAG
--========================================================--

local function MakeDraggable(Object, DragArea)
	local Dragging = false
	local DragStart
	local StartPosition

	-- Chỉ bắt kéo khi chạm/click trực tiếp vào vùng kéo của HUB.
	-- Không dùng UserInputService để giữ input toàn màn hình, tránh
	-- chặn thao tác xoay camera nhân vật khi kéo/chạm ngoài HUB.
	DragArea.Active = true

	DragArea.InputBegan:Connect(function(Input)
		if Input.UserInputType ~= Enum.UserInputType.MouseButton1
			and Input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		Dragging = true
		DragStart = Input.Position
		StartPosition = Object.Position

		Input.Changed:Connect(function()
			if Input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end
		end)
	end)

	DragArea.InputChanged:Connect(function(Input)
		if not Dragging then
			return
		end

		if Input.UserInputType ~= Enum.UserInputType.MouseMovement
			and Input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local Delta = Input.Position - DragStart

		Object.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end)
end

--========================================================--
-- FPS + PING
--========================================================--

local InfoFrame = Instance.new("Frame")
InfoFrame.Name = "FPS_NETWORK_DATA"
InfoFrame.Size = UDim2.new(0, 138, 0, 20)
InfoFrame.Position = UDim2.new(0, 2, 0.43, -24)
InfoFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
InfoFrame.BackgroundTransparency = 0.15
InfoFrame.BorderSizePixel = 0
InfoFrame.ZIndex = 10
InfoFrame.Parent = ScreenGui
InfoFrame.Visible = true

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 10)
InfoCorner.Parent = InfoFrame

local InfoLayout = Instance.new("UIListLayout")
InfoLayout.FillDirection = Enum.FillDirection.Horizontal
InfoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
InfoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
InfoLayout.Padding = UDim.new(0, 1)
InfoLayout.Parent = InfoFrame

local function MakeCompactInfoLabel(Text)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0, 44, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Text = Text
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 9
	Label.Font = INFO_FONT
	Label.TextStrokeTransparency = 0.25
	Label.TextXAlignment = Enum.TextXAlignment.Center
	Label.ZIndex = 11
	Label.Parent = InfoFrame
	return Label
end

local FPSLabel = MakeCompactInfoLabel("FPS --")
local NetworkPingLabel = MakeCompactInfoLabel("NP --")
local DataPingLabel = MakeCompactInfoLabel("DP --")

local PreviousPing = 0
local DataPing = 0
local SpikeTimer = 0

RunService.RenderStepped:Connect(function(dt)
	-- FPS
	if dt > 0 then
		local FPS = math.floor(1 / dt)
		FPSLabel.Text = "FPS " .. FPS

		if FPS >= 50 then
			FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
		elseif FPS >= 30 then
			FPSLabel.TextColor3 = Color3.fromRGB(255, 220, 0)
		else
			FPSLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
		end
	end

	-- NetworkPing
	local NetworkPing = 0
	pcall(function()
		NetworkPing = math.floor(Player:GetNetworkPing() * 1000)
	end)

	NetworkPingLabel.Text = "NP " .. NetworkPing

	if NetworkPing <= 60 then
		NetworkPingLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
	elseif NetworkPing <= 120 then
		NetworkPingLabel.TextColor3 = Color3.fromRGB(255, 220, 0)
	else
		NetworkPingLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
	end

	-- DataPing: lấy Data Ping thật từ Roblox Stats.
	-- Không dùng chênh lệch ping nữa vì khi ping ổn định nó sẽ luôn +0.
	SpikeTimer += dt
	if SpikeTimer >= 0.10 then
		SpikeTimer = 0

		local RealDataPing = nil

		pcall(function()
			local Stats = game:GetService("Stats")
			local Network = Stats:FindFirstChild("Network")
			local ServerStatsItem = Network and Network:FindFirstChild("ServerStatsItem")
			local DataPingItem = ServerStatsItem and ServerStatsItem:FindFirstChild("Data Ping")

			if DataPingItem then
				local Value = DataPingItem:GetValue()
				if typeof(Value) == "number" then
					RealDataPing = math.floor(Value)
				end
			end
		end)

		-- Fallback nếu executor/game không expose Data Ping:
		-- dùng NetworkPing hiện tại thay vì hiển thị +0.
		DataPing = RealDataPing or NetworkPing

		DataPingLabel.Text = "DP " .. DataPing

		if DataPing <= 60 then
			DataPingLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
		elseif DataPing <= 120 then
			DataPingLabel.TextColor3 = Color3.fromRGB(255, 220, 0)
		else
			DataPingLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
		end
	end
end)

--========================================================--
-- OPEN BUTTON
--========================================================--

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 92, 0, 40)
OpenButton.Position = UDim2.new(0, 2, 0.43, 0)
OpenButton.ZIndex = 3
OpenButton.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
OpenButton.BorderSizePixel = 0
OpenButton.Text = "⚡ DUMAVNG"
OpenButton.TextSize = 13
OpenButton.Font = Enum.Font.Arcade
OpenButton.TextXAlignment = Enum.TextXAlignment.Center
OpenButton.AutoButtonColor = true
OpenButton.Parent = ScreenGui

local LogoMark = Instance.new("TextLabel")
LogoMark.Name = "LogoMark"
LogoMark.Size = UDim2.new(0, 22, 0, 22)
LogoMark.Position = UDim2.new(0, 5, 0.5, -11)
LogoMark.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
LogoMark.BackgroundTransparency = 0.1
LogoMark.BorderSizePixel = 0
LogoMark.Text = "⚡"
LogoMark.TextSize = 14
LogoMark.Font = Enum.Font.Arcade
LogoMark.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoMark.TextStrokeTransparency = 0.25
LogoMark.ZIndex = 5
LogoMark.Parent = OpenButton

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0)
LogoCorner.Parent = LogoMark

StyleText(LogoMark)

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = OpenButton

StyleText(OpenButton)

--========================================================--
-- MAIN UI
--========================================================--

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 315, 0, 285)
Main.Position = UDim2.new(0.5, -157, 0.5, -167)
Main.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
Main.BackgroundTransparency = 0.35
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -24, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ DUMAVNG HUB"
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar
StyleText(Title)

MakeDraggable(Main, TitleBar)

--========================================================--
-- FLY
--========================================================--

local FlyEnabled = false
local FlySpeed = 80
local FlyBV = nil
local FlyBG = nil

local function GetJoystickVector()
	local Success, Result = pcall(function()
		local PlayerScripts = Player:FindFirstChild("PlayerScripts")
		local PlayerModule = PlayerScripts and PlayerScripts:FindFirstChild("PlayerModule")
		local ControlModule = PlayerModule and PlayerModule:FindFirstChild("ControlModule")

		if ControlModule then
			local MoveVector = require(ControlModule):GetMoveVector()
			return Vector3.new(MoveVector.X, 0, MoveVector.Z)
		end

		return Vector3.new(0, 0, 0)
	end)

	return Success and Result or Vector3.new(0, 0, 0)
end

local function StopFly()
	FlyEnabled = false

	if FlyBV then
		FlyBV:Destroy()
		FlyBV = nil
	end

	if FlyBG then
		FlyBG:Destroy()
		FlyBG = nil
	end

	local Character = Player.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

	if Humanoid then
		Humanoid.PlatformStand = false
	end
end

local function StartFly()
	if FlyEnabled then
		return
	end

	local Character = Player.Character
	if not Character then
		return
	end

	local Root = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if not Root or not Humanoid then
		return
	end

	FlyEnabled = true
	Humanoid.PlatformStand = true

	FlyBV = Instance.new("BodyVelocity")
	FlyBV.MaxForce = Vector3.new(99999, 99999, 99999)
	FlyBV.Velocity = Vector3.new(0, 0, 0)
	FlyBV.Parent = Root

	FlyBG = Instance.new("BodyGyro")
	FlyBG.MaxTorque = Vector3.new(99999, 99999, 99999)
	FlyBG.P = 12500
	FlyBG.Parent = Root
end

--========================================================--
-- BUTTON CREATOR
--========================================================--

local function CreateButton(Name, Text, Y)
	local Button = Instance.new("TextButton")

	Button.Name = Name
	Button.Size = UDim2.new(1, -24, 0, 39)
	Button.Position = UDim2.new(0, 12, 0, Y)
	Button.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
	Button.BackgroundTransparency = 0.25
	Button.BorderSizePixel = 1
	Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Button.Text = Text
	Button.TextSize = 15
	Button.AutoButtonColor = true
	Button.Parent = Main

	StyleText(Button)

	return Button
end

local ResetButton = CreateButton("ResetScript", "RESET SCRIPT", 56)
local ESPButton = CreateButton("ESP", "ESP ⚡ OFF", 101)
local FullBrightButton = CreateButton("FullBright", "FULLBRIGHT ⚡ OFF", 146)
local NoFogButton = CreateButton("NoFog", "NO FOG ⚡ OFF", 191)
local FlyButton = CreateButton("Fly", "FLY ⚡ OFF", 236)

local FlySpeedMinus = CreateButton("FlySpeedMinus", "-10", 281)
FlySpeedMinus.Size = UDim2.new(0, 60, 0, 34)

local FlySpeedBox = Instance.new("TextBox")
FlySpeedBox.Name = "FlySpeed"
FlySpeedBox.Size = UDim2.new(0, 90, 0, 34)
FlySpeedBox.Position = UDim2.new(0.5, -45, 0, 281)
FlySpeedBox.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
FlySpeedBox.BackgroundTransparency = 0.25
FlySpeedBox.BorderSizePixel = 1
FlySpeedBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
FlySpeedBox.Text = tostring(FlySpeed)
FlySpeedBox.TextSize = 15
FlySpeedBox.ClearTextOnFocus = false
FlySpeedBox.Parent = Main
StyleText(FlySpeedBox)

local FlySpeedPlus = CreateButton("FlySpeedPlus", "+10", 281)
FlySpeedPlus.Size = UDim2.new(0, 60, 0, 34)
FlySpeedPlus.Position = UDim2.new(1, -72, 0, 281)

-- Mở rộng Main để chứa phần Fly.
Main.Size = UDim2.new(0, 315, 0, 325)

FlyButton.MouseButton1Click:Connect(function()
	if FlyEnabled then
		StopFly()
		FlyButton.Text = "FLY ⚡ OFF"
	else
		StartFly()
		if FlyEnabled then
			FlyButton.Text = "FLY ⚡ ON"
		end
	end
end)

FlySpeedMinus.MouseButton1Click:Connect(function()
	FlySpeed = math.max(10, FlySpeed - 10)
	FlySpeedBox.Text = tostring(FlySpeed)
end)

FlySpeedPlus.MouseButton1Click:Connect(function()
	FlySpeed = FlySpeed + 10
	FlySpeedBox.Text = tostring(FlySpeed)
end)

FlySpeedBox.FocusLost:Connect(function()
	local Value = tonumber(FlySpeedBox.Text)

	if Value then
		FlySpeed = math.max(10, Value)
		FlySpeedBox.Text = tostring(FlySpeed)
	else
		FlySpeedBox.Text = tostring(FlySpeed)
	end
end)

RunService.RenderStepped:Connect(function()
	if not FlyEnabled or not FlyBV then
		return
	end

	local Character = Player.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")
	local Camera = workspace.CurrentCamera

	if not Root or not Camera then
		StopFly()
		FlyButton.Text = "FLY ⚡ OFF"
		return
	end

	local Move = GetJoystickVector()

	-- Analog joystick quyết định hướng bay.
	-- Vuốt xoay camera lên/xuống sẽ điều khiển luôn độ cao khi bay.
	local CameraLook = Camera.CFrame.LookVector
	local CameraRight = Camera.CFrame.RightVector

	-- Dùng hướng camera đầy đủ, bao gồm cả trục Y.
	-- Vì vậy khi vuốt camera nhìn lên + đẩy analog tiến, Fly sẽ bay lên;
	-- nhìn xuống + đẩy tiến thì Fly sẽ bay xuống.
	local WorldDirection = (CameraRight * Move.X) + (CameraLook * -Move.Z)

	if WorldDirection.Magnitude > 1 then
		WorldDirection = WorldDirection.Unit
	end

	-- Analog giữ được độ mạnh: đi nhẹ thì bay chậm, đẩy hết cần thì đạt FlySpeed.
	if WorldDirection.Magnitude > 0.05 then
		FlyBV.Velocity = WorldDirection * (FlySpeed * WorldDirection.Magnitude)
	else
		FlyBV.Velocity = Vector3.new(0, 0, 0)
	end

	-- Không khóa camera bằng BodyGyro; người chơi vẫn có thể vuốt xoay camera
	-- và hướng bay sẽ bám theo hướng nhìn mới.
	if FlyBG then
		-- Chỉ dùng camera để định hướng thân nhân vật, không khóa camera.
		FlyBG.CFrame = Camera.CFrame
	end
end)


--========================================================--
-- STATES
--========================================================--

local MenuEnabled = false
local ESPEnabled = false
local FullBrightEnabled = false
local NoFogEnabled = false

--========================================================--
-- FULLBRIGHT
--========================================================--

local OriginalLighting = {
	Ambient = Lighting.Ambient,
	ColorShift_Top = Lighting.ColorShift_Top,
	ColorShift_Bottom = Lighting.ColorShift_Bottom,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	ClockTime = Lighting.ClockTime,
	Brightness = Lighting.Brightness
}

local function UpdateFullBright()
	if not FullBrightEnabled then
		return
	end

	Lighting.Ambient = Color3.fromRGB(255, 255, 255)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
	Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
	Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
	Lighting.Brightness = 2
	Lighting.ClockTime = 14
end

local function RestoreFullBright()
	Lighting.Ambient = OriginalLighting.Ambient
	Lighting.ColorShift_Top = OriginalLighting.ColorShift_Top
	Lighting.ColorShift_Bottom = OriginalLighting.ColorShift_Bottom
	Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
	Lighting.Brightness = OriginalLighting.Brightness
	Lighting.ClockTime = OriginalLighting.ClockTime
end

RunService.Heartbeat:Connect(function()
	if FullBrightEnabled then
		UpdateFullBright()
	end
end)

FullBrightButton.MouseButton1Click:Connect(function()
	FullBrightEnabled = not FullBrightEnabled

	if FullBrightEnabled then
		FullBrightButton.Text = "FULLBRIGHT ⚡ ON"
		UpdateFullBright()
	else
		FullBrightButton.Text = "FULLBRIGHT ⚡ OFF"
		RestoreFullBright()
	end
end)

--========================================================--
-- NO FOG
--========================================================--

local OriginalFog = {
	FogColor = Lighting.FogColor,
	FogStart = Lighting.FogStart,
	FogEnd = Lighting.FogEnd
}

local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
local OriginalAtmosphereDensity = nil

if Atmosphere then
	OriginalAtmosphereDensity = Atmosphere.Density
end

local function UpdateNoFog()
	if not NoFogEnabled then
		return
	end

	Lighting.FogEnd = 999999
	Lighting.FogStart = 999999

	local Atmos = Lighting:FindFirstChildOfClass("Atmosphere")
	if Atmos then
		Atmos.Density = 0
	end
end

local function RestoreFog()
	Lighting.FogColor = OriginalFog.FogColor
	Lighting.FogStart = OriginalFog.FogStart
	Lighting.FogEnd = OriginalFog.FogEnd

	local Atmos = Lighting:FindFirstChildOfClass("Atmosphere")

	if Atmos and OriginalAtmosphereDensity ~= nil then
		Atmos.Density = OriginalAtmosphereDensity
	end
end

RunService.Heartbeat:Connect(function()
	if NoFogEnabled then
		UpdateNoFog()
	end
end)

NoFogButton.MouseButton1Click:Connect(function()
	NoFogEnabled = not NoFogEnabled

	if NoFogEnabled then
		NoFogButton.Text = "NO FOG ⚡ ON"
		UpdateNoFog()
	else
		NoFogButton.Text = "NO FOG ⚡ OFF"
		RestoreFog()
	end
end)

--========================================================--
-- ESP
-- DISPLAY NAME + [DISTANCE]
--========================================================--

local ESPObjects = {}

local function ClearESP()
	for _, Data in pairs(ESPObjects) do
		if Data.Highlight then
			pcall(function()
				Data.Highlight:Destroy()
			end)
		end

		if Data.Billboard then
			pcall(function()
				Data.Billboard:Destroy()
			end)
		end
	end

	table.clear(ESPObjects)
end

local function CreateESP(Target)
	if Target == Player then
		return
	end

	local Character = Target.Character
	if not 

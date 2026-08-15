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
Main.Size = UDim2.new(0, 411, 0, 285)
Main.Position = UDim2.new(0.5, -157, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
Main.BackgroundTransparency = 0.35
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui

-- Lưu vị trí Hub lúc vừa bật script
local DUMAVNG_Reset_StartPosition = Main.Position

local TitleBar = Instance.new("Frame")
-- Ẩn thanh tiêu đề DUMAVNG HUB để xem giao diện không có title bar

TitleBar.Size = UDim2.new(1, 48, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
TitleBar.BackgroundTransparency = 0
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -24, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ HUB"
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar
StyleText(Title)

TitleBar.Active = true
-- Giữ cố định vị trí UI, tắt kéo toàn bộ Hub
-- Không thay đổi Position/Size của bất kỳ UI nào


--========================================================--
-- FLY RAINBOW EFFECT (SAFE ADDON)
--========================================================--
local FlyEffectRunning = false
local FlyEffectToken = 0

local function ClearFlyEffect()
    FlyEffectToken += 1
    local Character = Player.Character
    if not Character then return end
    for _,v in ipairs(Character:GetDescendants()) do
        if v.Name == "FlyRainbowOutline" or v.Name == "FlyRainbowFire" or v.Name == "FlyRainbowFlame" or v.Name == "FlyFireAttachment" or v.Name == "FlyFlameAttachment" or v.Name == "FlyLightningAttachment" or v.Name == "FlyLightning" then
            v:Destroy()
        end
    end
end

local function StartFlyEffect()
    ClearFlyEffect()
    FlyEffectRunning = true
    local token = FlyEffectToken

    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local h = Instance.new("Highlight")
    h.Name = "FlyRainbowOutline"
    h.FillTransparency = 1
    h.OutlineTransparency = 0
    h.Parent = Character

    -- Lửa rainbow gom thành 1 tia duy nhất
    local fireParts = {}
    local att = Instance.new("Attachment")
    att.Name = "FlyFireAttachment"
    att.Position = Vector3.new(0,-2.5,0)
    att.Parent = Root

    local flame = Instance.new("Fire")
    flame.Name = "FlyRainbowFlame"
    flame.Size = 20
    flame.Heat = 35
    flame.Parent = att
    table.insert(fireParts, flame)

    -- Điện xanh chạy vòng ngoài ngọn lửa (không sát người)
    local lightningParts = {}
    for _,offset in ipairs({
        Vector3.new(2.8,-1.8,0), Vector3.new(-2.8,-1.8,0),
        Vector3.new(0,-2.5,2.8), Vector3.new(0,-2.5,-2.8)
    }) do
        local att = Instance.new("Attachment")
        att.Name = "FlyLightningAttachment"
        att.Position = offset
        att.Parent = Root

        local spark = Instance.new("ParticleEmitter")
        spark.Name = "FlyLightning"
        spark.Color = ColorSequence.new(Color3.fromRGB(80,180,255))
        spark.LightEmission = 1
        spark.Rate = 18
        spark.Lifetime = NumberRange.new(0.15,0.35)
        spark.Speed = NumberRange.new(6,10)
        spark.SpreadAngle = Vector2.new(45,45)
        spark.Size = NumberSequence.new(0.25)
        spark.Parent = att
        table.insert(lightningParts, spark)
    end

    local blink = 0

    task.spawn(function()
        local hue = 0
        while FlyEffectRunning and token == FlyEffectToken do
            local c = Color3.fromHSV(hue,1,1)
            h.OutlineColor = c
            for _,spark in ipairs(lightningParts) do
                local power = (math.sin(blink*1.5)+1)/2
                spark.Rate = 12 + power*25
                spark.LightEmission = 0.7 + power*0.3
            end
            for _,flame in ipairs(fireParts) do
                flame.Color = c
                flame.SecondaryColor = Color3.fromHSV((hue+0.2)%1,1,1)
                local pulse = (math.sin(blink) + 1) / 2
                flame.Size = 20 + pulse * 1.0
                flame.Heat = 25 + pulse * 8
            end
            hue = (hue + 0.08) % 1
            blink = blink + 0.35
            task.wait(0.03)
        end
    end)
end

--========================================================--
-- FLY
--========================================================--

local FlyEnabled = false
local FlySpeed = 100
local FlyBV = nil
local FlyBG = nil
local FlyVertical = 0
local FlyUpButton = nil
local FlyDownButton = nil

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
	FlyVertical = 0

	if FlyUpButton then
		FlyUpButton.Visible = false
	end
	if FlyDownButton then
		FlyDownButton.Visible = false
	end

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

	if FlyUpButton then
		FlyUpButton.Visible = true
	end
	if FlyDownButton then
		FlyDownButton.Visible = true
	end

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
	Button.Size = UDim2.new(1, -40, 0, 36)
	Button.Position = UDim2.new(0, 20, 0, Y)
	Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Button.BackgroundTransparency = 0
	Button.BorderSizePixel = 1
	Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Button.Text = Text
	Button.TextSize = 15
	Button.AutoButtonColor = true
	Button.Parent = Main

	StyleText(Button)

	return Button
end

local AllButton = CreateButton("All", "ALL ⚡ OFF", 55)
local ESPButton = CreateButton("ESP", "ESP ⚡ OFF", 105)
local FullBrightButton = CreateButton("FullBright", "FULLBRIGHT ⚡ OFF", 155)
local NoFogButton = CreateButton("NoFog", "NO FOG ⚡ OFF", 205)
local NoClipButton = CreateButton("NoClip", "NOCLIP ⚡ OFF", 255)
local InfiniteJumpButton = CreateButton("InfiniteJump", "INFINITE JUMP ⚡ OFF", 305)
local FlyButton = CreateButton("Fly", "FLY OFF", 355)

local FlySpeedMinus = CreateButton("FlySpeedMinus", "-10", 325)
FlySpeedMinus.Size = UDim2.new(0, 48, 0, 28)
FlySpeedMinus.Position = UDim2.new(0.5, -89, 0, 328)

local FlySpeedBox = Instance.new("TextBox")
FlySpeedBox.Name = "FlySpeed"
FlySpeedBox.Size = UDim2.new(0, 82, 0, 28)
FlySpeedBox.Position = UDim2.new(0.5, -41, 0, 328)
FlySpeedBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FlySpeedBox.BackgroundTransparency = 0
FlySpeedBox.BorderSizePixel = 1
FlySpeedBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
FlySpeedBox.Text = tostring(FlySpeed)
FlySpeedBox.TextSize = 15
FlySpeedBox.ClearTextOnFocus = true
FlySpeedBox.Parent = Main
StyleText(FlySpeedBox)

FlySpeedBox.Focused:Connect(function()
	FlySpeedBox.Text = ""
end)

-- Slider dengan nút kéo hình máy bay
local FlySlider = Instance.new("Frame")
FlySlider.Name = "FlySlider"
FlySlider.Size = UDim2.new(1, -24, 0, 42)
FlySlider.Position = UDim2.new(0, 12, 0, 358)
FlySlider.BackgroundColor3 = Color3.fromRGB(40,40,40)
FlySlider.BackgroundTransparency = 1
FlySlider.Parent = Main

-- Thanh hiển thị Fly Speed
local FlySliderLine = Instance.new("Frame")
FlySliderLine.Name = "FlySliderLine"
FlySliderLine.Size = UDim2.new(1, -30, 0, 8)
FlySliderLine.Position = UDim2.new(0, 15, 0, 8)
FlySliderLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
FlySliderLine.BorderSizePixel = 1
FlySliderLine.BorderColor3 = Color3.fromRGB(255, 255, 255)
FlySliderLine.Parent = FlySlider

local FlySliderLineCorner = Instance.new("UICorner")
FlySliderLineCorner.CornerRadius = UDim.new(1,0)
FlySliderLineCorner.Parent = FlySliderLine

local FlySliderButton = Instance.new("TextButton")
FlySliderButton.Name = "FlySliderButton"
FlySliderButton.Text = "✈"
FlySliderButton.TextSize = 16
FlySliderButton.Size = UDim2.new(0,24,0,24)
FlySliderButton.Position = UDim2.new(0.5,-12,0,0)
FlySliderButton.BackgroundTransparency = 1
FlySliderButton.Parent = FlySlider

local function UpdateFlySlider()
	local padding = 18 / FlySlider.AbsoluteSize.X
	local x = math.clamp((FlySpeed - 10) / 290, 0, 1)
	x = padding + x * (1 - padding * 2)
	-- Thu vùng chạy nút lại, không sát đầu/cuối thanh
	FlySliderButton.Position = UDim2.new(x, -12, 0, 0)
end

UpdateFlySlider()

local draggingSlider = false
local sliderInput = nil

FlySlider.Active = true
FlySliderButton.Active = true

local function SetFlyFromSliderX(x)
	-- Thu khoảng chạy nút kéo vào một chút để không sát đầu/cuối thanh
	local padding = 18 / FlySlider.AbsoluteSize.X
	x = math.clamp(x, padding, 1 - padding)

	local valueX = (x - padding) / (1 - padding * 2)
	local NewSpeed = math.floor(10 + valueX * 290 + 0.5)

	if NewSpeed ~= FlySpeed then
		FlySpeed = NewSpeed
		FlySpeedBox.Text = tostring(FlySpeed)
	end

	FlySliderButton.Position = UDim2.new(x, -12, 0, 0)
end

local function MoveSliderFromPosition(pos)
	local x = (pos.X - FlySlider.AbsolutePosition.X) / FlySlider.AbsoluteSize.X
	SetFlyFromSliderX(x)
end

local function StartSlider(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		draggingSlider = true
		sliderInput = input
		MoveSliderFromPosition(input.Position)

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				draggingSlider = false
				sliderInput = nil
			end
		end)
	end
end

FlySliderButton.InputBegan:Connect(StartSlider)
FlySlider.InputBegan:Connect(StartSlider)

UIS.InputChanged:Connect(function(input)
	if not draggingSlider or input ~= sliderInput then
		return
	end
	MoveSliderFromPosition(input.Position)
end)

UIS.InputChanged:Connect(function(input)
	if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
		MoveSliderFromPosition(input.Position)
	end
end)

local FlySpeedPlus = CreateButton("FlySpeedPlus", "+10", 275)
FlySpeedPlus.Size = UDim2.new(0, 48, 0, 28)
FlySpeedPlus.Position = UDim2.new(0.5, 41, 0, 278)


-- Nút bay lên / xuống ở góc phải màn hình
local function CreateFlyMoveButton(Name, Text, Y)
	local Button = Instance.new("TextButton")
	Button.Name = Name
	Button.Size = UDim2.new(0, 130, 0, 70)
	Button.Position = UDim2.new(1, -173, 1, Y - 40)
	Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Button.BackgroundTransparency = 0
	Button.BorderSizePixel = 1
	Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Button.Text = Text
	Button.TextSize = 26
	Button.Visible = false
	Button.Parent = ScreenGui
	StyleText(Button)
	return Button
end

FlyUpButton = CreateFlyMoveButton("FlyUp", "▲", -175)
FlyDownButton = CreateFlyMoveButton("FlyDown", "▼", -110)

FlyUpButton.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1
	or Input.UserInputType == Enum.UserInputType.Touch then
		FlyVertical = 1
	end
end)

FlyUpButton.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1
	or Input.UserInputType == Enum.UserInputType.Touch then
		FlyVertical = 0
	end
end)

FlyDownButton.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1
	or Input.UserInputType == Enum.UserInputType.Touch then
		FlyVertical = -1
	end
end)

FlyDownButton.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1
	or Input.UserInputType == Enum.UserInputType.Touch then
		FlyVertical = 0
	end
end)

-- Mở rộng Main để chứa phần Fly.
Main.Size = UDim2.new(0, 315, 0, 470)

FlyButton.MouseButton1Click:Connect(function()
	if FlyEnabled then
		StopFly()
		FlyButton.Text = "⚡ OFF"
	else
		StartFly()
		if FlyEnabled then
			FlyButton.Text = "⚡ ON"
		end
	end
end)

FlySpeedMinus.MouseButton1Click:Connect(function()
	FlySpeed = math.max(10, FlySpeed - 10)
	FlySpeedBox.Text = tostring(FlySpeed)
	UpdateFlySlider()
end)

FlySpeedPlus.MouseButton1Click:Connect(function()
	FlySpeed = FlySpeed + 10
	FlySpeedBox.Text = tostring(FlySpeed)
	UpdateFlySlider()
end)

FlySpeedBox.FocusLost:Connect(function()
	local Value = tonumber(FlySpeedBox.Text)

	if Value then
		FlySpeed = math.max(10, Value)
		FlySpeedBox.Text = tostring(FlySpeed)
		UpdateFlySlider()
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
		FlyButton.Text = "⚡ OFF"
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
	local WorldDirection = (CameraRight * Move.X) + (CameraLook * -Move.Z) + Vector3.new(0, FlyVertical, 0)

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
-- FLY SLIDER + AIRPLANE RAINBOW
--========================================================--

local SliderRainbowHue = 0

RunService.RenderStepped:Connect(function(dt)
	SliderRainbowHue = (SliderRainbowHue + dt * 0.25) % 1
	local RainbowColor = Color3.fromHSV(SliderRainbowHue, 0.9, 1)

	if FlySliderLine and FlySliderLine.Parent then
		FlySliderLine.BackgroundColor3 = RainbowColor
	end

	if FlySliderButton and FlySliderButton.Parent then
		FlySliderButton.TextColor3 = RainbowColor
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
-- NOCLIP
--========================================================--

local NoClipEnabled = false
local InfiniteJumpEnabled = false
local LongJumpPower = 70

local function UpdateNoClip()
	local Character = Player.Character
	if not Character then return end

	for _, Part in ipairs(Character:GetDescendants()) do
		if Part:IsA("BasePart") then
			Part.CanCollide = false
		end
	end
end

RunService.Stepped:Connect(function()
	if NoClipEnabled then
		UpdateNoClip()
	end
end)

NoClipButton.MouseButton1Click:Connect(function()
	NoClipEnabled = not NoClipEnabled

	if NoClipEnabled then
		NoClipButton.Text = "NOCLIP ⚡ ON"
	else
		NoClipButton.Text = "NOCLIP ⚡ OFF"
	end
end)



--========================================================--
-- INFINITE JUMP
--========================================================--

UIS.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")

        if Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

            -- Long jump tích hợp cùng Infinite Jump
            if Root then
                local Direction = Humanoid.MoveDirection
                if Direction.Magnitude > 0 then
                    Root.AssemblyLinearVelocity = Vector3.new(
                        Direction.X * LongJumpPower,
                        Root.AssemblyLinearVelocity.Y,
                        Direction.Z * LongJumpPower
                    )
                end
            end
        end
    end
end)

InfiniteJumpButton.MouseButton1Click:Connect(function()
    InfiniteJumpEnabled = not InfiniteJumpEnabled

    if InfiniteJumpEnabled then
        InfiniteJumpButton.Text = "INFINITE JUMP ⚡ ON"
    else
        InfiniteJumpButton.Text = "INFINITE JUMP ⚡ OFF"
    end
end)



--========================================================--
-- SPEED RUN ⚡ + HORSE SLIDER
--========================================================--
local SpeedRunEnabled = false
local SpeedRunValue = 100
local SpeedRunButton = CreateButton("SpeedRun", "SPEED RUN ⚡ OFF", 355)

-- đẩy Fly xuống dưới để chừa chỗ Speed Run
FlyButton.Position = UDim2.new(0,20,0,455)

local SpeedPanelGap = 5
local SpeedPanelX = 20
local SpeedPanelWidth = Main.AbsoluteSize.X - 40
local SpeedPanelHeight = 30
local SpeedPanelItemWidth = math.floor((SpeedPanelWidth - SpeedPanelGap * 2) / 3)

-- 3 panel bằng nhau, có khe hở nhẹ, nhưng căn đúng hai đầu với SPEED RUN.
local SpeedMinus = CreateButton("SpeedMinus", "-10", 396)
SpeedMinus.Size = UDim2.new(0, SpeedPanelItemWidth, 0, SpeedPanelHeight)
SpeedMinus.Position = UDim2.new(0, SpeedPanelX, 0, 396)

local SpeedBox = Instance.new("TextBox")
SpeedBox.Name = "SpeedRunSpeed"
SpeedBox.Size = UDim2.new(0, SpeedPanelItemWidth, 0, SpeedPanelHeight)
SpeedBox.Position = UDim2.new(0, SpeedPanelX + SpeedPanelItemWidth + SpeedPanelGap, 0, 396)
SpeedBox.BackgroundColor3 = Color3.fromRGB(0,0,0)
SpeedBox.BackgroundTransparency = 0
SpeedBox.BorderSizePixel = 1
SpeedBox.BorderColor3 = Color3.fromRGB(0,0,0)
SpeedBox.Text = tostring(SpeedRunValue)
SpeedBox.TextSize = 15
SpeedBox.ClearTextOnFocus = true
SpeedBox.Parent = Main
StyleText(SpeedBox)

local SpeedPlus = CreateButton("SpeedPlus", "+10", 396)
SpeedPlus.Size = UDim2.new(0, SpeedPanelItemWidth, 0, SpeedPanelHeight)
SpeedPlus.Position = UDim2.new(0, SpeedPanelX + (SpeedPanelItemWidth + SpeedPanelGap) * 2, 0, 396)

-- Thanh kéo nằm ngay dưới 3 panel, cùng hai đầu với cụm panel.
local SpeedSlider = Instance.new("Frame")
SpeedSlider.Name = "SpeedRunSlider"
SpeedSlider.Size = UDim2.new(1,-40,0,42)
SpeedSlider.Position = UDim2.new(0,20,0,437)
SpeedSlider.BackgroundTransparency = 1
SpeedSlider.Parent = Main

local SpeedLine = Instance.new("Frame")
SpeedLine.Size = UDim2.new(1,0,0,8)
SpeedLine.Position = UDim2.new(0,0,0,8)
SpeedLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
SpeedLine.BorderSizePixel = 1
SpeedLine.BorderColor3 = Color3.fromRGB(255,255,255)
SpeedLine.Parent = SpeedSlider
local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(1,0)
SpeedCorner.Parent = SpeedLine

local SpeedKnob = Instance.new("TextButton")
SpeedKnob.Name = "HorseSpeedKnob"
SpeedKnob.Text = "🐎"
SpeedKnob.TextSize = 18
SpeedKnob.Size = UDim2.new(0,28,0,28)
SpeedKnob.BackgroundTransparency = 1
SpeedKnob.Parent = SpeedSlider

-- Giới hạn nút kéo để nó luôn nằm hoàn toàn trong thanh.
local function UpdateSpeedSlider()
    local x = math.clamp((SpeedRunValue - 16) / (300 - 16), 0, 1)
    local lineWidth = SpeedLine.AbsoluteSize.X
    local knobWidth = SpeedKnob.AbsoluteSize.X
    local minCenter = knobWidth / 2
    local maxCenter = math.max(minCenter, lineWidth - knobWidth / 2)
    local centerX = minCenter + x * (maxCenter - minCenter)
    SpeedKnob.Position = UDim2.new(0, centerX - knobWidth / 2, 0, -10)
    SpeedBox.Text = tostring(SpeedRunValue)
end

SpeedKnob.Position = UDim2.new(0,0,0,-10)
UpdateSpeedSlider()

SpeedMinus.MouseButton1Click:Connect(function()
    SpeedRunValue = math.clamp(SpeedRunValue - 10,16,300)
    SpeedBox.Text = tostring(SpeedRunValue)
    UpdateSpeedSlider()
    ApplySpeed()
end)

SpeedPlus.MouseButton1Click:Connect(function()
    SpeedRunValue = math.clamp(SpeedRunValue + 10,16,300)
    SpeedBox.Text = tostring(SpeedRunValue)
    UpdateSpeedSlider()
    ApplySpeed()
end)

local function ApplySpeed()
    local c = Player.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h and SpeedRunEnabled then
        h.WalkSpeed = SpeedRunValue
    end
end

SpeedRunButton.MouseButton1Click:Connect(function()
    SpeedRunEnabled = not SpeedRunEnabled
    SpeedRunButton.Text = SpeedRunEnabled and "SPEED RUN ⚡ ON" or "SPEED RUN ⚡ OFF"
    if SpeedRunEnabled then
        ApplySpeed()
        -- Bật hiệu ứng cùng lúc với Speed Run

    else
        local c = Player.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 16 end
        -- Tắt hiệu ứng khi tắt Speed Run

    end
end)

SpeedBox.FocusLost:Connect(function()
    local n = tonumber(SpeedBox.Text)
    if n then
        SpeedRunValue = math.clamp(n,16,300)
        SpeedBox.Text = tostring(SpeedRunValue)
        UpdateSpeedSlider()
        ApplySpeed()
    end
end)

local draggingSpeed = false
SpeedKnob.MouseButton1Down:Connect(function()
    draggingSpeed = true
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        draggingSpeed = false
    end
end)
UIS.InputChanged:Connect(function(i)
    if draggingSpeed and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local lineLeft = SpeedLine.AbsolutePosition.X
        local lineWidth = SpeedLine.AbsoluteSize.X
        local knobWidth = SpeedKnob.AbsoluteSize.X
        local minCenter = knobWidth / 2
        local maxCenter = math.max(minCenter, lineWidth - knobWidth / 2)
        local pointerX = i.Position.X - lineLeft
        local centerX = math.clamp(pointerX, minCenter, maxCenter)
        local x = (centerX - minCenter) / math.max(1, maxCenter - minCenter)
        SpeedKnob.Position = UDim2.new(0, centerX - knobWidth / 2 + 15, 0, -10)
        SpeedRunValue = math.floor(16 + x * 284 + 0.5)
        SpeedBox.Text = tostring(SpeedRunValue)
        ApplySpeed()
    end
end)


-- SPEED RUN RAINBOW SLIDER + RESPAWN FIX
local SpeedRainbowHue = 0

RunService.RenderStepped:Connect(function(dt)
    SpeedRainbowHue = (SpeedRainbowHue + dt * 0.25) % 1
    local col = Color3.fromHSV(SpeedRainbowHue,0.9,1)

    if SpeedLine and SpeedLine.Parent then
        SpeedLine.BackgroundColor3 = col
    end

    if SpeedKnob and SpeedKnob.Parent then
        SpeedKnob.TextColor3 = col
    end
end)

Player.CharacterAdded:Connect(function(char)
    -- giống Fly: respawn thì tự tắt Speed Run
    SpeedRunEnabled = false

    if SpeedRunButton and SpeedRunButton.Parent then
        SpeedRunButton.Text = "SPEED RUN ⚡ OFF"
    end

    task.wait(1)
    local hum = char:WaitForChild("Humanoid",5)
    if hum then
        hum.WalkSpeed = 16
    end
end)

-- SPEED RUN FORCE APPLY
RunService.Heartbeat:Connect(function()
    if SpeedRunEnabled then
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.WalkSpeed ~= SpeedRunValue then
            hum.WalkSpeed = SpeedRunValue
        end
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
	if not Character then
		return
	end

	local Root = Character:FindFirstChild("HumanoidRootPart")
	if not Root then
		return
	end

	local Highlight = Instance.new("Highlight")
	Highlight.Name = "DUMAVNG_ESP"
	Highlight.Adornee = Character
	Highlight.FillTransparency = 1
	Highlight.OutlineTransparency = 0
	Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.Parent = Character

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = "DUMAVNG_ESP_INFO"
	Billboard.Adornee = Root
	Billboard.Size = UDim2.new(0, 150, 0, 42)
	Billboard.StudsOffset = Vector3.new(0, 3, 0)
	Billboard.AlwaysOnTop = true
	Billboard.Parent = Root

	local NameLabel = Instance.new("TextLabel")
	NameLabel.Size = UDim2.new(1, 0, 0, 21)
	NameLabel.BackgroundTransparency = 1

	-- HIỆN DISPLAY NAME
	NameLabel.Text = Target.DisplayName

	NameLabel.TextSize = 14
	NameLabel.Font = GAME_FONT
	NameLabel.TextStrokeTransparency = 0
	NameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	NameLabel.Parent = Billboard

	AddGameRainbow(NameLabel)

	local DistanceLabel = Instance.new("TextLabel")
	DistanceLabel.Size = UDim2.new(1, 0, 0, 19)
	DistanceLabel.Position = UDim2.new(0, 0, 0, 21)
	DistanceLabel.BackgroundTransparency = 1
	DistanceLabel.Text = "[--M]"
	DistanceLabel.TextSize = 12
	DistanceLabel.Font = GAME_FONT
	DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	DistanceLabel.TextStrokeTransparency = 0
	DistanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	DistanceLabel.Parent = Billboard

	ESPObjects[Target] = {
		Highlight = Highlight,
		Billboard = Billboard,
		NameLabel = NameLabel,
		DistanceLabel = DistanceLabel
	}
end

local function UpdateESP()
	ClearESP()

	if not ESPEnabled then
		return
	end

	for _, Target in ipairs(Players:GetPlayers()) do
		CreateESP(Target)
	end
end

Players.PlayerAdded:Connect(function(Target)
	Target.CharacterAdded:Connect(function()
		task.wait(0.5)

		if ESPEnabled then
			UpdateESP()
		end
	end)
end)

Players.PlayerRemoving:Connect(function(Target)
	local Data = ESPObjects[Target]

	if Data then
		if Data.Highlight then
			Data.Highlight:Destroy()
		end

		if Data.Billboard then
			Data.Billboard:Destroy()
		end

		ESPObjects[Target] = nil
	end
end)

RunService.RenderStepped:Connect(function()
	if not ESPEnabled then
		return
	end

	local Character = Player.Character

	local MyRoot = Character
		and Character:FindFirstChild("HumanoidRootPart")

	if not MyRoot then
		return
	end

	for Target, Data in pairs(ESPObjects) do
		if Target.Character then
			local Root =
				Target.Character:FindFirstChild("HumanoidRootPart")

			if Root and Data.DistanceLabel then
				local Distance =
					(MyRoot.Position - Root.Position).Magnitude

				local Meters =
					math.floor(Distance * 0.28)

				Data.DistanceLabel.Text =
					"[" .. tostring(Meters) .. "M]"
			end
		end
	end
end)

ESPButton.MouseButton1Click:Connect(function()
	ESPEnabled = not ESPEnabled

	if ESPEnabled then
		ESPButton.Text = "ESP ⚡ ON"
		UpdateESP()
	else
		ESPButton.Text = "ESP ⚡ OFF"
		ClearESP()
	end
end)

--========================================================--
-- ⚡ OPEN
-- TỰ BẬT ESP + FULLBRIGHT + NO FOG
--========================================================--

OpenButton.MouseButton1Click:Connect(function()
	MenuEnabled = not MenuEnabled
	Main.Visible = MenuEnabled

	if MenuEnabled then
		OpenButton.Text = "⚡ DUMAVNG"
	else
		OpenButton.Text = "⚡ DUMAVNG"
	end
end)

--========================================================--
-- FUNCTION 3
--========================================================--


--========================================================--
-- RESET SCRIPT
-- TẮT CHỨC NĂNG, KHÔNG XÓA UI
--========================================================--

--========================================================--
-- ALL ⚡ ON OFF
-- BẬT/TẮT TOÀN BỘ CHỨC NĂNG
--========================================================--

local AllEnabled = false

AllButton.MouseButton1Click:Connect(function()
	AllEnabled = not AllEnabled

	if AllEnabled then
		AllButton.Text = "ALL ⚡ ON"

		ESPEnabled = true
		UpdateESP()
		ESPButton.Text = "ESP ⚡ ON"

		FullBrightEnabled = true
		UpdateFullBright()
		FullBrightButton.Text = "FULLBRIGHT ⚡ ON"

		NoFogEnabled = true
		UpdateNoFog()
		NoFogButton.Text = "NO FOG ⚡ ON"

		StartFly()
		if FlyEnabled then
			FlyButton.Text = "⚡ ON"
		end

		GameFontEnabled = true
	else
		AllButton.Text = "ALL ⚡ OFF"

		ESPEnabled = false
		ClearESP()
		ESPButton.Text = "ESP ⚡ OFF"

		FullBrightEnabled = false
		RestoreFullBright()
		FullBrightButton.Text = "FULLBRIGHT ⚡ OFF"

		NoFogEnabled = false
		RestoreFog()
		NoFogButton.Text = "NO FOG ⚡ OFF"

		StopFly()
		FlyButton.Text = "⚡ OFF"

		GameFontEnabled = false
	end
end)

--========================================================--
-- REGISTER CLEANUP FOR NEXT EXECUTION
--========================================================--
if GlobalEnv then
	GlobalEnv.DUMAVNG_CLEANUP = function()
		ESPEnabled = false
		FullBrightEnabled = false
		NoFogEnabled = false
		StopFly()
		GameFontEnabled = false
		MenuEnabled = false

		pcall(ClearESP)
		pcall(RestoreFullBright)
		pcall(RestoreFog)

		pcall(function()
			if ScreenGui and ScreenGui.Parent then
				ScreenGui:Destroy()
			end
		end)
	end
end



--========================================================--
-- EFFECT REMOVED
--========================================================--

local CreateBlackBatWings

--========================================================--
-- DUMAVNG HUB - BLACK BAT WINGS EFFECT
--========================================================--

CreateBlackBatWings = function()
	local plr = game:GetService("Players").LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()

	local old = char:FindFirstChild("DUMAVNG_BlackBatWings")
	if old then old:Destroy() end

	local root = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	if not root then return end

	local folder = Instance.new("Folder")
	folder.Name = "DUMAVNG_BlackBatWings"
	folder.Parent = char

	local function wing(name, side)
		local w = Instance.new("Part")
		w.Name = name
		w.Size = Vector3.new(3.2,4.5,0.15)
		w.Material = Enum.Material.SmoothPlastic
		w.Color = Color3.fromRGB(22,22,22)
		w.CanCollide = false
		w.Massless = true
		w.Parent = folder

		local weld = Instance.new("Weld")
		weld.Part0 = root
		weld.Part1 = w
		weld.C0 = CFrame.new(side*1.3,0.6,1.1)
			* CFrame.Angles(0,side*math.rad(35),side*math.rad(15))
		weld.Parent = w

		local smoke = Instance.new("ParticleEmitter")
		smoke.Texture = "rbxassetid://243660364"
		smoke.Rate = 12
		smoke.Lifetime = NumberRange.new(.5,1)
		smoke.Speed = NumberRange.new(0,1)
		smoke.Parent = w
	end

	wing("LeftBlackWing",-1)
	wing("RightBlackWing",1)
end

-- wings disabled by default

-- wing respawn disabled



--========================================================--
-- ⚡ ULTRA INSTINCT FLY PANEL (RIGHT SIDE)
--========================================================--

local UltraOpen = false

local UltraButton = Instance.new("TextButton")
UltraButton.Name = "UltraInstinctButton_New"
UltraButton.Size = UDim2.new(0,48,0,112)
UltraButton.Position = UDim2.new(1,0,0,44)
UltraButton.BackgroundColor3 = Color3.fromRGB(17,17,17)
UltraButton.BackgroundTransparency = 0.35
UltraButton.BorderSizePixel = 0
UltraButton.Text = "✈"
UltraButton.TextSize = 34
UltraButton.Font = Enum.Font.GothamBold
UltraButton.TextStrokeTransparency = 1
UltraButton.Parent = Main
StyleText(UltraButton)
UltraButton.Font = Enum.Font.GothamBold
UltraButton.TextStrokeTransparency = 1
UltraButton.TextStrokeColor3 = Color3.fromRGB(0,0,0)
UltraButton.Parent = Main
StyleText(UltraButton)
UltraButton.Font = Enum.Font.GothamBold

local UltraPanel = Instance.new("Frame")
UltraPanel.Name = "UltraInstinctPanel"
UltraPanel.Size = UDim2.new(0,170,0,112)
UltraPanel.Position = UDim2.new(1,46,0,0)
UltraPanel.AnchorPoint = Vector2.new(0,0)
UltraPanel.BackgroundColor3 = Main.BackgroundColor3
UltraPanel.BackgroundTransparency = Main.BackgroundTransparency
UltraPanel.BorderSizePixel = Main.BorderSizePixel
UltraPanel.BorderColor3 = Main.BorderColor3
UltraPanel.Visible = false
UltraPanel.Parent = Main
UltraPanel.Active = true
-- Chặn vuốt nền Ultra ăn vào xoay camera nhân vật
pcall(function()
    UltraPanel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            input:CaptureController()
        end
    end)
end)

local UltraTitle = Instance.new("TextLabel")
UltraTitle.Size = UDim2.new(1,0,0,8)
UltraTitle.BackgroundTransparency = 1
UltraTitle.Text = ""
UltraTitle.TextSize = 13
UltraTitle.Parent = UltraPanel
StyleText(UltraTitle)

-- đưa Fly + điều chỉnh sang bảng riêng (gọn, đều kích thước)
pcall(function()
    FlyButton.Parent = UltraPanel
    FlyButton.Size = UDim2.new(1,-16,0,35)
    FlyButton.Position = UDim2.new(0,8,0,6)
    FlyButton.Text = FlyEnabled and "⚡ ON" or "⚡ OFF"

    local BoxY = 48
    local BoxSize = UDim2.new(0,45,0,30)

    FlySpeedMinus.Parent = UltraPanel
    FlySpeedMinus.Size = BoxSize
    FlySpeedMinus.Position = UDim2.new(0,8,0,BoxY)

    FlySpeedBox.Parent = UltraPanel
    FlySpeedBox.Size = UDim2.new(0,55,0,30)
    FlySpeedBox.Position = UDim2.new(0.5,-27,0,BoxY)

    FlySpeedPlus.Parent = UltraPanel
    FlySpeedPlus.Size = BoxSize
    FlySpeedPlus.Position = UDim2.new(1,-53,0,BoxY)

    FlySlider.Parent = UltraPanel
    FlySlider.Position = UDim2.new(0,4,0,83)
    FlySlider.Size = UDim2.new(1,-8,0,26)
end)

-- Ẩn/hiện ⚡ ULTRA INSTINCT theo UI chính
pcall(function()
    local oldMainVisible = Main.Visible
    Main:GetPropertyChangedSignal("Visible"):Connect(function()
        UltraButton.Visible = Main.Visible
        if not Main.Visible then
            -- Giữ trạng thái Ultra khi đóng/mở lại UI chính
            -- Không reset UltraOpen
            UltraPanel.Visible = false
        elseif UltraOpen then
            UltraPanel.Visible = true
            UltraButton.Text = UltraOpen and "◀" or "✈"
        end
    end)
    UltraButton.Visible = Main.Visible
end)



-- Chỉ kéo UI bằng tiêu đề
pcall(function()
    MakeDraggable(Main, TitleBar)
end)


-- DUMAVNG HUB UI TOUCH FIX
-- Lưu vị trí lúc execute
local DUMAVNG_StartPosition = Main.Position

-- Chỉ nền HUB chặn camera, không kéo UI
pcall(function()
    Main.Active = true
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            input:CaptureController()
        end
    end)
end)



-- ULTRA INSTINCT FOLLOW DUMAVNG HUB: attached to Main, keeps original position


-- Ultra Instinct: 5px gap from DUMAVNG HUB, title height matched to main title


-- Ultra Instinct list moved directly under button with no visible gap




-- SERVER PANEL 🌎
-- Nút ngoài giống Fly/Teleport, mở danh sách RESET SERVER + NEW SERVER
local ServerOpen = false

local ServerButton = Instance.new("TextButton")
ServerButton.Name = "ServerListButton"
ServerButton.Size = UDim2.new(0,48,0,112)
ServerButton.Position = UDim2.new(1,0,0,268)
ServerButton.BackgroundColor3 = UltraButton.BackgroundColor3
ServerButton.BackgroundTransparency = UltraButton.BackgroundTransparency
ServerButton.BorderSizePixel = 0
ServerButton.Text = ServerOpen and "◀" or "🌎"
ServerButton.TextSize = 34
ServerButton.Font = Enum.Font.GothamBold
ServerButton.TextStrokeTransparency = 1
ServerButton.Parent = Main
AddRainbow(ServerButton)

local ServerPanel = Instance.new("Frame")
ServerPanel.Name = "ServerPanel"
ServerPanel.Size = UDim2.new(0,170,0,96)
ServerPanel.Position = UDim2.new(1,46,0,0)
ServerPanel.BackgroundColor3 = Main.BackgroundColor3
ServerPanel.BackgroundTransparency = Main.BackgroundTransparency
ServerPanel.BorderSizePixel = 0
ServerPanel.Visible = false
ServerPanel.Parent = Main

local ServerLayout = Instance.new("UIListLayout")
ServerLayout.Padding = UDim.new(0,5)
ServerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ServerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ServerLayout.Parent = ServerPanel

local function CreateServerButton(text,callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-16,0,36)
    b.BackgroundColor3 = Color3.fromRGB(0,0,0)
    b.BorderSizePixel = 1
    b.Text = text
    b.TextSize = 15
    b.Parent = ServerPanel
    StyleText(b)
    b.MouseButton1Click:Connect(callback)
end

CreateServerButton("🔄 RESET SERVER", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
end)

CreateServerButton("🌐 NEW SERVER", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
end)

ServerButton.MouseButton1Click:Connect(function()
    ServerOpen = not ServerOpen
    if ServerOpen then
        if getgenv().DUMAVNG_CloseTeleport then
            getgenv().DUMAVNG_CloseTeleport()
        end
        if getgenv().DUMAVNG_CloseFly then
            getgenv().DUMAVNG_CloseFly()
        end
    end
    ServerButton.Text = ServerOpen and "◀" or "🌎"
    ServerPanel.Visible = ServerOpen
end)


-- TOGGLE PANEL ⚡/🔥 (DƯỚI SERVER, KHÔNG DANH SÁCH)
local TogglePanelOn = false

local TogglePanelButton = Instance.new("TextButton")
TogglePanelButton.Name = "TogglePanelButton"
TogglePanelButton.Size = UDim2.new(0,48,0,90)
TogglePanelButton.Position = UDim2.new(1,0,0,380)
TogglePanelButton.BackgroundColor3 = UltraButton.BackgroundColor3
TogglePanelButton.BackgroundTransparency = UltraButton.BackgroundTransparency
TogglePanelButton.BorderSizePixel = 0
TogglePanelButton.Text = "⚡"
TogglePanelButton.TextSize = 34
TogglePanelButton.Font = Enum.Font.GothamBold
TogglePanelButton.TextStrokeTransparency = 1
TogglePanelButton.AutoButtonColor = true
TogglePanelButton.Parent = Main
AddRainbow(TogglePanelButton)

local TogglePanel = Instance.new("Frame")
TogglePanel.Name = "TogglePanel"
TogglePanel.Size = UDim2.new(0,170,0,48)
TogglePanel.Position = UDim2.new(1,46,0,0)
TogglePanel.BackgroundColor3 = Main.BackgroundColor3
TogglePanel.BackgroundTransparency = Main.BackgroundTransparency
TogglePanel.BorderSizePixel = Main.BorderSizePixel
TogglePanel.BorderColor3 = Main.BorderColor3
TogglePanel.Visible = false
TogglePanel.Parent = Main

-- EFFECT BUTTON
-- Panel cũ chỉ đổi icon nhưng không bao giờ mở panel / gọi effect.
local EffectButton = Instance.new("TextButton")
EffectButton.Name = "FlyEffectButton"
EffectButton.Size = UDim2.new(1,-16,0,36)
EffectButton.Position = UDim2.new(0,8,0,6)
EffectButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
EffectButton.BorderSizePixel = 1
EffectButton.Text = FlyEffectRunning and "🔥 EFFECT ON" or "🔥 EFFECT OFF"
EffectButton.TextSize = 14
EffectButton.AutoButtonColor = true
EffectButton.Parent = TogglePanel
StyleText(EffectButton)

local function SetFlyEffect(state)
    FlyEffectRunning = state

    if state then
        EffectButton.Text = "🔥 EFFECT ON"
        StartFlyEffect()
    else
        EffectButton.Text = "🔥 EFFECT OFF"
        ClearFlyEffect()
    end
end

EffectButton.MouseButton1Click:Connect(function()
    SetFlyEffect(not FlyEffectRunning)
end)

-- Nếu nhân vật respawn thì gọi lại effect khi đang bật.
Player.CharacterAdded:Connect(function()
    if FlyEffectRunning then
        task.wait(0.5)
        StartFlyEffect()
        if EffectButton and EffectButton.Parent then
            EffectButton.Text = "🔥 EFFECT ON"
        end
    end
end)

TogglePanelButton.MouseButton1Click:Connect(function()
    SetFlyEffect(not FlyEffectRunning)
    TogglePanelButton.Text = FlyEffectRunning and "🔥" or "⚡"
end)

-- TELEPORT PLAYER LIST (5 DISPLAYNAME)
-- Nút ngoài giống nút máy bay/Fly: cùng tone nền UI, không bo góc.
local TeleportOpen = false

local TeleportButton = Instance.new("TextButton")
TeleportButton.Name = "TeleportListButton"
TeleportButton.Size = UDim2.new(0,48,0,112)
TeleportButton.Position = UDim2.new(1,0,0,156)
TeleportButton.BackgroundColor3 = UltraButton.BackgroundColor3
TeleportButton.BackgroundTransparency = UltraButton.BackgroundTransparency
TeleportButton.BorderSizePixel = 0
TeleportButton.Text = TeleportOpen and "◀" or "👥"
TeleportButton.TextSize = 34
TeleportButton.Font = Enum.Font.GothamBold
TeleportButton.TextStrokeTransparency = 1
TeleportButton.AutoButtonColor = true
TeleportButton.Parent = Main
-- Rainbow mũi tên đóng Teleport giống Fly
AddRainbow(TeleportButton)

local TeleportPanel = Instance.new("Frame")
TeleportPanel.Name = "TeleportPlayerList"
TeleportPanel.Size = UDim2.new(0,170,0,295)
TeleportPanel.Position = UDim2.new(1,46,0,0)
TeleportPanel.BackgroundColor3 = Main.BackgroundColor3
TeleportPanel.BackgroundTransparency = Main.BackgroundTransparency
TeleportPanel.BorderSizePixel = Main.BorderSizePixel
TeleportPanel.BorderColor3 = Main.BorderColor3
TeleportPanel.Visible = false
TeleportPanel.Parent = Main
TeleportPanel.Active = true

-- Không UICorner: bảng Teleport vuông góc giống yêu cầu.
local TeleportPadding = Instance.new("UIPadding")
TeleportPadding.PaddingTop = UDim.new(0,6)
TeleportPadding.PaddingBottom = UDim.new(0,6)
TeleportPadding.PaddingLeft = UDim.new(0,8)
TeleportPadding.PaddingRight = UDim.new(0,8)
TeleportPadding.Parent = TeleportPanel

local TeleportLayout = Instance.new("UIListLayout")
TeleportLayout.Padding = UDim.new(0,5)
TeleportLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TeleportLayout.SortOrder = Enum.SortOrder.LayoutOrder
TeleportLayout.Parent = TeleportPanel

local function RefreshTeleportList()
    for _,v in ipairs(TeleportPanel:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end

    local count = 0

    -- LƯU VỊ TRÍ SPAWN TÙY CHỈNH
    local setSpawnBtn = Instance.new("TextButton")
    setSpawnBtn.Name = "SetSpawn"
    setSpawnBtn.Size = UDim2.new(1,0,0,36)
    setSpawnBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    setSpawnBtn.BackgroundTransparency = 0
    setSpawnBtn.BorderSizePixel = 1
    setSpawnBtn.BorderColor3 = Color3.fromRGB(0,0,0)
    setSpawnBtn.Text = "SET SPAWN"
    setSpawnBtn.TextSize = 15
    setSpawnBtn.TextStrokeTransparency = 0.4
    setSpawnBtn.Parent = TeleportPanel
    StyleText(setSpawnBtn)

    if not getgenv().DUMAVNG_CustomSpawn then
        getgenv().DUMAVNG_CustomSpawn = nil
    end

    setSpawnBtn.MouseButton1Click:Connect(function()
        local Character = Player.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        if Root then
            getgenv().DUMAVNG_CustomSpawn = Root.CFrame
            setSpawnBtn.Text = "SPAWN SAVED"
            task.wait(0.8)
            setSpawnBtn.Text = "SET SPAWN"
        end
    end)

    -- SPAWN TELEPORT
    local spawnBtn = Instance.new("TextButton")
    spawnBtn.Name = "Spawn"
    spawnBtn.Size = UDim2.new(1,0,0,36)
    spawnBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    spawnBtn.BackgroundTransparency = 0
    spawnBtn.BorderSizePixel = 1
    spawnBtn.BorderColor3 = Color3.fromRGB(0,0,0)
    spawnBtn.Text = "SPAWN"
    spawnBtn.TextSize = 15
    spawnBtn.TextXAlignment = Enum.TextXAlignment.Center
    spawnBtn.AutoButtonColor = true
    spawnBtn.TextStrokeTransparency = 0.4
    spawnBtn.Parent = TeleportPanel
    StyleText(spawnBtn)

    spawnBtn.MouseButton1Click:Connect(function()
        local MyCharacter = Player.Character
        local MyRoot = MyCharacter and MyCharacter:FindFirstChild("HumanoidRootPart")
        if not MyRoot then return end

        if getgenv().DUMAVNG_CustomSpawn then
            MyRoot.CFrame = getgenv().DUMAVNG_CustomSpawn + Vector3.new(0,3,0)
            return
        end

        local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
        if spawn then
            MyRoot.CFrame = spawn.CFrame + Vector3.new(0,3,0)
        end
    end)

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and count < 5 then
            local b = Instance.new("TextButton")
            b.Name = "Player_" .. tostring(plr.UserId)
            b.Size = UDim2.new(1,0,0,36)
            b.BackgroundColor3 = Color3.fromRGB(0,0,0)
            b.BackgroundTransparency = 0
            b.BorderSizePixel = 1
            b.BorderColor3 = Color3.fromRGB(0,0,0)
            b.Text = plr.DisplayName
            b.TextSize = 15
            b.TextXAlignment = Enum.TextXAlignment.Center
            b.AutoButtonColor = true
            b.TextStrokeTransparency = 0.4
            b.Parent = TeleportPanel
            StyleText(b)

            -- Chỉ hiện DisplayName, click để teleport tới người đó.
            b.MouseButton1Click:Connect(function()
                local Character = plr.Character
                local TargetRoot = Character and Character:FindFirstChild("HumanoidRootPart")
                local MyCharacter = Player.Character
                local MyRoot = MyCharacter and MyCharacter:FindFirstChild("HumanoidRootPart")
                if TargetRoot and MyRoot then
                    MyRoot.CFrame = TargetRoot.CFrame + Vector3.new(0,3,0)
                end
            end)

            count += 1
        end
    end
end

local function SetTeleportPanelVisible(state)
    TeleportOpen = state
    TeleportButton.Text = state and "◀" or "👥"
    TeleportPanel.Visible = state
    if state then
        RefreshTeleportList()
    end
end

-- Đóng panel khác khi mở panel mới
getgenv().DUMAVNG_CloseTeleport = function()
    SetTeleportPanelVisible(false)
end

getgenv().DUMAVNG_CloseFly = function()
    UltraOpen = false
    UltraPanel.Visible = false
    UltraButton.Text = "✈"
end

TeleportButton.MouseButton1Click:Connect(function()
    SetTeleportPanelVisible(not TeleportOpen)
    if TeleportOpen then
        if getgenv().DUMAVNG_CloseFly then
            getgenv().DUMAVNG_CloseFly()
        end
        ServerOpen = false
        ServerPanel.Visible = false
        ServerButton.Text = "🌎"
    end
end)

UltraButton.MouseButton1Click:Connect(function()
    UltraOpen = not UltraOpen
    if UltraOpen then
        SetTeleportPanelVisible(false)
        ServerOpen = false
        ServerPanel.Visible = false
        ServerButton.Text = "🌎"
    end
    UltraPanel.Visible = UltraOpen
    UltraButton.Text = UltraOpen and "◀" or "✈"
end)

Players.PlayerAdded:Connect(function()
    if TeleportOpen then
        task.defer(RefreshTeleportList)
    end
end)

Players.PlayerRemoving:Connect(function()
    if TeleportOpen then
        task.defer(RefreshTeleportList)
    end
end)

-- Cập nhật liên tục để danh sách luôn phản ánh người chơi hiện tại.
task.spawn(function()
    while ScreenGui.Parent do
        if TeleportOpen then
            RefreshTeleportList()
        end
        task.wait(0.5)
    end
end)

TeleportButton.Visible = Main.Visible
Main:GetPropertyChangedSignal("Visible"):Connect(function()
    TeleportButton.Visible = Main.Visible
    if not Main.Visible then
        -- Giữ trạng thái Teleport khi đóng menu chính.
        -- Không reset TeleportOpen, không đóng bảng người chơi.
        TeleportPanel.Visible = TeleportOpen
    elseif TeleportOpen then
        -- Mở lại menu vẫn giữ bảng Teleport đang mở.
        TeleportPanel.Visible = true
        RefreshTeleportList()
    end
end)

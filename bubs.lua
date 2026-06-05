-- U CAN USE TS IN UR ROBLOX GAME --

local NeverLose = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/NeverLose/refs/heads/main/source.luau"))() --require(script:WaitForChild('ModuleScript'));

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Space = workspace
local Camera = Space.CurrentCamera
local AimMouse = LocalPlayer:GetMouse()

local ScriptActive = true
local ScriptConnections = {}
local ScriptDrawings = {}

local function connectConnection(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(ScriptConnections, conn)
    return conn
end

local function newDrawing(class)
    local d = Drawing.new(class)
    table.insert(ScriptDrawings, d)
    return d
end

local function uninject()
	ScriptActive = false

	-- stop & destroy intro sound
	pcall(function()
		if introSound then
			pcall(function() introSound:Stop() end)
			introSound:Destroy()
			introSound = nil
		end
	end)

	-- stop & destroy secondary intro sound
	pcall(function()
		if introSound2 then
			pcall(function() introSound2:Stop() end)
			introSound2:Destroy()
			introSound2 = nil
		end
	end)

	-- disconnect recorded connections
	for _, conn in ipairs(ScriptConnections) do
		pcall(function() conn:Disconnect() end)
	end
	ScriptConnections = {}

	-- remove drawings
	for _, d in ipairs(ScriptDrawings) do
		pcall(function() d:Remove() end)
	end
	ScriptDrawings = {}

	-- safely hide/destroy UI elements
	pcall(function()
		if Watermark and type(Watermark.SetRender) == 'function' then Watermark:SetRender(false) end
		if Watermark and type(Watermark.Destroy) == 'function' then Watermark:Destroy() end
		Watermark = nil
	end)
	pcall(function()
		if Indicator and type(Indicator.SetRender) == 'function' then Indicator:SetRender(false) end
		if Indicator and type(Indicator.Destroy) == 'function' then Indicator:Destroy() end
		Indicator = nil
	end)
	pcall(function()
		if window and type(window.ToggleInterface) == 'function' then window:ToggleInterface(false) end
		if window and type(window.Destroy) == 'function' then window:Destroy() end
		window = nil
	end)

	-- remove any leftover GUI instances
	pcall(function()
		local coreGui = game:GetService('CoreGui')
		local players = game:GetService('Players')
		local playerGui = players.LocalPlayer and players.LocalPlayer:FindFirstChild('PlayerGui')
		local menuGui = coreGui:FindFirstChild('Bubbles.cc') or coreGui:FindFirstChild('NeverLose')
		if not menuGui and playerGui then
			menuGui = playerGui:FindFirstChild('Bubbles.cc') or playerGui:FindFirstChild('NeverLose')
		end
		if menuGui then pcall(function() menuGui:Destroy() end) end
	end)

	pcall(function() collectgarbage() end)
end

local function setVsync(enabled)
    if type(setfpscap) == "function" then
        setfpscap(enabled and 60 or 0)
        return
    end
    if type(settings) == "table" then
        pcall(function()
            local renderSettings = settings().Rendering
            if renderSettings then
                renderSettings.Vsync = enabled
            end
        end)
    end
end

local function setStreamProof(enabled)
    local menuGui = game:GetService("CoreGui"):FindFirstChild("Bubbles.cc")
    if not menuGui then
        local playerGui = game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            menuGui = playerGui:FindFirstChild("Bubbles.cc")
        end
    end
    if menuGui then
        if enabled then
            -- Hide from Discord screenshare and streaming overlays
            local hidden = (get_hidden_gui and get_hidden_gui()) or (gethui and gethui())
            if hidden then
                menuGui.Parent = hidden
            else
                -- Fallback: hide in PlayerGui if gethui unavailable
                menuGui.Visible = false
            end
        else
            menuGui.Parent = game:GetService("CoreGui")
            menuGui.Visible = true
        end
    end
end

local Notification = NeverLose:CreateNotification();
local Logging = NeverLose:CreateLogger();
local Indicator = NeverLose:CreateIndicator();
local window = NeverLose:CreateWindow({
	Logo = "rbxassetid://120681281047173",
	Name = "Bubbles.cc",
	Content = "South-London",
	Size = NeverLose.Scales.Default,
	ConfigFolder = "BubblesCCConfigs",
	Enable3DRenderer = false,
	Keybind = "Insert"
});

local Watermark = window:Watermark();

window:AddTabLabel('AIMBOT')

local ping = Watermark:AddBlock("wifi", "0MS");
local titleBlock = Watermark:AddBlock("lightning-bolt", "Bubbles.cc");
local timeBlock = Watermark:AddBlock("clock", "00:00 EST");

titleBlock:Input(function()
	window:ToggleInterface();
end);

local function getESTTime()
	local utc = os.time(os.date("!*t"))
	local est = utc - 5 * 60 * 60
	return os.date("!%Y-%m-%d %I:%M:%S %p EST", est)
end

task.spawn(function()
	while ScriptActive do
		task.wait(1)
		ping:SetText(tostring(math.random(30,90)) .. 'MS')
		timeBlock:SetText(getESTTime())
	end
end)

Watermark:SetRender(true)

-- Intro sequence (play sound, show notifications, display menu)
local SoundService = game:GetService('SoundService')
local introSound = Instance.new('Sound')
introSound.SoundId = 'rbxassetid://137426393727807'
introSound.Volume = 1
introSound.Looped = false
introSound.Parent = SoundService

-- secondary intro sound (plays 2s after the first)
local introSound2 = Instance.new('Sound')
introSound2.SoundId = 'rbxassetid://111605929167392'
introSound2.Volume = 1
introSound2.Looped = false
introSound2.Parent = SoundService

-- start hidden
window:ToggleInterface(false)

task.spawn(function()
	pcall(function() introSound:Play() end)
	task.wait(2)
	pcall(function() introSound2:Play() end)
	task.wait(1)
	local notifs = {
		{ Icon = 'rbxassetid://120681281047173', Title = 'Bubbles.cc', Content = 'Welcome Bubbles.cc Users Time To Put Belt', Duration = 6 },
		{ Icon = 'rbxassetid://120681281047173', Title = 'Discord', Content = '@5nz3 for menus', Duration = 9 },
		{ Icon = 'rbxassetid://120681281047173', Title = 'Devs', Content = '@9wareowner @fryedyoass', Duration = 9 },
	}
	for _, n in ipairs(notifs) do
		pcall(function() Notification.new(n) end)
		task.wait(1)
	end
	pcall(function() Logging.new('crosshairs','Welcome to bubbles.cc injected successfully',15) end)
	pcall(function() window:ToggleInterface(true) end)
end)

local Legit = window:AddTab({
	Icon = "mouse-scrollwheel",
	Name = "Legit"
})

local ESP = window:AddTab({
	Icon = "eye",
	Name = "ESP"
})

local Misc = window:AddTab({
	Icon = "cube-vertexes",
	Name = "Misc"
})

local SettingsTab = window:AddTab({
	Icon = "gear",
	Name = "Settings"
})

local ESPSection = ESP:AddSection({
	Name = "ESP"
})

-- ESP Settings
local ESPConfig = {
	Box2D_Enabled = false,
	Box_Color = Color3.fromRGB(0, 170, 255),
	Box_Thickness = 1,
	Skeleton_Enabled = false,
	Skeleton_Color = Color3.fromRGB(0, 255, 255),
	Skeleton_Thickness = 1,
	Line_Enabled = false,
	Line_Origin = "Middle",
	Line_Color = Color3.fromRGB(255, 255, 255),
	Health_Enabled = false,
	Distance_Enabled = false,
	Tool_Enabled = false,
	Team_Check = false,
	Showcase_Enabled = false,
	Autothickness = true
}

-- UI Elements for ESP
ESPSection:AddLabel('2D Box ESP'):AddToggle({
	Default = false,
	Callback = function(v) ESPConfig.Box2D_Enabled = v end,
	Flag = "Legit_Box2DESP",
})

ESPSection:AddLabel('Skeleton ESP'):AddToggle({
	Default = false,
	Callback = function(v) ESPConfig.Skeleton_Enabled = v end,
	Flag = "Legit_SkeletonESP",
})

ESPSection:AddLabel('Line ESP'):AddToggle({
	Default = false,
	Callback = function(v) ESPConfig.Line_Enabled = v end,
	Flag = "Legit_LineESP",
})

ESPSection:AddLabel('Line Origin'):AddDropdown({
	Default = 'Middle',
	Values = {'Top','Middle','Bottom'},
	Callback = function(v) ESPConfig.Line_Origin = (type(v) == 'table' and v[1]) or v end,
})

ESPSection:AddLabel('Health ESP'):AddToggle({
	Default = false,
	Callback = function(v) ESPConfig.Health_Enabled = v end,
	Flag = "Legit_HealthESP",
})

ESPSection:AddLabel('Distance ESP'):AddToggle({
	Default = false,
	Callback = function(v) ESPConfig.Distance_Enabled = v end,
	Flag = "Legit_DistanceESP",
})

ESPSection:AddLabel('Tool ESP'):AddToggle({
	Default = false,
	Callback = function(v) ESPConfig.Tool_Enabled = v end,
	Flag = "Legit_ToolESP",
})

ESPSection:AddLabel('Team Check'):AddToggle({
	Default = false,
	Callback = function(v) ESPConfig.Team_Check = v end,
	Flag = "Legit_ESP_Team",
})

ESPSection:AddLabel('Showcase ESP'):AddToggle({
	Default = false,
	Callback = function(v) ESPConfig.Showcase_Enabled = v end,
	Flag = "Legit_ShowcaseESP",
})

ESPSection:AddLabel('Box Thickness'):AddSlider({
	Min = 1,
	Max = 5,
	Rounding = 1,
	Size = 100,
	Default = ESPConfig.Box_Thickness,
	Callback = function(v) ESPConfig.Box_Thickness = v end,
	Flag = "Legit_ESP_Thickness",
})

ESPSection:AddLabel('Skeleton Thickness'):AddSlider({
	Min = 1,
	Max = 3,
	Rounding = 1,
	Size = 100,
	Default = ESPConfig.Skeleton_Thickness,
	Callback = function(v) ESPConfig.Skeleton_Thickness = v end,
	Flag = "Legit_ESP_SkeletonThickness",
})

-- ESP Drawing Helpers
local function NewLine(color, thickness)
	local line = newDrawing("Line")
	line.Visible = false
	line.From = Vector2.new(0, 0)
	line.To = Vector2.new(0, 0)
	line.Color = color
	line.Thickness = thickness
	line.Transparency = 1
	return line
end

local function NewText(color)
	local text = newDrawing("Text")
	text.Visible = false
	text.Color = color
	text.Size = 14
	text.Center = true
	text.Outline = true
	text.Font = 2
	return text
end

local function Vis(lib, state)
	for i, v in pairs(lib) do
		v.Visible = state
	end
end

local function Colorize(lib, color)
	for i, v in pairs(lib) do
		v.Color = color
	end
end

local function CreateSkeletonLines(color, thickness)
	local lines = {}
	for i = 1, 16 do
		table.insert(lines, NewLine(color, thickness))
	end
	return lines
end

local function CreateESPTexts(color)
	local texts = {}
	for i = 1, 3 do
		table.insert(texts, NewText(color))
	end
	return texts
end

local function GetBonePart(character, name)
	local aliases = {
		UpperTorso = "Torso",
		LowerTorso = "Torso",
		LeftUpperArm = "Left Arm",
		RightUpperArm = "Right Arm",
		LeftLowerArm = "Left Arm",
		RightLowerArm = "Right Arm",
		LeftHand = "Left Arm",
		RightHand = "Right Arm",
		LeftUpperLeg = "Left Leg",
		RightUpperLeg = "Right Leg",
		LeftLowerLeg = "Left Leg",
		RightLowerLeg = "Right Leg",
		LeftFoot = "Left Leg",
		RightFoot = "Right Leg"
	}
	return character:FindFirstChild(name) or character:FindFirstChild(aliases[name])
end

local function DrawSkeleton(plr, character, skeletonLines)
	local bones = {
		{"Head", "UpperTorso"},
		{"UpperTorso", "LowerTorso"},
		{"UpperTorso", "LeftUpperArm"},
		{"UpperTorso", "RightUpperArm"},
		{"LeftUpperArm", "LeftLowerArm"},
		{"RightUpperArm", "RightLowerArm"},
		{"LeftLowerArm", "LeftHand"},
		{"RightLowerArm", "RightHand"},
		{"LowerTorso", "LeftUpperLeg"},
		{"LowerTorso", "RightUpperLeg"},
		{"LeftUpperLeg", "LeftLowerLeg"},
		{"RightUpperLeg", "RightLowerLeg"},
		{"LeftLowerLeg", "LeftFoot"},
		{"RightLowerLeg", "RightFoot"}
	}

	local color = ESPConfig.Team_Check and (plr.TeamColor == LocalPlayer.TeamColor and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)) or ESPConfig.Skeleton_Color
	local index = 1
	for _, bone in ipairs(bones) do
		local partA = GetBonePart(character, bone[1])
		local partB = GetBonePart(character, bone[2])
		local line = skeletonLines[index]
		if partA and partB and line then
			local posA, onA = Camera:WorldToViewportPoint(partA.Position)
			local posB, onB = Camera:WorldToViewportPoint(partB.Position)
			line.From = Vector2.new(posA.X, posA.Y)
			line.To = Vector2.new(posB.X, posB.Y)
			line.Thickness = ESPConfig.Skeleton_Thickness
			line.Color = color
			line.Visible = onA and onB
		elseif line then
			line.Visible = false
		end
		index = index + 1
	end

	for i = index, #skeletonLines do
		skeletonLines[i].Visible = false
	end
end

local function CreateBoxLines(color, thickness)
	return {
		TL1 = NewLine(color, thickness),
		TL2 = NewLine(color, thickness),
		TR1 = NewLine(color, thickness),
		TR2 = NewLine(color, thickness),
		BL1 = NewLine(color, thickness),
		BL2 = NewLine(color, thickness),
		BR1 = NewLine(color, thickness),
		BR2 = NewLine(color, thickness)
	}
end

local function NewSquare(color, thickness)
	local square = newDrawing("Square")
	square.Visible = false
	square.Size = Vector2.new(0, 0)
	square.Position = Vector2.new(0, 0)
	square.Color = color
	square.Thickness = thickness
	square.Filled = false
	square.Transparency = 1
	return square
end

local function CreateBoxSquare(color, thickness)
	return NewSquare(color, thickness)
end

local function CreateHealthBar(color)
	local bar = {
		Outline = NewSquare(Color3.fromRGB(25, 25, 25), 1),
		Fill = NewSquare(color, 1),
		Text = NewText(color)
	}
	bar.Fill.Filled = true
	bar.Text.Size = 14
	bar.Text.Center = true
	bar.Text.Outline = true
	bar.Text.Font = 2
	return bar
end

local function UpdateHealthBar(healthBar, boxTop, boxBottom, percent, health)
	local barHeight = math.max(20, (boxBottom.Y - boxTop.Y) * 0.8)
	local barWidth = 4
	local barPos = Vector2.new(boxTop.X - barWidth - 2, boxTop.Y + ((boxBottom.Y - boxTop.Y) - barHeight) / 2)

	healthBar.Outline.Size = Vector2.new(barWidth, barHeight)
	healthBar.Outline.Position = barPos
	healthBar.Outline.Color = Color3.fromRGB(25, 25, 25)
	healthBar.Outline.Visible = true

	local fillHeight = math.max(0, barHeight * percent)
	healthBar.Fill.Size = Vector2.new(barWidth - 2, fillHeight)
	healthBar.Fill.Position = Vector2.new(barPos.X + 1, barPos.Y + barHeight - fillHeight)
	healthBar.Fill.Color = percent > 0.6 and Color3.fromRGB(0, 255, 0) or percent > 0.35 and Color3.fromRGB(255, 230, 0) or Color3.fromRGB(255, 0, 0)
	healthBar.Fill.Visible = true

	healthBar.Text.Text = math.floor(health) .. " HP"
	healthBar.Text.Position = Vector2.new(barPos.X + barWidth + 8, barPos.Y + barHeight / 2)
	healthBar.Text.Color = healthBar.Fill.Color
	healthBar.Text.Visible = true
end

local function GetLineOriginPosition()
	local x = Camera.ViewportSize.X / 2
	local y = Camera.ViewportSize.Y / 2
	if ESPConfig.Line_Origin == "Top" then
		y = 20
	elseif ESPConfig.Line_Origin == "Bottom" then
		y = Camera.ViewportSize.Y - 20
	end
	return Vector2.new(x, y)
end

local function GetToolName(plr)
	local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
	return tool and tool.Name or nil
end

local function DrawInfoTexts(plr, texts, topPosition, color)
	local humanoid = plr.Character and plr.Character:FindFirstChild("Humanoid")
	local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
	local lines = {}
	if ESPConfig.Distance_Enabled and root and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local distance = math.ceil((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
		table.insert(lines, "Dist: " .. distance .. "m")
	end
	if ESPConfig.Tool_Enabled then
		table.insert(lines, GetToolName(plr) or "None")
	end

	for i, text in ipairs(texts) do
		if lines[i] then
			text.Text = lines[i]
			text.Color = color
			text.Position = Vector2.new(topPosition.X, topPosition.Y + (i - 1) * 18)
			text.Visible = true
		else
			text.Visible = false
		end
	end
end

local function GetBoxCorners(character)
	local root = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")
	if not root or not head then
		return nil
	end
	local height = math.max(2, (head.Position - root.Position).Magnitude * 1.5)
	local width = math.max(1, height / 2)
	local look = (Camera.CFrame.Position - root.Position).Unit
	local right = Vector3.new(look.Z, 0, -look.X).Unit
	local up = Vector3.new(0, 1, 0)
	local center = root.Position + Vector3.new(0, height * 0.5, 0)
	return {
		CFrame.new(center) * CFrame.new(right * -width / 2 + up * height / 2),
		CFrame.new(center) * CFrame.new(right * width / 2 + up * height / 2),
		CFrame.new(center) * CFrame.new(right * -width / 2 - up * height / 2),
		CFrame.new(center) * CFrame.new(right * width / 2 - up * height / 2)
	}
end

local function Draw2DBox(root, head, boxSquare, espColor, thickness)
	local rootScreen, rootOn = Camera:WorldToViewportPoint(root.Position)
	if not rootOn then
		boxSquare.Visible = false
		return nil
	end

	local height = 40
	local width = 22
	if head and head.Parent then
		local headScreen, headOn = Camera:WorldToViewportPoint(head.Position)
		if headOn then
			height = math.max(32, math.abs(rootScreen.Y - headScreen.Y) * 2)
			width = math.max(20, height * 0.5)
		end
	end

	height = math.clamp(height, 32, 120)
	width = math.clamp(width, 18, 64)

	boxSquare.Size = Vector2.new(width, height)
	boxSquare.Position = Vector2.new(rootScreen.X - width / 2, rootScreen.Y - height / 2)
	boxSquare.Color = espColor
	boxSquare.Thickness = thickness
	boxSquare.Visible = true

	local top = Vector2.new(rootScreen.X, rootScreen.Y - height / 2)
	local bottom = Vector2.new(rootScreen.X, rootScreen.Y + height / 2)
	return top, bottom
end

local function UpdateLine(lineDraw, screenCenter, targetScreen)
	lineDraw.From = screenCenter
	lineDraw.To = targetScreen
	lineDraw.Visible = true
end

-- Main ESP Draw Function
local function DrawESP(plr)
	repeat task.wait() until plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil
	local BoxLines = CreateBoxLines(ESPConfig.Box_Color, ESPConfig.Box_Thickness)
	local BoxSquare = CreateBoxSquare(ESPConfig.Box_Color, ESPConfig.Box_Thickness)
	local SkeletonLibrary = CreateSkeletonLines(ESPConfig.Skeleton_Color, ESPConfig.Skeleton_Thickness)
	local InfoTexts = CreateESPTexts(ESPConfig.Skeleton_Color)
	local LineDraw = NewLine(ESPConfig.Line_Color, 1)
	local HealthBar = CreateHealthBar(ESPConfig.Box_Color)

	local function Updater()
		local c
		c = connectConnection(RunService.RenderStepped, function()
if not (ESPConfig.Box2D_Enabled or ESPConfig.Skeleton_Enabled or ESPConfig.Line_Enabled or ESPConfig.Health_Enabled or ESPConfig.Distance_Enabled or ESPConfig.Tool_Enabled) then
				Vis(BoxLines, false)
				BoxSquare.Visible = false
				Vis(SkeletonLibrary, false)
				Vis(InfoTexts, false)
				LineDraw.Visible = false
				HealthBar.Outline.Visible = false
				HealthBar.Fill.Visible = false
				HealthBar.Text.Visible = false
				return
			end

			if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 then
				local Hum = plr.Character
				local root = Hum.HumanoidRootPart
				local rootScreen, rootOn = Camera:WorldToViewportPoint(root.Position)
				local head = Hum:FindFirstChild("Head")
				local headScreen, headOn = head and Camera:WorldToViewportPoint(head.Position)
				if rootOn then
					local espColor = ESPConfig.Team_Check and (plr.TeamColor == LocalPlayer.TeamColor and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)) or ESPConfig.Box_Color
					local infoColor = ESPConfig.Team_Check and (plr.TeamColor == LocalPlayer.TeamColor and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)) or ESPConfig.Skeleton_Color
					Colorize(BoxLines, espColor)
					Colorize(SkeletonLibrary, infoColor)
					for _, text in ipairs(InfoTexts) do
						text.Color = infoColor
					end

					local boxTop, boxBottom = nil, nil
			local squareVisible = false

			if ESPConfig.Box2D_Enabled then
				local top, bottom = Draw2DBox(root, head, BoxSquare, espColor, ESPConfig.Box_Thickness)
				if top and bottom then
					boxTop, boxBottom = top, bottom
					squareVisible = true
				else
					BoxSquare.Visible = false
				end
			else
				BoxSquare.Visible = false
			end

			Vis(BoxLines, false)

					if ESPConfig.Skeleton_Enabled then
						DrawSkeleton(plr, Hum, SkeletonLibrary)
					else
						Vis(SkeletonLibrary, false)
					end

					if ESPConfig.Line_Enabled then
						local screenOrigin = GetLineOriginPosition()
						LineDraw.Color = ESPConfig.Line_Color
						LineDraw.Thickness = 1
						UpdateLine(LineDraw, screenOrigin, Vector2.new(rootScreen.X, rootScreen.Y))
					else
						LineDraw.Visible = false
					end

					local labelY = rootScreen.Y + 18
					if boxBottom then
						labelY = boxBottom.Y + 10
					elseif headOn then
						labelY = headScreen.Y + 18
					end
					DrawInfoTexts(plr, InfoTexts, Vector2.new(rootScreen.X, labelY), infoColor)

					if ESPConfig.Health_Enabled then
						if not squareVisible and headOn then
							boxTop, boxBottom = headScreen, rootScreen
						end
						if boxTop and boxBottom then
							local percent = math.clamp(Hum.Humanoid.Health / math.max(Hum.Humanoid.MaxHealth, 1), 0, 1)
							UpdateHealthBar(HealthBar, boxTop, boxBottom, percent, Hum.Humanoid.Health)
						else
							HealthBar.Outline.Visible = false
							HealthBar.Fill.Visible = false
							HealthBar.Text.Visible = false
						end
					else
						HealthBar.Outline.Visible = false
						HealthBar.Fill.Visible = false
						HealthBar.Text.Visible = false
					end

					for _, x in pairs(BoxLines) do
						x.Thickness = ESPConfig.Box_Thickness
					end
					for _, x in pairs(SkeletonLibrary) do
						x.Thickness = ESPConfig.Skeleton_Thickness
					end
				else
					Vis(BoxLines, false)
					BoxSquare.Visible = false
					Vis(SkeletonLibrary, false)
					Vis(InfoTexts, false)
					LineDraw.Visible = false
					HealthBar.Outline.Visible = false
					HealthBar.Fill.Visible = false
					HealthBar.Text.Visible = false
				end
			else
				Vis(BoxLines, false)
				Vis(SkeletonLibrary, false)
				Vis(InfoTexts, false)
				LineDraw.Visible = false
				HealthBar.Outline.Visible = false
				HealthBar.Fill.Visible = false
				HealthBar.Text.Visible = false
				if game:GetService("Players"):FindFirstChild(plr.Name) == nil then
					for _, v in pairs(BoxLines) do
						v:Remove()
					end
					for _, v in pairs(SkeletonLibrary) do
						v:Remove()
					end
					for _, v in pairs(InfoTexts) do
						v:Remove()
					end
					LineDraw:Remove()
					HealthBar.Outline:Remove()
					HealthBar.Fill:Remove()
					HealthBar.Text:Remove()
					c:Disconnect()
				end
			end
		end)
	end
	coroutine.wrap(Updater)()
end

-- Draw Boxes for existing players
for _, v in pairs(Players:GetPlayers()) do
	if v.Name ~= LocalPlayer.Name or ESPConfig.Showcase_Enabled then
		coroutine.wrap(DrawESP)(v)
	end
end

-- Draw Boxes for new players
connectConnection(Players.PlayerAdded, function(newplr)
	if newplr.Name ~= LocalPlayer.Name or ESPConfig.Showcase_Enabled then
		coroutine.wrap(DrawESP)(newplr)
	end
end)


-- ================= MERGED FEATURES =================

local MConfig = {
   WeaponModsEnabled = false,
   StaminaEnabled = false,
   SaturationEnabled = false,
   ClickTPEnabled = false,
   NoBobEnabled = false,
   CrossChainEnabled = false,
   RayHookEnabled = false,
   Method = "Raycast",
   NameChangerEnabled = false,
   CustomName = "",
   WalkSpeed = 16,
}

-- Silent Aim Config
local SilentConfig = {
	Enabled = false,
	TeamCheck = false,
	HitPart = "Head",
	FieldOfView = { Enabled = true, Radius = 100 },
	AimKey = Enum.KeyCode.Space,
	Smoothness = 0.4,
	ShowFOV = false
}

-- Lock Config
local LockConfig = {
	Enabled = false,
	Key = Enum.KeyCode.Space,
	Radius = 100,
	Smoothness = 4,
	TargetPart = "Torso",
	ShowFOV = false,
	TeamCheck = false
}

local friend_check = {}

local function getPositionOnScreen(Vector)
	local Vec3, OnScreen = Camera:WorldToScreenPoint(Vector)
	return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

local function getMousePos()
	return Vector2.new(AimMouse.X, AimMouse.Y)
end

local function getDirection(Origin, Position)
	return (Position - Origin).Unit * 1000
end

local function getClosestTarget()
	if not SilentConfig.HitPart then return end
	local Closest
	local DistanceToMouse
	for _, Player in next, Players:GetChildren() do
		if Player == LocalPlayer then continue end
		if SilentConfig.TeamCheck and Player.Team == LocalPlayer.Team then continue end

		local Character = Player.Character
		if not Character then continue end

		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character:FindFirstChild("Humanoid")

		if not HumanoidRootPart or not Humanoid or (Humanoid and Humanoid.Health <= 0 and not table.find(friend_check, Player.Name)) then continue end

		local ScreenPosition, OnScreen = getPositionOnScreen(HumanoidRootPart.Position)
		if not OnScreen then continue end

		local Distance = (getMousePos() - ScreenPosition).Magnitude
		if Distance <= (DistanceToMouse or (SilentConfig.FieldOfView.Enabled and SilentConfig.FieldOfView.Radius) or 2000) then
			Closest = Character[SilentConfig.HitPart]
			DistanceToMouse = Distance
		end
	end
	return Closest
end

local function GetValidTargetPart(character)
	if LockConfig.TargetPart == "Torso" then
		return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	end
	return character:FindFirstChild("Head")
end

local function GetClosestPlayerAim()
	local closestPlayer = nil
	local shortestDistance = LockConfig.Radius

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
			if LockConfig.TeamCheck and player.Team == LocalPlayer.Team then continue end
			local part = GetValidTargetPart(player.Character)
			if part then
				local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
				if onScreen then
					local distance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
					if distance < shortestDistance then
						closestPlayer = player
						shortestDistance = distance
					end
				end
			end
		end
	end
	return closestPlayer
end

-- Hook for Silent Aim (from cheat source)
local ExpectedArguments = {
   FindPartOnRayWithIgnoreList = { ArgCountRequired = 3, Args = {"Instance","Ray","table","boolean","boolean"} },
   FindPartOnRayWithWhitelist = { ArgCountRequired = 3, Args = {"Instance","Ray","table","boolean"} },
   FindPartOnRay = { ArgCountRequired = 2, Args = {"Instance","Ray","Instance","boolean","boolean"} },
   Raycast = { ArgCountRequired = 3, Args = {"Instance","Vector3","Vector3","RaycastParams"} }
}

local function ValidateArguments(Args, RayMethod)
   local Matches = 0
   if #Args < RayMethod.ArgCountRequired then return false end
   for Pos, Argument in next, Args do
      if typeof(Argument) == RayMethod.Args[Pos] then Matches = Matches + 1 end
   end
   return Matches >= RayMethod.ArgCountRequired
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(...)
   local Method = getnamecallmethod()
   local Arguments = {...}
   local self = Arguments[1]

   if SilentConfig.Enabled and self == workspace then
      if Method == "FindPartOnRayWithIgnoreList" and MConfig.Method == Method then
         if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithIgnoreList) then
            local A_Ray = Arguments[2]
            local HitPart = getClosestTarget()
            if HitPart then
               local Origin = A_Ray.Origin
               local Direction = getDirection(Origin, HitPart.Position)
               Arguments[2] = Ray.new(Origin, Direction)
               return oldNamecall(unpack(Arguments))
            end
         end
      elseif Method == "FindPartOnRayWithWhitelist" and MConfig.Method == Method then
         if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithWhitelist) then
            local A_Ray = Arguments[2]
            local HitPart = getClosestTarget()
            if HitPart then
               local Origin = A_Ray.Origin
               local Direction = getDirection(Origin, HitPart.Position)
               Arguments[2] = Ray.new(Origin, Direction)
               return oldNamecall(unpack(Arguments))
            end
         end
      elseif (Method == "FindPartOnRay" or Method == "findPartOnRay") and MConfig.Method:lower() == Method:lower() then
         if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRay) then
            local A_Ray = Arguments[2]
            local HitPart = getClosestTarget()
            if HitPart then
               local Origin = A_Ray.Origin
               local Direction = getDirection(Origin, HitPart.Position)
               Arguments[2] = Ray.new(Origin, Direction)
               return oldNamecall(unpack(Arguments))
            end
         end
      elseif Method == "Raycast" and MConfig.Method == Method then
         if ValidateArguments(Arguments, ExpectedArguments.Raycast) then
            local A_Origin = Arguments[2]
            local HitPart = getClosestTarget()
            if HitPart then
               Arguments[3] = getDirection(A_Origin, HitPart.Position)
               return oldNamecall(unpack(Arguments))
            end
         end
      end
   end
   return oldNamecall(...)
end)

-- Weapon modification helpers with caching
local weaponCache = {}

local function modifyWeapon(tool)
	local stats = tool:FindFirstChild("Stats")
	if stats then
		local gunType = stats:FindFirstChild("GunType")
		local recoil = stats:FindFirstChild("Recoil")
		local fireRate = stats:FindFirstChild("FireRate")

		-- Cache original values on first encounter
		if not weaponCache[tool] then
			weaponCache[tool] = {
				GunType = gunType and gunType.Value or "Semi",
				Recoil = recoil and recoil.Value or 1,
				FireRate = fireRate and fireRate.Value or 0.12
			}
		end

		local original = weaponCache[tool]

		if MConfig.WeaponModsEnabled then
			if gunType then gunType.Value = "Auto" end
			if recoil then recoil.Value = 0 end
			if fireRate then fireRate.Value = 0 end
		else
			if gunType then gunType.Value = original.GunType end
			if recoil then recoil.Value = original.Recoil end
			if fireRate then fireRate.Value = original.FireRate end
		end
	end
end

local function updateAllWeapons()
	if LocalPlayer.Character then
		for _, obj in ipairs(LocalPlayer.Character:GetChildren()) do
			if obj:IsA("Tool") then modifyWeapon(obj) end
		end
	end
	if LocalPlayer.Backpack then
		for _, obj in ipairs(LocalPlayer.Backpack:GetChildren()) do
			if obj:IsA("Tool") then modifyWeapon(obj) end
		end
	end
end

connectConnection(LocalPlayer.CharacterAdded, function(newCharacter)
	table.clear(weaponCache)
	if MConfig.WeaponModsEnabled then
		task.wait(0.5)
		updateAllWeapons()
	end
end)

connectConnection(LocalPlayer.Backpack.ChildAdded, function(child)
	if child:IsA("Tool") then
		task.wait(0.1)
		modifyWeapon(child)
	end
end)

-- ================= NAME CHANGER FUNCTIONS =================

local realFirstNames = {
    "Ahmed", "Xong", "D'wayne", "Jacob", "George", "Noah", "Riley", "Ivan", "Leo", "Jack", 
    "Olivia", "Chloe", "Dan", "Sarah", "Oliver", "Kareem", "Harry", "Isabella", "Alexandra", 
    "Jessica", "Amelia", "Jones", "Muhammad", "Charlie", "Ryan", "Lewis", "Megan", "Wade", 
    "Rhianna", "Jamie", "Donavan", "Joshua", "Abdul", "Xavien", "Basir", "Kieron", "Dushane", 
    "Bell", "Leon", "Kadeem", "Aaron", "Lee", "John", "Levont", "Lamar", "May", "Jay", 
    "Victor", "Hank", "Jesse", "Jim", "Kim", "Jamal"
}

local function forceUpdateNametags(character)
	if not character or not MConfig.NameChangerEnabled then return end
	local targetName = string.lower(LocalPlayer.Name)
	local targetDisplay = string.lower(LocalPlayer.DisplayName)
	
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextBox") then
			local text = obj.Text
			local textLower = string.lower(text)
			local isMatch = false
			
			for _, name in ipairs(realFirstNames) do
				if string.find(textLower, string.lower(name)) then
					isMatch = true
					break
				end
			end
			
			if isMatch or string.find(textLower, targetName) or string.find(textLower, targetDisplay) then
				local prefix = string.match(text, "^(%b[])") 
				if prefix then
					obj.Text = prefix .. " " .. MConfig.CustomName
				else
					obj.Text = MConfig.CustomName
				end
			end
		end
	end
end

local function startNametagScanner(character)
	task.spawn(function()
		while character and character.Parent do
			if MConfig.NameChangerEnabled then
				forceUpdateNametags(character)
			end
			task.wait(0.3)
		end
	end)
end

connectConnection(LocalPlayer.CharacterAdded, function(char)
	if MConfig.NameChangerEnabled then
		forceUpdateNametags(char)
	end
	startNametagScanner(char)
end)

if LocalPlayer.Character then
	startNametagScanner(LocalPlayer.Character)
end

-- Infinite stamina heartbeat
connectConnection(RunService.Heartbeat, function()
	if not MConfig.StaminaEnabled then return end
	local character = LocalPlayer.Character
	if not character then return end
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("NumberValue") or obj:IsA("IntValue") then
			if string.find(obj.Name:lower(), "stam") or string.find(obj.Name:lower(), "energ") or string.find(obj.Name:lower(), "sprin") then
				pcall(function() obj.Value = 100 end)
			end
		end
	end
	for _, obj in ipairs(LocalPlayer:GetDescendants()) do
		if obj:IsA("NumberValue") or obj:IsA("IntValue") then
			if string.find(obj.Name:lower(), "stam") or string.find(obj.Name:lower(), "energ") or string.find(obj.Name:lower(), "sprin") then
				pcall(function() obj.Value = 100 end)
			end
		end
	end
end)

-- Click TP
local TELEPORT_KEY = Enum.KeyCode.V
local function teleportToMouse()
	local character = LocalPlayer.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or (humanoid and humanoid.Health <= 0) then return end
	local targetPosition = AimMouse.Hit and AimMouse.Hit.Position
	if not targetPosition then return end
	local safetyOffset = Vector3.new(0,3,0)
	hrp.CFrame = CFrame.new(targetPosition + safetyOffset)
end

connectConnection(UserInputService.InputBegan, function(input, gameProcessed)
	if gameProcessed then return end
	if not MConfig.ClickTPEnabled then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if UserInputService:IsKeyDown(TELEPORT_KEY) then
			teleportToMouse()
		end
	end
end)

-- Camera bob lock helpers
local function lockBobbingValue()
	if not MConfig.NoBobEnabled then return end
	local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
	if not playerGui then return end
	local cameraBob = playerGui:WaitForChild("Camera_Bob", 5)
	if not cameraBob then return end
	local targetValue = cameraBob:WaitForChild("bobbing_global_scale", 5)
	if targetValue then
		local property = "Value"
		if not pcall(function() return targetValue.Value end) then property = "Scale" end
		targetValue:GetPropertyChangedSignal(property):Connect(function()
			if MConfig.NoBobEnabled and targetValue[property] ~= 0 then
				targetValue[property] = 0
			end
		end)
	end
end

connectConnection(RunService.Heartbeat, function()
	if MConfig.NoBobEnabled then
		local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
		if playerGui then
			local cameraBob = playerGui:FindFirstChild("Camera_Bob")
			if cameraBob then
				local targetValue = cameraBob:FindFirstChild("bobbing_global_scale")
				if targetValue then
					local property = "Value"
					if not pcall(function() return targetValue.Value end) then property = "Scale" end
					if targetValue[property] ~= 0 then
						targetValue[property] = 0
					end
				end
			end
		end
	end
end)

-- Cross chain cosmetic
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local chainsFolder = ReplicatedStorage:FindFirstChild("Chains")

local function forceAttachChain(character)
	if not MConfig.CrossChainEnabled or not chainsFolder then return end
	local crossChain = chainsFolder:FindFirstChild("CrossChain")
	if not crossChain then return end
	local sourceHandle = crossChain:FindFirstChild("Handle")
	if not sourceHandle then return end
	local targetTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not targetTorso then return end
	if character:FindFirstChild("ForcedCrossChain") then return end
	local handleClone = sourceHandle:Clone()
	handleClone.Name = "ForcedCrossChain"
	local attachment = handleClone:FindFirstChildOfClass("Attachment")
	if attachment then attachment:Destroy() end
	handleClone.CanCollide = false
	handleClone.Anchored = false
	handleClone.Transparency = 0
	handleClone.Parent = character
	local weld = Instance.new("Weld")
	weld.Name = "LocalChainWeld"
	weld.Part0 = targetTorso
	weld.Part1 = handleClone
	local positionOffset = CFrame.new(0, 0.52, -0.02)
	local rotationOffset = CFrame.Angles(0, math.rad(-90), 0)
	weld.C0 = positionOffset * rotationOffset
	weld.Parent = handleClone
end

local function removeChain(character)
	if character then
		local existingChain = character:FindFirstChild("ForcedCrossChain")
		if existingChain then existingChain:Destroy() end
	end
end

connectConnection(LocalPlayer.CharacterAdded, function(char)
	if MConfig.CrossChainEnabled then forceAttachChain(char) end
end)


-- Drawings for FOV Circles
local FOVCircle = newDrawing("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = SilentConfig.FieldOfView.Radius
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7

local LockFOVCircle = newDrawing("Circle")
LockFOVCircle.Thickness = 1
LockFOVCircle.NumSides = 64
LockFOVCircle.Radius = LockConfig.Radius
LockFOVCircle.Filled = false
LockFOVCircle.Visible = false
LockFOVCircle.Color = Color3.fromRGB(0, 150, 255)
LockFOVCircle.Transparency = 0.7

-- Render loop for Mouse Lock and Silent Aim FOV
local IsLockKeyActive = false
local TargetPlayer = nil

connectConnection(UserInputService.InputBegan, function(input, gameProcessed)
	if gameProcessed or not ScriptActive then return end
	if input.KeyCode == LockConfig.Key then
		IsLockKeyActive = true
	end
end)

connectConnection(UserInputService.InputEnded, function(input, gameProcessed)
	if not ScriptActive then return end
	if input.KeyCode == LockConfig.Key then
		IsLockKeyActive = false
	end
end)

connectConnection(RunService.RenderStepped, function()
	if not ScriptActive then return end
    
    -- Update Silent Aim FOV Circle
	if SilentConfig.ShowFOV then
		FOVCircle.Position = UserInputService:GetMouseLocation()
		FOVCircle.Radius = SilentConfig.FieldOfView.Radius
		FOVCircle.Visible = true
	else
		FOVCircle.Visible = false
	end

    -- Update Mouse Lock Aiming
	if LockConfig.Enabled and IsLockKeyActive then
		if not TargetPlayer then
			TargetPlayer = GetClosestPlayerAim()
		end

		if TargetPlayer and TargetPlayer.Character then
			local part = GetValidTargetPart(TargetPlayer.Character)
			if part and TargetPlayer.Character:FindFirstChild("Humanoid") and TargetPlayer.Character.Humanoid.Health > 0 then
				local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
				if onScreen then
					local mouseLoc = UserInputService:GetMouseLocation()
					local targetX = (screenPos.X - mouseLoc.X) * (LockConfig.Smoothness / 10)
					local targetY = (screenPos.Y - mouseLoc.Y) * (LockConfig.Smoothness / 10)
					if mousemoverel then
						mousemoverel(targetX, targetY)
					end
				else
					TargetPlayer = nil
				end
			else
				TargetPlayer = nil
			end
		end
	else
		TargetPlayer = nil
	end

    -- Update Mouse Lock FOV Circle
	if LockConfig.ShowFOV then
		LockFOVCircle.Position = UserInputService:GetMouseLocation()
		LockFOVCircle.Radius = LockConfig.Radius
		LockFOVCircle.Visible = true
	else
		LockFOVCircle.Visible = false
	end
end)


-- ================= GUI SECTIONS =================

local LegitSilentSection = Legit:AddSection({ Name = "SILENT AIM" })
LegitSilentSection:AddLabel('Enabled'):AddToggle({
	Default = false,
	Callback = function(v) SilentConfig.Enabled = v end,
})
LegitSilentSection:AddLabel('Team Check'):AddToggle({
	Default = false,
	Callback = function(v) SilentConfig.TeamCheck = v end,
})
LegitSilentSection:AddLabel('Hit Part'):AddDropdown({
	Default = 'Head',
	Values = {'Head','HumanoidRootPart','UpperTorso','LowerTorso'},
	Callback = function(v) SilentConfig.HitPart = (type(v) == 'table' and v[1]) or v end,
})
LegitSilentSection:AddLabel('Field of View'):AddSlider({
	Min = 0,
	Max = 2000,
	Rounding = 1,
	Default = SilentConfig.FieldOfView.Radius,
	Size = 100,
	Callback = function(v) SilentConfig.FieldOfView.Radius = v end,
})
LegitSilentSection:AddLabel('Show FOV'):AddToggle({
	Default = false,
	Callback = function(v)
		SilentConfig.ShowFOV = v
		FOVCircle.Visible = v
	end,
})

local LegitMouseLockSection = Legit:AddSection({ Name = "CAMERA / MOUSE LOCK" })
LegitMouseLockSection:AddLabel('Enabled'):AddToggle({
	Default = false,
	Callback = function(v) LockConfig.Enabled = v end,
})
LegitMouseLockSection:AddLabel('Team Check'):AddToggle({
	Default = false,
	Callback = function(v) LockConfig.TeamCheck = v end,
})
LegitMouseLockSection:AddLabel('Lock Keybind'):AddKeybind({
	Default = 'Space',
	Callback = function(v)
		if typeof(v) == "EnumItem" then
			LockConfig.Key = v
		else
			local keyEnum = Enum.KeyCode[tostring(v)] or Enum.KeyCode.Space
			LockConfig.Key = keyEnum
		end
	end,
})
LegitMouseLockSection:AddLabel('Aim Radius (FOV)'):AddSlider({
	Min = 10,
	Max = 500,
	Rounding = 1,
	Default = LockConfig.Radius,
	Size = 100,
	Callback = function(v)
		LockConfig.Radius = v
		LockFOVCircle.Radius = v
	end,
})
LegitMouseLockSection:AddLabel('Smoothness'):AddSlider({
	Min = 1,
	Max = 10,
	Rounding = 1,
	Default = LockConfig.Smoothness,
	Size = 100,
	Callback = function(v) LockConfig.Smoothness = v end,
})
LegitMouseLockSection:AddLabel('Show FOV'):AddToggle({
	Default = false,
	Callback = function(v)
		LockConfig.ShowFOV = v
		LockFOVCircle.Visible = v
	end,
})
LegitMouseLockSection:AddLabel('Target Part'):AddDropdown({
	Default = 'Torso',
	Values = {'Head', 'Torso'},
	Callback = function(v)
		LockConfig.TargetPart = (type(v) == 'table' and v[1]) or v
	end,
})


local Extras_Main = Misc:AddSection({ Name = "EXTRAS" })
MConfig.WalkSpeed = 16
Extras_Main:AddLabel('Walk Speed'):AddSlider({
   Min = 16,
   Max = 150,
   Rounding = 1,
   Default = 16,
   Size = 100,
   Callback = function(v)
       MConfig.WalkSpeed = v
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
           LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v
       end
   end
})

connectConnection(LocalPlayer.CharacterAdded, function(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid and MConfig.WalkSpeed ~= 16 then
        humanoid.WalkSpeed = MConfig.WalkSpeed
    end
end)

Extras_Main:AddLabel('Weapon Mods (Auto/No Recoil)'):AddToggle({
   Default = false,
   Callback = function(v) MConfig.WeaponModsEnabled = v; updateAllWeapons() end,
})
Extras_Main:AddLabel('Infinite Stamina'):AddToggle({
   Default = false,
   Callback = function(v) MConfig.StaminaEnabled = v end,
})
Extras_Main:AddLabel('Click TP (Hold V + Click)'):AddToggle({
   Default = false,
   Callback = function(v) MConfig.ClickTPEnabled = v end,
})
Extras_Main:AddLabel('No Camera Bob'):AddToggle({
   Default = false,
   Callback = function(v) MConfig.NoBobEnabled = v; if v then lockBobbingValue() end end,
})
Extras_Main:AddLabel('Cross Chain Cosmetic'):AddToggle({
   Default = false,
   Callback = function(v) MConfig.CrossChainEnabled = v; if v and LocalPlayer.Character then forceAttachChain(LocalPlayer.Character) else removeChain(LocalPlayer.Character) end end,
})
local customColorCorrection = nil
Extras_Main:AddLabel('High Saturation'):AddToggle({
   Default = false,
   Callback = function(v)
	   MConfig.SaturationEnabled = v
	   if v then
		   if not customColorCorrection then
			   customColorCorrection = Instance.new('ColorCorrectionEffect')
			   customColorCorrection.Name = 'Merged_Saturation'
			   customColorCorrection.Saturation = 8
			   customColorCorrection.Parent = game:GetService('Lighting')
		   end
	   else
		   if customColorCorrection then customColorCorrection:Destroy(); customColorCorrection = nil end
	   end
   end
})

Extras_Main:AddLabel('Custom Name'):AddToggle({
   Default = false,
   Callback = function(v)
      MConfig.NameChangerEnabled = v
      if v and LocalPlayer.Character then
         forceUpdateNametags(LocalPlayer.Character)
      end
   end,
})

Extras_Main:AddLabel('Name Search'):AddTextInput({
   Placeholder = "search & type custom name...",
   Size = 200,
   Callback = function(Text)
      if Text and Text ~= "" then
         MConfig.CustomName = Text
         if MConfig.NameChangerEnabled and LocalPlayer.Character then
            forceUpdateNametags(LocalPlayer.Character)
         end
         Logging.new("search", "Name set to: " .. Text, 3)
      end
   end,
})

local MenuSettings = SettingsTab:AddSection({ Name = "MENU SETTINGS" })
local GameSettings = SettingsTab:AddSection({ Name = "GAME SETTINGS" })

MenuSettings:AddLabel("Menu Keybind"):AddKeybind({
	Default = 'Insert',
	Callback = function(v)
		window.Keybind = v;
		Logging.new("ps4-touchpad",'Changed ui keybind to '..tostring(v),5)
	end,
})

MenuSettings:AddLabel('Menu Scale'):AddDropdown({
	Default = "Default",
	Values = {"Default",'Large','Mobile','Small'},
	Callback = function(v)
		window:SetSize(NeverLose.Scales[v]);
		Logging.new("crop",'Changed ui size to '..tostring(v),5)
	end,
})

MenuSettings:AddButton({
	Icon = 'discord',
	Name = 'Discord',
	Callback = function()
		if setclipboard then
			setclipboard("https://discord.gg/6hn7FMNNz5")
		end
		Logging.new("discord",'Copied discord invite link',5)
	end,
})

GameSettings:AddLabel('Vsync (Lock 60 FPS)'):AddToggle({
	Default = false,
	Callback = function(v)
		setVsync(v)
	end,
})

GameSettings:AddLabel('Stream Proof'):AddToggle({
	Default = false,
	Callback = function(v)
		setStreamProof(v)
	end,
})

GameSettings:AddButton({
	Icon = "rbxassetid://120681281047173",
	Name = 'Exit / Uninject Script',
	Callback = function()
		uninject()
		Logging.new("cross",'Uninjected script successfully!',5)
	end,
})

-- (intro notifications handled in intro sequence)

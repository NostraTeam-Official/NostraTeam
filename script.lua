-- StarterPlayer > StarterPlayerScripts > LocalScript
-- Sağ Shift: menüyü açar/kapatır.
-- Menünün üst kısmından sol tıkla sürüklenir.
-- Sağ tık basılıyken, görüş alanındaki görünür oyuncuya yumuşakça döner.
-- Bu LocalScript kendi Roblox Studio deneyimin içindir.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local cfg = {
	enabled = true,
	smooth = 28,
	fov = 42,
	distance = 400,
	head = true,
	team = true,
	walls = false,
	ring = true,
	mark = true,
	esp = true,
}

local holding = false

local COL = {
	bg = Color3.fromRGB(17, 16, 15),
	panel = Color3.fromRGB(24, 23, 21),
	panelHover = Color3.fromRGB(35, 32, 27),
	line = Color3.fromRGB(57, 52, 44),
	text = Color3.fromRGB(236, 232, 224),
	muted = Color3.fromRGB(138, 132, 122),
	track = Color3.fromRGB(46, 43, 38),
	fill = Color3.fromRGB(196, 164, 106),
	knob = Color3.fromRGB(250, 244, 231),
	good = Color3.fromRGB(154, 178, 137),
}

local function corner(inst, px)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, px)
	c.Parent = inst
	return c
end

local function stroke(inst, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or COL.line
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = inst
	return s
end

local function gradient(inst, color1, color2, rotation)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color1),
		ColorSequenceKeypoint.new(1, color2),
	})
	g.Rotation = rotation or 0
	g.Parent = inst
	return g
end

local function tween(inst, duration, properties, style, direction)
	local info = TweenInfo.new(
		duration,
		style or Enum.EasingStyle.Quart,
		direction or Enum.EasingDirection.Out
	)

	local animation = TweenService:Create(inst, info, properties)
	animation:Play()
	return animation
end

local gui = Instance.new("ScreenGui")
gui.Name = "NisanYardimi"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

-- Ana menü
local root = Instance.new("Frame")
root.Name = "Panel"
root.BackgroundColor3 = COL.bg
root.BorderSizePixel = 0
root.Position = UDim2.fromOffset(16, 16)
root.Size = UDim2.fromOffset(320, 0)
root.AutomaticSize = Enum.AutomaticSize.Y
root.Visible = false
root.ClipsDescendants = false
root.Parent = gui

corner(root, 8)
stroke(root, COL.line, 1)
gradient(root, Color3.fromRGB(25, 23, 19), COL.bg, 90)

local rootScale = Instance.new("UIScale")
rootScale.Scale = 1
rootScale.Parent = root

local menuOpen = false
local menuTween = nil

local function setMenuOpen(open)
	menuOpen = open

	if menuTween then
		menuTween:Cancel()
		menuTween = nil
	end

	if open then
		root.Visible = true
		rootScale.Scale = 0.94

		menuTween = tween(
			rootScale,
			0.22,
			{ Scale = 1 },
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		)
	else
		if not root.Visible then
			return
		end

		menuTween = tween(
			rootScale,
			0.14,
			{ Scale = 0.95 },
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		)

		local closingTween = menuTween

		closingTween.Completed:Connect(function(playbackState)
			if playbackState == Enum.PlaybackState.Completed and not menuOpen then
				root.Visible = false
				rootScale.Scale = 1
			end
		end)
	end
end

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 12)
pad.PaddingBottom = UDim.new(0, 14)
pad.PaddingLeft = UDim.new(0, 14)
pad.PaddingRight = UDim.new(0, 14)
pad.Parent = root

local list = Instance.new("UIListLayout")
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Padding = UDim.new(0, 9)
list.Parent = root

-- Üst başlık
local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = COL.panel
header.BackgroundTransparency = 0
header.Size = UDim2.new(1, 0, 0, 54)
header.LayoutOrder = 1
header.Parent = root

corner(header, 7)
stroke(header, Color3.fromRGB(65, 57, 44), 1)
gradient(header, Color3.fromRGB(38, 33, 26), COL.panel, 0)

local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.BackgroundColor3 = Color3.fromRGB(38, 36, 32)
avatar.BorderSizePixel = 0
avatar.Position = UDim2.fromOffset(4, 3)
avatar.Size = UDim2.fromOffset(46, 46)
avatar.ScaleType = Enum.ScaleType.Crop
avatar.Parent = header

corner(avatar, 23)
stroke(avatar, COL.fill, 1)

local display = Instance.new("TextLabel")
display.Name = "DisplayName"
display.BackgroundTransparency = 1
display.Position = UDim2.fromOffset(60, 6)
display.Size = UDim2.new(1, -106, 0, 20)
display.Font = Enum.Font.GothamSemibold
display.TextSize = 15
display.TextXAlignment = Enum.TextXAlignment.Left
display.TextTruncate = Enum.TextTruncate.AtEnd
display.TextColor3 = COL.text
display.Text = player.DisplayName ~= "" and player.DisplayName or player.Name
display.Parent = header

local handle = Instance.new("TextLabel")
handle.Name = "Subtitle"
handle.BackgroundTransparency = 1
handle.Position = UDim2.fromOffset(60, 27)
handle.Size = UDim2.new(1, -106, 0, 15)
handle.Font = Enum.Font.Gotham
handle.TextSize = 11
handle.TextXAlignment = Enum.TextXAlignment.Left
handle.TextTruncate = Enum.TextTruncate.AtEnd
handle.TextColor3 = COL.muted
handle.Text = player.DisplayName ~= "" and player.DisplayName ~= player.Name
	and ("@" .. player.Name)
	or "OYUN İÇİ KONTROL PANELİ"
handle.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -7, 0, 7)
closeButton.Size = UDim2.fromOffset(25, 25)
closeButton.BackgroundColor3 = Color3.fromRGB(46, 39, 30)
closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = false
closeButton.Text = "×"
closeButton.Font = Enum.Font.GothamMedium
closeButton.TextSize = 21
closeButton.TextColor3 = COL.text
closeButton.Parent = header

corner(closeButton, 6)
stroke(closeButton, COL.line, 1)

closeButton.MouseEnter:Connect(function()
	tween(closeButton, 0.12, {
		BackgroundColor3 = Color3.fromRGB(90, 54, 43),
	})
end)

closeButton.MouseLeave:Connect(function()
	tween(closeButton, 0.12, {
		BackgroundColor3 = Color3.fromRGB(46, 39, 30),
	})
end)

closeButton.Activated:Connect(function()
	setMenuOpen(false)
end)

task.spawn(function()
	local ok, image = pcall(function()
		return Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size150x150
		)
	end)

	if ok and type(image) == "string" and avatar.Parent then
		avatar.Image = image
	end
end)

-- Bölüm başlıkları
local function section(order, text)
	local holder = Instance.new("Frame")
	holder.Name = "Section_" .. tostring(order)
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.new(1, 0, 0, 16)
	holder.LayoutOrder = order
	holder.Parent = root

	local accent = Instance.new("Frame")
	accent.Name = "Accent"
	accent.AnchorPoint = Vector2.new(0, 0.5)
	accent.Position = UDim2.new(0, 0, 0.5, 0)
	accent.Size = UDim2.fromOffset(3, 11)
	accent.BackgroundColor3 = COL.fill
	accent.BorderSizePixel = 0
	accent.Parent = holder

	corner(accent, 2)

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(10, 0)
	label.Size = UDim2.new(1, -10, 1, 0)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = COL.muted
	label.Text = text
	label.Parent = holder
end

section(2, "NİŞAN AYARLARI")

-- Açık/kapalı ayar satırı
local function toggleRow(order, text, value, onChange)
	local row = Instance.new("TextButton")
	row.Name = "Toggle_" .. tostring(order)
	row.AutoButtonColor = false
	row.BackgroundColor3 = COL.panelHover
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, 29)
	row.Text = ""
	row.LayoutOrder = order
	row.Parent = root

	corner(row, 5)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(7, 0)
	label.Size = UDim2.new(1, -58, 1, 0)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = COL.text
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = text
	label.Parent = row

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.AnchorPoint = Vector2.new(1, 0.5)
	track.Position = UDim2.new(1, -5, 0.5, 0)
	track.Size = UDim2.fromOffset(36, 20)
	track.BorderSizePixel = 0
	track.BackgroundColor3 = COL.track
	track.Parent = row

	corner(track, 10)
	stroke(track, COL.line, 1)

	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Size = UDim2.fromOffset(14, 14)
	knob.BorderSizePixel = 0
	knob.BackgroundColor3 = COL.knob
	knob.Parent = track

	corner(knob, 7)

	local state = value

	local function paint(animated)
		local trackColor = state and COL.fill or Color3.fromRGB(58, 54, 48)
		local knobPos = state
			and UDim2.new(1, -17, 0.5, 0)
			or UDim2.new(0, 3, 0.5, 0)

		if animated then
			tween(track, 0.13, { BackgroundColor3 = trackColor })
			tween(knob, 0.13, { Position = knobPos })
		else
			track.BackgroundColor3 = trackColor
			knob.Position = knobPos
		end
	end

	paint(false)

	row.MouseEnter:Connect(function()
		tween(row, 0.12, { BackgroundTransparency = 0.45 })
	end)

	row.MouseLeave:Connect(function()
		tween(row, 0.12, { BackgroundTransparency = 1 })
	end)

	row.Activated:Connect(function()
		state = not state
		paint(true)
		onChange(state)
	end)
end

toggleRow(3, "Yardım", cfg.enabled, function(v)
	cfg.enabled = v
end)

toggleRow(4, "Takımı geç", cfg.team, function(v)
	cfg.team = v
end)

toggleRow(5, "Duvar arkasını yok say", not cfg.walls, function(v)
	cfg.walls = not v
end)

toggleRow(6, "Görüş halkası", cfg.ring, function(v)
	cfg.ring = v
end)

toggleRow(7, "Hedef noktası", cfg.mark, function(v)
	cfg.mark = v
end)

toggleRow(8, "ESP", cfg.esp, function(v)
	cfg.esp = v
end)

-- Seçenek değiştirme satırı
local function cycleRow(order, text, options, index, onChange)
	local row = Instance.new("TextButton")
	row.Name = "Cycle_" .. tostring(order)
	row.AutoButtonColor = false
	row.BackgroundColor3 = COL.panelHover
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, 29)
	row.Text = ""
	row.LayoutOrder = order
	row.Parent = root

	corner(row, 5)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(7, 0)
	label.Size = UDim2.new(0.55, -7, 1, 0)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = COL.text
	label.Text = text
	label.Parent = row

	local value = Instance.new("TextLabel")
	value.BackgroundTransparency = 1
	value.Position = UDim2.new(0.55, 0, 0, 0)
	value.Size = UDim2.new(0.45, -7, 1, 0)
	value.Font = Enum.Font.GothamSemibold
	value.TextSize = 13
	value.TextXAlignment = Enum.TextXAlignment.Right
	value.TextColor3 = COL.fill
	value.Text = options[index]
	value.Parent = row

	local i = index

	row.MouseEnter:Connect(function()
		tween(row, 0.12, { BackgroundTransparency = 0.45 })
	end)

	row.MouseLeave:Connect(function()
		tween(row, 0.12, { BackgroundTransparency = 1 })
	end)

	row.Activated:Connect(function()
		i = i % #options + 1
		value.Text = options[i]

		tween(value, 0.1, {
			TextTransparency = 0.35,
		})

		task.delay(0.1, function()
			if value.Parent then
				tween(value, 0.12, {
					TextTransparency = 0,
				})
			end
		end)

		onChange(i, options[i])
	end)
end

cycleRow(9, "Hedef", { "Kafa", "Gövde" }, cfg.head and 1 or 2, function(i)
	cfg.head = i == 1
end)

section(10, "HASSASİYET")

-- Kaydırma çubuğu
local function sliderRow(order, text, min, max, value, fmt, onChange)
	local wrap = Instance.new("Frame")
	wrap.Name = "Slider_" .. tostring(order)
	wrap.BackgroundTransparency = 1
	wrap.Size = UDim2.new(1, 0, 0, 43)
	wrap.LayoutOrder = order
	wrap.Parent = root

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(4, 0)
	label.Size = UDim2.new(0.62, -4, 0, 17)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = COL.text
	label.Text = text
	label.Parent = wrap

	local readout = Instance.new("TextLabel")
	readout.BackgroundTransparency = 1
	readout.Position = UDim2.new(0.62, 0, 0, 0)
	readout.Size = UDim2.new(0.38, -4, 0, 17)
	readout.Font = Enum.Font.GothamSemibold
	readout.TextSize = 12
	readout.TextXAlignment = Enum.TextXAlignment.Right
	readout.TextColor3 = COL.fill
	readout.Parent = wrap

	local bar = Instance.new("TextButton")
	bar.Name = "Bar"
	bar.AutoButtonColor = false
	bar.Text = ""
	bar.BackgroundTransparency = 1
	bar.BorderSizePixel = 0
	bar.Position = UDim2.new(0, 4, 0, 19)
	bar.Size = UDim2.new(1, -8, 0, 19)
	bar.Parent = wrap

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.AnchorPoint = Vector2.new(0, 0.5)
	track.Position = UDim2.new(0, 0, 0.5, 0)
	track.Size = UDim2.new(1, 0, 0, 4)
	track.BackgroundColor3 = COL.track
	track.BorderSizePixel = 0
	track.Parent = bar

	corner(track, 3)

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = COL.fill
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.Parent = track

	corner(fill, 3)
	gradient(fill, Color3.fromRGB(224, 192, 137), COL.fill, 0)

	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = COL.knob
	knob.BorderSizePixel = 0
	knob.Size = UDim2.fromOffset(10, 10)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.Parent = track

	corner(knob, 5)
	stroke(knob, Color3.fromRGB(255, 237, 197), 1)

	local current = value

	local function apply(v, animated)
		current = math.clamp(v, min, max)

		local t = (current - min) / (max - min)
		local fillSize = UDim2.new(t, 0, 1, 0)
		local knobPos = UDim2.new(t, 0, 0.5, 0)

		if animated then
			tween(fill, 0.06, { Size = fillSize })
			tween(knob, 0.06, { Position = knobPos })
		else
			fill.Size = fillSize
			knob.Position = knobPos
		end

		readout.Text = fmt(current)
		onChange(current)
	end

	local function at(x)
		local width = bar.AbsoluteSize.X
		if width <= 0 then
			return
		end

		local t = math.clamp(
			(x - bar.AbsolutePosition.X) / width,
			0,
			1
		)

		apply(min + (max - min) * t, true)
	end

	local drag = false

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = true
			at(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
			at(input.Position.X)
		end
	end)

	apply(value, false)
end

sliderRow(11, "Yumuşaklık", 0, 100, cfg.smooth, function(v)
	return string.format("%d", math.floor(v + 0.5))
end, function(v)
	cfg.smooth = v
end)

sliderRow(12, "Görüş açısı", 8, 90, cfg.fov, function(v)
	return string.format("%d°", math.floor(v + 0.5))
end, function(v)
	cfg.fov = v
end)

sliderRow(13, "Menzil", 40, 800, cfg.distance, function(v)
	return string.format("%d", math.floor(v + 0.5))
end, function(v)
	cfg.distance = v
end)

-- Alt bilgi
local footer = Instance.new("Frame")
footer.Name = "Footer"
footer.BackgroundTransparency = 1
footer.Size = UDim2.new(1, 0, 0, 24)
footer.LayoutOrder = 14
footer.Parent = root

local footerLine = Instance.new("Frame")
footerLine.BackgroundColor3 = COL.line
footerLine.BorderSizePixel = 0
footerLine.Size = UDim2.new(1, 0, 0, 1)
footerLine.Parent = footer

local hint = Instance.new("TextLabel")
hint.Name = "Hint"
hint.BackgroundTransparency = 1
hint.Position = UDim2.fromOffset(0, 5)
hint.Size = UDim2.new(1, 0, 0, 16)
hint.Font = Enum.Font.Gotham
hint.TextSize = 10
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.TextColor3 = COL.muted
hint.Text = "SAĞ SHIFT  •  ÜSTTEN SÜRÜKLE"
hint.Parent = footer

-- Menü sürükleme
local dragging = false
local dragStart = Vector2.zero
local startPos = root.Position

header.Active = true

header.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end

	-- Kapatma düğmesine tıklanırken sürüklemeyi başlatma.
	local x, y = input.Position.X, input.Position.Y
	local closePos = closeButton.AbsolutePosition
	local closeSize = closeButton.AbsoluteSize

	local overClose =
		x >= closePos.X
		and x <= closePos.X + closeSize.X
		and y >= closePos.Y
		and y <= closePos.Y + closeSize.Y

	if overClose then
		return
	end

	dragging = true
	dragStart = Vector2.new(input.Position.X, input.Position.Y)
	startPos = root.Position
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		holding = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local dx = input.Position.X - dragStart.X
	local dy = input.Position.Y - dragStart.Y

	root.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + dx,
		startPos.Y.Scale,
		startPos.Y.Offset + dy
	)
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.RightShift and not processed then
		setMenuOpen(not menuOpen)
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		holding = true
	end
end)

-- Ekran göstergeleri
local overlay = Instance.new("ScreenGui")
overlay.Name = "NisanYardimiGosterge"
overlay.ResetOnSpawn = false
overlay.IgnoreGuiInset = true
overlay.DisplayOrder = 5
overlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
overlay.Parent = player.PlayerGui

local ring = Instance.new("Frame")
ring.Name = "GorusHalkasi"
ring.AnchorPoint = Vector2.new(0.5, 0.5)
ring.Position = UDim2.fromScale(0.5, 0.5)
ring.BackgroundTransparency = 1
ring.BorderSizePixel = 0
ring.Active = false
ring.Visible = false
ring.Parent = overlay

local ringStroke = stroke(ring, COL.fill, 1)
ringStroke.Transparency = 0.35

local ringCorner = Instance.new("UICorner")
ringCorner.CornerRadius = UDim.new(1, 0)
ringCorner.Parent = ring

local mark = Instance.new("Frame")
mark.Name = "HedefNoktasi"
mark.AnchorPoint = Vector2.new(0.5, 0.5)
mark.Size = UDim2.fromOffset(8, 8)
mark.BackgroundColor3 = COL.fill
mark.BorderSizePixel = 0
mark.Visible = false
mark.Parent = overlay

corner(mark, 4)
stroke(mark, COL.text, 1)

-- Oyuncu yardımcıları
local function isAlly(otherPlayer)
	if not otherPlayer or not otherPlayer.Team or not player.Team then
		return false
	end

	return otherPlayer.Team == player.Team
end

local function aimPart(character)
	if cfg.head then
		local head = character:FindFirstChild("Head")

		if head and head:IsA("BasePart") then
			return head
		end
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if rootPart and rootPart:IsA("BasePart") then
		return rootPart
	end

	return character:FindFirstChildWhichIsA("BasePart")
end

local tracked = {}
local scanClock = 0
local espClock = 0

-- Yalnızca gerçek oyuncuların karakterlerini listele.
-- NPC modelleri oyuncu listesine alınmaz.
local function rebuildTracked()
	table.clear(tracked)

	local seen = {}

	local function add(model)
		if not model or seen[model] or model == player.Character then
			return
		end

		local otherPlayer = Players:GetPlayerFromCharacter(model)

		if not otherPlayer or otherPlayer == player then
			return
		end

		local humanoid = model:FindFirstChildOfClass("Humanoid")

		if humanoid and humanoid.Health > 0 then
			seen[model] = true
			tracked[#tracked + 1] = model
		end
	end

	for _, other in Players:GetPlayers() do
		if other ~= player then
			add(other.Character)
		end
	end

	-- Mevcut dünya taraması korunur.
	-- add() filtresi NPC'lerin listeye eklenmesini önler.
	for _, child in workspace:GetChildren() do
		if child:IsA("Model") then
			add(child)
		elseif child:IsA("Folder") then
			for _, sub in child:GetChildren() do
				if sub:IsA("Model") then
					add(sub)
				end
			end
		end
	end
end

-- Görüş çizgisi kontrolü
local function clearLine(origin, part)
	if cfg.walls then
		return true
	end

	camera = workspace.CurrentCamera

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.RespectCanCollide = true

	local ignore = {}

	if part.Parent then
		table.insert(ignore, part.Parent)
	end

	if player.Character then
		table.insert(ignore, player.Character)
	end

	if camera then
		table.insert(ignore, camera)
	end

	params.FilterDescendantsInstances = ignore

	local goal = part.Position - origin
	local pos = origin

	for _ = 1, 5 do
		if goal.Magnitude < 0.75 then
			return true
		end

		local hit = workspace:Raycast(pos, goal, params)

		if not hit then
			return true
		end

		local inst = hit.Instance
		local model = inst:FindFirstAncestorOfClass("Model")
		local name = string.lower(inst.Name)
		local modelName = model and string.lower(model.Name) or ""

		local viewmodel = (camera and inst:IsDescendantOf(camera))
			or string.find(name, "view", 1, true) ~= nil
			or string.find(modelName, "view", 1, true) ~= nil
			or string.find(modelName, "arm", 1, true) ~= nil

		if viewmodel then
			table.insert(ignore, model or inst)
			params.FilterDescendantsInstances = ignore
			pos = hit.Position + goal.Unit * 0.2
			goal = part.Position - pos
		else
			return false
		end
	end

	return false
end

local function pointerOverPanel()
	if not root.Visible then
		return false
	end

	local loc = UserInputService:GetMouseLocation()
	local hits = player.PlayerGui:GetGuiObjectsAtPosition(loc.X, loc.Y)

	for _, obj in hits do
		if obj:IsDescendantOf(root) then
			return true
		end
	end

	return false
end

-- En uygun oyuncu hedefini bul
local function acquire()
	camera = workspace.CurrentCamera

	if not camera then
		return nil
	end

	local origin = camera.CFrame.Position
	local look = camera.CFrame.LookVector
	local limit = math.rad(cfg.fov * 0.5)
	local candidates = {}

	for i = 1, #tracked do
		local model = tracked[i]

		if model.Parent then
			local otherPlayer = Players:GetPlayerFromCharacter(model)

			if otherPlayer and otherPlayer ~= player then
				if not (cfg.team and isAlly(otherPlayer)) then
					local humanoid = model:FindFirstChildOfClass("Humanoid")
					local part = humanoid and humanoid.Health > 0 and aimPart(model)

					if part then
						local delta = part.Position - origin
						local dist = delta.Magnitude

						if dist > 2 and dist <= cfg.distance then
							local angle = math.acos(
								math.clamp(look:Dot(delta.Unit), -1, 1)
							)

							if angle <= limit then
								candidates[#candidates + 1] = {
									part = part,
									angle = angle,
									dist = dist,
								}
							end
						end
					end
				end
			end
		end
	end

	table.sort(candidates, function(a, b)
		if math.abs(a.angle - b.angle) > 1e-4 then
			return a.angle < b.angle
		end

		return a.dist < b.dist
	end)

	for i = 1, #candidates do
		if clearLine(origin, candidates[i].part) then
			return candidates[i].part
		end
	end

	return nil
end

-- ESP kayıtları
local espRecs = {}

local function dropEsp(model)
	local rec = espRecs[model]

	if not rec then
		return
	end

	if rec.highlight then
		rec.highlight:Destroy()
	end

	if rec.board then
		rec.board:Destroy()
	end

	espRecs[model] = nil
end

local function paintEsp(model, humanoid, otherPlayer)
	-- ESP yalnızca gerçek oyunculara uygulanır.
	if not otherPlayer or otherPlayer == player then
		dropEsp(model)
		return
	end

	local head = model:FindFirstChild("Head")

	if not (head and head:IsA("BasePart")) then
		head = model:FindFirstChild("HumanoidRootPart")
	end

	if not head then
		dropEsp(model)
		return
	end

	local ally = isAlly(otherPlayer)
	local rec = espRecs[model]

	if not rec or rec.head ~= head or not rec.highlight.Parent then
		dropEsp(model)

		local highlight = Instance.new("Highlight")
		highlight.Name = "NisanEsp"
		highlight.Adornee = model
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillTransparency = 0.68
		highlight.OutlineTransparency = 0
		highlight.Parent = overlay

		local board = Instance.new("BillboardGui")
		board.Name = "NisanEspTag"
		board.Adornee = head
		board.AlwaysOnTop = true
		board.LightInfluence = 0
		board.Size = UDim2.fromOffset(200, 36)
		board.StudsOffset = Vector3.new(0, 2.8, 0)
		board.Parent = overlay

		local name = Instance.new("TextLabel")
		name.Name = "Name"
		name.BackgroundTransparency = 1
		name.Size = UDim2.new(1, 0, 0, 18)
		name.Font = Enum.Font.GothamMedium
		name.TextSize = 14
		name.TextStrokeTransparency = 0.4
		name.TextXAlignment = Enum.TextXAlignment.Center
		name.Parent = board

		local hp = Instance.new("TextLabel")
		hp.Name = "Health"
		hp.BackgroundTransparency = 1
		hp.Position = UDim2.fromOffset(0, 16)
		hp.Size = UDim2.new(1, 0, 0, 16)
		hp.Font = Enum.Font.Gotham
		hp.TextSize = 12
		hp.TextStrokeTransparency = 0.45
		hp.TextXAlignment = Enum.TextXAlignment.Center
		hp.Parent = board

		rec = {
			highlight = highlight,
			board = board,
			head = head,
			name = name,
			hp = hp,
		}

		espRecs[model] = rec
	end

	local color = ally and Color3.fromRGB(142, 148, 136) or COL.fill

	rec.highlight.FillColor = color
	rec.highlight.OutlineColor = ally
		and Color3.fromRGB(214, 216, 206)
		or Color3.fromRGB(244, 236, 214)

	rec.highlight.Enabled = true

	local dist = (head.Position - camera.CFrame.Position).Magnitude
	local now = os.clock()

	if not rec.nextText or now >= rec.nextText then
		rec.nextText = now + 0.2

		local who = otherPlayer.DisplayName ~= ""
			and otherPlayer.DisplayName
			or otherPlayer.Name

		rec.name.Text = string.format(
			"%s   %dm",
			who,
			math.floor(dist + 0.5)
		)

		rec.name.TextColor3 = ally and Color3.fromRGB(214, 216, 206) or COL.text
		rec.hp.Text = string.format("HP %d", math.floor(humanoid.Health + 0.5))
		rec.hp.TextColor3 = COL.muted
	end
end

local function updateEsp()
	if not camera then
		return
	end

	local seen = {}

	if cfg.esp then
		local origin = camera.CFrame.Position
		local near = {}

		for i = 1, #tracked do
			local model = tracked[i]

			if model.Parent then
				local otherPlayer = Players:GetPlayerFromCharacter(model)

				if otherPlayer and otherPlayer ~= player then
					if not (cfg.team and isAlly(otherPlayer)) then
						local humanoid = model:FindFirstChildOfClass("Humanoid")
						local part = humanoid and humanoid.Health > 0 and aimPart(model)

						if part then
							local dist = (part.Position - origin).Magnitude

							if dist <= 800 then
								near[#near + 1] = {
									model = model,
									humanoid = humanoid,
									otherPlayer = otherPlayer,
									dist = dist,
								}
							end
						end
					end
				end
			end
		end

		table.sort(near, function(a, b)
			return a.dist < b.dist
		end)

		local limit = math.min(12, #near)

		for i = 1, limit do
			local item = near[i]
			seen[item.model] = true

			paintEsp(
				item.model,
				item.humanoid,
				item.otherPlayer
			)
		end
	end

	local stale = {}

	for model, rec in pairs(espRecs) do
		if not seen[model] or not rec.highlight.Parent then
			table.insert(stale, model)
		end
	end

	for _, model in stale do
		dropEsp(model)
	end
end

local function updateRing()
	camera = workspace.CurrentCamera

	if not camera or not cfg.enabled or not cfg.ring then
		ring.Visible = false
		return
	end

	local vFov = math.rad(camera.FieldOfView)

	local radius = math.tan(math.rad(cfg.fov * 0.5))
		/ math.tan(vFov * 0.5)
		* (camera.ViewportSize.Y * 0.5)

	radius = math.clamp(radius, 4, 2000)

	ring.Size = UDim2.fromOffset(radius * 2, radius * 2)
	ring.Visible = true
end

-- Eski RenderStep bağlantısını güvenle kaldır
pcall(function()
	RunService:UnbindFromRenderStep("NisanYardimi")
end)

-- Geliştirilmiş açılış animasyonu
local intro = Instance.new("Frame")
intro.Name = "Acilis"
intro.BackgroundColor3 = COL.bg
intro.BackgroundTransparency = 1
intro.Size = UDim2.fromScale(1, 1)
intro.BorderSizePixel = 0
intro.ZIndex = 30
intro.Parent = gui

gradient(
	intro,
	Color3.fromRGB(28, 24, 19),
	Color3.fromRGB(11, 11, 10),
	90
)

local introBlur = Instance.new("BlurEffect")
introBlur.Name = "NisanYardimiIntroBlur"
introBlur.Size = 0
introBlur.Parent = Lighting

local introAccent = Instance.new("Frame")
introAccent.AnchorPoint = Vector2.new(0.5, 0.5)
introAccent.Position = UDim2.fromScale(0.5, 0.405)
introAccent.Size = UDim2.fromOffset(0, 2)
introAccent.BackgroundColor3 = COL.fill
introAccent.BorderSizePixel = 0
introAccent.ZIndex = 31
introAccent.Parent = intro

corner(introAccent, 2)
gradient(introAccent, Color3.fromRGB(112, 87, 51), COL.fill, 0)

local title = Instance.new("TextLabel")
title.Name = "Baslik"
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.fromScale(0.5, 0.49)
title.Size = UDim2.new(0.9, 0, 0, 65)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 44
title.TextScaled = false
title.Text = "NostraTeam"
title.TextColor3 = COL.fill
title.TextTransparency = 1
title.ZIndex = 31
title.Parent = intro

local titleScale = Instance.new("UIScale")
titleScale.Scale = 0.82
titleScale.Parent = title

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(85, 66, 42)
titleStroke.Thickness = 0.6
titleStroke.Transparency = 1
titleStroke.Parent = title

local subtitle = Instance.new("TextLabel")
subtitle.Name = "AltBaslik"
subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
subtitle.Position = UDim2.fromScale(0.5, 0.555)
subtitle.Size = UDim2.new(0.9, 0, 0, 25)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 12
subtitle.Text = "OYUN İÇİ KONTROL PANELİ"
subtitle.TextColor3 = COL.muted
subtitle.TextTransparency = 1
subtitle.ZIndex = 31
subtitle.Parent = intro

local subScale = Instance.new("UIScale")
subScale.Scale = 0.96
subScale.Parent = subtitle

local introTag = Instance.new("TextLabel")
introTag.Name = "Etiket"
introTag.AnchorPoint = Vector2.new(0.5, 0.5)
introTag.Position = UDim2.fromScale(0.5, 0.61)
introTag.Size = UDim2.fromOffset(200, 22)
introTag.BackgroundTransparency = 1
introTag.Font = Enum.Font.GothamMedium
introTag.TextSize = 10
introTag.Text = "SİSTEM BAŞLATILIYOR"
introTag.TextColor3 = COL.fill
introTag.TextTransparency = 1
introTag.ZIndex = 31
introTag.Parent = intro

-- Küçük dekoratif noktalar
local dots = {}

for i = 1, 3 do
	local dot = Instance.new("Frame")
	dot.Name = "Nokta" .. tostring(i)
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Position = UDim2.new(0.5, (i - 2) * 18, 0.66, 0)
	dot.Size = UDim2.fromOffset(4, 4)
	dot.BackgroundColor3 = COL.fill
	dot.BackgroundTransparency = 1
	dot.BorderSizePixel = 0
	dot.ZIndex = 31
	dot.Parent = intro

	corner(dot, 2)
	dots[#dots + 1] = dot
end

local introEase = TweenInfo.new(
	0.85,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out
)

tween(intro, 0.5, {
	BackgroundTransparency = 0.08,
})

tween(introBlur, 0.65, {
	Size = 7,
})

tween(
	title,
	0.85,
	{
		TextTransparency = 0,
		Position = UDim2.fromScale(0.5, 0.48),
	},
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out
)

tween(titleScale, 0.85, {
	Scale = 1,
}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

tween(titleStroke, 0.7, {
	Transparency = 0.8,
})

tween(subtitle, 0.85, {
	TextTransparency = 0,
	Position = UDim2.fromScale(0.5, 0.555),
})

tween(subScale, 0.85, {
	Scale = 1,
})

tween(introTag, 0.9, {
	TextTransparency = 0.2,
})

tween(introAccent, 0.85, {
	Size = UDim2.fromOffset(190, 2),
}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

for i, dot in ipairs(dots) do
	task.delay(0.18 + i * 0.12, function()
		if dot.Parent then
			tween(dot, 0.25, {
				BackgroundTransparency = 0,
			})
		end
	end)
end

task.delay(1.65, function()
	if not intro.Parent then
		return
	end

	local leave = TweenInfo.new(
		0.55,
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.In
	)

	tween(title, 0.45, {
		TextTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.455),
	}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

	tween(titleScale, 0.45, {
		Scale = 0.96,
	}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	tween(titleStroke, 0.35, {
		Transparency = 1,
	})

	tween(subtitle, 0.35, {
		TextTransparency = 1,
	})

	tween(introTag, 0.25, {
		TextTransparency = 1,
	})

	tween(introAccent, 0.4, {
		Size = UDim2.fromOffset(40, 1),
		BackgroundTransparency = 1,
	})

	for _, dot in ipairs(dots) do
		tween(dot, 0.2, {
			BackgroundTransparency = 1,
		})
	end

	tween(introBlur, 0.5, {
		Size = 0,
	})

	local backgroundFade = TweenService:Create(intro, leave, {
		BackgroundTransparency = 1,
	})

	backgroundFade.Completed:Connect(function(playbackState)
		if playbackState ~= Enum.PlaybackState.Completed then
			return
		end

		if introBlur and introBlur.Parent then
			introBlur:Destroy()
		end

		if intro and intro.Parent then
			intro:Destroy()
		end

		setMenuOpen(true)
	end)

	backgroundFade:Play()
end)

-- Oyuncuları ilk kez listele
rebuildTracked()

RunService:BindToRenderStep(
	"NisanYardimi",
	Enum.RenderPriority.Last.Value + 1,
	function(dt)
		camera = workspace.CurrentCamera

		scanClock += dt

		if scanClock >= 0.6 then
			scanClock = 0
			rebuildTracked()
		end

		updateRing()

		espClock += dt

		if espClock >= 0.25 then
			espClock = 0
			updateEsp()
		end

		mark.Visible = false

		local aimHeld = UserInputService:IsMouseButtonPressed(
			Enum.UserInputType.MouseButton2
		)

		if not cfg.enabled or not aimHeld or not camera or pointerOverPanel() then
			return
		end

		local part = acquire()

		if not part then
			return
		end

		local response = 30 + (100 - cfg.smooth) * 1.5
		local alpha = 1 - math.exp(-response * dt)

		if cfg.smooth <= 6 then
			alpha = 1
		end

		local goal = CFrame.lookAt(
			camera.CFrame.Position,
			part.Position
		)

		camera.CFrame = camera.CFrame:Lerp(
			goal,
			math.clamp(alpha, 0, 1)
		)

		if cfg.mark then
			local screen = camera:WorldToViewportPoint(part.Position)

			if screen.Z > 0 then
				mark.Position = UDim2.fromOffset(screen.X, screen.Y)
				mark.Visible = true
			end
		end
	end
)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- ScreenGui chứa toàn bộ ESP và Menu
local mainScreenGui = Instance.new("ScreenGui")
mainScreenGui.Name = "GiangLiet_ESP_Gui"
mainScreenGui.IgnoreGuiInset = true
mainScreenGui.ResetOnSpawn = false
mainScreenGui.Parent = playerGui

local espContainer = Instance.new("Folder")
espContainer.Name = "GiangLiet_ESP_Elements"
espContainer.Parent = mainScreenGui

-- ==========================================
-- 1. CẤU HÌNH & TRẠNG THÁI (SETTINGS)
-- ==========================================
local CONFIG = {
	MenuTitle = "GIANG LIỆT ESP",
	Enabled = true,
	ShowBox = true,
	ShowInfo = true,
	ShowSkeleton = true,
	ColorByHP = false,

	BoxColor = Color3.fromRGB(0, 255, 127),
	SkeletonColor = Color3.fromRGB(255, 255, 255),
	TextColor = Color3.fromRGB(255, 255, 255),

	BoxThickness = 1.5,
	SkeletonThickness = 1.5,
	TextSize = 13,

	ToggleKey = Enum.KeyCode.RightShift, -- Phím đóng/mở mặc định
}

local isBindingKey = false

-- Bảng màu mẫu để chuyển đổi nhanh trên GUI
local COLOR_PALETTE = {
	{Name = "Xanh lá", Color = Color3.fromRGB(0, 255, 127)},
	{Name = "Trắng", Color = Color3.fromRGB(255, 255, 255)},
	{Name = "Đỏ", Color = Color3.fromRGB(255, 65, 65)},
	{Name = "Vàng", Color = Color3.fromRGB(255, 230, 0)},
	{Name = "Xanh dương", Color = Color3.fromRGB(0, 190, 255)},
	{Name = "Tím", Color = Color3.fromRGB(185, 80, 255)},
	{Name = "Cam", Color = Color3.fromRGB(255, 140, 0)},
}

-- ==========================================
-- 2. KHỞI TẠO GIAO DIỆN ĐIỀU KHIỂN (MENU GUI)
-- ==========================================
local menuFrame = Instance.new("Frame")
menuFrame.Name = "GiangLiet_ControlPanel"
menuFrame.Size = UDim2.fromOffset(265, 376)
menuFrame.Position = UDim2.new(0, 30, 0.5, -188)
menuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
menuFrame.BorderSizePixel = 0
menuFrame.Active = true
menuFrame.Parent = mainScreenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 8)
menuCorner.Parent = menuFrame

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(60, 60, 70)
menuStroke.Thickness = 1
menuStroke.Parent = menuFrame

-- Thanh tiêu đề (Dùng để kéo thả Menu)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 34)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
titleBar.BorderSizePixel = 0
titleBar.Parent = menuFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.fromOffset(10, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = CONFIG.MenuTitle .. " [" .. CONFIG.ToggleKey.Name .. "]"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Tính năng kéo thả cửa sổ Menu
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = menuFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		menuFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- Danh sách chứa các nút chức năng
local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -20, 1, -44)
contentHolder.Position = UDim2.fromOffset(10, 40)
contentHolder.BackgroundTransparency = 1
contentHolder.Parent = menuFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = contentHolder

-- Hàm tạo nút Bật/Tắt (Toggle)
local function createToggle(labelText, configKey, order)
	local btn = Instance.new("TextButton")
	btn.LayoutOrder = order
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = contentHolder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 1, 0)
	label.Position = UDim2.fromOffset(10, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = btn

	local statusBox = Instance.new("Frame")
	statusBox.Size = UDim2.fromOffset(40, 20)
	statusBox.Position = UDim2.new(1, -48, 0.5, -10)
	statusBox.BorderSizePixel = 0
	statusBox.Parent = btn

	local statusCorner = Instance.new("UICorner")
	statusCorner.CornerRadius = UDim.new(1, 0)
	statusCorner.Parent = statusBox

	local function updateVisual()
		if CONFIG[configKey] then
			statusBox.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
		else
			statusBox.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
		end
	end

	btn.MouseButton1Click:Connect(function()
		CONFIG[configKey] = not CONFIG[configKey]
		updateVisual()
	end)

	updateVisual()
end

-- Hàm tạo nút Đổi Màu (Cycle qua bảng màu)
local function createColorSelector(labelText, configKey, defaultIndex, order)
	local currentIndex = defaultIndex
	local btn = Instance.new("TextButton")
	btn.LayoutOrder = order
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = contentHolder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -90, 1, 0)
	label.Position = UDim2.fromOffset(10, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = btn

	local colorPreview = Instance.new("TextLabel")
	colorPreview.Size = UDim2.fromOffset(75, 20)
	colorPreview.Position = UDim2.new(1, -83, 0.5, -10)
	colorPreview.Font = Enum.Font.GothamBold
	colorPreview.TextSize = 11
	colorPreview.TextColor3 = Color3.fromRGB(20, 20, 20)
	colorPreview.Parent = btn

	local previewCorner = Instance.new("UICorner")
	previewCorner.CornerRadius = UDim.new(0, 4)
	previewCorner.Parent = colorPreview

	local function applyColor()
		local entry = COLOR_PALETTE[currentIndex]
		CONFIG[configKey] = entry.Color
		colorPreview.BackgroundColor3 = entry.Color
		colorPreview.Text = entry.Name
	end

	btn.MouseButton1Click:Connect(function()
		currentIndex = (currentIndex % #COLOR_PALETTE) + 1
		applyColor()
	end)

	applyColor()
end

-- Hàm tạo nút Gán Phím Tắt (Keybind)
local function createKeybindButton(labelText, order)
	local btn = Instance.new("TextButton")
	btn.LayoutOrder = order
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = contentHolder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -100, 1, 0)
	label.Position = UDim2.fromOffset(10, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = btn

	local keyBadge = Instance.new("TextLabel")
	keyBadge.Size = UDim2.fromOffset(85, 20)
	keyBadge.Position = UDim2.new(1, -93, 0.5, -10)
	keyBadge.BackgroundColor3 = Color3.fromRGB(60, 60, 72)
	keyBadge.Font = Enum.Font.GothamBold
	keyBadge.TextSize = 11
	keyBadge.TextColor3 = Color3.fromRGB(240, 240, 240)
	keyBadge.Text = CONFIG.ToggleKey.Name
	keyBadge.Parent = btn

	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(0, 4)
	badgeCorner.Parent = keyBadge

	btn.MouseButton1Click:Connect(function()
		if isBindingKey then return end
		isBindingKey = true
		keyBadge.Text = "[Nhấn phím...]"
		keyBadge.BackgroundColor3 = Color3.fromRGB(230, 150, 0)
		keyBadge.TextColor3 = Color3.fromRGB(20, 20, 20)
	end)

	-- Lắng nghe phím để gán hoặc đóng/mở Menu
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if isBindingKey then
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
				-- Nhấn Escape để hủy đổi phím
				if input.KeyCode ~= Enum.KeyCode.Escape then
					CONFIG.ToggleKey = input.KeyCode
					titleLabel.Text = CONFIG.MenuTitle .. " [" .. CONFIG.ToggleKey.Name .. "]"
				end
				keyBadge.Text = CONFIG.ToggleKey.Name
				keyBadge.BackgroundColor3 = Color3.fromRGB(60, 60, 72)
				keyBadge.TextColor3 = Color3.fromRGB(240, 240, 240)

				task.defer(function()
					isBindingKey = false
				end)
			end
			return
		end

		if not gameProcessed and input.KeyCode == CONFIG.ToggleKey then
			menuFrame.Visible = not menuFrame.Visible
		end
	end)
end

-- Tạo các nút điều khiển
createToggle("Bật toàn bộ ESP", "Enabled", 1)
createToggle("Hiện Khung chữ nhật (Box)", "ShowBox", 2)
createToggle("Hiện Tên, HP & Khoảng cách", "ShowInfo", 3)
createToggle("Hiện Xương bộ phận (Que)", "ShowSkeleton", 4)
createToggle("Màu khung tự đổi theo % HP", "ColorByHP", 5)

createColorSelector("Màu Khung:", "BoxColor", 1, 6)
createColorSelector("Màu Xương:", "SkeletonColor", 2, 7)
createColorSelector("Màu Chữ:", "TextColor", 2, 8)
createKeybindButton("Phím đóng/mở Menu:", 9)

-- ==========================================
-- 3. HỆ THỐNG XỬ LÝ ESP (BOX, TEXT, SKELETON)
-- ==========================================
local R15_BONES = {
	{"Head", "UpperTorso"},
	{"UpperTorso", "LowerTorso"},
	{"UpperTorso", "LeftUpperArm"},
	{"LeftUpperArm", "LeftLowerArm"},
	{"LeftLowerArm", "LeftHand"},
	{"UpperTorso", "RightUpperArm"},
	{"RightUpperArm", "RightLowerArm"},
	{"RightLowerArm", "RightHand"},
	{"LowerTorso", "LeftUpperLeg"},
	{"LeftUpperLeg", "LeftLowerLeg"},
	{"LeftLowerLeg", "LeftFoot"},
	{"LowerTorso", "RightUpperLeg"},
	{"RightUpperLeg", "RightLowerLeg"},
	{"RightLowerLeg", "RightFoot"},
}

local R6_BONES = {
	{"Head", "Torso"},
	{"Torso", "Left Arm"},
	{"Torso", "Right Arm"},
	{"Torso", "Left Leg"},
	{"Torso", "Right Leg"},
}

local activeESP = {}

local function createLine()
	local line = Instance.new("Frame")
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BackgroundColor3 = CONFIG.SkeletonColor
	line.BorderSizePixel = 0
	line.Visible = false
	line.Parent = espContainer
	return line
end

local function updateLine(line, p1, p2, color)
	local dx = p2.X - p1.X
	local dy = p2.Y - p1.Y
	local distance = math.sqrt(dx * dx + dy * dy)
	local centerX = (p1.X + p2.X) / 2
	local centerY = (p1.Y + p2.Y) / 2
	local angle = math.deg(math.atan2(dy, dx))

	line.Position = UDim2.fromOffset(centerX, centerY)
	line.Size = UDim2.fromOffset(distance, CONFIG.SkeletonThickness)
	line.Rotation = angle
	line.BackgroundColor3 = color
	line.Visible = true
end

local function removeESP(player)
	local data = activeESP[player]
	if data then
		if data.BoxGui then data.BoxGui:Destroy() end
		if data.InfoGui then data.InfoGui:Destroy() end
		if data.Lines then
			for _, line in ipairs(data.Lines) do
				line:Destroy()
			end
		end
		activeESP[player] = nil
	end
end

local function createESP(player)
	if player == localPlayer then return end
	removeESP(player)

	-- 1. Khung hình chữ nhật
	local boxGui = Instance.new("BillboardGui")
	boxGui.Name = player.Name .. "_Box"
	boxGui.AlwaysOnTop = true
	boxGui.Size = UDim2.new(4, 0, 5.5, 0)
	boxGui.Parent = espContainer

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = boxGui

	local stroke = Instance.new("UIStroke")
	stroke.Color = CONFIG.BoxColor
	stroke.Thickness = CONFIG.BoxThickness
	stroke.Parent = frame

	-- 2. Nhãn Tên, HP và Khoảng cách
	local infoGui = Instance.new("BillboardGui")
	infoGui.Name = player.Name .. "_Info"
	infoGui.AlwaysOnTop = true
	infoGui.Size = UDim2.new(0, 200, 0, 40)
	infoGui.StudsOffset = Vector3.new(0, 3.5, 0)
	infoGui.Parent = espContainer

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = CONFIG.TextColor
	textLabel.TextStrokeTransparency = 0.2
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = CONFIG.TextSize
	textLabel.Text = ""
	textLabel.Parent = infoGui

	-- 3. Các thanh que nối xương
	local lines = {}
	for i = 1, #R15_BONES do
		table.insert(lines, createLine())
	end

	activeESP[player] = {
		BoxGui = boxGui,
		InfoGui = infoGui,
		Label = textLabel,
		Stroke = stroke,
		Lines = lines,
	}
end

-- Vòng lặp cập nhật ESP mỗi khung hình
RunService.RenderStepped:Connect(function()
	camera = Workspace.CurrentCamera
	local myChar = localPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	for player, data in pairs(activeESP) do
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")

		if CONFIG.Enabled and char and root and humanoid and humanoid.Health > 0 then
			-- Xử lý Khung chữ nhật (Box)
			data.BoxGui.Adornee = root
			data.BoxGui.Enabled = CONFIG.ShowBox

			if CONFIG.ColorByHP then
				local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
				data.Stroke.Color = Color3.fromHSV(hpPercent * 0.33, 1, 1)
			else
				data.Stroke.Color = CONFIG.BoxColor
			end

			-- Xử lý Thông tin chữ (Tên, HP, Khoảng cách)
			data.InfoGui.Adornee = root
			data.InfoGui.Enabled = CONFIG.ShowInfo

			if CONFIG.ShowInfo then
				local currentHP = math.floor(humanoid.Health)
				local maxHP = math.floor(humanoid.MaxHealth)
				local distance = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0

				data.Label.TextColor3 = CONFIG.TextColor
				data.Label.Text = string.format(
					"%s\nHP: %d/%d | %dm",
					player.DisplayName,
					currentHP,
					maxHP,
					distance
				)
			end

			-- Xử lý ESP Que (Skeleton)
			if CONFIG.ShowSkeleton then
				local boneList = (humanoid.RigType == Enum.HumanoidRigType.R15) and R15_BONES or R6_BONES
				for i, line in ipairs(data.Lines) do
					local bonePair = boneList[i]
					if bonePair then
						local part1 = char:FindFirstChild(bonePair[1])
						local part2 = char:FindFirstChild(bonePair[2])

						if part1 and part2 then
							local pos1, onScreen1 = camera:WorldToViewportPoint(part1.Position)
							local pos2, onScreen2 = camera:WorldToViewportPoint(part2.Position)

							if (onScreen1 or onScreen2) and pos1.Z > 0 and pos2.Z > 0 then
								updateLine(line, pos1, pos2, CONFIG.SkeletonColor)
							else
								line.Visible = false
							end
						else
							line.Visible = false
						end
					else
						line.Visible = false
					end
				end
			else
				for _, line in ipairs(data.Lines) do
					line.Visible = false
				end
			end
		else
			-- Ẩn tất cả khi tắt ESP hoặc nhân vật không hợp lệ
			data.BoxGui.Enabled = false
			data.InfoGui.Enabled = false
			for _, line in ipairs(data.Lines) do
				line.Visible = false
			end
		end
	end
end)

-- Gắn ESP cho người chơi hiện tại và người chơi mới
for _, player in ipairs(Players:GetPlayers()) do
	createESP(player)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

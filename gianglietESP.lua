local P, RS, UIS, W = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), game:GetService("Workspace")
local lp, cam = P.LocalPlayer, W.CurrentCamera
local function N(c, p) local i = Instance.new(c) for k, v in pairs(p) do i[k] = v end return i end

-- Xóa bản cũ nếu chạy lại nhiều lần
if lp:WaitForChild("PlayerGui"):FindFirstChild("GiangLiet_ESP_Gui") then
	pcall(function() RS:UnbindFromRenderStep("GiangLiet_Render") end)
	lp.PlayerGui.GiangLiet_ESP_Gui:Destroy()
end

local gui = N("ScreenGui", {Name = "GiangLiet_ESP_Gui", IgnoreGuiInset = true, ResetOnSpawn = false, Parent = lp:WaitForChild("PlayerGui")})
local folder = N("Frame", {Name = "GiangLiet_ESP_Elements", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = gui})

local hasMouseMoveRel = (typeof(mousemoverel) == "function")

local CFG = {
	Title = "GIANG LIỆT ESP",
	-- Cấu hình ESP
	Enabled = true,
	ShowBox = true,
	ShowInfo = true,
	ShowSkeleton = true,
	ColorByHP = false,
	BoxColor = Color3.fromRGB(0, 255, 127),
	SkeletonColor = Color3.new(1, 1, 1),
	TextColor = Color3.new(1, 1, 1),

	-- Cấu hình Aimlock & FOV
	AimEnabled = false,
	AimMethod = hasMouseMoveRel and 1 or 2, -- 1: Kéo chuột (Chuẩn tay súng), 2: Khóa Camera
	AimSpeed = 5, -- Tốc độ kéo tâm (1 -> 10)
	ShowFOV = true,
	FOVRadius = 120,
	FOVColor = Color3.fromRGB(255, 255, 255),
	AimPartMode = 1, -- 1: Đầu, 2: Thân, 3: Chân, 4: Gần tâm nhất
	AimBindType = "Mouse",
	AimBind = Enum.UserInputType.MouseButton2,

	-- Phím đóng/mở Menu
	Key = Enum.KeyCode.RightShift
}

local AIM_PARTS = {
	{Name = "Đầu (Head)", Mode = "Head"},
	{Name = "Thân (Torso)", Mode = "Torso"},
	{Name = "Chân (Leg)", Mode = "Leg"},
	{Name = "Gần tâm nhất", Mode = "Closest"}
}

local AIM_METHODS = {
	"Chuột (Chuẩn súng)",
	"Camera + Xoay người"
}

local PAL = {
	{N = "Xanh lá", C = Color3.fromRGB(0, 255, 127)},
	{N = "Trắng", C = Color3.new(1, 1, 1)},
	{N = "Đỏ", C = Color3.fromRGB(255, 65, 65)},
	{N = "Vàng", C = Color3.fromRGB(255, 230, 0)},
	{N = "Xanh dương", C = Color3.fromRGB(0, 190, 255)},
	{N = "Tím", C = Color3.fromRGB(185, 80, 255)},
	{N = "Cam", C = Color3.fromRGB(255, 140, 0)}
}

local bindingMenuKey, bindingAimKey, active = false, false, {}

-- Vòng tròn FOV
local fovCircle = N("Frame", {
	Name = "FOVCircle",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(CFG.FOVRadius * 2, CFG.FOVRadius * 2),
	BackgroundTransparency = 1,
	Visible = CFG.ShowFOV,
	Parent = folder
})
N("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fovCircle})
local fovStroke = N("UIStroke", {Color = CFG.FOVColor, Thickness = 1.5, Parent = fovCircle})

-- ==========================================
-- GIAO DIỆN MENU ĐIỀU KHIỂN
-- ==========================================
local menu = N("Frame", {Size = UDim2.fromOffset(285, 430), Position = UDim2.new(0, 30, 0.5, -215), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Active = true, Parent = gui})
N("UICorner", {CornerRadius = UDim.new(0, 8), Parent = menu})
N("UIStroke", {Color = Color3.fromRGB(60, 60, 70), Parent = menu})

local top = N("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Color3.fromRGB(35, 35, 42), Parent = menu})
N("UICorner", {CornerRadius = UDim.new(0, 8), Parent = top})
local titleLbl = N("TextLabel", {Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Text = CFG.Title.." ["..CFG.Key.Name.."]", TextColor3 = Color3.fromRGB(0, 255, 127), Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = top})

local drag, dInput, dStart, sPos
top.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		drag, dStart, sPos = true, inp.Position, menu.Position
		inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then drag = false end end)
	end
end)
top.InputChanged:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then dInput = inp end
end)
UIS.InputChanged:Connect(function(inp)
	if inp == dInput and drag then
		local d = inp.Position - dStart
		menu.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
	end
end)

local holder = N("ScrollingFrame", {
	Size = UDim2.new(1, -16, 1, -44),
	Position = UDim2.fromOffset(8, 40),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = Color3.fromRGB(0, 255, 127),
	CanvasSize = UDim2.new(0, 0, 0, 620),
	Parent = menu
})
local listLayout = N("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder})
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	holder.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

local function makeRow(txt, order)
	local b = N("TextButton", {LayoutOrder = order, Size = UDim2.new(1, -6, 0, 30), BackgroundColor3 = Color3.fromRGB(40, 40, 48), Text = "", AutoButtonColor = false, Parent = holder})
	N("UICorner", {CornerRadius = UDim.new(0, 6), Parent = b})
	N("TextLabel", {Size = UDim2.new(1, -115, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Text = txt, TextColor3 = Color3.fromRGB(220, 220, 220), Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = b})
	return b
end

local function addToggle(txt, k, order)
	local b = makeRow(txt, order)
	local st = N("Frame", {Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -48, 0.5, -10), BackgroundColor3 = Color3.fromRGB(0, 200, 100), Parent = b})
	N("UICorner", {CornerRadius = UDim.new(1, 0), Parent = st})
	local function upd() st.BackgroundColor3 = CFG[k] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 90) end
	b.MouseButton1Click:Connect(function() CFG[k] = not CFG[k] upd() end)
	upd()
end

local function addColor(txt, k, idx, order)
	local b = makeRow(txt, order)
	local prv = N("TextLabel", {Size = UDim2.fromOffset(80, 20), Position = UDim2.new(1, -88, 0.5, -10), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(20, 20, 20), Parent = b})
	N("UICorner", {CornerRadius = UDim.new(0, 4), Parent = prv})
	local function set() CFG[k], prv.BackgroundColor3, prv.Text = PAL[idx].C, PAL[idx].C, PAL[idx].N end
	b.MouseButton1Click:Connect(function() idx = (idx % #PAL) + 1 set() end)
	set()
end

-- Các mục ESP
addToggle("Bật toàn bộ ESP", "Enabled", 1)
addToggle("Hiện Khung chữ nhật (Box)", "ShowBox", 2)
addToggle("Hiện Tên, HP & Khoảng cách", "ShowInfo", 3)
addToggle("Hiện Xương bộ phận (Que)", "ShowSkeleton", 4)
addToggle("Màu khung tự đổi theo % HP", "ColorByHP", 5)
addColor("Màu Khung:", "BoxColor", 1, 6)
addColor("Màu Xương:", "SkeletonColor", 2, 7)
addColor("Màu Chữ:", "TextColor", 2, 8)

-- Các mục Aimlock & FOV
addToggle("Bật Aimlock", "AimEnabled", 9)

local methodRow = makeRow("Kiểu Aim:", 10)
local methodBadge = N("TextLabel", {Size = UDim2.fromOffset(110, 20), Position = UDim2.new(1, -118, 0.5, -10), BackgroundColor3 = Color3.fromRGB(60, 60, 72), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Color3.fromRGB(0, 255, 127), Text = AIM_METHODS[CFG.AimMethod], Parent = methodRow})
N("UICorner", {CornerRadius = UDim.new(0, 4), Parent = methodBadge})
methodRow.MouseButton1Click:Connect(function()
	CFG.AimMethod = (CFG.AimMethod % #AIM_METHODS) + 1
	methodBadge.Text = AIM_METHODS[CFG.AimMethod]
end)

-- Tốc độ / Độ nhạy kéo tâm
local spdRow = makeRow("Độ nhạy kéo tâm:", 11)
local spdMinus = N("TextButton", {Size = UDim2.fromOffset(24, 22), Position = UDim2.new(1, -98, 0.5, -11), BackgroundColor3 = Color3.fromRGB(60, 60, 72), Text = "-", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 14, Parent = spdRow})
N("UICorner", {CornerRadius = UDim.new(0, 4), Parent = spdMinus})
local spdValLbl = N("TextLabel", {Size = UDim2.fromOffset(40, 22), Position = UDim2.new(1, -72, 0.5, -11), BackgroundTransparency = 1, Text = tostring(CFG.AimSpeed).."/10", TextColor3 = Color3.fromRGB(0, 255, 127), Font = Enum.Font.GothamBold, TextSize = 12, Parent = spdRow})
local spdPlus = N("TextButton", {Size = UDim2.fromOffset(24, 22), Position = UDim2.new(1, -30, 0.5, -11), BackgroundColor3 = Color3.fromRGB(60, 60, 72), Text = "+", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 14, Parent = spdRow})
N("UICorner", {CornerRadius = UDim.new(0, 4), Parent = spdPlus})

spdMinus.MouseButton1Click:Connect(function()
	CFG.AimSpeed = math.clamp(CFG.AimSpeed - 1, 1, 10)
	spdValLbl.Text = tostring(CFG.AimSpeed).."/10"
end)
spdPlus.MouseButton1Click:Connect(function()
	CFG.AimSpeed = math.clamp(CFG.AimSpeed + 1, 1, 10)
	spdValLbl.Text = tostring(CFG.AimSpeed).."/10"
end)

addToggle("Hiện viền vòng tròn FOV", "ShowFOV", 12)

local fovRow = makeRow("Kích thước FOV:", 13)
local btnMinus = N("TextButton", {Size = UDim2.fromOffset(24, 22), Position = UDim2.new(1, -98, 0.5, -11), BackgroundColor3 = Color3.fromRGB(60, 60, 72), Text = "-", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 14, Parent = fovRow})
N("UICorner", {CornerRadius = UDim.new(0, 4), Parent = btnMinus})
local fovValLbl = N("TextLabel", {Size = UDim2.fromOffset(40, 22), Position = UDim2.new(1, -72, 0.5, -11), BackgroundTransparency = 1, Text = tostring(CFG.FOVRadius), TextColor3 = Color3.fromRGB(0, 255, 127), Font = Enum.Font.GothamBold, TextSize = 12, Parent = fovRow})
local btnPlus = N("TextButton", {Size = UDim2.fromOffset(24, 22), Position = UDim2.new(1, -30, 0.5, -11), BackgroundColor3 = Color3.fromRGB(60, 60, 72), Text = "+", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 14, Parent = fovRow})
N("UICorner", {CornerRadius = UDim.new(0, 4), Parent = btnPlus})

btnMinus.MouseButton1Click:Connect(function()
	CFG.FOVRadius = math.clamp(CFG.FOVRadius - 15, 30, 500)
	fovValLbl.Text = tostring(CFG.FOVRadius)
end)
btnPlus.MouseButton1Click:Connect(function()
	CFG.FOVRadius = math.clamp(CFG.FOVRadius + 15, 30, 500)
	fovValLbl.Text = tostring(CFG.FOVRadius)
end)

local partRow = makeRow("Vùng Aimlock:", 14)
local partBadge = N("TextLabel", {Size = UDim2.fromOffset(90, 20), Position = UDim2.new(1, -98, 0.5, -10), BackgroundColor3 = Color3.fromRGB(60, 60, 72), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(0, 255, 127), Text = AIM_PARTS[CFG.AimPartMode].Name, Parent = partRow})
N("UICorner", {CornerRadius = UDim.new(0, 4), Parent = partBadge})
partRow.MouseButton1Click:Connect(function()
	CFG.AimPartMode = (CFG.AimPartMode % #AIM_PARTS) + 1
	partBadge.Text = AIM_PARTS[CFG.AimPartMode].Name
end)

addColor("Màu vòng FOV:", "FOVColor", 2, 15)

local aimKeyRow = makeRow("Phím giữ Aimlock:", 16)
local aimKeyBadge = N("TextLabel", {Size = UDim2.fromOffset(90, 20), Position = UDim2.new(1, -98, 0.5, -10), BackgroundColor3 = Color3.fromRGB(60, 60, 72), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(240, 240, 240), Text = "MouseButton2", Parent = aimKeyRow})
N("UICorner", {CornerRadius = UDim.new(0, 4), Parent = aimKeyBadge})
aimKeyRow.MouseButton1Click:Connect(function()
	if not bindingAimKey and not bindingMenuKey then
		bindingAimKey, aimKeyBadge.Text, aimKeyBadge.BackgroundColor3, aimKeyBadge.TextColor3 = true, "[Nhấn phím...]", Color3.fromRGB(230, 150, 0), Color3.fromRGB(20, 20, 20)
	end
end)

local kbBtn = makeRow("Phím đóng/mở Menu:", 17)
local kbBadge = N("TextLabel", {Size = UDim2.fromOffset(90, 20), Position = UDim2.new(1, -98, 0.5, -10), BackgroundColor3 = Color3.fromRGB(60, 60, 72), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(240, 240, 240), Text = CFG.Key.Name, Parent = kbBtn})
N("UICorner", {CornerRadius = UDim.new(0, 4), Parent = kbBadge})
kbBtn.MouseButton1Click:Connect(function()
	if not bindingMenuKey and not bindingAimKey then
		bindingMenuKey, kbBadge.Text, kbBadge.BackgroundColor3, kbBadge.TextColor3 = true, "[Nhấn phím...]", Color3.fromRGB(230, 150, 0), Color3.fromRGB(20, 20, 20)
	end
end)

UIS.InputBegan:Connect(function(inp, gpe)
	if bindingMenuKey then
		if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode ~= Enum.KeyCode.Unknown then
			if inp.KeyCode ~= Enum.KeyCode.Escape then
				CFG.Key = inp.KeyCode
				titleLbl.Text = CFG.Title.." ["..CFG.Key.Name.."]"
			end
			kbBadge.Text, kbBadge.BackgroundColor3, kbBadge.TextColor3 = CFG.Key.Name, Color3.fromRGB(60, 60, 72), Color3.fromRGB(240, 240, 240)
			task.defer(function() bindingMenuKey = false end)
		end
		return
	elseif bindingAimKey then
		if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode ~= Enum.KeyCode.Unknown then
			if inp.KeyCode ~= Enum.KeyCode.Escape then
				CFG.AimBindType = "Key"
				CFG.AimBind = inp.KeyCode
			end
			aimKeyBadge.Text, aimKeyBadge.BackgroundColor3, aimKeyBadge.TextColor3 = CFG.AimBind.Name, Color3.fromRGB(60, 60, 72), Color3.fromRGB(240, 240, 240)
			task.defer(function() bindingAimKey = false end)
		elseif inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.MouseButton2 or inp.UserInputType == Enum.UserInputType.MouseButton3 then
			CFG.AimBindType = "Mouse"
			CFG.AimBind = inp.UserInputType
			aimKeyBadge.Text, aimKeyBadge.BackgroundColor3, aimKeyBadge.TextColor3 = CFG.AimBind.Name, Color3.fromRGB(60, 60, 72), Color3.fromRGB(240, 240, 240)
			task.defer(function() bindingAimKey = false end)
		end
		return
	end

	if not gpe and inp.KeyCode == CFG.Key then
		menu.Visible = not menu.Visible
	end
end)

-- ==========================================
-- XỬ LÝ ESP & AIMLOCK ĐỒNG BỘ KHUNG HÌNH
-- ==========================================
local R15 = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local R6 = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"},{"Torso","LeftArm"},{"Torso","RightArm"},{"Torso","LeftLeg"},{"Torso","RightLeg"}}

local function getJoints(c)
	local list = {}
	if c:FindFirstChild("UpperTorso") then
		for _, bp in ipairs(R15) do
			local p1, p2 = c:FindFirstChild(bp[1]), c:FindFirstChild(bp[2])
			if p1 and p2 then table.insert(list, {p1, p2}) end
		end
	elseif c:FindFirstChild("Torso") then
		for _, bp in ipairs(R6) do
			local p1, p2 = c:FindFirstChild(bp[1]), c:FindFirstChild(bp[2])
			if p1 and p2 then table.insert(list, {p1, p2}) end
		end
	end
	if #list == 0 then
		for _, d in ipairs(c:GetDescendants()) do
			if d:IsA("Motor6D") and d.Part0 and d.Part1 and d.Part0.Name ~= "HumanoidRootPart" and d.Part1.Name ~= "HumanoidRootPart" then
				table.insert(list, {d.Part0, d.Part1})
			end
		end
	end
	return list
end

local function getTargetPart(char, refPos)
	local mode = AIM_PARTS[CFG.AimPartMode].Mode
	if mode == "Head" then
		return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	elseif mode == "Torso" then
		return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
	elseif mode == "Leg" then
		return char:FindFirstChild("LeftLowerLeg") or char:FindFirstChild("Left Leg") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
	elseif mode == "Closest" then
		local bestPart, bestDist = nil, math.huge
		local candidates = {"Head", "UpperTorso", "Torso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}
		for _, name in ipairs(candidates) do
			local p = char:FindFirstChild(name)
			if p then
				local v, onScreen = cam:WorldToViewportPoint(p.Position)
				if onScreen and v.Z > 0 then
					local dist = (Vector2.new(v.X, v.Y) - refPos).Magnitude
					if dist < bestDist then
						bestDist, bestPart = dist, p
					end
				end
			end
		end
		return bestPart
	end
end

local function isAimKeyPressed()
	if bindingAimKey or bindingMenuKey then return false end
	if CFG.AimBindType == "Mouse" then
		return UIS:IsMouseButtonPressed(CFG.AimBind)
	else
		return UIS:IsKeyDown(CFG.AimBind)
	end
end

local function delESP(p)
	if active[p] then
		active[p].B:Destroy()
		active[p].I:Destroy()
		for _, l in ipairs(active[p].L) do l:Destroy() end
		active[p] = nil
	end
end

local function addESP(p)
	if p == lp then return end
	delESP(p)
	local bGui = N("BillboardGui", {AlwaysOnTop = true, Size = UDim2.new(4, 0, 5.5, 0), Parent = folder})
	local st = N("UIStroke", {Color = CFG.BoxColor, Thickness = 1.5, Parent = N("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = bGui})})
	local iGui = N("BillboardGui", {AlwaysOnTop = true, Size = UDim2.fromOffset(200, 40), StudsOffset = Vector3.new(0, 3.5, 0), Parent = folder})
	local lbl = N("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextStrokeTransparency = 0.2, Font = Enum.Font.GothamBold, TextSize = 13, Parent = iGui})
	local lines = {}
	for i = 1, 20 do lines[i] = N("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, ZIndex = 5, Visible = false, Parent = folder}) end
	active[p] = {B = bGui, I = iGui, Lbl = lbl, St = st, L = lines}
end

-- Chạy ở RenderPriority.Camera.Value + 10 để lấy đúng Camera sau khi game cập nhật
RS:BindToRenderStep("GiangLiet_Render", Enum.RenderPriority.Camera.Value + 10, function()
	cam = W.CurrentCamera
	if not cam then return end

	-- Nếu chuột bị khóa tâm (First Person / Shiftlock / ADS), lấy tâm màn hình hoặc vị trí chuột
	local mousePos = UIS:GetMouseLocation()
	fovCircle.Visible = CFG.ShowFOV
	fovCircle.Position = UDim2.fromOffset(mousePos.X, mousePos.Y)
	fovCircle.Size = UDim2.fromOffset(CFG.FOVRadius * 2, CFG.FOVRadius * 2)
	fovStroke.Color = CFG.FOVColor

	local myChar = lp.Character
	local myR = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar.PrimaryPart or myChar:FindFirstChildWhichIsA("BasePart"))

	-- BƯỚC 1: TÌM MỤC TIÊU AIMLOCK VÀ KHÓA TÂM TRƯỚC KHI VẼ ESP
	if CFG.AimEnabled and isAimKeyPressed() then
		local closestAimPart, closestScreenPos = nil, nil
		local shortestFovDist = CFG.FOVRadius

		for p, _ in pairs(active) do
			local c = p.Character
			local r = c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso") or c.PrimaryPart)
			local h = c and c:FindFirstChildOfClass("Humanoid")
			local alive = (h and h.Health > 0) or (not h and r ~= nil)

			if c and r and alive then
				local tp = getTargetPart(c, mousePos)
				if tp then
					local v, onScreen = cam:WorldToViewportPoint(tp.Position)
					if onScreen and v.Z > 0 then
						local screenPt = Vector2.new(v.X, v.Y)
						local dist = (screenPt - mousePos).Magnitude
						if dist <= shortestFovDist then
							shortestFovDist = dist
							closestAimPart = tp
							closestScreenPos = screenPt
						end
					end
				end
			end
		end

		if closestAimPart and closestScreenPos then
			local factor = CFG.AimSpeed / 10
			if CFG.AimMethod == 1 and typeof(mousemoverel) == "function" then
				-- Kiểu 1: Dịch chuyển chuột thực tế -> Tay cầm súng, nòng súng và Camera quay cùng nhau 100%
				local dx = (closestScreenPos.X - mousePos.X) * factor
				local dy = (closestScreenPos.Y - mousePos.Y) * factor
				mousemoverel(dx, dy)
			else
				-- Kiểu 2: Xoay đồng thời cả Camera và thân nhân vật (HumanoidRootPart) để tay súng hướng theo
				local targetCFrame = CFrame.new(cam.CFrame.Position, closestAimPart.Position)
				cam.CFrame = cam.CFrame:Lerp(targetCFrame, factor)
				if myR then
					local flatTarget = Vector3.new(closestAimPart.Position.X, myR.Position.Y, closestAimPart.Position.Z)
					if (flatTarget - myR.Position).Magnitude > 0.1 then
						myR.CFrame = myR.CFrame:Lerp(CFrame.new(myR.Position, flatTarget), factor)
					end
				end
			end
		end
	end

	-- BƯỚC 2: VẼ ESP SAU KHI CAMERA ĐÃ CỐ ĐỊNH (ĐẢM BẢO XƯƠNG QUE VÀ BOX KHỚP 100%)
	for p, d in pairs(active) do
		local c = p.Character
		local r = c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso") or c.PrimaryPart)
		local h = c and c:FindFirstChildOfClass("Humanoid")
		local alive = (h and h.Health > 0) or (not h and r ~= nil)

		if CFG.Enabled and c and r and alive then
			local hp, maxHp = h and h.Health or 100, (h and h.MaxHealth > 0) and h.MaxHealth or 100
			d.B.Adornee, d.B.Enabled = r, CFG.ShowBox
			d.St.Color = CFG.ColorByHP and Color3.fromHSV(math.clamp(hp / maxHp, 0, 1) * 0.33, 1, 1) or CFG.BoxColor
			d.I.Adornee, d.I.Enabled = r, CFG.ShowInfo
			if CFG.ShowInfo then
				d.Lbl.TextColor3 = CFG.TextColor
				d.Lbl.Text = string.format("%s\nHP: %d/%d | %dm", p.DisplayName, hp, maxHp, myR and (myR.Position - r.Position).Magnitude or 0)
			end
			if CFG.ShowSkeleton then
				local joints = getJoints(c)
				for i, ln in ipairs(d.L) do
					local pair = joints[i]
					if pair then
						local v1, s1 = cam:WorldToViewportPoint(pair[1].Position)
						local v2, s2 = cam:WorldToViewportPoint(pair[2].Position)
						if (s1 or s2) and v1.Z > 0 and v2.Z > 0 then
							local dx, dy = v2.X - v1.X, v2.Y - v1.Y
							ln.Position = UDim2.fromOffset((v1.X + v2.X) / 2, (v1.Y + v2.Y) / 2)
							ln.Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy), 1.5)
							ln.Rotation = math.deg(math.atan2(dy, dx))
							ln.BackgroundColor3 = CFG.SkeletonColor
							ln.Visible = true
						else ln.Visible = false end
					else ln.Visible = false end
				end
			else
				for _, ln in ipairs(d.L) do ln.Visible = false end
			end
		else
			d.B.Enabled, d.I.Enabled = false, false
			for _, ln in ipairs(d.L) do ln.Visible = false end
		end
	end
end)

for _, p in ipairs(P:GetPlayers()) do addESP(p) end
P.PlayerAdded:Connect(addESP)
P.PlayerRemoving:Connect(delESP)

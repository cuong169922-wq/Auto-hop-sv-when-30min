--[[
    BLOX FRUITS SEA 3 AUTO HOP
    Dành cho Arceus X
    - Auto hop mỗi 30 phút vào server 3-4 người
    - Nút bật/tắt chỉ để ẩn/hiện MENU, không tắt auto hop
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- CẤU HÌNH
local CONFIG = {
    HopInterval = 1800,  -- 30 phút
    MinPlayers = 3,
    MaxPlayers = 4,
    HopDelay = 3
}

-- Hàm wait an toàn cho Arceus
local function SafeWait(seconds)
    local start = tick()
    repeat task.wait() until tick() - start >= seconds
end

-- TẠO MENU (chỉ để hiển thị thông tin)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoHopUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 220)
mainFrame.Position = UDim2.new(0.02, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Tiêu đề
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
title.Text = "⚡ AUTO HOP 30 PHÚT ⚡"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Nút thu nhỏ menu (CHỈ ẨN/HIỆN MENU, KHÔNG TẮT AUTO HOP)
local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Size = UDim2.new(0, 30, 0, 30)
toggleMenuBtn.Position = UDim2.new(1, -35, 0, 3)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleMenuBtn.Text = "🗕"
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleMenuBtn.TextScaled = true
toggleMenuBtn.Font = Enum.Font.GothamBold
toggleMenuBtn.Parent = title

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleMenuBtn

-- Panel thông tin
local infoPanel = Instance.new("Frame")
infoPanel.Size = UDim2.new(0.94, 0, 0, 110)
infoPanel.Position = UDim2.new(0.03, 0, 0, 45)
infoPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
infoPanel.BackgroundTransparency = 0.6
infoPanel.Parent = mainFrame

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = infoPanel

-- Số người chơi
local playerCountText = Instance.new("TextLabel")
playerCountText.Size = UDim2.new(1, 0, 0, 35)
playerCountText.Position = UDim2.new(0, 0, 0, 5)
playerCountText.BackgroundTransparency = 1
playerCountText.TextColor3 = Color3.fromRGB(255, 255, 255)
playerCountText.Text = "👥 Người chơi: --"
playerCountText.TextScaled = true
playerCountText.Font = Enum.Font.Gotham
playerCountText.Parent = infoPanel

-- Thời gian trong server
local timeText = Instance.new("TextLabel")
timeText.Size = UDim2.new(1, 0, 0, 35)
timeText.Position = UDim2.new(0, 0, 0, 40)
timeText.BackgroundTransparency = 1
timeText.TextColor3 = Color3.fromRGB(100, 200, 255)
timeText.Text = "⏱️ Thời gian: 00:00:00"
timeText.TextScaled = true
timeText.Font = Enum.Font.Gotham
timeText.Parent = infoPanel

-- Trạng thái
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 30)
statusText.Position = UDim2.new(0, 0, 0, 75)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
statusText.Text = "🟢 Auto hop đang chạy..."
statusText.TextScaled = true
statusText.Font = Enum.Font.Gotham
statusText.Parent = infoPanel

-- Nút Hop ngay
local hopBtn = Instance.new("TextButton")
hopBtn.Size = UDim2.new(0.9, 0, 0, 40)
hopBtn.Position = UDim2.new(0.05, 0, 0, 165)
hopBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
hopBtn.Text = "🔄 HOP NGAY"
hopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hopBtn.TextScaled = true
hopBtn.Font = Enum.Font.GothamBold
hopBtn.Parent = mainFrame

hopBtnCorner = Instance.new("UICorner")
hopBtnCorner.CornerRadius = UDim.new(0, 6)
hopBtnCorner.Parent = hopBtn

-- ============ HÀM CHÍNH ============
local joinTime = os.time()

local function GetServerList()
    local servers = {}
    local success, result = pcall(function()
        local data = game:HttpGet("https://games.roblox.com/v1/games/2753915549/servers/Public?limit=100")
        return HttpService:JSONDecode(data)
    end)
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            local playerCount = server.playing
            if playerCount >= CONFIG.MinPlayers and playerCount <= CONFIG.MaxPlayers then
                table.insert(servers, server.id)
            end
        end
    end
    return servers
end

local function HopServer()
    statusText.Text = "🔍 Đang tìm server 3-4 người..."
    local servers = GetServerList()
    if #servers > 0 then
        local targetId = servers[math.random(1, #servers)]
        statusText.Text = "✅ Tìm thấy! Đang hop..."
        SafeWait(CONFIG.HopDelay)
        TeleportService:TeleportToPlaceInstance(2753915549, targetId, LocalPlayer)
    else
        statusText.Text = "❌ Không tìm thấy server 3-4 người"
        SafeWait(5)
        statusText.Text = "🟢 Auto hop đang chạy..."
    end
end

-- ============ VÒNG LẶP AUTO HOP ============
spawn(function()
    while true do
        -- Cập nhật UI
        local currentPlayers = #Players:GetPlayers()
        playerCountText.Text = "👥 Người chơi: " .. currentPlayers
        
        local elapsed = os.time() - joinTime
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = elapsed % 60
        timeText.Text = string.format("⏱️ Thời gian: %02d:%02d:%02d", hours, minutes, seconds)
        
        -- Kiểm tra auto hop
        if elapsed >= CONFIG.HopInterval or currentPlayers < CONFIG.MinPlayers or currentPlayers > CONFIG.MaxPlayers then
            HopServer()
            joinTime = os.time()  -- Reset timer sau khi hop
        end
        
        task.wait(1)
    end
end)

-- Nút thu nhỏ menu (CHỈ ẨN MENU, KHÔNG TẮT AUTO HOP)
toggleMenuBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Nút hop ngay
hopBtn.MouseButton1Click:Connect(function()
    HopServer()
    joinTime = os.time()
end)

print("=== AUTO HOP ĐÃ CHẠY ===")
print("Nút đỏ chỉ để ẩn menu, auto hop vẫn chạy ngầm!")

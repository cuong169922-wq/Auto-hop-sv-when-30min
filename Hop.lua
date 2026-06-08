--[[
    BLOX FRUITS SEA 3 AUTO HOP SCRIPT
    Tối ưu dành riêng cho Arceus X Executor
    Chức năng: Hop server 3-4 người mỗi 30 phút, hiển thị thời gian, menu bật/tắt
--]]

-- ============ CẤU HÌNH ============
local CONFIG = {
    HopInterval = 1800,        -- 30 phút
    MinPlayers = 3,
    MaxPlayers = 4,
    HopDelay = 3
}

-- ============ KIỂM TRA MÔI TRƯỜNG ============
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Fix cho Arceus X: Tạo hàm wait an toàn hơn
local function SafeWait(seconds)
    local start = tick()
    repeat
        task.wait()
    until tick() - start >= seconds
end

-- ============ TẠO MENU ============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ArceusHopMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 280)
mainFrame.Position = UDim2.new(0.02, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title Bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
title.Text = "🔥 ARCEUS X AUTO HOP 🔥"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- Info Panel
local infoPanel = Instance.new("Frame")
infoPanel.Size = UDim2.new(0.94, 0, 0, 130)
infoPanel.Position = UDim2.new(0.03, 0, 0, 50)
infoPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
infoPanel.BackgroundTransparency = 0.6
infoPanel.Parent = mainFrame

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = infoPanel

-- Player Count
local playerCountText = Instance.new("TextLabel")
playerCountText.Size = UDim2.new(1, 0, 0, 40)
playerCountText.Position = UDim2.new(0, 0, 0, 5)
playerCountText.BackgroundTransparency = 1
playerCountText.TextColor3 = Color3.fromRGB(255, 255, 255)
playerCountText.Text = "👥 Người chơi: Đang tải..."
playerCountText.TextScaled = true
playerCountText.Font = Enum.Font.Gotham
playerCountText.Parent = infoPanel

-- Time Display
local timeText = Instance.new("TextLabel")
timeText.Size = UDim2.new(1, 0, 0, 40)
timeText.Position = UDim2.new(0, 0, 0, 45)
timeText.BackgroundTransparency = 1
timeText.TextColor3 = Color3.fromRGB(100, 200, 255)
timeText.Text = "⏱️ Thời gian: 00:00:00"
timeText.TextScaled = true
timeText.Font = Enum.Font.Gotham
timeText.Parent = infoPanel

-- Status
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 40)
statusText.Position = UDim2.new(0, 0, 0, 85)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
statusText.Text = "🟢 Đang hoạt động"
statusText.TextScaled = true
statusText.Font = Enum.Font.Gotham
statusText.Parent = infoPanel

-- Buttons Panel
local btnPanel = Instance.new("Frame")
btnPanel.Size = UDim2.new(0.94, 0, 0, 50)
btnPanel.Position = UDim2.new(0.03, 0, 0, 190)
btnPanel.BackgroundTransparency = 1
btnPanel.Parent = mainFrame

-- Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.48, 0, 1, 0)
toggleBtn.Position = UDim2.new(0, 0, 0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
toggleBtn.Text = "🔛 BẬT"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = btnPanel

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleBtn

-- Hop Now Button
local hopBtn = Instance.new("TextButton")
hopBtn.Size = UDim2.new(0.48, 0, 1, 0)
hopBtn.Position = UDim2.new(0.52, 0, 0, 0)
hopBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
hopBtn.Text = "🔄 HOP NGAY"
hopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hopBtn.TextScaled = true
hopBtn.Font = Enum.Font.GothamBold
hopBtn.Parent = btnPanel

local hopCorner = Instance.new("UICorner")
hopCorner.CornerRadius = UDim.new(0, 6)
hopCorner.Parent = hopBtn

-- Close Button (Thu nhỏ)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "🗕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

-- ============ CÁC HÀM CHÍNH ============
local isEnabled = true
local joinTime = os.time()
local lastHopTime = 0

-- Lấy danh sách server
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

-- Hàm Hop chính
local function HopToBestServer()
    if not isEnabled then return end
    
    statusText.Text = "🔍 Đang tìm server 3-4 người..."
    SafeWait(1)
    
    local servers = GetServerList()
    
    if #servers > 0 then
        local targetId = servers[math.random(1, #servers)]
        statusText.Text = "✅ Đã tìm thấy, đang hop..."
        SafeWait(CONFIG.HopDelay)
        
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(2753915549, targetId, LocalPlayer)
        end)
        
        if success then
            -- Script sẽ tự động stop khi teleport, không cần làm gì thêm
        else
            statusText.Text = "❌ Hop thất bại, thử lại sau"
            SafeWait(2)
            statusText.Text = "🟢 Đang hoạt động"
        end
    else
        statusText.Text = "⚠️ Không tìm thấy server 3-4 người"
        SafeWait(5)
        statusText.Text = "🟢 Đang hoạt động"
    end
end

-- ============ VÒNG LẶP CHÍNH (Tối ưu cho Arceus X) ============
-- Cập nhật UI
spawn(function()
    while true do
        if mainFrame and mainFrame.Parent then
            local playerCount = #Players:GetPlayers()
            playerCountText.Text = "👥 Người chơi: " .. playerCount
            
            local elapsed = os.time() - joinTime
            local hours = math.floor(elapsed / 3600)
            local minutes = math.floor((elapsed % 3600) / 60)
            local seconds = elapsed % 60
            timeText.Text = string.format("⏱️ Thời gian: %02d:%02d:%02d", hours, minutes, seconds)
        end
        task.wait(1)
    end
end)

-- Vòng lặp kiểm tra và auto hop
spawn(function()
    while true do
        if isEnabled then
            local currentPlayers = #Players:GetPlayers()
            local elapsedTime = os.time() - joinTime
            
            -- Kiểm tra nếu đã đủ 30p HOẶC số người không phù hợp
            if elapsedTime >= CONFIG.HopInterval or 
               currentPlayers < CONFIG.MinPlayers or 
               currentPlayers > CONFIG.MaxPlayers then
                
                if os.time() - lastHopTime >= 60 then -- Tránh hop liên tục
                    lastHopTime = os.time()
                    HopToBestServer()
                    joinTime = os.time() -- Reset timer sau khi hop
                    
                    -- Nếu hop thành công, script sẽ dừng ở đây
                    -- Nếu không, vòng lặp vẫn chạy
                end
            end
        end
        task.wait(5) -- Kiểm tra mỗi 5 giây thay vì 1s để tiết kiệm performance
    end
end)

-- ============ XỬ LÝ SỰ KIỆN NÚT ============
toggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        toggleBtn.Text = "🔛 BẬT"
        statusText.Text = "🟢 Đang hoạt động"
        joinTime = os.time() -- Reset timer khi bật lại
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        toggleBtn.Text = "🔴 TẮT"
        statusText.Text = "🔴 Đã tạm dừng"
    end
end)

hopBtn.MouseButton1Click:Connect(function()
    if isEnabled then
        HopToBestServer()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Thông báo khởi động
statusText.Text = "🟢 Sẵn sàng! Auto hop 30 phút"
print("=== Auto Hop Script for Arceus X đã chạy ===")
print("Menu đã hiện, kéo thả để di chuyển")

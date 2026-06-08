--[[
    BLOX FRUITS - AUTO REJOIN (Không cần API)
    - Sau 30 phút tự động rejoin
    - Không cần lấy danh sách server
    - Hoạt động 100% trên Arceus X
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local GameId = 2753915549  -- Blox Fruits

-- Cấu hình
local REJOIN_INTERVAL = 1800  -- 30 phút
local joinTime = os.time()

-- Tạo menu đơn giản
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoRejoin"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.02, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Tiêu đề
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
title.Text = "🔄 AUTO REJOIN 30 PHÚT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Nút thu nhỏ
local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 30, 0, 30)
miniBtn.Position = UDim2.new(1, -35, 0, 3)
miniBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
miniBtn.Text = "━"
miniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
miniBtn.TextScaled = true
miniBtn.Parent = title

-- Thời gian
local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(0.9, 0, 0, 40)
timeLabel.Position = UDim2.new(0.05, 0, 0, 45)
timeLabel.BackgroundTransparency = 1
timeLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
timeLabel.Text = "⏱️ 00:00:00"
timeLabel.TextScaled = true
timeLabel.Font = Enum.Font.Gotham
timeLabel.Parent = frame

-- Trạng thái
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0, 90)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.Text = "🟢 Đang chạy..."
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = frame

-- Nút Rejoin ngay
local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Size = UDim2.new(0.8, 0, 0, 35)
rejoinBtn.Position = UDim2.new(0.1, 0, 0, 125)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
rejoinBtn.Text = "🔄 REJOIN NGAY"
rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rejoinBtn.TextScaled = true
rejoinBtn.Font = Enum.Font.GothamBold
rejoinBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 5)
btnCorner.Parent = rejoinBtn

-- Hàm Rejoin (không cần API)
local function RejoinGame()
    statusLabel.Text = "🔄 Đang rejoin..."
    task.wait(2)
    
    -- Cách 1: Teleport lại chính game (rejoin cùng server hoặc server khác)
    TeleportService:Teleport(GameId, LocalPlayer)
    
    -- Nếu cách 1 không dùng được, thử cách 2:
    -- game:Shutdown()
    -- task.wait(1)
    -- TeleportService:Teleport(GameId)
end

-- Cập nhật thời gian
spawn(function()
    while frame and frame.Parent do
        local elapsed = os.time() - joinTime
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = elapsed % 60
        timeLabel.Text = string.format("⏱️ %02d:%02d:%02d", hours, minutes, seconds)
        
        -- Auto rejoin sau 30 phút
        if elapsed >= REJOIN_INTERVAL then
            RejoinGame()
            joinTime = os.time()
        end
        
        task.wait(1)
    end
end)

-- Ẩn/hiện menu
local menuVisible = true
miniBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    frame.Visible = menuVisible
end)

-- Rejoin ngay
rejoinBtn.MouseButton1Click:Connect(function()
    RejoinGame()
    joinTime = os.time()
end)

print("=== AUTO REJOIN ĐÃ CHẠY ===")
print("Sau 30 phút sẽ tự động rejoin game")

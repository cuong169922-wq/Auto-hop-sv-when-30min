--[[
    BLOX FRUITS - AUTO KICK & REJOIN
    Cách hoạt động: Tự kick bản thân -> game báo "Please rejoin" -> tự động rejoin
    KHÔNG lỗi dịch chuyển!
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local GameId = 2753915549

-- Cấu hình
local REJOIN_INTERVAL = 1800  -- 30 phút (1800 giây)
local joinTime = os.time()

-- Hàm tự kick bản thân
local function KickYourself()
    -- Cách 1: Gây lỗi để server tự kick
    local success, err = pcall(function()
        -- Thử teleport đến vị trí không hợp lệ
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, -99999, 0)
    end)
    
    -- Cách 2: Xóa Humanoid (gây chết và kick)
    -- if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    --     LocalPlayer.Character.Humanoid:Destroy()
    -- end
end

-- Hàm rejoin sau khi bị kick
local function RejoinAfterKick()
    -- Chờ game kick
    task.wait(2)
    -- Teleport lại game
    TeleportService:Teleport(GameId)
end

-- Tạo menu
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoKickRejoin"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 180)
frame.Position = UDim2.new(0.02, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
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
title.BackgroundColor3 = Color3.fromRGB(255, 80, 50)
title.Text = "⚡ AUTO KICK & REJOIN ⚡"
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
statusLabel.Size = UDim2.new(0.9, 0, 0, 35)
statusLabel.Position = UDim2.new(0.05, 0, 0, 90)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
statusLabel.Text = "🟢 Đang chạy..."
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = frame

-- Nút Kick & Rejoin ngay
local kickBtn = Instance.new("TextButton")
kickBtn.Size = UDim2.new(0.8, 0, 0, 40)
kickBtn.Position = UDim2.new(0.1, 0, 0, 132)
kickBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
kickBtn.Text = "🔥 KICK & REJOIN NGAY"
kickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
kickBtn.TextScaled = true
kickBtn.Font = Enum.Font.GothamBold
kickBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = kickBtn

-- Vòng lặp auto
local autoEnabled = true

spawn(function()
    while autoEnabled and frame and frame.Parent do
        local elapsed = os.time() - joinTime
        local minutes = math.floor(elapsed / 60)
        local seconds = elapsed % 60
        timeLabel.Text = string.format("⏱️ %02d:%02d", minutes, seconds)
        
        -- Sau 30 phút thì tự kick và rejoin
        if elapsed >= REJOIN_INTERVAL then
            statusLabel.Text = "🔄 Đang tự kick..."
            task.wait(0.5)
            KickYourself()
            statusLabel.Text = "⏳ Chờ rejoin..."
            task.wait(3)
            RejoinAfterKick()
            joinTime = os.time()
            break  -- Thoát vòng lặp vì đã rejoin
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

-- Nút kick ngay
kickBtn.MouseButton1Click:Connect(function()
    statusLabel.Text = "🔄 Đang kick..."
    KickYourself()
    task.wait(2)
    RejoinAfterKick()
end)

print("=== AUTO KICK & REJOIN ĐÃ CHẠY ===")
print("Sau 30 phút sẽ tự kick và rejoin, không lỗi dịch chuyển!")

--[[
    BLOX FRUITS AUTO HOP FIXED
    Dành cho Arceus X
--]]

-- ============ CẤU HÌNH ============
local CONFIG = {
    HopInterval = 1800,  -- 30 phút (1800 giây)
    TargetPlayers = {3, 4}  -- Chỉ vào server có 3 hoặc 4 người
}

-- ============ KHỞI TẠO ============
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- ============ BIẾN TOÀN CỤC ============
local isMenuVisible = true  -- Menu đang hiện
local autoHopRunning = true  -- Auto hop đang chạy
local lastHopTime = 0
local joinTime = os.time()

-- ============ HÀM WAIT AN TOÀN ============
local function waitSafe(seconds)
    local start = tick()
    repeat
        task.wait()
    until tick() - start >= seconds
end

-- ============ LẤY DANH SÁCH SERVER (CÁCH KHÁC) ============
local function getServerList()
    local servers = {}
    
    -- Cách 1: Dùng API cũ
    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/2753915549/servers/Public?limit=100"
        local data = game:HttpGet(url)
        return HttpService:JSONDecode(data)
    end)
    
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            local playerCount = server.playing
            if playerCount >= CONFIG.TargetPlayers[1] and playerCount <= CONFIG.TargetPlayers[2] then
                table.insert(servers, {
                    id = server.id,
                    players = playerCount
                })
            end
        end
    end
    
    -- Cách 2: Dùng API dự phòng nếu cách 1 fail
    if #servers == 0 then
        local success2, result2 = pcall(function()
            local url = "https://api.roproxy.com/games/v1/games/2753915549/servers/Public?limit=100"
            local data = game:HttpGet(url)
            return HttpService:JSONDecode(data)
        end)
        
        if success2 and result2 and result2.data then
            for _, server in ipairs(result2.data) do
                local playerCount = server.playing
                if playerCount >= CONFIG.TargetPlayers[1] and playerCount <= CONFIG.TargetPlayers[2] then
                    table.insert(servers, {
                        id = server.id,
                        players = playerCount
                    })
                end
            end
        end
    end
    
    return servers
end

-- ============ HÀM HOP SERVER ============
local function hopToServer(serverId)
    if not serverId then return false end
    
    print("Đang hop sang server: " .. tostring(serverId))
    waitSafe(2)
    
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(2753915549, serverId, LocalPlayer)
    end)
    
    if not success then
        print("Hop thất bại: " .. tostring(err))
        return false
    end
    return true
end

-- ============ TÌM VÀ HOP ============
local function findAndHop()
    if not autoHopRunning then 
        print("Auto hop đang tắt")
        return false 
    end
    
    print("Đang tìm server có " .. CONFIG.TargetPlayers[1] .. "-" .. CONFIG.TargetPlayers[2] .. " người...")
    
    local servers = getServerList()
    
    if #servers > 0 then
        -- Chọn random server phù hợp
        local target = servers[math.random(1, #servers)]
        print("Tìm thấy server " .. target.id .. " (" .. target.players .. " người)")
        return hopToServer(target.id)
    else
        print("Không tìm thấy server phù hợp, thử lại sau 30 giây")
        return false
    end
end

-- ============ TẠO MENU (CÁCH MỚI, CHẮC CHẮN HOẠT ĐỘNG) ============
local function createMenu()
    -- Xóa menu cũ nếu có
    local oldGui = LocalPlayer.PlayerGui:FindFirstChild("AutoHopMenu")
    if oldGui then oldGui:Destroy() end
    
    -- Tạo ScreenGui mới
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoHopMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 200)
    mainFrame.Position = UDim2.new(0.02, 0, 0.2, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Bo góc
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = mainFrame
    
    -- Thanh tiêu đề (có thể kéo)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
    titleBar.BackgroundTransparency = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Tiêu đề text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -35, 1, 0)
    titleText.Position = UDim2.new(0, 5, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "⚡ AUTO HOP 30P ⚡"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.Parent = titleBar
    
    -- NÚT BẬT/TẮT MENU (THU NHỎ)
    local toggleMenuBtn = Instance.new("TextButton")
    toggleMenuBtn.Size = UDim2.new(0, 35, 0, 35)
    toggleMenuBtn.Position = UDim2.new(1, -35, 0, 0)
    toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    toggleMenuBtn.Text = "━"
    toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleMenuBtn.TextSize = 20
    toggleMenuBtn.Font = Enum.Font.GothamBold
    toggleMenuBtn.Parent = titleBar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = toggleMenuBtn
    
    -- Panel nội dung (sẽ ẩn/hiện khi bấm nút)
    local contentPanel = Instance.new("Frame")
    contentPanel.Size = UDim2.new(1, 0, 0, 165)
    contentPanel.Position = UDim2.new(0, 0, 0, 35)
    contentPanel.BackgroundTransparency = 1
    contentPanel.Parent = mainFrame
    
    -- Thông tin số người chơi
    local playerCountLabel = Instance.new("TextLabel")
    playerCountLabel.Size = UDim2.new(1, -20, 0, 35)
    playerCountLabel.Position = UDim2.new(0, 10, 0, 10)
    playerCountLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    playerCountLabel.BackgroundTransparency = 0.5
    playerCountLabel.Text = "👥 Người chơi: Đang tải..."
    playerCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerCountLabel.TextSize = 14
    playerCountLabel.Font = Enum.Font.Gotham
    playerCountLabel.Parent = contentPanel
    
    local countCorner = Instance.new("UICorner")
    countCorner.CornerRadius = UDim.new(0, 4)
    countCorner.Parent = playerCountLabel
    
    -- Thời gian trong server
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(1, -20, 0, 35)
    timeLabel.Position = UDim2.new(0, 10, 0, 50)
    timeLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    timeLabel.BackgroundTransparency = 0.5
    timeLabel.Text = "⏱️ Thời gian: 00:00:00"
    timeLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    timeLabel.TextSize = 14
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.Parent = contentPanel
    
    local timeCorner = Instance.new("UICorner")
    timeCorner.CornerRadius = UDim.new(0, 4)
    timeCorner.Parent = timeLabel
    
    -- Nút HOP NGAY
    local hopNowBtn = Instance.new("TextButton")
    hopNowBtn.Size = UDim2.new(0.45, -10, 0, 40)
    hopNowBtn.Position = UDim2.new(0.03, 0, 0, 95)
    hopNowBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    hopNowBtn.Text = "🔄 HOP NGAY"
    hopNowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    hopNowBtn.TextSize = 14
    hopNowBtn.Font = Enum.Font.GothamBold
    hopNowBtn.Parent = contentPanel
    
    local hopCorner = Instance.new("UICorner")
    hopCorner.CornerRadius = UDim.new(0, 4)
    hopCorner.Parent = hopNowBtn
    
    -- Nút BẬT/TẮT AUTO HOP
    local autoHopBtn = Instance.new("TextButton")
    autoHopBtn.Size = UDim2.new(0.45, -10, 0, 40)
    autoHopBtn.Position = UDim2.new(0.52, 0, 0, 95)
    autoHopBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    autoHopBtn.Text = "🔛 BẬT AUTO"
    autoHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoHopBtn.TextSize = 14
    autoHopBtn.Font = Enum.Font.GothamBold
    autoHopBtn.Parent = contentPanel
    
    local autoCorner = Instance.new("UICorner")
    autoCorner.CornerRadius = UDim.new(0, 4)
    autoCorner.Parent = autoHopBtn
    
    -- Trạng thái
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 140)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "🟢 Đang chạy auto hop"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = contentPanel
    
    return {
        gui = screenGui,
        frame = mainFrame,
        content = contentPanel,
        playerCount = playerCountLabel,
        timeLabel = timeLabel,
        status = statusLabel,
        toggleMenuBtn = toggleMenuBtn,
        hopBtn = hopNowBtn,
        autoHopBtn = autoHopBtn
    }
end

-- ============ CẬP NHẬT UI ============
local function updateUI(ui)
    while ui and ui.playerCount and ui.gui and ui.gui.Parent do
        -- Cập nhật số người
        local count = #Players:GetPlayers()
        ui.playerCount.Text = "👥 Người chơi: " .. count
        
        -- Cập nhật thời gian
        local elapsed = os.time() - joinTime
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = elapsed % 60
        ui.timeLabel.Text = string.format("⏱️ Thời gian: %02d:%02d:%02d", hours, minutes, seconds)
        
        task.wait(1)
    end
end

-- ============ VÒNG LẶP AUTO HOP CHÍNH ============
local function autoHopLoop(ui)
    while true do
        if autoHopRunning then
            local currentPlayers = #Players:GetPlayers()
            local elapsedTime = os.time() - joinTime
            
            -- Kiểm tra điều kiện hop
            local needHop = false
            local reason = ""
            
            if elapsedTime >= CONFIG.HopInterval then
                needHop = true
                reason = "đã 30 phút"
            elseif currentPlayers < CONFIG.TargetPlayers[1] then
                needHop = true
                reason = "quá ít người (" .. currentPlayers .. ")"
            elseif currentPlayers > CONFIG.TargetPlayers[2] then
                needHop = true
                reason = "quá đông (" .. currentPlayers .. ")"
            end
            
            if needHop and (os.time() - lastHopTime) >= 60 then
                lastHopTime = os.time()
                if ui and ui.status then
                    ui.status.Text = "🟡 Đang hop (" .. reason .. ")"
                end
                print("Auto hop: " .. reason)
                
                local success = findAndHop()
                if success then
                    joinTime = os.time()  -- Reset timer sau khi hop thành công
                    -- Script sẽ dừng ở đây nếu hop thành công (đã teleport)
                    break
                else
                    if ui and ui.status then
                        ui.status.Text = "🔴 Hop thất bại, thử lại sau"
                        waitSafe(30)
                        ui.status.Text = "🟢 Đang chạy auto hop"
                    end
                end
            end
        end
        
        task.wait(5)  -- Kiểm tra mỗi 5 giây
    end
end

-- ============ KHỞI CHẠY ============
local function main()
    print("=== ĐANG KHỞI TẠO AUTO HOP ===")
    
    local ui = createMenu()
    print("Đã tạo menu")
    
    -- Xử lý nút thu nhỏ menu
    ui.toggleMenuBtn.MouseButton1Click:Connect(function()
        isMenuVisible = not isMenuVisible
        ui.content.Visible = isMenuVisible
        if isMenuVisible then
            ui.toggleMenuBtn.Text = "━"
            ui.frame.Size = UDim2.new(0, 280, 0, 200)
        else
            ui.toggleMenuBtn.Text = "□"
            ui.frame.Size = UDim2.new(0, 280, 0, 35)
        end
    end)
    
    -- Xử lý nút HOP NGAY
    ui.hopBtn.MouseButton1Click:Connect(function()
        print("Người dùng bấm HOP NGAY")
        ui.status.Text = "🟡 Đang hop theo yêu cầu..."
        local success = findAndHop()
        if success then
            joinTime = os.time()
        else
            ui.status.Text = "🔴 Không tìm thấy server phù hợp"
            waitSafe(3)
            ui.status.Text = "🟢 Đang chạy auto hop"
        end
    end)
    
    -- Xử lý nút BẬT/TẮT AUTO HOP
    ui.autoHopBtn.MouseButton1Click:Connect(function()
        autoHopRunning = not autoHopRunning
        if autoHopRunning then
            ui.autoHopBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            ui.autoHopBtn.Text = "🔛 BẬT AUTO"
            ui.status.Text = "🟢 Đang chạy auto hop"
            print("Đã bật auto hop")
        else
            ui.autoHopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            ui.autoHopBtn.Text = "🔴 TẮT AUTO"
            ui.status.Text = "⚪ Auto hop đã tắt"
            print("Đã tắt auto hop")
        end
    end)
    
    -- Chạy UI updater
    spawn(function()
        updateUI(ui)
    end)
    
    -- Chạy auto hop loop
    spawn(function()
        autoHopLoop(ui)
    end)
    
    print("=== AUTO HOP ĐÃ SẴN SÀNG ===")
    print("📌 Nút '━' để thu nhỏ menu")
    print("📌 Nút 'BẬT/TẮT AUTO' để bật/tắt tự động hop")
    print("📌 Nút 'HOP NGAY' để hop ngay lập tức")
end

-- Chạy script
pcall(main)

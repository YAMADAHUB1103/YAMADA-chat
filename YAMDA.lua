# YAMADA-chat-- ==========================================
-- YAMADA chat（キャラリセット対応版）
-- ==========================================
local Players = game:GetService("Players")
local MessagingService = game:GetService("MessagingService")
local localPlayer = Players.LocalPlayer

print("YAMADA chat (リセット対応版): 起動中...")

-- 既存のGUIが残っていれば完全に削除して再作成
if _G.YamadaChatGui and _G.YamadaChatGui.Parent then
    _G.YamadaChatGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YamadaChatGui"
screenGui.ResetOnSpawn = false -- ★これによってキャラリセットしても消えなくなります！

if syn and syn.protect_gui then
    syn.protect_gui(screenGui)
    screenGui.Parent = game:GetService("CoreGui")
else
    pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if screenGui.Parent ~= game:GetService("CoreGui") then
        screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    end
end

_G.YamadaChatGui = screenGui

-- ユーザー情報
local myName = localPlayer.DisplayName
local myId = tostring(localPlayer.UserId)

-- チャットデータ（リセット後も消えないようにグローバル領域に保持）
if not _G.YamadaChatRooms then
    _G.YamadaChatRooms = {
        { id = "memo", name = "📝 自分用メモ", messages = {} }
    }
end
local rooms = _G.YamadaChatRooms

local currentRoomIndex = nil
local currentTheme = Color3.fromRGB(245, 247, 250)
local chatTextColor = Color3.fromRGB(30, 30, 30)

-- 1. 最小化ボタン
local miniButton = Instance.new("TextButton")
miniButton.Size = UDim2.new(0, 110, 0, 36)
miniButton.Position = UDim2.new(0.02, 0, 0.15, 0)
miniButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
miniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
miniButton.Text = "💎 YAMADA chat"
miniButton.Font = Enum.Font.GothamBold
miniButton.TextSize = 11
miniButton.Visible = false
miniButton.Active = true
miniButton.Draggable = true
miniButton.Parent = screenGui
Instance.new("UICorner", miniButton).CornerRadius = UDim.new(0, 10)
local miniStroke = Instance.new("UIStroke")
miniStroke.Color = Color3.fromRGB(80, 200, 120)
miniStroke.Thickness = 1.5
miniStroke.Parent = miniButton

-- 2. メインウィンドウ
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 380)
mainFrame.Position = UDim2.new(0.5, -140, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 70)
mainStroke.Thickness = 1
mainStroke.Parent = mainFrame

-- ヘッダー
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
header.BorderSizePixel = 0
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local fixCover = Instance.new("Frame")
fixCover.Size = UDim2.new(1, 0, 0, 8)
fixCover.Position = UDim2.new(0, 0, 1, -8)
fixCover.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
fixCover.BorderSizePixel = 0
fixCover.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -110, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "💎 メッセージ"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- 友だち追加ボタン
local addFriendBtn = Instance.new("TextButton")
addFriendBtn.Size = UDim2.new(0, 36, 0, 24)
addFriendBtn.Position = UDim2.new(1, -76, 0, 9)
addFriendBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
addFriendBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
addFriendBtn.Text = "＋追加"
addFriendBtn.Font = Enum.Font.GothamBold
addFriendBtn.TextSize = 9
addFriendBtn.Parent = header
Instance.new("UICorner", addFriendBtn).CornerRadius = UDim.new(0, 6)

-- 設定ボタン
local settingsBtn = Instance.new("TextButton")
settingsBtn.Size = UDim2.new(0, 32, 0, 24)
settingsBtn.Position = UDim2.new(1, -112, 0, 9)
settingsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
settingsBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
settingsBtn.Text = "⚙️"
settingsBtn.Font = Enum.Font.GothamBold
settingsBtn.TextSize = 10
settingsBtn.Parent = header
Instance.new("UICorner", settingsBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -32, 0, 9)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    miniButton.Visible = true
end)

miniButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    miniButton.Visible = false
end)

-- 3. トーク一覧画面
local chatListFrame = Instance.new("ScrollingFrame")
chatListFrame.Size = UDim2.new(1, -12, 1, -52)
chatListFrame.Position = UDim2.new(0, 6, 0, 48)
chatListFrame.BackgroundTransparency = 1
chatListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
chatListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
chatListFrame.ScrollBarThickness = 3
chatListFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = chatListFrame

-- 4. 個別トーク画面
local roomFrame = Instance.new("Frame")
roomFrame.Size = UDim2.new(1, 0, 1, -42)
roomFrame.Position = UDim2.new(0, 0, 0, 42)
roomFrame.BackgroundColor3 = currentTheme
roomFrame.Visible = false
roomFrame.Parent = mainFrame

local roomHeader = Instance.new("Frame")
roomHeader.Size = UDim2.new(1, 0, 0, 36)
roomHeader.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
roomHeader.BorderSizePixel = 0
roomHeader.Parent = roomFrame

local backBtn = Instance.new("TextButton")
backBtn.Size = UDim2.new(0, 48, 0, 24)
backBtn.Position = UDim2.new(0, 6, 0, 6)
backBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
backBtn.Text = "＜ 戻る"
backBtn.Font = Enum.Font.GothamBold
backBtn.TextSize = 9
backBtn.Parent = roomHeader
Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 6)

local roomTitle = Instance.new("TextLabel")
roomTitle.Size = UDim2.new(1, -60, 1, 0)
roomTitle.Position = UDim2.new(0, 60, 0, 0)
roomTitle.BackgroundTransparency = 1
roomTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
roomTitle.Font = Enum.Font.GothamBold
roomTitle.TextSize = 11
roomTitle.TextXAlignment = Enum.TextXAlignment.Left
roomTitle.Parent = roomHeader

-- メッセージスクロール領域
local roomScroll = Instance.new("ScrollingFrame")
roomScroll.Size = UDim2.new(1, -12, 1, -110)
roomScroll.Position = UDim2.new(0, 6, 0, 38)
roomScroll.BackgroundTransparency = 1
roomScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
roomScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
roomScroll.ScrollBarThickness = 3
roomScroll.Parent = roomFrame

local roomListLayout = Instance.new("UIListLayout")
roomListLayout.SortOrder = Enum.SortOrder.LayoutOrder
roomListLayout.Padding = UDim.new(0, 6)
roomListLayout.Parent = roomScroll

-- スタンプバー
local stampBar = Instance.new("Frame")
stampBar.Size = UDim2.new(1, -12, 0, 28)
stampBar.Position = UDim2.new(0, 6, 1, -68)
stampBar.BackgroundTransparency = 1
stampBar.Parent = roomFrame

local stampLayout = Instance.new("UIListLayout")
stampLayout.FillDirection = Enum.FillDirection.Horizontal
stampLayout.SortOrder = Enum.SortOrder.LayoutOrder
stampLayout.Padding = UDim.new(0, 6)
stampLayout.Parent = stampBar

-- 入力バー
local inputBar = Instance.new("Frame")
inputBar.Size = UDim2.new(1, -12, 0, 32)
inputBar.Position = UDim2.new(0, 6, 1, -34)
inputBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inputBar.Parent = roomFrame
Instance.new("UICorner", inputBar).CornerRadius = UDim.new(0, 8)
local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(200, 200, 200)
inputStroke.Parent = inputBar

local msgBox = Instance.new("TextBox")
msgBox.Size = UDim2.new(1, -48, 1, 0)
msgBox.Position = UDim2.new(0, 8, 0, 0)
msgBox.BackgroundTransparency = 1
msgBox.PlaceholderText = "メッセージを入力..."
msgBox.Text = ""
msgBox.TextColor3 = Color3.fromRGB(30, 30, 30)
msgBox.Font = Enum.Font.Gotham
msgBox.TextSize = 10
msgBox.TextXAlignment = Enum.TextXAlignment.Left
msgBox.Parent = inputBar

local sendBtn = Instance.new("TextButton")
sendBtn.Size = UDim2.new(0, 36, 0, 24)
sendBtn.Position = UDim2.new(1, -40, 0, 4)
sendBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 100)
sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sendBtn.Text = "送信"
sendBtn.Font = Enum.Font.GothamBold
sendBtn.TextSize = 9
sendBtn.Parent = inputBar
Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 6)

-- 5. 友だち追加 ＆ エラー通知ポップアップ
local addPopup = Instance.new("Frame")
addPopup.Size = UDim2.new(0, 240, 0, 140)
addPopup.Position = UDim2.new(0.5, -120, 0.5, -70)
addPopup.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
addPopup.Visible = false
addPopup.Parent = screenGui
Instance.new("UICorner", addPopup).CornerRadius = UDim.new(0, 12)
local addStroke = Instance.new("UIStroke")
addStroke.Color = Color3.fromRGB(80, 80, 100)
addStroke.Parent = addPopup

local popupTitle = Instance.new("TextLabel")
popupTitle.Size = UDim2.new(1, 0, 0, 32)
popupTitle.Text = "🔍 友だちID検索"
popupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
popupTitle.Font = Enum.Font.GothamBold
popupTitle.TextSize = 11
popupTitle.BackgroundTransparency = 1
popupTitle.Parent = addPopup

local friendIdInput = Instance.new("TextBox")
friendIdInput.Size = UDim2.new(0.9, 0, 0, 30)
friendIdInput.Position = UDim2.new(0.05, 0, 0, 38)
friendIdInput.PlaceholderText = "相手の正確なIDまたはユーザー名"
friendIdInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
friendIdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
friendIdInput.Text = ""
friendIdInput.Font = Enum.Font.Gotham
friendIdInput.TextSize = 10
friendIdInput.Parent = addPopup
Instance.new("UICorner", friendIdInput).CornerRadius = UDim.new(0, 6)

local confirmAddBtn = Instance.new("TextButton")
confirmAddBtn.Size = UDim2.new(0.42, 0, 0, 28)
confirmAddBtn.Position = UDim2.new(0.05, 0, 0, 82)
confirmAddBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 100)
confirmAddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmAddBtn.Text = "検索して追加"
confirmAddBtn.Font = Enum.Font.GothamBold
confirmAddBtn.TextSize = 10
confirmAddBtn.Parent = addPopup
Instance.new("UICorner", confirmAddBtn).CornerRadius = UDim.new(0, 6)

local cancelAddBtn = Instance.new("TextButton")
cancelAddBtn.Size = UDim2.new(0.42, 0, 0, 28)
cancelAddBtn.Position = UDim2.new(0.53, 0, 0, 82)
cancelAddBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
cancelAddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cancelAddBtn.Text = "閉じる"
cancelAddBtn.Font = Enum.Font.GothamBold
cancelAddBtn.TextSize = 10
cancelAddBtn.Parent = addPopup
Instance.new("UICorner", cancelAddBtn).CornerRadius = UDim.new(0, 6)

-- エラー通知モーダル
local errorPopup = Instance.new("Frame")
errorPopup.Size = UDim2.new(0, 220, 0, 100)
errorPopup.Position = UDim2.new(0.5, -110, 0.5, -50)
errorPopup.BackgroundColor3 = Color3.fromRGB(35, 20, 20)
errorPopup.Visible = false
errorPopup.ZIndex = 10
errorPopup.Parent = screenGui
Instance.new("UICorner", errorPopup).CornerRadius = UDim.new(0, 10)
local errStroke = Instance.new("UIStroke")
errStroke.Color = Color3.fromRGB(220, 60, 60)
errStroke.Thickness = 1.5
errStroke.Parent = errorPopup

local errorText = Instance.new("TextLabel")
errorText.Size = UDim2.new(1, -10, 0, 50)
errorText.Position = UDim2.new(0, 5, 0, 8)
errorText.BackgroundTransparency = 1
errorText.Text = "⚠️ ユーザーが見つかりません\n入力されたIDは存在しません。"
errorText.TextColor3 = Color3.fromRGB(255, 180, 180)
errorText.Font = Enum.Font.GothamBold
errorText.TextSize = 10
errorText.ZIndex = 11
errorText.Parent = errorPopup

local errCloseBtn = Instance.new("TextButton")
errCloseBtn.Size = UDim2.new(0.5, 0, 0, 26)
errCloseBtn.Position = UDim2.new(0.25, 0, 0, 64)
errCloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
errCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
errCloseBtn.Text = "OK"
errCloseBtn.Font = Enum.Font.GothamBold
errCloseBtn.TextSize = 10
errCloseBtn.ZIndex = 11
errCloseBtn.Parent = errorPopup
Instance.new("UICorner", errCloseBtn).CornerRadius = UDim.new(0, 6)

errCloseBtn.MouseButton1Click:Connect(function()
    errorPopup.Visible = false
end)

addFriendBtn.MouseButton1Click:Connect(function()
    addPopup.Visible = true
end)

cancelAddBtn.MouseButton1Click:Connect(function()
    addPopup.Visible = false
    friendIdInput.Text = ""
end)

-- 6. 設定画面 ＆ 背景テーマ選択
local settingFrame = Instance.new("Frame")
settingFrame.Size = UDim2.new(0, 240, 0, 180)
settingFrame.Position = UDim2.new(0.5, -120, 0.5, -90)
settingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
settingFrame.Visible = false
settingFrame.Parent = screenGui
Instance.new("UICorner", settingFrame).CornerRadius = UDim.new(0, 12)
local setStroke = Instance.new("UIStroke")
setStroke.Color = Color3.fromRGB(80, 80, 100)
setStroke.Parent = settingFrame

local stTitle = Instance.new("TextLabel")
stTitle.Size = UDim2.new(1, 0, 0, 32)
stTitle.Text = "⚙️ 背景テーマ選択"
stTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
stTitle.Font = Enum.Font.GothamBold
stTitle.TextSize = 11
stTitle.BackgroundTransparency = 1
stTitle.Parent = settingFrame

local themes = {
    { name = "ライト (白)", bg = Color3.fromRGB(245, 247, 250), text = Color3.fromRGB(30, 30, 30) },
    { name = "ダークブラック", bg = Color3.fromRGB(20, 20, 24), text = Color3.fromRGB(240, 240, 240) },
    { name = "ディープブルー", bg = Color3.fromRGB(15, 25, 45), text = Color3.fromRGB(220, 230, 255) }
}

for idx, th in ipairs(themes) do
    local thBtn = Instance.new("TextButton")
    thBtn.Size = UDim2.new(0.9, 0, 0, 28)
    thBtn.Position = UDim2.new(0.05, 0, 0, 32 + (idx * 34))
    thBtn.BackgroundColor3 = th.bg
    thBtn.TextColor3 = th.text
    thBtn.Text = th.name
    thBtn.Font = Enum.Font.GothamBold
    thBtn.TextSize = 10
    thBtn.Parent = settingFrame
    Instance.new("UICorner", thBtn).CornerRadius = UDim.new(0, 6)
    
    thBtn.MouseButton1Click:Connect(function()
        currentTheme = th.bg
        chatTextColor = th.text
        roomFrame.BackgroundColor3 = currentTheme
        settingFrame.Visible = false
    end)
end

settingsBtn.MouseButton1Click:Connect(function()
    settingFrame.Visible = not settingFrame.Visible
end)

-- メッセージ描画・通信ロジック
local function appendMessage(sender, text, timeStr)
    local mb = Instance.new("Frame")
    mb.Size = UDim2.new(1, 0, 0, 28)
    mb.BackgroundTransparency = 1
    mb.Parent = roomScroll
    
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -10, 1, 0)
    tl.Position = UDim2.new(0, 5, 0, 0)
    tl.BackgroundTransparency = 1
    tl.TextColor3 = chatTextColor
    tl.Font = Enum.Font.Gotham
    tl.TextSize = 10
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Text = string.format("[%s] %s: %s", timeStr, sender, text)
    tl.Parent = mb
    
    task.defer(function()
        roomScroll.CanvasPosition = Vector2.new(0, roomScroll.AbsoluteCanvasSize.Y)
    end)
end

local refreshList
refreshList = function()
    for _, child in ipairs(chatListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for i, room in ipairs(rooms) do
        local roomBtn = Instance.new("TextButton")
        roomBtn.Size = UDim2.new(1, 0, 0, 46)
        roomBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
        roomBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        roomBtn.Text = ""
        roomBtn.Parent = chatListFrame
        Instance.new("UICorner", roomBtn).CornerRadius = UDim.new(0, 8)
        
        local rName = Instance.new("TextLabel")
        rName.Size = UDim2.new(1, -10, 0, 18)
        rName.Position = UDim2.new(0, 8, 0, 6)
        rName.BackgroundTransparency = 1
        rName.TextColor3 = Color3.fromRGB(255, 255, 255)
        rName.Font = Enum.Font.GothamBold
        rName.TextSize = 11
        rName.TextXAlignment = Enum.TextXAlignment.Left
        rName.Text = room.name
        rName.Parent = roomBtn
        
        local lastMsg = room.messages[#room.messages]
        local subText = "メッセージはありません"
        if lastMsg then
            subText = lastMsg.sender .. ": " .. lastMsg.text
        end
        
        local rSub = Instance.new("TextLabel")
        rSub.Size = UDim2.new(1, -10, 0, 16)
        rSub.Position = UDim2.new(0, 8, 0, 24)
        rSub.BackgroundTransparency = 1
        rSub.TextColor3 = Color3.fromRGB(160, 160, 170)
        rSub.Font = Enum.Font.Gotham
        rSub.TextSize = 9
        rSub.TextXAlignment = Enum.TextXAlignment.Left
        rSub.Text = subText
        rSub.Parent = roomBtn
        
        roomBtn.MouseButton1Click:Connect(function()
            currentRoomIndex = i
            roomTitle.Text = room.name
            chatListFrame.Visible = false
            roomFrame.Visible = true
            titleLabel.Text = "💎 トーク"
            
            for _, c in ipairs(roomScroll:GetChildren()) do
                if c:IsA("Frame") then c:Destroy() end
            end
            for _, m in ipairs(room.messages) do
                appendMessage(m.sender, m.text, m.time)
            end
        end)
    end
end

backBtn.MouseButton1Click:Connect(function()
    roomFrame.Visible = false
    chatListFrame.Visible = true
    titleLabel.Text = "💎 メッセージ"
    refreshList()
end)

confirmAddBtn.MouseButton1Click:Connect(function()
    local searchId = friendIdInput.Text
    if searchId ~= "" then
        local found = false
        if searchId == myId or searchId == myName then
            found = true
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if tostring(p.UserId) == searchId or p.Name == searchId or p.DisplayName == searchId then
                    found = true
                    break
                end
            end
        end
        
        if found then
            table.insert(rooms, { id = searchId, name = "💬 " .. searchId, messages = { {sender="システム", text="トークルームが作成されました", time=os.date("%H:%M")} } })
            friendIdInput.Text = ""
            addPopup.Visible = false
            refreshList()
        else
            errorPopup.Visible = true
        end
    end
end)

pcall(function()
    MessagingService:SubscribeAsync("YamadaChatGlobal", function(msg)
        local data = msg.Data
        if data and data.targetId == myId then
            for idx, r in ipairs(rooms) do
                if r.id == data.senderId then
                    table.insert(r.messages, {sender = data.senderName, text = data.text, time = data.time})
                    if currentRoomIndex == idx then
                        appendMessage(data.senderName, data.text, data.time)
                    end
                    break
                end
            end
        end
    end)
end)

sendBtn.MouseButton1Click:Connect(function()
    local text = msgBox.Text
    if text ~= "" and currentRoomIndex then
        local t = os.date("%H:%M")
        msgBox.Text = ""
        
        table.insert(rooms[currentRoomIndex].messages, {sender = "自分", text = text, time = t})
        appendMessage("自分", text, t)
        
        if rooms[currentRoomIndex].id ~= "memo" then
            pcall(function()
                MessagingService:PublishAsync("YamadaChatGlobal", {
                    targetId = rooms[currentRoomIndex].id,
                    senderId = myId,
                    senderName = myName,
                    text = text,
                    time = t
                })
            end)
        end
    end
end)

local stamps = {"👍", "❤️", "🔥", "🎉", "👋"}
for _, stamp in ipairs(stamps) do
    local stBtn = Instance.new("TextButton")
    stBtn.Size = UDim2.new(0, 36, 0, 24)
    stBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    stBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stBtn.Text = stamp
    stBtn.Font = Enum.Font.GothamBold
    stBtn.TextSize = 12
    stBtn.Parent = stampBar
    Instance.new("UICorner", stBtn).CornerRadius = UDim.new(0, 6)
    
    stBtn.MouseButton1Click:Connect(function()
        if currentRoomIndex then
            local t = os.date("%H:%M")
            local stampText = "[スタンプ: " .. stamp .. "]"
            table.insert(rooms[currentRoomIndex].messages, {sender = "自分", text = stampText, time = t})
            appendMessage("自分", stampText, t)
        end
    end)
end

refreshList()
print("YAMADA chat: 起動完了！（リセット対応版）")

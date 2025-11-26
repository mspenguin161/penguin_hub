-- IMPORTANT --
local DISCORD_WEBHOOK_URL = _G.DISCORD_WEBHOOK_URL
-- IMPORTANT --





---------------------------------------------------------------------
-- IGNORE
---------------------------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local configModule = ReplicatedStorage.Modules.Spinner:FindFirstChild("HalloweenContentsConfiguration")
if not configModule then
    warn("Could not find Halloween spinner config module!")
    return
end

local player = Players.LocalPlayer
local partsFolder = Workspace:WaitForChild("Ignore")

local character = player.Character
local rootPart = character and character:FindFirstChild("HumanoidRootPart")

local VirtualUser = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

---------------------------------------------------------------------
-- Character Handler
---------------------------------------------------------------------
local function onCharacterAdded(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
end

if not character then
    player.CharacterAdded:Connect(onCharacterAdded)
else
    onCharacterAdded(character)
end

---------------------------------------------------------------------
-- Touch Handler
---------------------------------------------------------------------
local function handleDescendant(desc)
    if rootPart and desc.Name == "TouchInterest" and desc.Parent then
        firetouchinterest(rootPart, desc.Parent, 0)
    end
end

for _, desc in ipairs(partsFolder:GetDescendants()) do
    handleDescendant(desc)
end
partsFolder.DescendantAdded:Connect(handleDescendant)

---------------------------------------------------------------------
-- Discord Notification
---------------------------------------------------------------------
local function sendToDiscord(message)
    if not DISCORD_WEBHOOK_URL or DISCORD_WEBHOOK_URL == "" then return end
    local payload = HttpService:JSONEncode({
        content = message
    })
    pcall(function()
        http.request({
            Url = DISCORD_WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = payload
        })
    end)
end

---------------------------------------------------------------------
-- Candy Spin Handler
---------------------------------------------------------------------
local iconLabel = player.PlayerGui:WaitForChild("TopbarStandard")
    :WaitForChild("Holders")
    :WaitForChild("Right")
    :WaitForChild("Candy")
    :WaitForChild("IconButton")
    :WaitForChild("Menu")
    :WaitForChild("IconSpot")
    :WaitForChild("Contents")
    :WaitForChild("IconLabelContainer")
    :WaitForChild("IconLabel")

local function trySpin()
    local text = iconLabel.Text
    local numberValue = tonumber(string.match(text, "x(-?%d+)"))
    if numberValue and numberValue >= 10 then
        local data = ReplicatedStorage.Events.Spin:InvokeServer(configModule)
        if data and data.WinningItem and data.WinningItem.Name then
            local itemName = tostring(data.WinningItem.Name)
            StarterGui:SetCore("SendNotification", {
                Title = "🎃 Halloween Spin Result",
                Text = "You won: " .. itemName,
                Duration = 6
            })

            sendToDiscord(player.Name .. " won **" .. itemName .. "** from Halloween Spin!")
        end
    end
end

iconLabel:GetPropertyChangedSignal("Text"):Connect(trySpin)
trySpin()

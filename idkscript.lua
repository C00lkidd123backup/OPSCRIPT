local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local lighting = game:GetService("Lighting")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MZBGui"
screenGui.Parent = playerGui

-- Create the Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 550)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Dragging logic
local dragging = false
local dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Title with Rainbow Effect
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.new(0, 0, 0)
title.BorderSizePixel = 0
title.Text = "🔫 MZB Gui 🔫"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24
title.Parent = mainFrame

-- Rainbow Effect for Title
runService.RenderStepped:Connect(function()
    local hue = tick() % 5 / 5
    title.TextColor3 = Color3.fromHSV(hue, 1, 1)
end)

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 50, 0, 50)
closeButton.Position = UDim2.new(1, -60, 0, 0)
closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 24
closeButton.Parent = mainFrame

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Utility Functions
local function toggleESP(enabled)
    for _, targetPlayer in pairs(players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local highlight = targetPlayer.Character:FindFirstChild("Highlight")
            if enabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Parent = targetPlayer.Character
                    runService.RenderStepped:Connect(function()
                        highlight.FillColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                    end)
                end
            elseif highlight then
                highlight:Destroy()
            end
        end
    end
end

local function toggleTracers(enabled)
    for _, targetPlayer in pairs(players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local torso = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if enabled and torso then
                local beam = targetPlayer.Character:FindFirstChild("Tracer")
                if not beam then
                    local part = Instance.new("Part")
                    part.Size = Vector3.new(0.1, 0.1, 0.1)
                    part.Anchored = true
                    part.CanCollide = false
                    part.Transparency = 1
                    part.Name = "Tracer"
                    part.Parent = targetPlayer.Character

                    local attachment0 = Instance.new("Attachment", part)
                    local attachment1 = Instance.new("Attachment", torso)

                    local tracer = Instance.new("Beam")
                    tracer.Attachment0 = attachment0
                    tracer.Attachment1 = attachment1
                    tracer.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(tick() % 5 / 5, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV((tick() + 0.5) % 5 / 5, 1, 1))
                    })
                    tracer.Width0 = 0.1
                    tracer.Width1 = 0.1
                    tracer.Parent = part
                end
            else
                local tracerPart = targetPlayer.Character:FindFirstChild("Tracer")
                if tracerPart then tracerPart:Destroy() end
            end
        end
    end
end

local infJumpEnabled = false
userInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Additional Functions
local megaSuperman = false
local function toggleMegaSuperman(enabled)
    megaSuperman = enabled
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if enabled then
            humanoid.WalkSpeed = 100
            humanoid.JumpPower = 100
        else
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
    end
end

local skyboxEnabled = false
local function toggleSkybox(enabled)
    if enabled then
        runService.RenderStepped:Connect(function()
            lighting.Sky.SkyboxBk = Color3.fromHSV(tick() % 1, 1, 1)
        end)
    end
end

local function crashFPS()
    player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10000000, 0)
end

-- Buttons
local buttons = {
    {Text = "ESP", Action = toggleESP},
    {Text = "Tracers", Action = toggleTracers},
    {Text = "INF Jump", Action = function(enabled) infJumpEnabled = enabled end},
    {Text = "Mega Superman", Action = toggleMegaSuperman},
    {Text = "C00lkidd Skybox", Action = toggleSkybox},
    {Text = "Crash FPS", Action = crashFPS}
}

for i, buttonData in ipairs(buttons) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0, 50)
    button.Position = UDim2.new(0.1, 0, 0, 60 + (i - 1) * 70)
    button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    button.Text = buttonData.Text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.Parent = mainFrame

    local toggled = false
    button.MouseButton1Click:Connect(function()
        toggled = not toggled
        buttonData.Action(toggled)
    end)
end

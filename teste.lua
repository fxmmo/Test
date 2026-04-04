local WindUI = ""
local way = "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
local success, result = pcall(function()
    return loadstring(game:HttpGet(way))()
end)

if success then
    WindUI = result
else
    warn("Erro ao carregar WindUI:", result)
end

-- Serviços
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
local remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")
local IsGameActive = ReplicatedStorage:WaitForChild("IsGameActive")
local LocalPlayer = Players.LocalPlayer
local CollectionService = game:GetService("CollectionService")

-- Variáveis de Controle
local running = true
local speedBoostEnabled = false
local noclipEnabled = false
local antiSeerEnabled = false
local AntiFlingEnabled = false
local InfDoublejumpEnabled = false

local slowBeastEnabled = false
local autoCrawlEnabled = false
local ghostHitEnabled = false

local antiTieUpEnabled = false
local autoTieUpEnabled = false
local autoInteract = false

local targetLockerCFrame = nil
local antiRagdollEnabled = false

local highlightEnabled = false

local reachEnabled = false
local reachSize = 15
local clearAllHighlights = false

local espBeast = false
local espSurvivors = false
local espEveryone = false

local tableHighlightEnabled = false
local podHighlightEnabled = false
local autoHelpEnabled = false
local autoHackerEnabled = false
local antiSeerEnabled = true

local targetWalkSpeed = 60
local highlightTransparency = 0.5 
local originalZoom = LocalPlayer.CameraMaxZoomDistance

local auraEnabled = false
local auraDistance = 20
local effectEnabled = true

local EnabledNotifications = true

local Saturation = 0.15

local function getMap()
  local Map = ReplicatedStorage:FindFirstChild("CurrentMap")
  
  if not Map then
    return "Mapa não encontrado"
  end
  
  if Map.Value == nil then
    return "Esperando Mapa..."
  else
    return tostring(Map.Value)
  end
end

local CurrentMap = getMap()

local function applyHighlight(target, name, color, fillTransparency)
  
    local h = target:FindFirstChild(name)
    
    if not h then
        h = Instance.new("Highlight")
        h.Name = name
        h.Parent = target
    end
    
    h.FillColor = color
    h.FillTransparency = highlightTransparency or 0.5
    h.OutlineColor = color
    h.Enabled = true
    h.Adornee = target
    
    return h
end

-- Função para limpar os ESPs
local function clearAllHighlights(highlightName)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChild(highlightName)
            if highlight and highlight:IsA("Highlight") then
                highlight:Destroy()
            end
        end
    end
    
    if CurrentMap and CurrentMap.Value then
        for _, obj in pairs(CurrentMap.Value:GetChildren()) do
            local highlight = obj:FindFirstChild(highlightName)
            if highlight and highlight:IsA("Highlight") then
                highlight:Destroy()
            end
        end
    end
end

local function Notify(title, content, duration, icon)
  
  function PlayNotifySound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://18886652611"
    sound.Volume = 0.5
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
  end
  
  if title == "" then
    title = "Helper"
  elseif content == "" then
    content = "???"
  elseif duration == "" or "0" then 
    duration = 2
  elseif icon == "" then
    icon = ""
  end
  
  if EnabledNotifications then 
    PlayNotifySound()
    WindUI:Notify({
      Title = title,
      Content = content,
      Duration = duration
    })
  end 
end

local function CreateEffect()
    local screen = PlayerGui:FindFirstChild("EffectOpenClose")
    local blur = Lighting:FindFirstChild("EffectBlurr")

    if screen then
        screen.Enabled = true
        local frame = screen:FindFirstChildOfClass("Frame")
        if frame then
            frame.BackgroundTransparency = 1
            if blur then blur.Enabled = true end

            local TweenService = game:GetService("TweenService")
            local fadeIn = TweenService:Create(
                frame,
                TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = 0}
            )
            fadeIn:Play()
        end
        return screen
    end

    -- cria se não existir
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EffectOpenClose"
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 100
    screenGui.Enabled = true
    screenGui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(14, 7, 79)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1
    frame.Parent = screenGui

    local blur = Instance.new("BlurEffect")
    blur.Size = 10
    blur.Name = "EffectBlurr"
    blur.Parent = Lighting
    blur.Enabled = true

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(111, 111, 111)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0.369)
    }
    gradient.Rotation = 270
    gradient.Parent = frame

    local TweenService = game:GetService("TweenService")
    local fadeIn = TweenService:Create(
        frame,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 0}
    )
    fadeIn:Play()

    return screenGui
end

local function CloseEffect(screenGui)
    local TweenService = game:GetService("TweenService")
    
    local screenGui = PlayerGui:FindFirstChild("EffectOpenClose")
    
    local blur = Lighting:FindFirstChild("EffectBlurr")
    
    if screenGui then
        local frame = screenGui:FindFirstChild("Frame")
        
        if frame then
            local fadeOutInfo = TweenInfo.new(
                0.5, -- Duração
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )
            
            local fadeOut = TweenService:Create(
                frame,
                fadeOutInfo,
                {BackgroundTransparency = 1}
            )
            
            fadeOut.Completed:Connect(function()
                screenGui.Enabled = false
            end)
            
            fadeOut:Play()
            
            if blur then
              blur.Enabled = false
            end
        else
            screenGui.Enabled = false
            print("No animation")
        end
    end
end

WindUI:AddTheme({
    Name = "Aurora",

    Accent = Color3.fromHex("#7c3aed"),
    Background = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#0f0c29") },
        ["50"]  = { Color = Color3.fromHex("#1a1040") },
        ["100"] = { Color = Color3.fromHex("#0d0d1a") },
    }, {
        Rotation = 135,
    }),
    Outline = Color3.fromHex("#7c3aed"),
    Text = Color3.fromHex("#e2e8f0"),
    Placeholder = Color3.fromHex("#6b7280"),
    Button = Color3.fromHex("#4c1d95"),
    Icon = Color3.fromHex("#a78bfa"),
})

local assetPath = "Nightfall/Assets"
local iconFileName = assetPath .. "/nightfall_icon.png"
local iconURL = "https://raw.githubusercontent.com/fxmmo/Night-fall-Hub/refs/heads/main/Icon.png"

local function getIcon()
    if isfolder and makefolder and writefile and isfile and getcustomasset then
        local success, result = pcall(function()
            if not isfolder("Nightfall") then
                makefolder("Nightfall")
            end
            if not isfolder(assetPath) then
                makefolder(assetPath)
            end

            if not isfile(iconFileName) then
                local data = game:HttpGet(iconURL)
                writefile(iconFileName, data)
            end

            return getcustomasset(iconFileName)
        end)
        
        if success and result then
            return result
        end
    end
    
    warn("Falha ao salvar ícone em " .. iconFileName .. ". Usando URL direta.")
    return iconURL
end

local iconAsset = getIcon()

--Janela
local Window = WindUI:CreateWindow({
    Title = "Night-fall",
    Author = "v1.0",
    Folder = "Nightfall",
    Icon = iconAsset, 
    IconSize = 27,
    Theme = "Aurora",
    Transparent = true,
    HideSearchBar = false,
    User = {
      Enabled = true
    },
  
    KeySystem = {
     Note = "Night-Fall Hub Key System",

     API = {
         {
             Type = "platoboost",
             ServiceId = 20343,
             Secret = "8ddbd5df-283f-42ae-a20d-2d0049855e00",
        }
      }
   },

    OpenButton = { 
      Enabled = true,
      Title = "Night-fall hub",
      Draggable = true,
      StrokeThickness = 0
    }
})

Window:OnOpen(function() 
  if effectEnabled then 
    local effect = CreateEffect()
  else
    local EffectClose = CloseEffect()
  end
end)

Window:OnClose(function() 
  if effectEnabled then 
    local EffectClose = CloseEffect()
  else
    local EffectClose = CloseEffect()
  end
end)

Window:Tag({
        Title = "Gemini",
        Icon = "solar:code-bold",
        Color = Color3.fromHex("#7775F2"),
        Border = false
})

Window:Tag({
        Title = "Jogorbx",
        Icon = "solar:code-bold",
        Color = Color3.fromHex("#10C550"),
        Border = false
})

--Tabs
local HomeTab = Window:Tab({ 
  Title = "Main",
  Icon = "solar:home-2-bold" 
})

local VisualTab = Window:Tab({ 
  Title = "Visuals",
  Icon = "solar:eye-bold"
})

local AutoTab = Window:Tab({
  Title = "Auto",
  Icon = "solar:lightbulb-bold"
})

local BeastTab = Window:Tab({
  Title = "Beast",
  Icon = "solar:shield-warning-bold"
})

Window:Divider()

local ConfigsTab = Window:Tab({
  Title = "Settings",
  Icon = "solar:settings-bold"
})

--Geral
local StatsSec = HomeTab:Section({
  Title = "Stats"})

local Stats = game:GetService("Stats")

local statsUI = StatsSec:Paragraph({
    Title = "FPS: 0\nPing: 0 ms"
})

local deltaSum = 0
local frameCount = 0

local function getPing()
    local pingString = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
    local ping = tonumber(string.match(pingString, "%d+"))
    return ping or 0
end

RunService.RenderStepped:Connect(function(deltaTime)
    frameCount += 1
    deltaSum += deltaTime

    if deltaSum >= 1 then
        local fps = math.floor(frameCount / deltaSum)
        local ping = getPing()

        statsUI:SetTitle("FPS: "..fps.."\nPing: "..ping.." ms")

        frameCount = 0
        deltaSum = 0
    end
end)

local t = os.date("*t")
local clockParagraph = StatsSec:Paragraph({
    Title = "Map: "..tostring(CurrentMap.Value)..
            "\nDate: "..string.format("%02d/%02d/%04d", t.month, t.day, t.year)..
            "\nHour: "..os.date("%I:%M:%S %p")
})


HomeTab:Section({ 
  Title = "Players" })

local spectating = false

local function getPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    table.sort(names)
    return names
end

local selectedPlayerName = ""
local PlayerDropdown = HomeTab:Dropdown({
    Title = "Select Player",
    Values = getPlayerNames(),
    Callback = function(selected)
        selectedPlayerName = selected
    end
})

HomeTab:Button({
    Title = "Teleport to Player",
    Callback = function()
        if selectedPlayerName ~= "" then
            local target = Players:FindFirstChild(selectedPlayerName)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:PivotTo(target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0))
                Notify("Teleport", "Teleported to " .. selectedPlayerName, 2)
            end
        else
            Notify("Erro", "Selecione um player no menu acima!", 3)
        end
    end
})

HomeTab:Toggle({
    Title = "View Player",
    Callback = function(state)
        spectating = state
        local camera = workspace.CurrentCamera
        
        if state then
            task.spawn(function()
                while spectating do
                    local target = Players:FindFirstChild(selectedPlayerName)
                    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                        camera.CameraSubject = target.Character.Humanoid
                    else
                        camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
                    end
                    task.wait(0.1)
                end
                camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
            end)
        else
            camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
        end
    end
})

HomeTab:Space()

HomeTab:Dropdown({
    Title = "Teleport to",
    Values = { "Spawn", "Beast Cave", "Map", "Lobby Cave", "Secret Place" },
    Callback = function(selectedValue)
      
      local tpLocations = {
    ["Spawn"] = function() return workspace:FindFirstChild("LobbySpawnPad") end,
    ["Beast Cave"] = function() return workspace:FindFirstChild("BeastCaveSpawnPad") end,
    ["Mini-game Cave"] = function() return workspace:FindFirstChild("LobbyCaveSpawnPadIn") end,
    ["Map"] = function() 
        for _, obj in pairs(CurrentMap.Value:GetChildren()) do
            if obj:IsA("Model") and obj:FindFirstChild("ExitDoor") then
                return obj.ExitDoor
            end
        end
        return nil
    end
}
      
        local targetFunc = tpLocations[selectedValue]
        local target = targetFunc and targetFunc()

        if target and LocalPlayer.Character then
            local targetCFrame = target:IsA("Model") and target:GetPivot() or target.CFrame
            LocalPlayer.Character:PivotTo(targetCFrame + Vector3.new(0, 3, 0))

            Notify("Teleport","Teleported to " .. selectedValue, 2
            )
        else
            Notify("Erro","Location unavailable or not found.", 4
            )
        end
    end
})

local function refreshDropdown()
    PlayerDropdown:Refresh(getPlayerNames())
end

Players.PlayerAdded:Connect(function() task.wait(1) refreshDropdown() end)
Players.PlayerRemoving:Connect(function() refreshDropdown() end)

HomeTab:Section({
  Title = "LocalPlayer"
})

HomeTab:Slider({ 
  Title = "Walkspeed",
  Step = 1, Value = { Min = 0, Max = 120, Default = 16 },
  Callback = function(v) targetWalkSpeed = v end })

HomeTab:Toggle({ 
  Title = "Enable Walkspeed", 
  Callback = function(state) speedBoostEnabled = state if not state and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end })

HomeTab:Space()

HomeTab:Toggle({
  Title = "Noclip",
  Callback = function(state) noclipEnabled = state end })

HomeTab:Toggle({
  Title = "Unlimited Zoom-Out",
  Callback = function(state) LocalPlayer.CameraMaxZoomDistance = state and 10000 or originalZoom end })

HomeTab:Toggle({
    Title = "Infinite Jump",
    Callback = function(state)
        InfDoublejumpEnabled = state
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfDoublejumpEnabled then
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

HomeTab:Space()

local fovValue = 70
local fovEnabled = false
local defaultFOV = 70

HomeTab:Slider({
    Title = "Fov",
    Step = 1,
    Value = { Min = 30, Max = 120, Default = 70 },
    Callback = function(v)
        fovValue = v
        
        if fovEnabled then
            workspace.CurrentCamera.FieldOfView = v
        end
    end
})

HomeTab:Toggle({
    Title = "Enable FOV",
    Callback = function(state)
        fovEnabled = state
        if not state then
            workspace.CurrentCamera.FieldOfView = defaultFOV
        else
            workspace.CurrentCamera.FieldOfView = fovValue
        end
    end
})

task.spawn(function()
    while task.wait(0.5) do
        if fovEnabled then
            workspace.CurrentCamera.FieldOfView = fovValue
        end
    end
end)

HomeTab:Space()

HomeTab:Button({
    Title = "Disable fog",
    Callback = function()
        Lighting.FogEnd = 100000
        for _, effect in pairs(Lighting:GetDescendants()) do
            if effect:IsA("Atmosphere") then effect:Destroy() end
        end
        Notify("System",  "Fog Disabled", 2)
    end
})

HomeTab:Toggle({
     Title = "Anti-Fling",
     Callback = function(state)
         AntiFlingEnabled = state
     end
 })

--Visual
local VisualSec = VisualTab:Section({ Title = "Highlights",
  Opened = true})

VisualSec:Toggle({ 
    Title = "Beast", 
    Callback = function(state) espBeast = state end 
})

VisualSec:Toggle({ 
    Title = "Survivors", 
    Callback = function(state) espSurvivors = state end 
})

VisualSec:Toggle({ 
    Title = "Everyone", 
    Callback = function(state) espEveryone = state end 
})

VisualSec:Space()

VisualSec:Toggle({ 
  Title = "Computers",
  Callback = function(state) tableHighlightEnabled = state if not state then clearAllHighlights("TableESP") end end })

VisualSec:Toggle({
  Title = "Capsules", 
  Callback = function(state) podHighlightEnabled = state if not state then clearAllHighlights("PodESP") end end })

VisualSec:Slider({ 
  Title = "Highlight transparency", 
  Step = 0.1, Value = { Min = 0, Max = 1, Default = 0.5 }, Callback = function(v) highlightTransparency = v end })

--Auto
AutoTab:Section({ 
  Title = "Anti and Auto" 
})
AutoTab:Toggle({ 
  Title = "Anti pc error", 
  Callback = function(state) autoHackerEnabled = state end })

AutoTab:Toggle({
  Title = "Anti Ragdoll",
  Callback = function(state)
    antiRagdollEnabled = state end
})

--#Auto Interact
local stats = LocalPlayer:WaitForChild("TempPlayerStatsModule")
local ontrigger = stats:WaitForChild("OnTrigger")
local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")

ontrigger:GetPropertyChangedSignal("Value"):Connect(function()
	if autoInteract and ontrigger.Value then
		RemoteEvent:FireServer("Input","Action", true)
	end
end)

AutoTab:Toggle({
	Title = "Auto Interact",
	Callback = function(state)
		autoInteract = state
	end
})

AutoTab:Section({ 
  Title = "Fast" })

AutoTab:Toggle({ 
  Title = "Auto save captured",
  Desc = "Automatically save captured players.",
  Callback = function(state) autoHelpEnabled = state end }) 

local function triggerHelp()
    local char = LocalPlayer.Character
    if not char or not CurrentMap.Value then return end

    local statsModule = LocalPlayer:FindFirstChild("TempPlayerStatsModule")
    if not statsModule then return end
    local stats = require(statsModule)
    
    for _, obj in pairs(CurrentMap.Value:GetDescendants()) do
        if obj.Name == "PodTrigger" and obj:IsA("BasePart") then
            local capturedValue = obj:FindFirstChild("CapturedTorso")
            local podEvent = obj:FindFirstChild("Event")
            
            if capturedValue and capturedValue.Value ~= nil and podEvent then
                
                task.spawn(function()
                    pcall(function() stats.SetValue("ActionEvent", podEvent) end)
                    task.wait(0.05)

                    for i = 1, 3 do
                        remoteEvent:FireServer("Input", "Action", true)
                        remoteEvent:FireServer("Input", "Trigger", true, podEvent)
                        task.wait(0.05)
                    end

                    Notify("Auto Help", "Free captured", 2.5)
                    
                    task.delay(0.3, function()
                        pcall(function() stats.SetValue("ActionEvent", nil) end)
                        remoteEvent:FireServer("Input", "Action", false)
                    end)
                end)

                return true
            end
        end
    end
    return false
end


task.spawn(function()
    while running do
        if autoHelpEnabled then
            triggerHelp()
        end
        task.wait(0.5)
    end
end)

local savecapturedButton

savecapturedButton = AutoTab:Button({
    Title = "Save Captured",
    Callback = function()
      savecapturedButton:Highlight()
        local result = triggerHelp()
    end
})

local FastCrawl = false

AutoTab:Toggle({
  Title = "No Slow Crawl",
  Callback = function(state)
    FastCrawl = state end
})

game:GetService("RunService").Heartbeat:Connect(function()
    if FastCrawl then
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.HipHeight < 0 then
            hum.WalkSpeed = 16
        end
    end
end)

--Beast
local CombatSec = BeastTab:Section({ Title = "Combat" })

local auraMode = "Rage"

CombatSec:Dropdown({
    Title = "Aura Intensity",
    Values = { "Legit", "Rage" },
    Value = 1,
    Callback = function(v) auraMode = v end
})

CombatSec:Slider({
    Title = "Aura Distance",
    Step = 1, Value = { Min = 5, Max = 25, Default = 15 },
    Callback = function(v) auraDistance = v end
})

CombatSec:Toggle({
    Title = "Enable Kill Aura",
    Callback = function(state) auraEnabled = state end
})

CombatSec:Section({ Title = "Hitbox Expander" })

local hitboxEnabled = false
local hitboxSize = 10

CombatSec:Toggle({
    Title = "Hitbox",
    Callback = function(state) 
        hitboxEnabled = state 
        if not state then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                    p.Character.HumanoidRootPart.Transparency = 1
                end
            end
        end
    end 
})

CombatSec:Slider({
    Title = "Hitbox Size",
    Step = 1, Value = { Min = 2, Max = 20, Default = 10 },
    Callback = function(v) hitboxSize = v end
})

BeastTab:Divider()
BeastTab:Space()

BeastTab:Toggle({
    Title = "Crawn Beast",
    Locked = true,
    Callback = function(state)
        autoCrawlEnabled = state
    end
})

BeastTab:Toggle({
    Title = "Auto Tie-Up",
    Callback = function(state)
        autoTieUpEnabled = state
    end
})

BeastTab:Button({
  Title = "Unlock third person",
  Desc = "Allows you to use the third person when you're a beast.",
  Callback = function() LocalPlayer.CameraMode = Enum.CameraMode.Classic end })

BeastTab:Divider()

local TrollSec = BeastTab:Section({
  Title = "Troll",
  Opened = true
})

TrollSec:Toggle({
    Title = "Slow Beast",
    Desc = "It makes the beast slow down.",
    Callback = function(state)
        slowBeastEnabled = state
    end
})

TrollSec:Toggle({
    Title = "Anti-Tie Up️",
    Callback = function(state)
        antiTieUpEnabled = state
    end
})

--Configs
ConfigsTab:Section({
  Title = "Hub"
})

ConfigsTab:Toggle({
  Title = "Notifications",
  Value = true,
  Callback = function(state)
    EnabledNotifications = state 
  end 
})

ConfigsTab:Toggle({
  Title = "Open/Close effect",
  Callback = function(state)
    effectEnabled = state end
})

ConfigsTab:Section({
  Title = "Graphics"
})

ConfigsTab:Slider({
  Title = "Saturation",
  Step = 0.1, Value = { Min = -5, Max = 5, Default = 0.5 },
    Callback = function(v) Saturation = v
      
      local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
    
if not colorCorrection then
    colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Parent = Lighting
end

colorCorrection.Saturation = Saturation
end
})

ConfigsTab:Slider ({
  Title = "Contrast",
  Step = 0.1,
  Value = { Min = -5, Max = 5, Default = 0.2},
  Callback = function(v) Contrast = v
    
    local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
  if not colorCorrection then
    colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Parent = Lighting
  end

colorCorrection.Contrast = Contrast

end
})

ConfigsTab:Button({
  Title = "Remove textures/decals",
  Callback = function()
    local count = 0

    for _, obj in ipairs(workspace:GetDescendants()) do
        
        if obj:IsA("Texture") or obj:IsA("Decal") then
            obj:Destroy()
            count += 1

        elseif obj:IsA("SpecialMesh") then
            obj.TextureId = ""

        elseif obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
                obj:SetAttribute("SurfaceTexture_" .. face.Name, nil)
            end

        elseif obj:IsA("MeshPart") then
            obj.TextureID = ""

        elseif obj:IsA("Terrain") then
        end
    end

    workspace.DescendantAdded:Connect(function(obj)
        task.wait()
        if obj:IsA("Texture") or obj:IsA("Decal") then
            obj:Destroy()
        elseif obj:IsA("SpecialMesh") then
            obj.TextureId = ""
        elseif obj:IsA("MeshPart") then
            obj.TextureID = ""
        end
    end)
    
end
})

-- [[ Toda parte lógica]]

--#Amarrar auto
task.spawn(function()
    while running do
        if autoTieUpEnabled then
            local char = LocalPlayer.Character
            local hammer = char and char:FindFirstChild("Hammer")
            local hEvent = hammer and hammer:FindFirstChild("HammerEvent")
            local myRoot = char and char:FindFirstChild("HumanoidRootPart")

            if hEvent and myRoot then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local tChar = p.Character
                        local tTorso = tChar:FindFirstChild("Torso") or tChar:FindFirstChild("UpperTorso")
                        local stats = p:FindFirstChild("TempPlayerStatsModule")
                        
                        local isBeast = stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value
                        
                        if not isBeast and tTorso then
                            local dist = (myRoot.Position - tTorso.Position).Magnitude
                            
                            if dist <= 12 then 
                                local args = {
                                    "HammerTieUp",
                                    tTorso,
                                    myRoot.Position
                                }
                                hEvent:FireServer(unpack(args))
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

--#Anti amarrar
task.spawn(function()
    while running do
        if antiTieUpEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                local stats = p:FindFirstChild("TempPlayerStatsModule")
                if stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value then
                    
                    for _, survivor in pairs(Players:GetPlayers()) do
                        local sStats = survivor:FindFirstChild("TempPlayerStatsModule")
                        
                        if sStats and sStats:FindFirstChild("Ragdoll") and sStats.Ragdoll.Value == true then
                            
                            local beastChar = p.Character
                            if beastChar then
                                local hammer = beastChar:FindFirstChild("Hammer")
                                local hEvent = hammer and hammer:FindFirstChild("HammerEvent")
                                
                                if hEvent then
                                    hEvent:FireServer("HammerClick", true)
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)

--#Anti pc error
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FireServer" and not checkcaller() then
        if autoHackerEnabled and args[1] == "SetPlayerMinigameResult" then
            args[2] = true
            return oldNamecall(self, unpack(args))
        end
    end
    
    return oldNamecall(self, ...)
end)

RunService.Heartbeat:Connect(function()
    if running and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        
        if speedBoostEnabled and hum then
            hum.WalkSpeed = targetWalkSpeed
        end
        
        if noclipEnabled then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end
    end
end)

--#Power Notify
local lastNotifiedPower = ""
local notifyDebounce = false

local function monitorBeastPower(player)
    local stats = player:FindFirstChild("TempPlayerStatsModule")
    if not stats then 
        player.ChildAdded:Connect(function(child)
            if child.Name == "TempPlayerStatsModule" then
                monitorBeastPower(player)
            end
        end)
        return 
    end

    local isBeast = stats:FindFirstChild("IsBeast")
    if not isBeast then
        stats.ChildAdded:Connect(function(child)
            if child.Name == "IsBeast" then
                monitorBeastPower(player)
            end
        end)
        return
    end

    local powerObj = stats:FindFirstChild("CurrentPower") or ReplicatedStorage:FindFirstChild("CurrentPower")
    if not powerObj then
        local function checkPowerAdded()
            powerObj = stats:FindFirstChild("CurrentPower") or ReplicatedStorage:FindFirstChild("CurrentPower")
            if powerObj then
                monitorBeastPower(player)
            end
        end
        stats.ChildAdded:Connect(checkPowerAdded)
        ReplicatedStorage.ChildAdded:Connect(checkPowerAdded)
        return
    end

    local function notifyPower()
        if notifyDebounce then return end
        if isBeast and isBeast.Value == true and powerObj and powerObj.Value ~= "" then
            local currentPower = tostring(powerObj.Value)
            if currentPower ~= lastNotifiedPower then
                notifyDebounce = true
                task.wait(0.1)
                currentPower = tostring(powerObj.Value)
                if currentPower ~= lastNotifiedPower then
                    lastNotifiedPower = currentPower
                    Notify(
                        "Beast is: " .. player.Name, 
                        "Power: " .. currentPower, 
                        5
                    )
                end
                notifyDebounce = false
            end
        end
    end

    powerObj:GetPropertyChangedSignal("Value"):Connect(notifyPower)

    isBeast:GetPropertyChangedSignal("Value"):Connect(function()
        if isBeast.Value == true then
            lastNotifiedPower = ""
            task.wait(0.5)
            notifyPower()
        end
    end)

    if isBeast.Value == true then 
        notifyPower() 
    end
end

Players.PlayerAdded:Connect(monitorBeastPower)

for _, player in pairs(Players:GetPlayers()) do
    task.spawn(function()
        monitorBeastPower(player)
    end)
end

--#Kill aura 
task.spawn(function()
    while running do
        if auraEnabled then
            local char = LocalPlayer.Character
            local hammer = char and char:FindFirstChild("Hammer")
            local hEvent = hammer and hammer:FindFirstChild("HammerEvent")
            local myRoot = char and char:FindFirstChild("HumanoidRootPart")
            
            if hEvent and myRoot then
                local maxDist = 22 or auraDistance 
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local tChar = p.Character
                        local tRoot = tChar:FindFirstChild("HumanoidRootPart")
                        local stats = p:FindFirstChild("TempPlayerStatsModule")
                        
                        local isBeast = stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value
                        local isCaptured = stats and stats:FindFirstChild("IsCaptured") and stats.IsCaptured.Value
                        
                        if not isBeast and not isCaptured and tRoot then
                            local dist = (myRoot.Position - tRoot.Position).Magnitude
                            
                            if dist <= maxDist then
                                hEvent:FireServer("HammerClick", true)
                                
                                local hitPart = tChar:FindFirstChild("Right Arm") or tChar:FindFirstChild("Torso") or tChar:FindFirstChild("HumanoidRootPart")
                                
                                if auraMode == "Rage" then
                                    hEvent:FireServer("HammerHit", hitPart)
                                else
                                    task.wait(0.1)
                                    hEvent:FireServer("HammerHit", hitPart)
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

--#ESP e Hitbox
task.spawn(function()
    local lastHitboxUpdate = 0
    
    while running do
        local currentTime = tick()
        
        if hitboxEnabled and (currentTime - lastHitboxUpdate >= 5) then
            lastHitboxUpdate = currentTime
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local stats = p:FindFirstChild("TempPlayerStatsModule")
                    local isBeast = stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value
                    
                    if not isBeast then
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                            hrp.Transparency = 1
                            hrp.Shape = Enum.PartType.Block 
                            hrp.CanCollide = false
                        end
                    end
                end
            end
        end
        
        task.wait()
    end
end)

task.spawn(function()
    local lastESPScan = 0
    
    while running do
        local currentTime = tick()
        
        if currentTime - lastESPScan >= 1.5 then
            lastESPScan = currentTime
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local stats = p:FindFirstChild("TempPlayerStatsModule")
                    if stats and stats:FindFirstChild("IsBeast") then
                        local isBeast = stats.IsBeast.Value
                        local color = isBeast and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)

                        local showHighlight = espEveryone or (espBeast and isBeast) or (espSurvivors and not isBeast)
                        if showHighlight then
                            applyHighlight(p.Character, "PlayerESP", color)
                        else
                            local h = p.Character:FindFirstChild("PlayerESP")
                            if h then h:Destroy() end
                        end
                    end
                end
            end

            if (tableHighlightEnabled or podHighlightEnabled) and CurrentMap and CurrentMap.Value then
                for _, obj in pairs(CurrentMap.Value:GetChildren()) do
                    
                    if tableHighlightEnabled and obj.Name == "ComputerTable" then
                        local screen = obj:FindFirstChild("Screen", true)
                        
                        if screen and screen:IsA("BasePart") then
                            local isFinished = (screen.Color == Color3.fromRGB(40, 127, 71))
                            local targetColor = isFinished and Color3.fromRGB(4, 106, 179) or Color3.fromRGB(0, 150, 255)
                            
                            local h = applyHighlight(obj, "TableESP", targetColor, highlightTransparency)
                            
                            if h then
                                h.FillColor = targetColor
                                h.OutlineColor = targetColor
                                h.FillTransparency = isFinished and 0.8 or (highlightTransparency or 0.5)
                                h.OutlineTransparency = isFinished and 0.6 or 0
                            end
                        end
                    
                    elseif podHighlightEnabled and obj.Name == "FreezePod" then
                        applyHighlight(obj, "PodESP", Color3.fromRGB(255, 200, 0), highlightTransparency)
                        local h = obj:FindFirstChild("PodESP")
                        if h then
                            h.FillTransparency = highlightTransparency or 0.5
                            h.OutlineTransparency = 0
                        end
                    end
                end
            else
                if not tableHighlightEnabled then clearAllHighlights("TableESP") end
                if not podHighlightEnabled then clearAllHighlights("PodESP") end
            end
        end
        
        task.wait()
    end
end)

local function getBeastCharacter()
    for _, p in pairs(Players:GetPlayers()) do
        local stats = p:FindFirstChild("TempPlayerStatsModule")
        if stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value == true then
            return p.Character
        end
    end
    return nil
end

-- Slow Beast
task.spawn(function()
    while running do
        if slowBeastEnabled then
            local beastChar = getBeastCharacter()
            if beastChar then
                local powersEvent = beastChar:FindFirstChild("BeastPowers") and beastChar.BeastPowers:FindFirstChild("PowersEvent")
                
                if powersEvent then
                    powersEvent:FireServer("Jumped")
                end
            end
        end
        task.wait(0.1) 
    end
end)

--#AntiRagdoll
task.spawn(function()
    local player = game.Players.LocalPlayer
    local statsModule = player:WaitForChild("TempPlayerStatsModule")
    local stats = require(statsModule)

    local success, internalTable = pcall(function()
        return debug.getupvalue(stats.GetValue, 1)
    end)

    if success and type(internalTable) == "table" then
        local mt = getmetatable(internalTable) or {}
        local oldIndex = mt.__index or function(t, k) return rawget(t, k) end
        
        setreadonly(internalTable, false)
        
        mt.__index = newcclosure(function(t, k)
            if k == "Ragdoll" or k == "IsRagdoll" then
                return false
            end
            return oldIndex(t, k)
        end)
        
        setmetatable(internalTable, mt)
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if antiRagdollEnabled then
            local char = game.Players.LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if hum then
                if hum:GetState() == Enum.HumanoidStateType.Physics or hum.PlatformStand then
                    hum.PlatformStand = false
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
                
                if hum.JumpPower < 10 then
                    hum.JumpPower = 36
                end
            end
        end
    end
end)

--#Anti fling
task.spawn(function()
    game:GetService("RunService").Stepped:Connect(function()
        if AntiFlingEnabled then
            local char = game.Players.LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false 
                    end
                end
            end
            
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end)
end)

task.spawn(function()
    game:GetService("RunService").Heartbeat:Connect(function()
        if InfJumpEnabled then
        end
    end)
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfJumpEnabled then
        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

Notify("Night-fall Hub", "Welcome", 2)
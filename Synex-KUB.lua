local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fisch | SynexHUB ",
    SubTitle = "by xJONATHANw",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "House" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "Notification",
        Content = "This is a notification",
        SubContent = "SubContent", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
    })


local Toggle = Tabs.Main:AddToggle("MyToggle", {Title = "Auto Farm", Default = false })
    Toggle:OnChanged(function(Value)
        local function autoFish()
            while task.wait(1) do  -- ใช้เวลารอที่ 1 วินาทีระหว่างการตกปลา (เร็วขึ้น)
                if character and krakenRod then
                    -- ส่งคำสั่งตกปลา
                    local args = { 57.2, 1 }
                    krakenRod.events.cast:FireServer(unpack(args))
                    
                    task.wait(0.5)  -- รอ 1 วินาทีระหว่างการตกปลาให้เร็วขึ้น
        
                    -- ส่งคำสั่งให้ตกปลาสำเร็จ
                    local finishArgs = { 100, true }
                    game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("reelfinished"):FireServer(unpack(finishArgs))
                else
                    print("Kraken Rod หรือ Character หายไป หยุดการตกปลา")
                    break  -- ออกจากลูปหากไม่มีตัวละครหรือเบ็ดตกปลา
                end
            end
        end    
-- เริ่มการตกปลาอัตโนมัติ
autoFish()
    
local Toggle = Tabs.Main:AddToggle("MyToggle", {Title = "Auto Farm", Default = false })
    Toggle:OnChanged(function(Value)
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart") -- หา HumanoidRootPart
        
    -- กำหนดตำแหน่งใหม่
    local newPosition = CFrame.new(-4291.22803, -948.522034, 2076.08667, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        
-- ย้ายตัวละครไปยังตำแหน่งใหม่
hrp.CFrame = newPosition


-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "SynexHUB",
    Content = "The script has been loaded.",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()

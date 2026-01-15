--
local LoadingTick = os.clock()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bidness1337/samets-drawing-lib-for-skids/refs/heads/main/thugsense%20lads/library%20source.lua"))()

local Window = Library:Window({
    Name = "wahwahwah",
    Size = UDim2.new(0, 760, 0, 500),
    FadeSpeed = 0.25
})



local Watermark = Library:Watermark("wahwahwah ~ ".. os.date("%b %d %Y") .. " ~ ".. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
local KeybindList = Library:KeybindList()

Watermark:SetVisibility(false)
KeybindList:SetVisibility(false)
local CombatTab = Window:Page({Name = "Combat", Columns = 2, Subtabs = false})
local MiscTab = Window:Page({Name = "Misc", Columns = 2, Subtabs = true})
local VisualsTab = Window:Page({Name = "Visuals", Columns = 2, Subtabs = false})
local PlayersTab = Window:Page({Name = "Players", Columns = 1, Subtabs = false})
local SettingsTab = Window:Page({Name = "Settings", Columns = 2, Subtabs = false})
local NewSubtab = MiscTab:SubPage({Icon = "79080568477801", Columns = 2})
local NewSubtab2 = MiscTab:SubPage({Icon = "84929780240463", Columns = 2})
do -- Combat Tab
    local AimbotSection = CombatTab:Section({Name = "Aimbot", Side = 1})
    AimbotSection:Toggle({Name = "Enabled", Flag = "Enabled", Default = false, Callback = function(Value)
        print(Value)
    end}):Keybind({Name = "Hotkey", Flag = "Hotkey", Default = Enum.KeyCode.Z, Mode = "Toggle", Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Slider({Name = "Hit Chance", Min = 0, Max = 100, Default = 100, Suffix = "%", Decimals = 1, Compact = true, Flag = "Hit Chance", Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Toggle({Name = "FoV", Flag = "FoV", Default = false, Callback = function(Value)
        print(Value)
    end}):Colorpicker({Name = "FoV Color", Flag = "FoV Color", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value, Alpha)
        print(Value, Alpha)
    end})
    local Divider = AimbotSection:Divider()
    AimbotSection:Toggle({Name = "Silent Aim", Flag = "Silent Aim", Default = false, Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Toggle({Name = "Auto Fire", Flag = "Auto Fire", Default = false, Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Slider({Name = "FoV Size", Min = 0, Max = 1000, Default = 50, Decimals = 0.1, Flag = "FoV Size", Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Dropdown({Name = "Bone", Flag = "Bone", Default = "Head", Items = {"Head", "Torso", "Cock", "Ass🤤"}, Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Dropdown({Name = "Multi part", Flag = "Multi Bone", Default = {"Head", "Torso"}, Multi = true, Items = {"Head", "Torso", "Cock", "Ass🤤"}, Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Toggle({Name = "Visible Check", Flag = "Visible Check2", Default = false, Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Toggle({Name = "Wall Check", Flag = "Wall Check2", Default = false, Callback = function(Value)
        print(Value)
    end})
    local WeaponSection = CombatTab:Section({Name = "Weapon", Side = 2})
    WeaponSection:Toggle({Name = "Auto reload", Flag = "Auto Reload", Default = false, Callback = function(Value)
        print(Value)
    end})
    WeaponSection:Toggle({Name = "Infinite ammo", Flag = "Infinite Ammo", Default = false, Callback = function(Value)
        print(Value)
    end})
    WeaponSection:Toggle({Name = "No recoil", Flag = "No Recoil", Default = false, Callback = function(Value)
        print(Value)
    end})
    WeaponSection:Toggle({Name = "No spread", Flag = "No spread", Default = false, Callback = function(Value)
        print(Value)
    end})
    WeaponSection:Toggle({Name = "Instant hit", Flag = "Instant hit", Default = false, Callback = function(Value)
        print(Value)
    end})
    WeaponSection:Toggle({Name = "Instant reload", Flag = "Instant reload", Default = false, Callback = function(Value)
        print(Value)
    end})
    WeaponSection:Toggle({Name = "Rapid fire", Flag = "Rapid fire", Default = false, Callback = function(Value)
        print(Value)
    end})
    local Ragebot, Originscan, Visuals = CombatTab:MultiSection({Sections = {"Ragebot", "Origin scan", "Visuals"}, Side = 2})
    Ragebot:Toggle({Name = "Enabled", Flag = "Ragebot", Default = false, Callback = function(Value)
        print(Value)
    end})
    Ragebot:Toggle({Name = "Visible Check", Flag = "Visible Check", Default = false, Callback = function(Value)
        print(Value)
    end})
    Ragebot:Toggle({Name = "Wall Check", Flag = "Wall Check", Default = false, Callback = function(Value)
        print(Value)
    end})
    Originscan:Toggle({Name = "Enabled", Flag = "Origin Scan", Default = false, Callback = function(Value)
        print(Value)
    end})
    Originscan:Slider({Name = "Studs", Min = 0, Max = 50, Default = 15, Decimals = 1, Flag = "st", Callback = function(Value)
        print(Value)
    end})
    Visuals:Toggle({Name = "Enabled", Flag = "Visuals", Default = false, Callback = function(Value)
        print(Value)
    end})
    Visuals:Toggle({Name = "Indicator", Flag = "Box", Default = false, Callback = function(Value)
        print(Value)
    end}):Colorpicker({Name = "Color", Flag = "Box Color", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
        print(Value)
    end})
    local HighlightLabel = Visuals:Toggle({Name = "Highlight", Flag = "Highlight", Default = false, Callback = function(Value)
        print(Value)
    end})
    HighlightLabel:Colorpicker({Name = "Color", Flag = "Highlight Color", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
        print(Value)
    end})
    HighlightLabel:Colorpicker({Name = "Outline Color", Flag = "Highlight Outline Color", Default = Color3.fromRGB(0, 0, 0), Callback = function(Value)
        print(Value)
    end})
    local ScrollableSection = CombatTab:ScrollableSection({Name = "Section", Side = 2, Size = 185})
    for Index = 1, 25 do
        ScrollableSection:Toggle({Name = "Toggle", Flag = "Toggle1234" .. Index})
    end
    ScrollableSection:Slider({Name = "Slider", Min = 0, Max = 100, Default = 50, Suffix = "%", Decimals = 1, Compact = true, Flag = "Slider"})
end
do -- Misc tab
    local AimbotSection = NewSubtab:Section({Name = "Aimbot", Side = 1})
    AimbotSection:Toggle({Name = "Enabled", Flag = "Enabled", Default = false, Callback = function(Value)
        print(Value)
    end}):Keybind({Name = "Hotkey", Flag = "Hotkey", Default = Enum.KeyCode.Z, Mode = "Toggle", Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Slider({Name = "Hit Chance", Min = 0, Max = 100, Default = 100, Suffix = "%", Decimals = 1, Compact = true, Flag = "Hit Chance", Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Toggle({Name = "FoV", Flag = "FoV", Default = false, Callback = function(Value)
        print(Value)
    end}):Colorpicker({Name = "FoV Color", Flag = "FoV Color", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value, Alpha)
        print(Value, Alpha)
    end})
    local Divider = AimbotSection:Divider()
    AimbotSection:Toggle({Name = "Silent Aim", Flag = "Silent Aim", Default = false, Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Toggle({Name = "Auto Fire", Flag = "Auto Fire", Default = false, Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Slider({Name = "FoV Size", Min = 0, Max = 1000, Default = 50, Decimals = 0.1, Flag = "FoV Size", Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Dropdown({Name = "Bone", Flag = "Bone", Default = "Head", Items = {"Head", "Torso", "Cock", "Ass🤤"}, Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Dropdown({Name = "Multi part", Flag = "Multi Bone", Default = {"Head", "Torso"}, Multi = true, Items = {"Head", "Torso", "Cock", "Ass🤤"}, Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Toggle({Name = "Visible Check", Flag = "Visible Check2", Default = false, Callback = function(Value)
        print(Value)
    end})
    AimbotSection:Toggle({Name = "Wall Check", Flag = "Wall Check2", Default = false, Callback = function(Value)
        print(Value)
    end})
    local WeaponSection = NewSubtab:Section({Name = "Weapon", Side = 2})
    WeaponSection:Toggle({Name = "Auto reload", Flag = "Auto Reload", Default = false, Callback = function(Value)
        print(Value)
    end})
    WeaponSection:Toggle({Name = "Infinite ammo", Flag = "Infinite Ammo", Default = false, Callback = function(Value)
        print(Value)
    end})
    WeaponSection:Toggle({Name = "No recoil", Flag = "No Recoil", Default = false, Callback = function(Value)
        print(Value)
    end})
    WeaponSection:Toggle({Name = "No spread", Flag = "No spread", Default = false, Callback = function(Value)
        print(Value)
    end})
    WeaponSection:Toggle({Name = "Instant hit", Flag = "Instant hit", Default = false, Callback = function(Value)
        print(Value)
    end})
    WeaponSection:Toggle({Name = "Instant reload", Flag = "Instant reload", Default = false, Callback = function(Value)
        print(Value)
    end})
    WeaponSection:Toggle({Name = "Rapid fire", Flag = "Rapid fire", Default = false, Callback = function(Value)
        print(Value)
    end})
    local Ragebot, Originscan, Visuals = NewSubtab:MultiSection({Sections = {"Ragebot", "Origin scan", "Visuals"}, Side = 2})
    Ragebot:Toggle({Name = "Enabled", Flag = "Ragebot", Default = false, Callback = function(Value)
        print(Value)
    end})
    Ragebot:Toggle({Name = "Visible Check", Flag = "Visible Check", Default = false, Callback = function(Value)
        print(Value)
    end})
    Ragebot:Toggle({Name = "Wall Check", Flag = "Wall Check", Default = false, Callback = function(Value)
        print(Value)
    end})
    Originscan:Toggle({Name = "Enabled", Flag = "Origin Scan", Default = false, Callback = function(Value)
        print(Value)
    end})
    Originscan:Slider({Name = "Studs", Min = 0, Max = 50, Default = 15, Decimals = 1, Flag = "st", Callback = function(Value)
        print(Value)
    end})
    Visuals:Toggle({Name = "Enabled", Flag = "Visuals", Default = false, Callback = function(Value)
        print(Value)
    end})
    Visuals:Toggle({Name = "Indicator", Flag = "Box", Default = false, Callback = function(Value)
        print(Value)
    end}):Colorpicker({Name = "Color", Flag = "Box Color", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
        print(Value)
    end})
    local HighlightLabel = Visuals:Toggle({Name = "Highlight", Flag = "Highlight", Default = false, Callback = function(Value)
        print(Value)
    end})
    HighlightLabel:Colorpicker({Name = "Color", Flag = "Highlight Color", Default = Color3.fromRGB(255, 255, 255), Callback = function(Value)
        print(Value)
    end})
    HighlightLabel:Colorpicker({Name = "Outline Color", Flag = "Highlight Outline Color", Default = Color3.fromRGB(0, 0, 0), Callback = function(Value)
        print(Value)
    end})
    local ScrollableSection = NewSubtab:ScrollableSection({Name = "Section", Side = 2, Size = 185})
    for Index = 1, 25 do
        ScrollableSection:Toggle({Name = "Toggle", Flag = "Toggle1234" .. Index})
    end
    ScrollableSection:Slider({Name = "Slider", Min = 0, Max = 100, Default = 50, Suffix = "%", Decimals = 1, Compact = true, Flag = "Slider"})
end
do -- Players Tab
    local PlayersSection = PlayersTab:Section({Name = "Player List", Side = 1})
    local SelectedPlayer = nil
    local isSpectating = false
    local Highlights = {}
    local function getPlayerList()
        local list = {}
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer then
                table.insert(list, p.Name .. " - " .. p.UserId)
            end
        end
        return list
    end
    local function onSelect(Value)
        local parts = string.split(Value, " - ")
        if parts[1] then
            SelectedPlayer = game.Players:FindFirstChild(parts[1])
        end
    end
    local PlayerList = PlayersSection:Listbox({
        Size = 400,
        Items = getPlayerList(),
        Multi = false,
        Flag = "PlayerList",
        Callback = onSelect
    })
    local function refreshPlayers()
        PlayerList:Refresh(getPlayerList())
    end
    game.Players.PlayerAdded:Connect(refreshPlayers)
    game.Players.PlayerRemoving:Connect(function(player)
        refreshPlayers()
        if SelectedPlayer == player then
            SelectedPlayer = nil
        end
        if Highlights[player] then
            Highlights[player]:Destroy()
            Highlights[player] = nil
        end
        if isSpectating and SelectedPlayer == player then
            workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            isSpectating = false
        end
    end)
    refreshPlayers()
    PlayersSection:Button({Name = "Teleport", Callback = function()
        local player = SelectedPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
        end
    end})
    PlayersSection:Button({Name = "Spectate", Callback = function()
        local player = SelectedPlayer
        if isSpectating then
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
                isSpectating = false
            end
        else
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
                isSpectating = true
            end
        end
    end})
    PlayersSection:Button({Name = "Friendly", Callback = function()
        local player = SelectedPlayer
        if player and player.Character then
            if Highlights[player] then
                Highlights[player]:Destroy()
                Highlights[player] = nil
            else
                local hl = Instance.new("Highlight")
                hl.Parent = player.Character
                hl.FillColor = Library.Theme.Accent
                hl.OutlineColor = Library.Theme.Accent
                Highlights[player] = hl
            end
        end
    end})
end
do -- Settings Tab
    local SettingsSection = SettingsTab:Section({Name = "Settings", Side = 2})
    local ConfigsSection = SettingsTab:Section({Name = "Profiles", Side = 1})
    for Index, Value in Library.Theme do
        SettingsSection:Label({Name = Index, Alignment = "Left"}):Colorpicker({ Name = Index, Default = Value, Flag = "Theme"..Index, Callback = function(Color)
            Library.Theme[Index] = Color
            Library:ChangeTheme(Index, Color)
        end})
    end
    SettingsSection:Label({Name = "Menu Keybind", Alignment = "Left"}):Keybind({Name = "Menu Keybind", Flag = "Menu Keybind", Default = Enum.KeyCode.RightControl, Mode = "Toggle", Callback = function(Value)
        Library.MenuKeybind = Library.Flags["Menu Keybind"].Key
    end})
    SettingsSection:Toggle({Name = "Watermark", Flag = "Watermark", Default = false, Callback = function(Value)
        Watermark:SetVisibility(Value)
    end})
    SettingsSection:Toggle({Name = "Keybind List", Flag = "Keybind List", Default = false, Callback = function(Value)
        KeybindList:SetVisibility(Value)
    end})
    SettingsSection:Dropdown({Name = "Tweening Style", Flag = "Tweening Style", Default = "Exponential", Items = {"Linear", "Sine", "Quad", "Cubic", "Quart", "Quint", "Exponential", "Circular", "Back", "Elastic", "Bounce"}, Callback = function(Value)
        Library.Tween.Style = Enum.EasingStyle[Value]
    end})
    SettingsSection:Dropdown({Name = "Tweening Direction", Flag = "Tweening Direction", Default = "Out", Items = {"In", "Out", "InOut"}, Callback = function(Value)
        Library.Tween.Direction = Enum.EasingDirection[Value]
    end})
    SettingsSection:Slider({Name = "Tweening Time", Min = 0, Max = 5, Default = 0.25, Decimals = 0.01, Flag = "Tweening Time", Callback = function(Value)
        Library.Tween.Time = Value
    end})
    SettingsSection:Button({Name = "Notification test", Callback = function()
        Library:Notification("This is a notification This is a notification This is a notification This is a notification", 5, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
    end})
    SettingsSection:Button({Name = "Unload library", Callback = function()
        Library:Unload()
    end})
    local ConfigName
    local ConfigSelected
    local ConfigsListbox = ConfigsSection:Listbox({Items = { }, Name = "Configs", Flag = "Configs List", Callback = function(Value)
        ConfigSelected = Value
    end})
    ConfigsSection:Textbox({Name = "Config Name", Placeholder = ". .", Flag = "Config Name", Callback = function(Value)
        ConfigName = Value
    end})
    ConfigsSection:Button({Name = "Create Config", Callback = function()
        if not isfile(Library.Folders.Configs .. "/" .. ConfigName .. ".json") then
            writefile(Library.Folders.Configs .. "/" .. ConfigName .. ".json", Library:GetConfig())
            Library:RefreshConfigsList(ConfigsListbox)
        else
            Library:Notification("Config '" .. ConfigName .. ".json' already exists", 3, Color3.FromR(255, 0, 0))
            return
        end
    end})
    ConfigsSection:Button({Name = "Load Config", Callback = function()
        if ConfigSelected then
            Library:LoadConfig(readfile(Library.Folders.Configs .. "/" .. ConfigSelected))
        end
        Library:Thread(function()
            task.wait(0.1)
            for Index, Value in Library.Theme do
                Library.Theme[Index] = Library.Flags["Theme"..Index].Color
                Library:ChangeTheme(Index, Library.Flags["Theme"..Index].Color)
            end
        end)
    end})
    ConfigsSection:Button({Name = "Delete Config", Callback = function()
        if ConfigSelected then
            Library:DeleteConfig(ConfigSelected)
            Library:RefreshConfigsList(ConfigsListbox)
        end
    end})
    ConfigsSection:Button({Name = "Save Config", Callback = function()
        if ConfigSelected then
            Library:SaveConfig(ConfigSelected)
        end
    end})
    ConfigsSection:Button({Name = "Refresh Configs", Callback = function()
        Library:RefreshConfigsList(ConfigsListbox)
    end})
    Library:RefreshConfigsList(ConfigsListbox)
end

Library:Notification(string.format("Loaded in %.4f seconds", os.clock() - LoadingTick), 5, Library.Theme.Accent, {"rbxassetid://135757045959142", Color3.fromRGB(149, 255, 139)})

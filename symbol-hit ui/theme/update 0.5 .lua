local LoadingTick = os.clock()
if getgenv().Library then
    getgenv().Library:Unload()
end

-- Service references - simplified version
local serviceCache = {}
do
    local function initServices()
        local cache = {}

        cache.Players = cloneref(game:GetService('Players'))
        cache.RunService = cloneref(game:GetService('RunService'))
        cache.UserInputService = cloneref(game:GetService('UserInputService'))
        cache.HttpService = cloneref(game:GetService('HttpService'))
        cache.Stats = cloneref(game:GetService('Stats'))
        cache.Lighting = cloneref(game:GetService('Lighting'))
        cache.TeleportService = cloneref(game:GetService('TeleportService'))    
        cache.MarketplaceService = cloneref(game:GetService('MarketplaceService'))
        cache.TweenService = cloneref(game:GetService('TweenService'))
        cache.ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
        cache.StarterGui = cloneref(game:GetService('StarterGui'))
        cache.CoreGui = cloneref(game:GetService('CoreGui'))
        cache.Debris = cloneref(game:GetService('Debris'))
        cache.lp = cache.Players.LocalPlayer
        cache.cam = workspace.CurrentCamera
        cache.ws = workspace
        cache.huge = math.huge
        cache.floor = math.floor
        cache.ceil = math.ceil
        cache.random = math.random
        cache.abs = math.abs
        cache.sin = math.sin
        cache.cos = math.cos
        cache.rad = math.rad
        cache.clamp = math.clamp
        cache.min = math.min
        cache.max = math.max
        cache.sqrt = math.sqrt
        cache.atan2 = math.atan2
        cache.pi = math.pi
        cache.insert = table.insert
        cache.remove = table.remove
        cache.sort = table.sort
        cache.concat = table.concat
        cache.clear = table.clear
        cache.find = table.find
        cache.vec2 = Vector2.new
        cache.vec3 = Vector3.new
        cache.cfr = CFrame.new
        cache.cfrAngles = CFrame.Angles
        cache.dim2 = UDim2.new
        cache.dim = UDim.new
        cache.c3 = Color3.new
        cache.c3rgb = Color3.fromRGB
        cache.c3hsv = Color3.fromHSV
        cache.c3hex = Color3.fromHex
        cache.tweenFast = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        cache.tweenMedium = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        cache.tweenSlow = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        function cache.getPing()
            local item = cache.Stats.Network.ServerStatsItem:FindFirstChild('Data Ping')

            if item then
                local ok, v = pcall(function()
                    return item:GetValueString()
                end)

                if ok and v then
                    return (tonumber(v:match('%d+')) or 0) / 1000
                end
            end

            return 0
        end
        
        function cache.getPingMs()
            local item = cache.Stats.Network.ServerStatsItem:FindFirstChild('Data Ping')

            if item then
                local ok, v = pcall(function()
                    return item:GetValueString()
                end)

                if ok and v then
                    return tonumber(v:match('%d+')) or 0
                end
            end

            return 0
        end
        
        function cache.getMainEvent()
            return cache.ReplicatedStorage:WaitForChild('MainEvent')
        end

        cache.icons = {
            ragebot = 'rbxassetid://10734934585',
            misc = 'rbxassetid://10709811939',
            visuals = 'rbxassetid://10723346959',
            settings = 'rbxassetid://10734950309',
        }

        return cache
    end
    
    serviceCache = initServices()
end

-- Create the library directly
local Library = (function()
    local Env = getgenv()

    if getgenv().Library then
        getgenv().Library.Utility.unload()
    end

    local Players = game:GetService('Players')
    local UserInputService = game:GetService('UserInputService')
    local RunService = game:GetService('RunService')
    local CoreGui = game:GetService('CoreGui')
    local HttpService = game:GetService('HttpService')
    local TweenService = game:GetService('TweenService')
    local TeleportService = game:GetService('TeleportService')
    local Workspace = game:GetService('Workspace')
    local GuiService = game:GetService('GuiService')
    local Lighting = game:GetService('Lighting')
    local Stats = game:GetService('Stats')

    if not LPH_OBFUSCATED then
        LPH_ENCSTR = function(...)
            return ...
        end
        LPH_ENCNUM = function(...)
            return ...
        end
        LPH_CRASH = function(...)
            return ...
        end
        LPH_JIT = function(...)
            return ...
        end
        LPH_JIT_MAX = function(...)
            return ...
        end
        LPH_NO_VIRTUALIZE = function(...)
            return ...
        end
        LPH_NO_UPVALUES = function(...)
            return ...
        end
    end

    local Camera = workspace.CurrentCamera
    local HiddenUI = gethui()
    local LocalPlayer = Players.LocalPlayer
    local Loaded = false
    local Acceleration = Vector3.new(0, -Workspace.Gravity, 0)

    getgenv().Library = {}

    local BinLib = {
        methods = {
            ['function'] = true,
            thread = true,
            RBXScriptConnection = 'Disconnect',
        },
    }

    do
        function BinLib.bin()
            local bin = {storage = {}}

            function bin:add(item, method)
                table.insert(self.storage, {
                    main = item,
                    destroy = function()
                        local destroyMethod = method or BinLib.methods[typeof(item)] or 'Destroy'

                        if destroyMethod == true then
                            if type(item) == 'function' then
                                item()
                            else
                                task.cancel(item)
                            end
                        else
                            local callMethod = item[destroyMethod]

                            if callMethod then
                                callMethod(item)
                            end
                        end
                    end,
                })

                return item
            end
            
            function bin:destroy()
                if not (self and self.storage) then
                    return
                end

                for _, entry in ipairs(self.storage)do
                    if entry and entry.destroy then
                        entry.destroy()
                    end
                end

                self.storage = nil
            end

            return bin
        end
    end

    getgenv().Library.BinLib = BinLib
    local Bin = BinLib.bin()
    getgenv().Library.Bin = Bin

    local Utility = {}

    do
        function Utility.unload()
            Bin:destroy()

            getgenv().Library = nil
        end
        
        function Utility.Connect(connection)
            Bin:add(connection)

            return connection
        end
        
        function Utility.New(sqr, props)
            local Obj = Instance.new(sqr)

            if props then
                for _, v in props do
                    Obj[_] = v
                end
            end

            Bin:add(Obj)

            return Obj
        end
        
        function Utility.Round(number, float)
            local Mult = 1 / (float or 1)

            return math.floor(number * Mult + 0.5) / Mult
        end
        
        function Utility.GetTrans(obj)
            local Index

            if obj:IsA('Frame') then
                Index = 'BackgroundTransparency'
            elseif obj:IsA('TextLabel') or obj:IsA('TextButton') then
                Index = 'TextTransparency'
            elseif obj:IsA('ImageLabel') or obj:IsA('ImageButton') then
                Index = 'ImageTransparency'
            elseif obj:IsA('ScrollingFrame') then
                Index = 'BackgroundTransparency'
            elseif obj:IsA('TextBox') then
                Index = 'TextTransparency'
            end

            return Index
        end
        
        function Utility.GetFiles(folder, extensions)
            if not isfolder(folder) then
                makefolder(folder)
            end

            local Files = isfolder(folder) and listfiles(folder) or {}
            local StoredFiles = {}
            local FileNames = {}

            for _, v in Files do
                for _, ext in extensions do
                    if v:find(ext) then
                        StoredFiles[#StoredFiles + 1] = v
                        FileNames[#FileNames + 1] = v:gsub(folder, ''):gsub(ext, '')
                    end
                end
            end

            return StoredFiles, FileNames
        end
        
        function Utility.Lerp(a, b, c)
            c = c or 0.125

            local offset = math.abs(b - a)

            if (offset < c) then
                return b
            end

            return a + (b - a) * c
        end
        
        function Utility.LineMath(obj, from, to, thickness)
            local Direction = (to - from)
            local Center = (to + from) / 2
            local Distance = Direction.Magnitude
            local Theta = math.deg(math.atan2(Direction.Y, Direction.X))

            obj.Position = UDim2.fromOffset(Center.x, Center.y)
            obj.Rotation = Theta
            obj.Size = UDim2.fromOffset(Distance, thickness)
        end

        Utility.Signal = Utility.Connect
    end

    getgenv().Library.Utility = Utility

    local Games = {
        Data = {
            ['Arsenal'] = {
                Name = 'Arsenal',
                GameId = 111958650,
                GetInfo = function(data, player, ...)
                    local NRPBS = player:FindFirstChild('NRPBS')
                    local Health = NRPBS and NRPBS:FindFirstChild('Health')
                    local MaxHealth = NRPBS and NRPBS:FindFirstChild('MaxHealth')
                    local EquippedTool = NRPBS and NRPBS:FindFirstChild('EquippedTool')

                    data.Tool = EquippedTool and EquippedTool.Value or nil
                    data.Health = Health and Health.Value or 0
                    data.MaxHealth = MaxHealth and MaxHealth.Value or 100
                end,
            },
            ['Apocalypse Rising 2'] = {
                Name = 'Apocalypse Rising 2',
                GameId = 358276974,
                GetPlayers = function()
                    local Entities = Players:GetPlayers()
                    local Zombies = workspace:FindFirstChild('Zombies')

                    if not Zombies then
                        return Entities
                    end

                    local Mobs = Zombies:FindFirstChild('Mobs')

                    if not Mobs then
                        return Entities
                    end

                    for _, mob in Mobs:GetChildren()do
                        table.insert(Entities, mob)
                    end

                    return Entities
                end,
                GetInfo = function(data, player, ...)
                    if data.IsPlayer then
                        local Stats = player:FindFirstChild('Stats')
                        local Health = Stats and Stats:FindFirstChild('Health')
                        local Weapon = Stats and Stats:FindFirstChild('Primary')

                        data.Tool = Weapon and Weapon.Value or nil
                        data.Health = Health and Health.Value or 0
                    else
                        data.Tool = 'None'
                        data.Health = 100
                        data.MaxHealth = 100
                        data.Team = nil
                        data.IsTeammate = false
                    end
                end,
            },
            ['Typical Colors 2'] = {
                Name = 'Typical Colors 2',
                GameId = 147332621,
                GetInfo = function(data, player, ...)
                    local Character = data.Character
                    local Gun = Character and Character:FindFirstChild('Gun')
                    local Boop = Gun and Gun:FindFirstChild('Boop')

                    data.Tool = Boop and Boop.Value or nil
                end,
            },
        },
    }

    function Games.GetGame()
        for _, v in Games.Data do
            if game.GameId == v.GameId then
                return v
            end
        end

        return nil
    end

    local Game = Games.GetGame()
    local GameName = Game and Game.Name or ''
    local Folder = 'Library'

    makefolder(Folder)

    local ImagesFolder = string.format('%s\\%s\\', Folder, 'Images')

    makefolder(ImagesFolder)

    local FontsFolder = string.format('%s\\%s\\', Folder, 'FontsFolder')

    makefolder(FontsFolder)

    local ConfigFolder = string.format('%s\\%s\\', Folder, 'Configs')

    makefolder(ConfigFolder)

    local SoundsFolder = string.format('%s\\%s\\', Folder, 'Sounds')

    makefolder(SoundsFolder)

    local Folders = {
        Root = Folder,
        GetPath = function(subfolder)
            return string.format('%s\\%s', Folder, subfolder)
        end,
        Create = function(subfolder)
            local path = Folders.GetPath(subfolder)

            if not isfolder(path) then
                makefolder(path)
            end

            return path
        end,
    }

    getgenv().Library.Folders = Folders

    task.spawn(function()
        local soundsPath = Folders.GetPath('Sounds')

        local function downloadSound(fileName, url)
            local path = soundsPath .. '\\' .. fileName

            if isfile(path) then
                return true
            end

            local success, data = pcall(function()
                return game:HttpGet(url)
            end)

            if success and data then
                writefile(path, data)

                return true
            end

            return false
        end

        local success1, response1 = pcall(function()
            return game:HttpGet(
[[https://api.github.com/repos/OnChangedCallback/sounds/contents/main]])
        end)

        if success1 then
            local jsonSuccess, data = pcall(function()
                return HttpService:JSONDecode(response1)
            end)

            if jsonSuccess and type(data) == 'table' then
                for _, file in ipairs(data)do
                    if file.name and file.name:match('%.wav$') then
                        downloadSound(file.name, file.download_url)
                    end
                end
            end
        end

        local success2, response2 = pcall(function()
            return game:HttpGet(
[[https://api.github.com/repos/f1nobe7650/Nebula/contents/Sounds]])
        end)

        if success2 then
            local jsonSuccess, data = pcall(function()
                return HttpService:JSONDecode(response2)
            end)

            if jsonSuccess and type(data) == 'table' then
                for _, file in ipairs(data)do
                    if file.name and (file.name:match('%.wav$') or file.name:match('%.mp3$') or file.name:match('%.ogg$')) then
                        downloadSound('Nebula_' .. file.name, 
[[https://github.com/f1nobe7650/Nebula/raw/refs/heads/main/Sounds/]] .. file.name)
                    end
                end
            end
        end
    end)

    local Fonts = {
        URL = 
[[https://raw.githubusercontent.com/luminbot/FontStorage/main/]],
        Names = {
            'Proggy',
            'ProggyTiny',
            'Minecraftia',
            'SmallestPixel7',
            'Verdana',
            'VerdanaBold',
            'Tahoma',
            'ProggyClean',
            'TahomaXP',
        },
        Data = {},
    }

    do
        function Fonts.Load(font)
            local TTF = string.format('%s%s.ttf', FontsFolder, font)
            local JSON = string.format('%s%s.json', FontsFolder, font)

            if not isfile(TTF) then
                local success, data = pcall(function()
                    return game:HttpGet(string.format('%s%s.txt', Fonts.URL, font))
                end)

                if success and data then
                    writefile(TTF, base64_decode(data))
                else
                    return
                end
            end
            if not isfile(JSON) then
                local Font = {
                    name = font,
                    faces = {
                        {
                            name = 'Regular',
                            weight = 400,
                            style = 'normal',
                            assetId = getcustomasset(TTF),
                        },
                    },
                }

                writefile(JSON, HttpService:JSONEncode(Font))
            end

            Fonts.Data[font] = Font.new(getcustomasset(JSON), Enum.FontWeight.Regular)
        end
        
        function Fonts.Get(font)
            return Fonts.Data[font]
        end

        for _, font in Fonts.Names do
            Fonts.Load(font)
        end
    end

    getgenv().Library.Fonts = Fonts

    local Images = {
        URL = 
[[https://raw.githubusercontent.com/OxygenClub/LUAS/refs/heads/main/pictures/]],
        Names = {
            'gear',
        },
        Data = {},
    }

    do
        function Images.Load(image)
            local PNG = string.format('%s%s.png', ImagesFolder, image)

            if not isfile(PNG) then
                local success, data = pcall(function()
                    return game:HttpGet(string.format('%s%s.txt', Images.URL, image))
                end)

                if success and data then
                    writefile(PNG, base64_decode(data))
                else
                    return
                end
            end

            Images.Data[image] = getcustomasset(PNG)
        end
        
        function Images.Get(image)
            return Images.Data[image]
        end

        for _, image in Images.Names do
            Images.Load(image)
        end
    end

    getgenv().Library.Images = Images

    local AssetLoader = {
        URL = 'https://raw.githubusercontent.com/GhoulSER/env/main/',
        AssetsFolder = string.format('%s\\%s\\', Folder, 'assets'),
        Names = {
            'peter.png',
        },
        Data = {},
        AssetNames = {},
    }

    do
        makefolder(AssetLoader.AssetsFolder)

        function AssetLoader:Init(directory)
            self.AssetsFolder = string.format('%s\\%s\\', directory, 'assets')

            if not isfolder(self.AssetsFolder) then
                makefolder(self.AssetsFolder)
            end
        end
        
        function AssetLoader:LoadAsset(assetName)
            local ext = assetName:match('%.([^%.]+)$') or 'png'
            local fileName = assetName:match('%.([^%.]+)$') and assetName or (assetName .. '.png')
            local filePath = string.format('%s%s', self.AssetsFolder, fileName)

            if isfile(filePath) then
                local success, asset = pcall(function()
                    return getcustomasset(filePath)
                end)

                if success and asset then
                    self.Data[assetName] = asset

                    if not table.find(self.AssetNames, assetName) then
                        table.insert(self.AssetNames, assetName)
                    end

                    return asset
                else
                    warn('[AssetLoader] Failed to load asset from file: ' .. filePath)

                    return nil
                end
            else
                local success, data = pcall(function()
                    return game:HttpGet(string.format('%s%s', self.URL, fileName))
                end)

                if success and data then
                    writefile(filePath, data)

                    local success, asset = pcall(function()
                        return getcustomasset(filePath)
                    end)

                    if success and asset then
                        self.Data[assetName] = asset

                        if not table.find(self.AssetNames, assetName) then
                            table.insert(self.AssetNames, assetName)
                        end

                        return asset
                    else
                        warn('[AssetLoader] Failed to load asset from file: ' .. filePath)

                        return nil
                    end
                else
                    warn('[AssetLoader] Failed to load ' .. fileName .. 
[[ from GitHub. Make sure the file exists in the assets folder or on GitHub.]])

                    return nil
                end
            end
        end
        
        function AssetLoader:GetCustomAsset(assetName)
            if self.Data[assetName] then
                return self.Data[assetName]
            end

            return self:LoadAsset(assetName)
        end
        
        function AssetLoader:GetAssetNames()
            return self.AssetNames
        end
        
        function AssetLoader:LoadAll(assetNames)
            if assetNames then
                for _, name in ipairs(assetNames)do
                    self:LoadAsset(name)
                end
            else
                local files = isfolder(self.AssetsFolder) and listfiles(self.AssetsFolder) or {}

                for _, filePath in ipairs(files)do
                    local fileName = filePath:gsub(self.AssetsFolder, '')

                    if fileName ~= '' then
                        self:LoadAsset(fileName)
                    end
                end
            end
        end
        
        function AssetLoader:PreloadDefaults()
            for _, name in ipairs(self.Names)do
                self:LoadAsset(name)
            end
        end
    end
    
    do
        AssetLoader:PreloadDefaults()
        AssetLoader:LoadAll()
    end

    getgenv().Library.AssetLoader = AssetLoader

    local Library = {
        TweenSpeed = 0.2,
        TweenStyle = Enum.EasingStyle.Quad,
        ThemeObjects = {},
        Font = Font.new('rbxassetid://12187365364', Enum.FontWeight.Bold),
        FontSize = 15,
        Flags = {},
        ConfigFlags = {},
        LoadConfigCallbacks = {},
        OnToggleChange = nil,
        Popups = {},
        Dropdowns = {},
        Fps = 0,
        ScrollBar = 'rbxassetid://12776289446',
        Saturation = 'rbxassetid://13901004307',
        Checkers = 'http://www.roblox.com/asset/?id=18274452449',
        Checkmark = 'rbxassetid://10709790644',
        Converts = {
            [0] = '0',
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
        },
        KeyConverters = {
            escape = 'ESC',
            backquote = '`',
            backspace = 'BSP',
            slash = '/',
            leftquote = "'",
            rightquote = '"',
            leftbracket = '[',
            rightbracket = ']',
            semicolon = ';',
            comma = ',',
            period = '.',
            backslash = '\\',
            minus = '-',
            equals = '=',
            space = 'SPC',
            ['return'] = 'ENT',
            tab = 'TAB',
            capslock = 'CAP',
            leftshift = 'LSH',
            mousebutton1 = 'MB1',
            mousebutton2 = 'MB2',
            mousebutton3 = 'MB3',
            rightshift = 'RSH',
            leftcontrol = 'CTRL',
            leftalt = 'ALT',
            leftsuper = 'WIN',
            rightcontrol = 'CTRL',
            rightalt = 'ALT',
            rightsuper = 'WIN',
            insert = 'INS',
            delete = 'DEL',
            home = 'HME',
            pageup = 'PUD',
            pagedown = 'PDN',
            up = 'UP',
            down = 'DWN',
            left = 'LFT',
            right = 'RGT',
            numlock = 'NUM',
            numpad0 = 'N0',
            numpad1 = 'N1',
            numpad2 = 'N2',
            numpad3 = 'N3',
            numpad4 = 'N4',
            numpad5 = 'N5',
            numpad6 = 'N6',
            numpad7 = 'N7',
            numpad8 = 'N8',
            numpad9 = 'N9',
        },
        Theme = {
            Inline = Color3.fromRGB(52, 52, 52),
            Background = Color3.fromRGB(36, 36, 36),
            ['Page Background'] = Color3.fromRGB(22, 22, 22),
            ['Section Background'] = Color3.fromRGB(30, 30, 30),
            ['Dark Background'] = Color3.fromRGB(19, 19, 19),
            Accent = Color3.fromRGB(0, 134, 229),
            ['Dark Text'] = Color3.fromRGB(120, 120, 120),
            ['Light Text'] = Color3.fromRGB(160, 160, 160),
            Text = Color3.fromRGB(220, 220, 220),
        },
        Notifications = {},
    }

    Library.__index = Library

    do
        Library.Folders = Folders
        Library.Utility = {
            Objects = {},
            Connections = {},
        }

        local Utility = Library.Utility

        do
            function Utility.New(object, props, theme)
                local Obj = Instance.new(object)

                if props then
                    for prop, val in props do
                        Obj[prop] = val
                    end
                end
                if theme then
                    Library.AddObjectTheme(Obj, theme)
                end

                table.insert(Utility.Objects, Obj)

                return Obj
            end
            
            function Utility.Signal(connection)
                table.insert(Utility.Connections, connection)

                return connection
            end
            
            function Utility.GetTransparency(obj)
                if obj:IsA('Frame') then
                    return 'BackgroundTransparency'
                elseif obj:IsA('TextLabel') or obj:IsA('TextButton') then
                    return {
                        'TextTransparency',
                        'BackgroundTransparency',
                    }
                elseif obj:IsA('ImageLabel') or obj:IsA('ImageButton') then
                    return {
                        'BackgroundTransparency',
                        'ImageTransparency',
                    }
                elseif obj:IsA('ScrollingFrame') then
                    return {
                        'BackgroundTransparency',
                        'ScrollBarImageTransparency',
                    }
                elseif obj:IsA('TextBox') then
                    return {
                        'TextTransparency',
                        'BackgroundTransparency',
                    }
                end

                return nil
            end
            
            function Utility.Round(number, float)
                local Mult = 1 / (float or 1)

                return math.floor(number * Mult + 0.5) / Mult
            end
            
            function Utility.PositionOver(position, object, addedy)
                addedy = addedy or 0

                local posX, posY = object.AbsolutePosition.X, (object.AbsolutePosition.Y - addedy)
                local size = object.AbsoluteSize
                local sizeX, sizeY = posX + size.X, posY + size.Y + addedy

                if position.X >= posX and position.Y >= posY and position.X <= sizeX and position.Y <= sizeY then
                    return true
                end

                return false
            end
            
            function Utility.MouseOver(object, input)
                local posX, posY = object.AbsolutePosition.X, object.AbsolutePosition.Y
                local size = object.AbsoluteSize
                local sizeX, sizeY = posX + size.X, posY + size.Y
                local position = input.Position

                if position.X >= posX and position.Y >= posY and position.X <= sizeX and position.Y <= sizeY then
                    return true
                end

                return false
            end
            
            function Utility.Lerp(a, b, c)
                c = c or 0.125

                local offset = math.abs(b - a)

                if (offset < c) then
                    return b
                end

                return a + (b - a) * c
            end
            
            function Utility.StringToEnum(enumstring)
                local EnumType, EnumValue = enumstring:match('Enum%.([^%.]+)%.(.+)')

                if EnumType and EnumValue then
                    return Enum[EnumType][EnumValue]
                end

                return nil
            end
            
            function Utility.TextTriggers(text)
                local gameName = 'Universal'
                local success, result = pcall(function()
                    return game:GetService('MarketplaceService'):GetProductInfo(game.PlaceId, Enum.InfoType.Asset).Name
                end)

                if success and result then
                    gameName = result
                end

                local Triggers = {
                    ['{hour}'] = os.date('%H'),
                    ['{minute}'] = os.date('%M'),
                    ['{second}'] = os.date('%S'),
                    ['{ap}'] = os.date('%p'),
                    ['{month}'] = os.date('%b'),
                    ['{day}'] = os.date('%d'),
                    ['{year}'] = os.date('%Y'),
                    ['{fps}'] = Library.Fps,
                    ['{ping}'] = math.floor(Stats.PerformanceStats.Ping:GetValue() or 0),
                    ['{time}'] = os.date('%H:%M:%S'),
                    ['{date}'] = os.date('%b. %d, %Y'),
                    ['{game}'] = gameName,
                    ['{n}'] = '\n',
                }

                for i, v in Triggers do
                    text = string.gsub(text, i, v)
                end

                return text
            end
        end

        Library.ScreenGui = Utility.New('ScreenGui', {
            Name = '\0',
            DisplayOrder = 1,
            Parent = HiddenUI,
        })

        function Library.Tween(obj, props, tweeninfo)
            tweeninfo = tweeninfo or TweenInfo.new(Library.TweenSpeed, Library.TweenStyle)

            local Tween = TweenService:Create(obj, tweeninfo, props)

            Tween:Play()

            return Tween
        end
        
        function Library.Fade(obj, prop, vis)
            if not obj or not prop or not pcall(function()
                return obj.Visible
            end) then
                return
            end

            local OldTransparency = obj[prop]

            obj[prop] = vis and 1 or OldTransparency

            local Tween = Library.Tween(obj, {
                [prop] = vis and OldTransparency or 1,
            })

            Utility.Signal(Tween.Completed:Connect(function()
                if not vis then
                    task.wait()

                    obj[prop] = OldTransparency
                end
            end))

            return Tween
        end
        
        function Library.AddObjectTheme(object, props)
            local Theme = {
                Props = props,
                Object = object,
            }

            for prop, v in props do
                if type(v) == 'string' then
                    object[prop] = Library.Theme[v]
                elseif type(v) == 'function' then
                    object[prop] = v()
                end
            end

            Library.ThemeObjects[object] = Theme
        end
        
        function Library.ChangeObjectTheme(object, props, tweened)
            local Theme = Library.ThemeObjects[object]

            if Theme then
                Theme.Props = props

                for prop, v in props do
                    if type(v) == 'string' then
                        if tweened then
                            Theme.Tween = Library.Tween(object, {
                                [prop] = Library.Theme[v],
                            })
                        else
                            object[prop] = Library.Theme[v]
                        end
                    elseif type(v) == 'function' then
                        object[prop] = v()
                    end
                end
            end
        end
        
        function Library.UpdateTheme(theme, color)
            if not Library.Theme[theme] then
                return
            end

            Library.Theme[theme] = color

            for _, themeobj in Library.ThemeObjects do
                for prop, val in themeobj.Props do
                    if val == theme then
                        if themeobj.Tween then
                            themeobj.Tween:Cancel()
                        end

                        themeobj.Object[prop] = color
                    end
                end
            end
            
            if theme == 'Accent' then
                for _, obj in pairs(Utility.Objects) do
                    if obj.Name == 'ToggleIcon' and obj:IsA('ImageLabel') then
                        if obj.Visible then
                            obj.ImageColor3 = color
                        end
                    end
                end
            end
        end
        
        function Library.Config(cfg, default)
            local Table = {}

            for name, val in cfg do
                Table[name:lower()] = val
            end
            for name, val in default do
                if Table[name] == nil then
                    Table[name] = val
                end
            end

            return Table
        end
        
        function Library.Resize(holder, box)
            local Start, StartSize, Resizing
            local CurrentSize = holder.Size
            local OriginalSize = holder.Size

            Utility.Signal(box.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Resizing = true
                    Start = input.Position
                    StartSize = holder.Size
                end
            end))
            Utility.Signal(UserInputService.InputChanged:Connect(function(
                input
            )
                if input.UserInputType == Enum.UserInputType.MouseMovement and Resizing then
                    local ViewportSize = Camera.ViewportSize

                    CurrentSize = UDim2.new(0, math.clamp(StartSize.X.Offset + (input.Position.X - Start.X), OriginalSize.X.Offset, ViewportSize.x), 0, math.clamp(StartSize.Y.Offset + (input.Position.Y - Start.Y), OriginalSize.Y.Offset, ViewportSize.y))
                    holder.Size = CurrentSize
                end
            end))
            Utility.Signal(UserInputService.InputEnded:Connect(function(
                input
            )
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Resizing = false
                end
            end))
        end
        
        function Library.Dragging(holder, box)
            local Start, StartPos, Dragging
            local CurrentPos
            local Inset = GuiService:GetGuiInset()

            Utility.Signal(box.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    Start = input.Position
                    StartPos = holder.AbsolutePosition
                end
            end))
            Utility.Signal(UserInputService.InputChanged:Connect(function(
                input
            )
                if input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
                    local MaxSize = holder.AbsoluteSize
                    local ViewportSize = Camera.ViewportSize

                    CurrentPos = UDim2.new(0, math.clamp(StartPos.X + (input.Position.X - Start.X), 0, ViewportSize.x - MaxSize.x), 0, math.clamp(StartPos.Y + (input.Position.Y - Start.Y + 36), 0, ViewportSize.y - MaxSize.y) + (Inset.Y / 2))
                    holder.Position = CurrentPos
                end
            end))
            Utility.Signal(UserInputService.InputEnded:Connect(function(
                input
            )
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end))
        end
        
        function Library.ColorpickerWindow(self)
            local Popup = {
                Visible = false,
                Tweening = false,
                ZIndex = self.ZIndex,
                Objects = {},
                Flag = nil,
                SetFunc = function() end,
                Alpha = 1,
                Color = Color3.new(1, 1, 1),
                HuePos = nil,
            }
            local ZIndex = Popup.ZIndex
            local Objects = Popup.Objects

            do
                Objects.Outline = Utility.New('Frame', {
                    Name = 'Outline',
                    Size = UDim2.new(0, 200, 0, 150),
                    BorderSizePixel = 0,
                    Parent = Library.ScreenGui,
                    ZIndex = ZIndex,
                    ClipsDescendants = true,
                    Visible = false,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.Outline,
                    CornerRadius = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.Background = Utility.New('TextButton', {
                    Name = 'Background',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.fromOffset(1, 1),
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    BorderSizePixel = 0,
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.Background,
                    CornerRadius = UDim.new(0, 5),
                })
                Utility.New('UIPadding', {
                    Name = 'UIPadding',
                    Parent = Objects.Background,
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.SaturationOutline = Utility.New('TextButton', {
                    Name = 'SaturationOutline',
                    Size = UDim2.new(1, -14, 1, -14),
                    BorderSizePixel = 0,
                    Parent = Objects.Background,
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.SaturationOutline,
                    CornerRadius = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.SaturationBackground = Utility.New('ImageLabel', {
                    Name = 'SaturationBackground',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 255),
                    BorderSizePixel = 0,
                    Parent = Objects.SaturationOutline,
                    ZIndex = ZIndex,
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.SaturationBackground,
                    CornerRadius = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.SaturationImage = Utility.New('ImageLabel', {
                    Name = 'SaturationImage',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderSizePixel = 0,
                    Parent = Objects.SaturationOutline,
                    BackgroundTransparency = 1,
                    Image = Library.Saturation,
                    ZIndex = ZIndex,
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.SaturationImage,
                    CornerRadius = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.SaturationPickerOutline = Utility.New('TextButton', {
                    Name = 'SaturationPickerOutline',
                    Size = UDim2.new(0, 6, 0, 6),
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    Parent = Objects.SaturationImage,
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.SaturationPickerOutline,
                    CornerRadius = UDim.new(1, 0),
                })

                ZIndex = ZIndex + 1
                Objects.SaturationPicker = Utility.New('Frame', {
                    Name = 'SaturationPicker',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderSizePixel = 0,
                    Parent = Objects.SaturationPickerOutline,
                    ZIndex = ZIndex,
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.SaturationPicker,
                    CornerRadius = UDim.new(1, 0),
                })

                Objects.HueOutline = Utility.New('TextButton', {
                    Name = 'HueOutline',
                    Size = UDim2.new(0, 16, 1, 0),
                    Position = UDim2.new(1, -16, 0, 0),
                    BorderSizePixel = 0,
                    Parent = Objects.Background,
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.HueOutline,
                    CornerRadius = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.HueBackground = Utility.New('Frame', {
                    Name = 'HueBackground',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = Objects.HueOutline,
                    ZIndex = ZIndex,
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.HueBackground,
                    CornerRadius = UDim.new(0, 5),
                })
                Utility.New('UIGradient', {
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
                    },
                    Rotation = 90,
                    Parent = Objects.HueBackground,
                })

                ZIndex = ZIndex + 1
                Objects.HuePickerOutline = Utility.New('TextButton', {
                    Name = 'HuePickerOutline',
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    Parent = Objects.HueBackground,
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.HuePickerOutline,
                    CornerRadius = UDim.new(1, 0),
                })

                ZIndex = ZIndex + 1
                Objects.HuePicker = Utility.New('Frame', {
                    Name = 'SaturationPicker',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderSizePixel = 0,
                    Parent = Objects.HuePickerOutline,
                    ZIndex = ZIndex,
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.HuePicker,
                    CornerRadius = UDim.new(1, 0),
                })

                Objects.AlphaOutline = Utility.New('TextButton', {
                    Name = 'AlphaOutline',
                    Size = UDim2.new(1, -14, 0, 14),
                    Position = UDim2.new(0, 0, 1, -14),
                    BorderSizePixel = 0,
                    Parent = Objects.Background,
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.AlphaOutline,
                    CornerRadius = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.AlphaImage = Utility.New('ImageLabel', {
                    Name = 'AlphaImage',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 255),
                    BorderSizePixel = 0,
                    Parent = Objects.AlphaOutline,
                    Image = Library.Checkers,
                    ScaleType = Enum.ScaleType.Tile,
                    TileSize = UDim2.new(0, 6, 0, 6),
                    ZIndex = ZIndex,
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.AlphaImage,
                    CornerRadius = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.AlphaBackground = Utility.New('Frame', {
                    Name = 'SaturationPicker',
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    Parent = Objects.AlphaImage,
                    ZIndex = ZIndex,
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.AlphaBackground,
                    CornerRadius = UDim.new(0, 5),
                })
                Utility.New('UIGradient', {
                    Parent = Objects.AlphaBackground,
                    Rotation = 180,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0),
                    }),
                })

                ZIndex = ZIndex + 1
                Objects.AlphaPickerOutline = Utility.New('TextButton', {
                    Name = 'AlphaPickerOutline',
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    Parent = Objects.AlphaBackground,
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.AlphaPickerOutline,
                    CornerRadius = UDim.new(1, 0),
                })

                ZIndex = ZIndex + 1
                Objects.AlphaPicker = Utility.New('Frame', {
                    Name = 'AlphaPicker',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderSizePixel = 0,
                    Parent = Objects.AlphaPickerOutline,
                    ZIndex = ZIndex,
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.AlphaPicker,
                    CornerRadius = UDim.new(1, 0),
                })
            end

            local Hue, Sat, Val

            function Popup.Set(color, alpha, ignore)
                alpha = alpha or Popup.Alpha
                Hue, Sat, Val = color:ToHSV()
                Popup.Color = color
                Popup.Alpha = alpha

                if not ignore then
                    Objects.SaturationPickerOutline.Position = UDim2.new(math.clamp(Sat, 0, 1), Sat < 1 and 0 or 
-6, math.clamp(1 - Val, 0, 1), 1 - Val < 1 and 0 or -6)
                    Popup.HuePos = Hue
                    Objects.HuePickerOutline.Position = UDim2.new(0, 0, math.clamp(1 - Hue, 0, 1), 1 - Hue < 1 and 0 or 
-10)
                    Objects.AlphaPickerOutline.Position = UDim2.new(math.clamp(alpha, 0, 1), alpha < 1 and 0 or 
-10, 0, 0)
                end
                if Popup.SetFunc and type(Popup.SetFunc) == 'function' then
                    Popup.SetFunc(color, alpha)
                end

                Objects.HuePicker.BackgroundColor3 = Color3.fromHSV(Popup.HuePos, 1, 1)
                Objects.SaturationPicker.BackgroundColor3 = color
                Objects.AlphaPicker.BackgroundColor3 = color
                Objects.AlphaBackground.BackgroundColor3 = color
                Objects.SaturationBackground.BackgroundColor3 = Color3.fromHSV(Popup.HuePos, 1, 1)
            end
            
            function Popup.Open(position)
                if Popup.Tweening then
                    return
                end

                Popup.Tweening = true
                Popup.Visible = not Popup.Visible

                if Popup.Visible then
                    Objects.Outline.Visible = true
                end

                local ParentObjects = Objects.Outline:GetDescendants()

                table.insert(ParentObjects, Objects.Outline)

                for _, obj in ParentObjects do
                    local Index = Utility.GetTransparency(obj)

                    if Index then
                        if type(Index) == 'table' then
                            for _, prop in Index do
                                Library.Fade(obj, prop, Popup.Visible)
                            end
                        else
                            Library.Fade(obj, Index, Popup.Visible)
                        end
                    end
                end

                if position then
                    Objects.Outline.Position = UDim2.new(0, position.X, 0, position.Y)
                end

                local Size = Objects.Outline.AbsoluteSize

                Objects.Outline.Size = Popup.Visible and UDim2.new(0, Size.X, 0, 20) or UDim2.new(0, Size.X, 0, Size.Y)

                local Tween = Library.Tween(Objects.Outline, {
                    Size = Popup.Visible and UDim2.new(0, Size.X, 0, Size.Y) or UDim2.new(0, Size.X, 0, 20),
                })

                Utility.Signal(Tween.Completed:Connect(function()
                    Objects.Outline.Visible = Popup.Visible
                    Objects.Outline.Size = UDim2.new(0, Size.X, 0, Size.Y)
                    Popup.Tweening = false
                end))
            end
            
            function Popup.SlideSaturation(input)
                local SizeX = math.clamp((input.Position.X - Objects.SaturationOutline.AbsolutePosition.X) / Objects.SaturationOutline.AbsoluteSize.X, 0, 1)
                local SizeY = 1 - math.clamp((input.Position.Y - Objects.SaturationOutline.AbsolutePosition.Y) / Objects.SaturationOutline.AbsoluteSize.Y, 0, 1)

                Objects.SaturationPickerOutline.Position = UDim2.new(SizeX, 0, 1 - SizeY, 0)
                Objects.SaturationPickerOutline.AnchorPoint = Vector2.new(SizeX, 1 - SizeY)

                Popup.Set(Color3.fromHSV(Popup.HuePos, SizeX, SizeY), Popup.Alpha, true)
            end

            Utility.Signal(Objects.SaturationOutline.MouseButton1Down:Connect(function(
            )
                Popup.SlidingSaturation = true

                Popup.SlideSaturation({
                    Position = UserInputService:GetMouseLocation() - Vector2.new(0, 62),
                })
            end))

            function Popup.SlideHue(input)
                local SizeY = 1 - math.clamp((input.Position.Y - Objects.HueOutline.AbsolutePosition.Y) / Objects.HueOutline.AbsoluteSize.Y, 0, 1)

                Objects.HuePickerOutline.Position = UDim2.new(0, 0, 1 - SizeY, 0)
                Objects.HuePickerOutline.AnchorPoint = Vector2.new(0, 1 - SizeY)
                Popup.HuePos = SizeY

                Popup.Set(Color3.fromHSV(SizeY, Sat, Val), Popup.Alpha, true)
            end

            Utility.Signal(Objects.HueOutline.MouseButton1Down:Connect(function(
            )
                Popup.SlidingHue = true

                Popup.SlideHue({
                    Position = UserInputService:GetMouseLocation() - Vector2.new(0, 62),
                })
            end))

            function Popup.SlideAlpha(input)
                local SizeX = math.clamp((input.Position.X - Objects.AlphaOutline.AbsolutePosition.X) / Objects.AlphaOutline.AbsoluteSize.X, 0, 1)

                Objects.AlphaPickerOutline.Position = UDim2.new(SizeX, 0, 0, 0)
                Objects.AlphaPickerOutline.AnchorPoint = Vector2.new(SizeX, 0)

                Popup.Set(Popup.Color, SizeX, true)
            end

            Utility.Signal(Objects.AlphaOutline.MouseButton1Down:Connect(function(
            )
                Popup.SlidingAlpha = true

                Popup.SlideAlpha({
                    Position = UserInputService:GetMouseLocation(),
                })
            end))
            Utility.Signal(UserInputService.InputChanged:Connect(function(
                input
            )
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if Popup.SlidingSaturation then
                        Popup.SlideSaturation({
                            Position = UserInputService:GetMouseLocation() - Vector2.new(0, 62),
                        })
                    end
                    if Popup.SlidingHue then
                        Popup.SlideHue({
                            Position = UserInputService:GetMouseLocation() - Vector2.new(0, 62),
                        })
                    end
                    if Popup.SlidingAlpha then
                        Popup.SlideAlpha({
                            Position = UserInputService:GetMouseLocation(),
                        })
                    end
                end
            end))
            Utility.Signal(UserInputService.InputEnded:Connect(function(
                input
            )
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Popup.SlidingSaturation, Popup.SlidingHue, Popup.SlidingAlpha = false, false, false
                end
            end))

            return Popup
        end

        do
            local ColorpickerWindowFunc = Library.ColorpickerWindow

            Library.ColorpickerWindow = ColorpickerWindowFunc({ZIndex = 5000})
        end

        function Library.Window(self, cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                name = 'User Interface',
                size = UDim2.fromOffset(350, 430),
                open = true,
                fontsize = 15,
            })

            local Window = {
                Objects = {},
                Visible = cfg.open,
                Tweening = false,
                TabsTweening = false,
                ZIndex = 0,
                Tabs = {},
            }
            local ZIndex = Window.ZIndex
            local Objects = Window.Objects

            do
                Objects.ScreenGui = Utility.New('ScreenGui', {
                    Name = '\0',
                    Parent = HiddenUI,
                    IgnoreGuiInset = true,
                })
                Objects.Outline = Utility.New('Frame', {
                    Name = 'Outline',
                    Size = cfg.size,
                    Position = UDim2.new(0.5, -cfg.size.X.Offset / 2, 0.5, 
-cfg.size.Y.Offset / 2),
                    BorderSizePixel = 0,
                    Parent = Objects.ScreenGui,
                    ZIndex = ZIndex,
                    Visible = Window.Visible,
                    ClipsDescendants = true,
                }, {
                    BackgroundColor3 = 'Page Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.Outline,
                    CornerRadius = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                
                -- Sidebar Container with full outline
                Objects.SideContainer = Utility.New('Frame', {
                    Name = 'SideContainer',
                    Size = UDim2.new(0, 162, 1, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BorderSizePixel = 0,
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                    ClipsDescendants = true,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.SideContainer,
                    CornerRadius = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                
                -- Sidebar Background (inside the outline)
                Objects.SideBackground = Utility.New('Frame', {
                    Name = 'SideBackground',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderSizePixel = 0,
                    Parent = Objects.SideContainer,
                    ZIndex = ZIndex,
                    ClipsDescendants = true,
                }, {
                    BackgroundColor3 = 'Dark Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.SideBackground,
                    CornerRadius = UDim.new(0, 5),
                })
                
                Library.Dragging(Objects.Outline, Objects.SideBackground)
                
                -- Add padding inside the sidebar
                Utility.New('UIPadding', {
                    Name = 'UIPadding',
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 5),
                    Parent = Objects.SideBackground,
                })

                ZIndex = ZIndex + 1
                Objects.Title = Utility.New('TextLabel', {
                    Name = 'Title',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = cfg.fontsize + 6,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    FontFace = Library.Font,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Text = cfg.name,
                    Parent = Objects.SideBackground,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Accent',
                })
                Objects.Title.Size = UDim2.new(1, 0, 0, Objects.Title.TextBounds.Y + 22)
                
                Objects.SideScroll = Utility.New('ScrollingFrame', {
                    Name = 'SideScroll',
                    Size = UDim2.new(1, 0, 1, -Objects.Title.AbsoluteSize.Y),
                    Position = UDim2.fromOffset(0, Objects.Title.AbsoluteSize.Y),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Objects.SideBackground,
                    ZIndex = ZIndex,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    BottomImage = Library.ScrollBar,
                    MidImage = Library.ScrollBar,
                    TopImage = Library.ScrollBar,
                    ScrollBarThickness = 2,
                }, {
                    ScrollBarImageColor3 = 'Accent',
                })
                
                Objects.SideContent = Utility.New('Frame', {
                    Name = 'SideContent',
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Objects.SideScroll,
                    ZIndex = ZIndex,
                })

                Utility.Signal(Objects.SideScroll:GetPropertyChangedSignal('AbsoluteCanvasSize'):Connect(function()
                    if Objects.SideScroll.AbsoluteCanvasSize.Y > Objects.SideScroll.AbsoluteSize.Y then
                        Objects.SideContent.Size = UDim2.new(1, -7, 0, 0)
                    else
                        Objects.SideContent.Size = UDim2.new(1, 0, 0, 0)
                    end
                end))
                
                Utility.Signal(Objects.SideScroll:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
                    if Objects.SideScroll.AbsoluteCanvasSize.Y > Objects.SideScroll.AbsoluteSize.Y then
                        Objects.SideContent.Size = UDim2.new(1, -7, 0, 0)
                    else
                        Objects.SideContent.Size = UDim2.new(1, 0, 0, 0)
                    end
                end))
                
                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Objects.SideContent,
                    Padding = UDim.new(0, 6),
                })

                Window.SideHolder = Objects.SideContent
                
                Objects.ResizeBar = Utility.New('Frame', {
                    Name = 'ResizeBar',
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 5, 0, 5),
                    Position = UDim2.new(1, -5, 1, -5),
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                })

                Library.Resize(Objects.Outline, Objects.ResizeBar)

                Objects.PageHolder = Utility.New('Frame', {
                    Name = 'PageHolder',
                    Size = UDim2.new(1, -Objects.SideContainer.AbsoluteSize.X, 1, 0),
                    Position = UDim2.new(0, Objects.SideContainer.AbsoluteSize.X, 0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                })

                Utility.New('UIPadding', {
                    Name = 'UIPadding',
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                    Parent = Objects.PageHolder,
                })

                Window.PageHolder = Objects.PageHolder
                ZIndex = ZIndex + 1
            end

            Window.ZIndex = ZIndex

            local AnimationSizeAmount = 20

            function Window.Open()
                if Window.Tweening then
                    return
                end

                for _, popup in Library.Popups do
                    if popup.Objects.Outline.Visible then
                        popup.Visible(false)
                    end
                end
                for _, dropdown in Library.Dropdowns do
                    if dropdown.Visible then
                        dropdown.Open()
                    end
                end

                if Library.ColorpickerWindow and type(Library.ColorpickerWindow) == 'table' and Library.ColorpickerWindow.Visible then
                    if Library.ColorpickerWindow.Open and type(Library.ColorpickerWindow.Open) == 'function' then
                        Library.ColorpickerWindow.Open()
                    end
                end

                Window.Tweening = true
                Window.Visible = not Window.Visible

                if Window.Visible then
                    Objects.Outline.Visible = true
                end

                for _, obj in Objects.ScreenGui:GetDescendants()do
                    local Index = Utility.GetTransparency(obj)

                    if Index then
                        if type(Index) == 'table' then
                            for _, prop in Index do
                                Library.Fade(obj, prop, Window.Visible)
                            end
                        else
                            Library.Fade(obj, Index, Window.Visible)
                        end
                    end
                end

                local OldSize = Objects.Outline.AbsoluteSize

                Objects.Outline.Size = Window.Visible and UDim2.fromOffset(OldSize.X - AnimationSizeAmount, OldSize.Y - AnimationSizeAmount) or UDim2.fromOffset(OldSize.X, OldSize.Y)

                local Tween = Library.Tween(Objects.Outline, {
                    Size = Window.Visible and UDim2.fromOffset(OldSize.x, OldSize.y) or UDim2.fromOffset(OldSize.x - AnimationSizeAmount, OldSize.y - AnimationSizeAmount),
                })

                Utility.Signal(Tween.Completed:Connect(function()
                    Objects.Outline.Size = UDim2.fromOffset(OldSize.X, OldSize.Y)
                    Window.Tweening = false
                    Objects.Outline.Visible = Window.Visible
                end))
            end

            return setmetatable(Window, Library)
        end
        
        function Library.Info(self, cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                name = 'Misc',
            })

            local Info = {
                Objects = {},
                ZIndex = self.ZIndex,
            }
            local ZIndex = Info.ZIndex
            local Objects = Info.Objects

            do
                Objects.Holder = Utility.New('Frame', {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = self.SideHolder,
                    ZIndex = ZIndex,
                })

                Utility.New('UIPadding', {
                    Name = 'UIPadding',
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 0),
                    PaddingBottom = UDim.new(0, 0),
                    Parent = Objects.Holder,
                })

                ZIndex = ZIndex + 1
                Objects.Text = Utility.New('TextLabel', {
                    Name = 'Text',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = Library.FontSize - 2,
                    FontFace = Library.Font,
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Text = cfg.name,
                    Parent = Objects.Holder,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Dark Text',
                })
                ZIndex = ZIndex + 1
            end

            Info.ZIndex = ZIndex

            return setmetatable(Info, Library)
        end
        
        function Library.Tab(self, cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                name = 'New Tab',
                icon = 'rbxassetid://284402752',
            })

            local Tab = {
                ZIndex = self.ZIndex,
                Tweening = false,
                Objects = {},
                Sections = {},
                Name = cfg.name,
            }
            local ZIndex = Tab.ZIndex
            local Objects = Tab.Objects

            do
                Objects.Holder = Utility.New('Frame', {
                    Name = 'Holder',
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = self.SideHolder,
                    ZIndex = ZIndex,
                })
                ZIndex = ZIndex + 1
                
                Objects.Background = Utility.New('TextButton', {
                    Name = 'Background',
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    Parent = Objects.Holder,
                    ZIndex = ZIndex,
                    ClipsDescendants = true,
                })
                ZIndex = ZIndex + 1

                Objects.SelectionLine = Utility.New('Frame', {
                    Name = 'SelectionLine',
                    Size = UDim2.new(0, 3, 0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Parent = Objects.Background,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Accent',
                })
                
                Utility.Signal(Objects.Background:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
                    Objects.SelectionLine.Size = UDim2.new(0, 3, 1, 0)
                end))
                
                ZIndex = ZIndex + 1
                
                Objects.Content = Utility.New('Frame', {
                    Name = 'Content',
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Objects.Background,
                    ZIndex = ZIndex,
                })
                ZIndex = ZIndex + 1
                
                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    Parent = Objects.Content,
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 7),
                })

                if cfg.icon then
                    Objects.Icon = Utility.New('ImageLabel', {
                        Name = 'Icon',
                        Size = UDim2.new(0, 20, 0, 20),
                        Position = UDim2.new(0, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        BackgroundTransparency = 1,
                        Image = cfg.icon,
                        Parent = Objects.Content,
                        ZIndex = ZIndex,
                    }, {
                        ImageColor3 = 'Dark Text',
                    })
                end

                Objects.Text = Utility.New('TextLabel', {
                    Name = 'Text',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = Library.FontSize,
                    FontFace = Library.Font,
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Text = cfg.name,
                    Parent = Objects.Content,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Dark Text',
                })
                Objects.Text.Size = UDim2.new(0, Objects.Text.TextBounds.X, 0, Objects.Text.TextBounds.Y - 2)

                if Objects.Icon then
                    Objects.Icon.Size = UDim2.new(0, Objects.Text.TextBounds.Y, 0, Objects.Text.TextBounds.Y)
                end

                Objects.Page = Utility.New('Frame', {
                    Name = 'Page',
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Parent = self.PageHolder,
                    Visible = false,
                    ZIndex = ZIndex,
                })
                ZIndex = ZIndex + 1
                
                Objects.Left = Utility.New('Frame', {
                    Name = 'Left',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0.5, -2, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Parent = Objects.Page,
                    ZIndex = ZIndex,
                })

                table.insert(Tab.Sections, Objects.Left)
                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    Parent = Objects.Left,
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalFlex = Enum.UIFlexAlignment.Fill,
                    Padding = UDim.new(0, 8),
                })

                Tab.left = Objects.Left
                
                Objects.Right = Utility.New('Frame', {
                    Name = 'Right',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0.5, -2, 1, 0),
                    Position = UDim2.new(0.5, 2, 0, 0),
                    Parent = Objects.Page,
                    ZIndex = ZIndex,
                })

                table.insert(Tab.Sections, Objects.Right)
                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    Parent = Objects.Right,
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalFlex = Enum.UIFlexAlignment.Fill,
                    Padding = UDim.new(0, 8),
                })

                Tab.right = Objects.Right
            end

            Tab.ZIndex = ZIndex

            function Tab.Set(status, nested)
                if self.TabsTweening and status then
                    return
                end

                if status then
                    Objects.SelectionLine.BackgroundTransparency = 0
                    Library.Tween(Objects.SelectionLine, {
                        BackgroundTransparency = 0,
                    })
                    Library.ChangeObjectTheme(Objects.Text, {
                        TextColor3 = 'Text',
                    }, true)
                    if Objects.Icon then
                        Library.ChangeObjectTheme(Objects.Icon, {
                            ImageColor3 = 'Text',
                        }, true)
                    end
                else
                    Library.Tween(Objects.SelectionLine, {
                        BackgroundTransparency = 1,
                    })
                    Library.ChangeObjectTheme(Objects.Text, {
                        TextColor3 = 'Dark Text',
                    }, true)
                    if Objects.Icon then
                        Library.ChangeObjectTheme(Objects.Icon, {
                            ImageColor3 = 'Dark Text',
                        }, true)
                    end
                end

                Objects.Page.Visible = status

                if not self.TabsTweening then
                    if not nested then
                        self.TabsTweening = true

                        for _, tab in self.Tabs do
                            if tab.Name ~= Tab.Name then
                                tab.Set(false, true)
                            end
                        end
                        for _, obj in Objects.Page:GetDescendants()do
                            local Index = Utility.GetTransparency(obj)

                            if Index then
                                if type(Index) == 'table' then
                                    for _, prop in Index do
                                        Library.Fade(obj, prop, status)
                                    end
                                else
                                    Library.Fade(obj, Index, status)
                                end
                            end
                        end

                        Objects.Page.Position = status and UDim2.fromOffset(0, 20) or UDim2.fromOffset(0, 0)

                        local Tween = Library.Tween(Objects.Page, {
                            Position = status and UDim2.fromOffset(0, 0) or UDim2.fromOffset(0, 20),
                        })

                        Utility.Signal(Tween.Completed:Connect(function()
                            self.TabsTweening = false
                        end))
                    end
                end
            end

            Utility.Signal(Objects.Background.MouseEnter:Connect(function()
                if not Tab._isSelected then
                    Library.ChangeObjectTheme(Objects.Text, {
                        TextColor3 = 'Text',
                    }, true)
                    if Objects.Icon then
                        Library.ChangeObjectTheme(Objects.Icon, {
                            ImageColor3 = 'Text',
                        }, true)
                    end
                end
            end))

            Utility.Signal(Objects.Background.MouseLeave:Connect(function()
                if not Tab._isSelected then
                    Library.ChangeObjectTheme(Objects.Text, {
                        TextColor3 = 'Dark Text',
                    }, true)
                    if Objects.Icon then
                        Library.ChangeObjectTheme(Objects.Icon, {
                            ImageColor3 = 'Dark Text',
                        }, true)
                    end
                end
            end))

            local originalSet = Tab.Set
            Tab.Set = function(status, nested)
                Tab._isSelected = status
                originalSet(status, nested)
            end

            Utility.Signal(Objects.Background.MouseButton1Click:Connect(function()
                Tab.Set(true)
            end))
            table.insert(self.Tabs, Tab)

            return setmetatable(Tab, Library)
        end

        function Library.Section(self, cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                name = 'New Section',
                description = nil,
                side = 'left',
                size = 1,
            })

            local Section = {
                ZIndex = self.ZIndex,
                Objects = {},
                Resizing = false,
                Dragging = false,
            }
            
            local Parent = self[cfg.side:lower()]
            if not Parent then
                warn("Section side '" .. cfg.side .. "' not found")
                return
            end
            
            local ZIndex = Section.ZIndex
            local Objects = Section.Objects

            do
                Objects.MainOutline = Utility.New('Frame', {
                    Name = 'MainOutline',
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Parent = Parent,
                    ZIndex = ZIndex,
                    ClipsDescendants = false,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Objects.TopHider = Utility.New('Frame', {
                    Name = 'TopHider',
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 5),
                    Position = UDim2.new(0, 0, 0, 0),
                    Parent = Objects.MainOutline,
                    ZIndex = ZIndex,
                    BackgroundTransparency = 1,
                })
                
                local cornerRadius = 5
                
                local UICorner = Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.MainOutline,
                    CornerRadius = UDim.new(0, cornerRadius),
                })
                
                ZIndex = ZIndex + 1
                
                Objects.Outline = Utility.New('Frame', {
                    Name = 'Background',
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 0),
                    Parent = Objects.MainOutline,
                    ZIndex = ZIndex,
                    ClipsDescendants = false,
                }, {
                    BackgroundColor3 = 'Section Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.Outline,
                    CornerRadius = UDim.new(0, cornerRadius),
                })

                Objects.Constraint = Utility.New('UISizeConstraint', {
                    Parent = Objects.MainOutline,
                    MinSize = Vector2.new(0, 30),
                })
                
                ZIndex = ZIndex + 1
                
                Objects.Dragging = Utility.New('TextButton', {
                    Name = 'Dragging',
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 0, 5),
                    Position = UDim2.new(0, 5, 0, 0),
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    Text = '',
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                })
                
                ZIndex = ZIndex + 1
                
                Objects.AccentLine = Utility.New('Frame', {
                    Name = 'AccentLine',
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 2),
                    Position = UDim2.new(0, 0, 0, 0),
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Accent',
                })
                
                Objects.TitleBackground = Utility.New('Frame', {
                    Name = 'TitleBackground',
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0, 15, 0, 0),
                    Parent = Objects.Outline,
                    ZIndex = ZIndex + 1,
                    AutomaticSize = Enum.AutomaticSize.XY,
                }, {
                    BackgroundColor3 = 'Section Background',
                })
                
                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.TitleBackground,
                    CornerRadius = UDim.new(0, 3),
                })
                
                ZIndex = ZIndex + 2
                
                Objects.Title = Utility.New('TextLabel', {
                    Name = 'Title',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = Library.FontSize,
                    FontFace = Library.Font,
                    Size = UDim2.new(0, 0, 0, 0),
                    Text = cfg.name,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Objects.TitleBackground,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Accent',
                })
                
                Utility.New('UIPadding', {
                    Name = 'UIPadding',
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 1),
                    PaddingBottom = UDim.new(0, 1),
                    Parent = Objects.TitleBackground,
                })
                
                local function PositionTitle()
                    local titleHeight = Objects.Title.TextBounds.Y
                    local bgHeight = titleHeight + 2
                    Objects.TitleBackground.Position = UDim2.new(0, 15, 0, - (bgHeight / 2) + 1)
                end
                
                task.spawn(function()
                    task.wait()
                    PositionTitle()
                end)
                
                Utility.Signal(Objects.Title:GetPropertyChangedSignal('TextBounds'):Connect(PositionTitle))
                
                ZIndex = ZIndex + 1
                
                if cfg.description then
                    Objects.Description = Utility.New('TextLabel', {
                        Name = 'Description',
                        TextStrokeTransparency = 0.8,
                        BackgroundTransparency = 1,
                        TextSize = Library.FontSize - 2,
                        FontFace = Library.Font,
                        Size = UDim2.new(1, -24, 0, 0),
                        Position = UDim2.new(0, 12, 0, 12),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Text = cfg.description,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Objects.Outline,
                        ZIndex = ZIndex,
                        TextWrapped = true,
                    }, {
                        TextColor3 = 'Light Text',
                    })
                    ZIndex = ZIndex + 1
                end

                local contentTopOffset = cfg.description and 40 or 20
                
                Objects.Padded = Utility.New('Frame', {
                    Name = 'Padded',
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -12, 1, -(contentTopOffset + 6)),
                    Position = UDim2.new(0, 6, 0, contentTopOffset),
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                })
                
                ZIndex = ZIndex + 1
                
                Objects.Scrolling = Utility.New('ScrollingFrame', {
                    Name = 'Scrolling',
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Objects.Padded,
                    ZIndex = ZIndex,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    BottomImage = Library.ScrollBar,
                    MidImage = Library.ScrollBar,
                    TopImage = Library.ScrollBar,
                    ScrollBarThickness = 2,
                    ClipsDescendants = true,
                }, {
                    ScrollBarImageColor3 = 'Accent',
                })
                
                ZIndex = ZIndex + 1
                
                Objects.Content = Utility.New('Frame', {
                    Name = 'Content',
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Objects.Scrolling,
                    ZIndex = ZIndex,
                })
                Section.Holder = Objects.Content

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Objects.Content,
                    Padding = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1

                Utility.Signal(Objects.Scrolling:GetPropertyChangedSignal('AbsoluteCanvasSize'):Connect(function()
                    if Objects.Scrolling.AbsoluteCanvasSize.Y > Objects.Scrolling.AbsoluteSize.Y then
                        Objects.Content.Size = UDim2.new(1, -7, 0, 0)
                    else
                        Objects.Content.Size = UDim2.new(1, 0, 0, 0)
                    end
                end))
                
                Utility.Signal(Objects.Scrolling:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
                    if Objects.Scrolling.AbsoluteCanvasSize.Y > Objects.Scrolling.AbsoluteSize.Y then
                        Objects.Content.Size = UDim2.new(1, -7, 0, 0)
                    else
                        Objects.Content.Size = UDim2.new(1, 0, 0, 0)
                    end
                end))

                Objects.ResizeBar = Utility.New('TextButton', {
                    Name = 'ResizeBar',
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 3),
                    Position = UDim2.new(0, 0, 1, -3),
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    Text = '',
                    Parent = Objects.MainOutline,
                    ZIndex = ZIndex,
                })
            end

            Section.ZIndex = ZIndex

            Utility.Signal(Objects.ResizeBar.MouseButton1Down:Connect(function()
                Section.Resizing = true

                local Resize = Utility.Signal(UserInputService.InputChanged:Connect(function(input)
                    if not Section.Resizing or input.UserInputType ~= Enum.UserInputType.MouseMovement then
                        return
                    end

                    Objects.Constraint.MaxSize = Vector2.new(math.huge, math.clamp(input.Position.Y - Objects.MainOutline.AbsolutePosition.Y, 30, 9e9))
                end))
                
                local ResizeStop = Utility.Signal(UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Section.Resizing = false

                        Resize:Disconnect()
                        ResizeStop:Disconnect()
                    end
                end))
            end))

            Section.OldParent = Objects.MainOutline.Parent

            Utility.Signal(Objects.Dragging.MouseButton1Down:Connect(function()
                Section.Dragging = true

                local MousePosition = UserInputService:GetMouseLocation()
                local Offset = Vector2.new(MousePosition.X - Objects.Dragging.AbsolutePosition.X, MousePosition.Y - Objects.Dragging.AbsolutePosition.Y)

                Objects.MainOutline.Size = UDim2.new(0, Objects.MainOutline.AbsoluteSize.X, 0, Objects.MainOutline.AbsoluteSize.Y)
                Objects.MainOutline.Position = UDim2.new(0, Objects.MainOutline.AbsolutePosition.X, 0, Objects.MainOutline.AbsolutePosition.Y)
                Objects.MainOutline.Parent = Library.ScreenGui

                local ClosestHolder, Indicator
                local Drag = Utility.Signal(UserInputService.InputChanged:Connect(function(input)
                    if not Section.Dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
                        return
                    end

                    Objects.MainOutline.Position = UDim2.new(0, input.Position.X - Offset.X, 0, input.Position.Y - Offset.Y)

                    local MinDistance = math.huge

                    for _, holder in ipairs(self.Sections or {}) do
                        if holder and holder:IsA('Frame') then
                            local Distance = (Vector2.new(input.Position.x, input.Position.y) - holder.AbsolutePosition).Magnitude
                            if Distance < MinDistance then
                                MinDistance = Distance
                                ClosestHolder = holder
                            end
                        end
                    end

                    if ClosestHolder then
                        if not Indicator then
                            Indicator = Utility.New('Frame', {
                                Parent = ClosestHolder,
                                BorderSizePixel = 0,
                                Size = UDim2.new(1, 0, 0, Objects.MainOutline.AbsoluteSize.Y),
                                ZIndex = 5000,
                            }, {
                                BackgroundColor3 = 'Accent',
                            })

                            Utility.New('UICorner', {
                                Name = 'UICorner',
                                Parent = Indicator,
                                CornerRadius = UDim.new(0, 5),
                            })

                            local Background = Utility.New('Frame', {
                                Parent = Indicator,
                                BorderSizePixel = 0,
                                Size = UDim2.new(1, -2, 1, -2),
                                Position = UDim2.new(0, 1, 0, 1),
                                ZIndex = 5001,
                            }, {
                                BackgroundColor3 = 'Section Background',
                            })

                            Utility.New('UICorner', {
                                Name = 'UICorner',
                                Parent = Background,
                                CornerRadius = UDim.new(0, 5),
                            })
                            Utility.New('UISizeConstraint', {
                                Parent = Indicator,
                                MaxSize = Objects.Constraint.MaxSize,
                                MinSize = Objects.Constraint.MinSize,
                            })
                        end

                        Indicator.Parent = ClosestHolder
                        Indicator.Position = UDim2.new(0, 0, 0, 0)
                        Indicator.Visible = true
                    else
                        if Indicator then
                            Indicator:Destroy()
                            Indicator = nil
                        end
                    end
                end))
                
                local DragStop = Utility.Signal(UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Section.Dragging = false

                        Drag:Disconnect()
                        DragStop:Disconnect()

                        Objects.MainOutline.Position = UDim2.new()
                        Objects.MainOutline.Size = UDim2.new(1, 0, 0, 0)

                        if ClosestHolder then
                            Objects.MainOutline.Parent = ClosestHolder
                        else
                            Objects.MainOutline.Parent = Section.OldParent
                        end
                        if Indicator then
                            Indicator:Destroy()
                        end
                    end
                end))
            end))

            if self.Sections then
                table.insert(self.Sections, Objects.MainOutline)
            end

            return setmetatable(Section, Library)
        end

        function Library.PopupMenu(self, cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {size = 120})

            local Popup = {
                Tweening = false,
                Objects = {},
                ZIndex = self.ZIndex,
                ParentPopup = nil,
                ChildPopups = {},
            }
            local ZIndex = Popup.ZIndex
            local Objects = Popup.Objects

            do
                Objects.Outline = Utility.New('Frame', {
                    Name = 'Outline',
                    Size = UDim2.new(0, cfg.size, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    Parent = Library.ScreenGui,
                    ZIndex = ZIndex,
                    ClipsDescendants = true,
                    Visible = false,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.Outline,
                    CornerRadius = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.Background = Utility.New('TextButton', {
                    Name = 'Background',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.fromOffset(1, 1),
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    BorderSizePixel = 0,
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.Background,
                    CornerRadius = UDim.new(0, 5),
                })
                Utility.New('UIPadding', {
                    Name = 'UIPadding',
                    Parent = Objects.Background,
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.Holder = Utility.New('Frame', {
                    Name = 'Holder',
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Parent = Objects.Background,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Objects.Holder,
                    Padding = UDim.new(0, 5),
                })

                Popup.Holder = Objects.Holder
            end

            Popup.ZIndex = ZIndex

            function Popup.Visible(visibility, position, stopPropagation)
                if Popup.Tweening then
                    return
                end

                Popup.Tweening = true

                if visibility then
                    Objects.Outline.Visible = true

                    if not stopPropagation then
                        local parentChain = Popup:GetParentChain()
                        local parentChainMap = {}

                        for _, parent in ipairs(parentChain)do
                            parentChainMap[parent] = true
                        end

                        if Popup.ParentPopup and Popup.ParentElement then
                            for _, childPopup in pairs(Popup.ParentPopup.ChildPopups)do
                                if childPopup ~= Popup and not parentChainMap[childPopup] and childPopup.Objects.Outline.Visible and childPopup.ParentElement == Popup.ParentElement then
                                    childPopup.Visible(false, nil, true)
                                end
                            end
                        elseif not Popup.ParentPopup then
                            for _, popup in pairs(Library.Popups)do
                                if popup ~= Popup and not parentChainMap[popup] and popup.Objects.Outline.Visible and not popup.ParentPopup and popup.ParentElement == Popup.ParentElement then
                                    popup.Visible(false, nil, true)
                                end
                            end
                        end
                    end
                end

                local ParentObjects = Objects.Outline:GetDescendants()

                table.insert(ParentObjects, Objects.Outline)

                for _, obj in ParentObjects do
                    local Index = Utility.GetTransparency(obj)

                    if Index then
                        if type(Index) == 'table' then
                            for _, prop in Index do
                                Library.Fade(obj, prop, visibility)
                            end
                        else
                            Library.Fade(obj, Index, visibility)
                        end
                    end
                end

                local targetHeight = Objects.Holder.AbsoluteSize.Y + 10
                
                if position then
                    Objects.Outline.Position = UDim2.new(0, position.X, 0, position.Y)
                end

                Objects.Outline.AutomaticSize = Enum.AutomaticSize.None
                
                if visibility then
                    Objects.Outline.Size = UDim2.new(0, cfg.size, 0, 0)
                    local Tween = Library.Tween(Objects.Outline, {
                        Size = UDim2.new(0, cfg.size, 0, targetHeight),
                    })
                    Utility.Signal(Tween.Completed:Connect(function()
                        Popup.Tweening = false
                        Objects.Outline.Size = UDim2.new(0, cfg.size, 0, 0)
                        Objects.Outline.AutomaticSize = Enum.AutomaticSize.Y
                    end))
                else
                    local currentHeight = Objects.Outline.AbsoluteSize.Y
                    Objects.Outline.Size = UDim2.new(0, cfg.size, 0, currentHeight)
                    local Tween = Library.Tween(Objects.Outline, {
                        Size = UDim2.new(0, cfg.size, 0, 0),
                    })
                    Utility.Signal(Tween.Completed:Connect(function()
                        Popup.Tweening = false
                        Objects.Outline.Size = UDim2.new(0, cfg.size, 0, 0)
                        Objects.Outline.AutomaticSize = Enum.AutomaticSize.Y
                        Objects.Outline.Visible = visibility

                        if not visibility and not stopPropagation then
                            for _, childPopup in pairs(Popup.ChildPopups)do
                                if childPopup.Objects.Outline.Visible then
                                    childPopup.Visible(false)
                                end
                            end
                            for _, dropdown in pairs(Library.Dropdowns)do
                                if dropdown.ParentPopup == Popup and dropdown.Visible then
                                    dropdown.Open()
                                end
                            end
                        end
                    end))
                end
            end
            
            function Popup:NestedPopup(cfg)
                local NestedPopup = Library.PopupMenu(self, cfg)

                NestedPopup.ParentPopup = self

                table.insert(self.ChildPopups, NestedPopup)

                return NestedPopup
            end
            
            function Popup:GetParentChain()
                local chain = {}
                local current = self

                while current do
                    table.insert(chain, current)

                    current = current.ParentPopup
                end

                return chain
            end

            table.insert(Library.Popups, Popup)

            return setmetatable(Popup, Library)
        end
        
        function Library.Popup(self, cfg)
    cfg = cfg or {}
    cfg = Library.Config(cfg, {size = 120})

    local Cog = {
        Objects = {},
        ZIndex = self.ZIndex,
        Visible = false,
    }
    local ZIndex = Cog.ZIndex
    local Objects = Cog.Objects

    -- Check if SideHolder exists, if not create one
    if not self.SideHolder then
        -- Create a SideHolder if it doesn't exist
        self.SideHolder = Utility.New('Frame', {
            Name = 'SideHolder',
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Position = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = self.Holder or self,
            ZIndex = ZIndex,
        })

        Utility.New('UIListLayout', {
            Name = 'UIListLayout',
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Parent = self.SideHolder,
            Padding = UDim.new(0, 2),
        })
    end

    do
        Objects.Icon = Utility.New('ImageButton', {
            Name = 'Icon',
            Size = UDim2.new(0, 20, 0, 20), -- Default size if AbsoluteSize is not available
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Style = Enum.ButtonStyle.Custom,
            Image = 'rbxassetid://81593156472608',
            Parent = self.SideHolder,
            ZIndex = ZIndex,
        }, {
            ImageColor3 = 'Dark Text',
        })
        
        -- Set the size after a small delay to ensure AbsoluteSize is available
        task.spawn(function()
            task.wait()
            if Objects.Icon and self.SideHolder then
                local size = self.SideHolder.AbsoluteSize.Y
                if size > 0 then
                    Objects.Icon.Size = UDim2.new(0, size, 0, size)
                else
                    Objects.Icon.Size = UDim2.new(0, 20, 0, 20)
                end
            end
        end)
    end

    local Popup = self:PopupMenu(cfg)

    Popup.BoundObjects = {
        Objects.Icon,
        Popup.Objects.Outline,
        (Library.ColorpickerWindow and type(Library.ColorpickerWindow) == 'table' and Library.ColorpickerWindow.Objects and Library.ColorpickerWindow.Objects.Outline) or nil,
    }
    Popup.ParentElement = self

    function Cog.InsideBounds(input)
        for _, obj in Popup.BoundObjects do
            if obj and Utility.MouseOver(obj, input) then
                return true
            end
        end
        for _, childPopup in pairs(Popup.ChildPopups)do
            if childPopup.Objects.Outline.Visible then
                if Utility.MouseOver(childPopup.Objects.Outline, input) then
                    return true
                end

                for _, nestedObj in pairs(childPopup.BoundObjects or {})do
                    if nestedObj and Utility.MouseOver(nestedObj, input) then
                        return true
                    end
                end
            end
        end

        return false
    end

    if not Library.GlobalPopupClickHandler then
        Library.GlobalPopupClickHandler = true

        Utility.Signal(UserInputService.InputBegan:Connect(function(
            input
        )
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                return
            end

            local function isLibraryUI(obj)
                while obj do
                    if obj == Library.ScreenGui then
                        return true
                    end

                    obj = obj.Parent
                end

                return false
            end

            local ignoreCloseCheck = false
            local guiObjectsAtPosition = game:GetService('CoreGui'):GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)

            for _, obj in ipairs(guiObjectsAtPosition)do
                if isLibraryUI(obj) then
                    if obj:IsA('ImageButton') or obj:IsA('TextButton') then
                        ignoreCloseCheck = true

                        break
                    end
                end
            end

            if ignoreCloseCheck then
                return
            end

            for _, popup in pairs(Library.Popups)do
                if popup.Objects.Outline.Visible then
                    local function isInsidePopupHierarchy(
                        p,
                        input
                    )
                        if Utility.MouseOver(p.Objects.Outline, input) then
                            return true
                        end

                        for _, child in pairs(p.ChildPopups)do
                            if child.Objects.Outline.Visible and isInsidePopupHierarchy(child, input) then
                                return true
                            end
                        end

                        return false
                    end

                    if not isInsidePopupHierarchy(popup, input) then
                        local isChildOfActiveParent = false

                        local function isInParentOfPopup(
                            p,
                            input
                        )
                            if p.ParentPopup and p.ParentPopup.Objects.Outline.Visible then
                                if Utility.MouseOver(p.ParentPopup.Objects.Outline, input) then
                                    return true
                                end

                                return isInParentOfPopup(p.ParentPopup, input)
                            end

                            return false
                        end

                        if not isInParentOfPopup(popup, input) and popup.ParentElement then
                            popup.Visible(false, nil, true)

                            if popup.ParentElement.Objects and popup.ParentElement.Objects.Icon then
                                Library.ChangeObjectTheme(popup.ParentElement.Objects.Icon, {
                                    ImageColor3 = 'Dark Text',
                                }, true)
                            end
                        end
                    end
                end
            end
            for _, dropdown in pairs(Library.Dropdowns)do
                if dropdown.Visible then
                    if not Utility.MouseOver(dropdown.Popup.Outline, input) and not Utility.MouseOver(dropdown.Objects.Outline, input) then
                        dropdown.Open()
                    end
                end
            end
        end))
    end

    -- Use RenderStepped for position updates
    local positionUpdater
    positionUpdater = Utility.Signal(RunService.RenderStepped:Connect(function()
        if Popup.Objects.Outline and Popup.Objects.Outline.Visible and Objects.Icon then
            local AbsolutePosition = Objects.Icon.AbsolutePosition
            local AbsoluteSize = Objects.Icon.AbsoluteSize
            
            if AbsolutePosition and AbsoluteSize then
                local newPos = UDim2.new(0, AbsolutePosition.x, 0, AbsolutePosition.y + AbsoluteSize.y + 5)
                if Popup.Objects.Outline.Position ~= newPos then
                    Popup.Objects.Outline.Position = newPos
                end
            end
        end
    end))
    
    Popup._positionUpdater = positionUpdater

    Utility.Signal(Objects.Icon.MouseButton1Click:Connect(function(
    )
        Cog.Visible = not Cog.Visible

        local AbsolutePosition = Objects.Icon.AbsolutePosition
        local AbsoluteSize = Objects.Icon.AbsoluteSize
        local Position = Vector2.new(AbsolutePosition.x or 0, (AbsolutePosition.y or 0) + (AbsoluteSize.y or 20) + 5)

        Library.ChangeObjectTheme(Objects.Icon, {
            ImageColor3 = Cog.Visible and 'Text' or 'Dark Text',
        }, true)

        local stopPropagation = true

        Popup.Visible(Cog.Visible, Position, stopPropagation)
    end))

    return Popup
end
        
        function Library.Toggle(self, cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                name = 'New Toggle',
                description = nil,
                value = false,
                callback = function() end,
                flag = nil,
                children = nil,
            })

            if not cfg.flag then
                cfg.flag = cfg.name
            end

            local Toggle = {
                Objects = {},
                Tweening = false,
                ZIndex = self.ZIndex,
                Value = false,
            }
            local ZIndex = Toggle.ZIndex
            local Objects = Toggle.Objects

            do
                Objects.Holder = Utility.New('Frame', {
                    Name = 'Holder',
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    Parent = self.Holder,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Objects.Holder,
                    Padding = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                
                Objects.Row = Utility.New('Frame', {
                    Name = 'Row',
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    Parent = Objects.Holder,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    Parent = Objects.Row,
                    Padding = UDim.new(0, 8),
                })

                ZIndex = ZIndex + 1
                
                Objects.Outline = Utility.New('Frame', {
                    Name = 'Outline',
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 0,
                    Parent = Objects.Row,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })
                Objects.Outline.Size = UDim2.new(0, 20, 0, 20)

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Outline,
                })

                ZIndex = ZIndex + 1
                Objects.Background = Utility.New('Frame', {
                    Name = 'Background',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.fromOffset(1, 1),
                    BorderSizePixel = 0,
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Background,
                })

                ZIndex = ZIndex + 1
                Objects.Icon = Utility.New('ImageLabel', {
                    Name = 'ToggleIcon',
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Image = Library.Checkmark,
                    ImageColor3 = Library.Theme.Accent,
                    Parent = Objects.Background,
                    ZIndex = ZIndex,
                    Visible = false,
                })
                ZIndex = ZIndex + 1

                Objects.Text = Utility.New('TextLabel', {
                    Name = 'Text',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = Library.FontSize,
                    FontFace = Library.Font,
                    Size = UDim2.new(0, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Text = cfg.name,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Objects.Row,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Dark Text',
                })

                Objects.Clickable = Utility.New('TextButton', {
                    Name = 'Clickable',
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    Text = '',
                    Parent = Objects.Row,
                    ZIndex = ZIndex,
                })
                ZIndex = ZIndex + 1

                if cfg.description then
                    Objects.Description = Utility.New('TextLabel', {
                        Name = 'Description',
                        TextStrokeTransparency = 0.8,
                        BackgroundTransparency = 1,
                        TextSize = Library.FontSize - 2,
                        FontFace = Library.Font,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Text = cfg.description,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Objects.Holder,
                        ZIndex = ZIndex,
                        TextWrapped = true,
                    }, {
                        TextColor3 = 'Light Text',
                    })
                    ZIndex = ZIndex + 1
                end

                if cfg.children ~= nil then
                    Objects.ChildrenHolder = Utility.New('Frame', {
                        Name = 'ChildrenHolder',
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.fromOffset(0, 0),
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BorderSizePixel = 0,
                        Parent = Objects.Holder,
                        ZIndex = ZIndex,
                        Visible = cfg.children,
                        ClipsDescendants = true,
                    })

                    Utility.New('UIListLayout', {
                        Name = 'UIListLayout',
                        FillDirection = Enum.FillDirection.Vertical,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = Objects.ChildrenHolder,
                        Padding = UDim.new(0, 5),
                    })

                    Toggle.Holder = Objects.ChildrenHolder
                    ZIndex = ZIndex + 1
                end
            end

            Toggle.ZIndex = ZIndex

            function Toggle.Children(visibility)
                if cfg.children == nil and not Toggle.Holder then
                    return
                end
                if Toggle.Tweening then
                    return
                end
                if visibility == Objects.ChildrenHolder.Visible then
                    return
                end

                Toggle.Tweening = true

                if visibility then
                    Objects.ChildrenHolder.Visible = true
                end

                for _, obj in Objects.ChildrenHolder:GetDescendants()do
                    local Index = Utility.GetTransparency(obj)

                    if not Index then
                    end
                    if type(Index) == 'table' then
                        for _, prop in Index do
                            Library.Fade(obj, prop, visibility)
                        end
                    else
                        Library.Fade(obj, Index, visibility)
                    end
                end

                local OldSize = Objects.ChildrenHolder.AbsoluteSize

                Objects.ChildrenHolder.AutomaticSize = Enum.AutomaticSize.None
                Objects.ChildrenHolder.Size = visibility and UDim2.new(1, 0, 0, 0) or UDim2.new(1, 0, 0, OldSize.Y)

                local Tween = Library.Tween(Objects.ChildrenHolder, {
                    Size = visibility and UDim2.new(1, 0, 0, OldSize.Y) or UDim2.new(1, 0, 0, 0),
                })

                Utility.Signal(Tween.Completed:Connect(function()
                    Toggle.Tweening = false
                    Objects.ChildrenHolder.Size = UDim2.new(1, 0, 0, 0)
                    Objects.ChildrenHolder.AutomaticSize = Enum.AutomaticSize.Y
                    Objects.ChildrenHolder.Visible = visibility
                end))
            end
            
            function Toggle.Set(value)
                if Toggle.Tweening then
                    return
                end

                Toggle.Value = value

                Toggle.Children(value)
                
                if Objects.Icon then
                    Objects.Icon.Visible = value
                    if value then
                        Objects.Icon.ImageColor3 = Library.Theme.Accent
                    end
                end
                
                Library.ChangeObjectTheme(Objects.Text, {
                    TextColor3 = value and 'Text' or 'Dark Text',
                }, true)

                cfg.callback(value)

                Library.Flags[cfg.flag] = value

                if Library.OnToggleChange then
                    Library.OnToggleChange(cfg.name, value)
                end
            end
            
            function Toggle.Enable()
                Toggle.Set(not Toggle.Value)
            end

            Utility.Signal(Objects.Clickable.MouseButton1Click:Connect(Toggle.Enable))
            Toggle.Set(cfg.value)

            Library.ConfigFlags[cfg.flag] = Toggle.Set

            return setmetatable(Toggle, Library)
        end
        
        function Library.Slider(self, cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                name = 'New Slider',
                description = nil,
                value = 50,
                min = 0,
                max = 100,
                float = 1,
                suffix = '%s',
                callback = function() end,
                flag = nil,
                children = nil,
            })

            if not cfg.flag then
                cfg.flag = cfg.name
            end

            local Slider = {
                Tweening = false,
                Objects = {},
                ZIndex = self.ZIndex,
                Value = cfg.value,
                Sliding = false,
            }
            local ZIndex = Slider.ZIndex
            local Objects = Slider.Objects

            do
                Objects.Holder = Utility.New('Frame', {
                    Name = 'Holder',
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    Parent = self.Holder,
                    ZIndex = ZIndex,
                })

                Utility.New('UIPadding', {
                    Parent = Objects.Holder,
                    PaddingBottom = UDim.new(0, 2),
                })
                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Objects.Holder,
                    Padding = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.Line = Utility.New('TextButton', {
                    Name = 'Line',
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Style = Enum.ButtonStyle.Custom,
                    Text = '',
                    Parent = Objects.Holder,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Objects.Line,
                    Padding = UDim.new(0, 2),
                })

                ZIndex = ZIndex + 1
                Objects.Text = Utility.New('TextLabel', {
                    Name = 'Text',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = Library.FontSize,
                    FontFace = Library.Font,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Text = cfg.name,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Objects.Line,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Dark Text',
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Parent = Objects.Text,
                    Padding = UDim.new(0, 2),
                })

                ZIndex = ZIndex + 1
                Objects.SideHolder = Utility.New('Frame', {
                    Name = 'SideHolder',
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Objects.Text,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Parent = Objects.SideHolder,
                    Padding = UDim.new(0, 2),
                })

                Slider.SideHolder = Objects.SideHolder
                ZIndex = ZIndex + 1
                Objects.Value = Utility.New('TextLabel', {
                    Name = 'Value',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = Library.FontSize,
                    FontFace = Library.Font,
                    Size = UDim2.new(0, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Text = '',
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Objects.Text,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Dark Text',
                })
                ZIndex = ZIndex + 1

                if cfg.description then
                    Objects.Description = Utility.New('TextLabel', {
                        Name = 'Description',
                        TextStrokeTransparency = 0.8,
                        BackgroundTransparency = 1,
                        TextSize = Library.FontSize - 2,
                        FontFace = Library.Font,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Text = cfg.description,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Objects.Line,
                        ZIndex = ZIndex,
                        TextWrapped = true,
                    }, {
                        TextColor3 = 'Light Text',
                    })
                    ZIndex = ZIndex + 1
                end

                Objects.Outline = Utility.New('TextButton', {
                    Name = 'Line',
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.fromOffset(0, 0),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    Text = '',
                    Parent = Objects.Holder,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.Signal(Objects.Outline.MouseEnter:Connect(function()
                    if not Slider.Sliding then
                        Library.ChangeObjectTheme(Objects.Text, {
                            TextColor3 = 'Accent',
                        }, true)
                    end
                end))

                Utility.Signal(Objects.Outline.MouseLeave:Connect(function()
                    if not Slider.Sliding then
                        Library.ChangeObjectTheme(Objects.Text, {
                            TextColor3 = 'Dark Text',
                        }, true)
                    end
                end))

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Outline,
                })

                ZIndex = ZIndex + 1
                Objects.Background = Utility.New('Frame', {
                    Name = 'Background',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.fromOffset(1, 1),
                    BorderSizePixel = 0,
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Background,
                })

                ZIndex = ZIndex + 1
                Objects.Accent = Utility.New('Frame', {
                    Name = 'Accent',
                    Size = UDim2.new(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    Parent = Objects.Background,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Accent',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Accent,
                })
            end

            Slider.ZIndex = ZIndex

            function Slider.Set(value)
                Slider.Value = math.clamp(Utility.Round(value, cfg.float), cfg.min, cfg.max)
                Objects.Value.Text = string.format(cfg.suffix, tostring(Slider.Value))

                Library.Tween(Objects.Accent, {
                    Size = UDim2.new((Slider.Value - cfg.min) / (cfg.max - cfg.min), 0, 1, 0),
                })
                Library.ChangeObjectTheme(Objects.Text, {
                    TextColor3 = value > cfg.min and 'Text' or 'Dark Text',
                }, true)
                Library.ChangeObjectTheme(Objects.Value, {
                    TextColor3 = value > cfg.min and 'Text' or 'Dark Text',
                }, true)
                cfg.callback(Slider.Value)

                Library.Flags[cfg.flag] = Slider.Value
            end

            Utility.Signal(Objects.Outline.MouseButton1Down:Connect(function(
                input
            )
                local MouseLocation = UserInputService:GetMouseLocation()

                Slider.Sliding = true

                Slider.Set(((cfg.max - cfg.min) * ((MouseLocation.x - Objects.Outline.AbsolutePosition.x) / Objects.Outline.AbsoluteSize.x)) + cfg.min)
            end))
            Utility.Signal(UserInputService.InputEnded:Connect(function(
                input
            )
                if input.UserInputType == Enum.UserInputType.MouseButton1 and Slider.Sliding then
                    Slider.Sliding = false
                end
            end))
            Utility.Signal(UserInputService.InputChanged:Connect(function(
                input
            )
                if input.UserInputType == Enum.UserInputType.MouseMovement and Slider.Sliding then
                    Slider.Set(((cfg.max - cfg.min) * ((input.Position.x - Objects.Outline.AbsolutePosition.x) / Objects.Outline.AbsoluteSize.x)) + cfg.min)
                end
            end))
            Slider.Set(cfg.value)

            Library.ConfigFlags[cfg.flag] = Slider.Set

            return setmetatable(Slider, Library)
        end
        
        function Library.Button(self, cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                name = 'New Button',
                confirm = false,
                autosize = false,
                callback = function() end,
            })

            local Button = {
                Clicked = false,
                ZIndex = self.ZIndex,
                Time = 0,
                Objects = {},
            }
            local ZIndex = Button.ZIndex
            local Objects = Button.Objects

            do
                Objects.Outline = Utility.New('TextButton', {
                    Name = 'Outline',
                    Size = cfg.autosize and UDim2.new(0, 0, 0, 0) or UDim2.new(1, 0, 0, 0),
                    AutomaticSize = cfg.autosize and Enum.AutomaticSize.XY or Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    Parent = self.Holder,
                    TextSize = 0,
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Outline,
                })

                ZIndex = ZIndex + 1
                Objects.Background = Utility.New('Frame', {
                    Name = 'Background',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.fromOffset(1, 1),
                    BorderSizePixel = 0,
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Background,
                })
                Utility.New('UIPadding', {
                    Name = 'UIPadding',
                    PaddingTop = UDim.new(0, 2),
                    PaddingBottom = UDim.new(0, 5),
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    Parent = Objects.Background,
                })

                ZIndex = ZIndex + 1
                Objects.Text = Utility.New('TextLabel', {
                    Name = 'Text',
                    Size = cfg.autosize and UDim2.new(0, 0, 0, 0) or UDim2.new(1, 0, 0, 0),
                    Text = cfg.name,
                    TextSize = Library.FontSize,
                    FontFace = Library.Font,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    BackgroundTransparency = 1,
                    TextStrokeTransparency = 0.8,
                    Parent = Objects.Background,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Dark Text',
                })
                Objects.Text.Size = UDim2.new(cfg.autosize and 0 or 1, cfg.autosize and Objects.Text.TextBounds.X or 0, 0, Objects.Text.TextBounds.Y - 2)
            end

            Button.ZIndex = ZIndex

            function Button.StartConfirmation()
                Button.Clicked = true
                Button.Time = 5
                Objects.Text.Text = string.format('Confirm %s? (%s)', cfg.name, Button.Time)
                Button.Coroutine = coroutine.create(function()
                    for i = 1, 5 do
                        task.wait(1)

                        Button.Time = Button.Time - 1

                        if Button.Time > 0 then
                            Objects.Text.Text = string.format('Confirm %s? (%s)', cfg.name, Button.Time)
                        else
                            Objects.Text.Text = cfg.name

                            if Button.Clicked then
                                Library.ChangeObjectTheme(Objects.Text, {
                                    TextColor3 = 'Dark Text',
                                }, true)

                                Button.Clicked = false
                            end

                            break
                        end
                    end
                end)

                coroutine.resume(Button.Coroutine)
            end
            
            function Button.Click()
                if cfg.confirm then
                    if Button.Clicked then
                        Library.ChangeObjectTheme(Objects.Text, {
                            TextColor3 = 'Dark Text',
                        }, true)
                        coroutine.close(Button.Coroutine)

                        Objects.Text.Text = cfg.name
                        Button.Clicked = false

                        cfg.callback()
                    else
                        Library.ChangeObjectTheme(Objects.Text, {
                            TextColor3 = 'Accent',
                        }, true)
                        Button.StartConfirmation()
                    end
                else
                    cfg.callback()
                    Library.ChangeObjectTheme(Objects.Text, {
                        TextColor3 = 'Accent',
                    }, true)
                    task.wait(Library.TweenSpeed)
                    Library.ChangeObjectTheme(Objects.Text, {
                        TextColor3 = 'Dark Text',
                    }, true)
                end
            end

            Utility.Signal(Objects.Outline.MouseButton1Click:Connect(Button.Click))

            return setmetatable(Button, Library)
        end
        
        function Library.List(self, cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                name = 'New List',
                description = nil,
                value = 'value1',
                values = {
                    'value1',
                    'value2',
                    'value3',
                    'value4',
                    'value5',
                },
                multi = false,
                size = 100,
                callback = function() end,
                flag = nil,
            })

            if not cfg.flag then
                cfg.flag = cfg.name
            end

            local List = {
                ZIndex = self.ZIndex,
                Objects = {},
                Popup = {},
                Items = {},
                Value = nil,
            }
            local ZIndex = List.ZIndex
            local Objects = List.Objects

            do
                Objects.Holder = Utility.New('Frame', {
                    Name = 'Holder',
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    Parent = self.Holder,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Objects.Holder,
                    Padding = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.Line = Utility.New('TextButton', {
                    Name = 'Line',
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Style = Enum.ButtonStyle.Custom,
                    Text = '',
                    Parent = Objects.Holder,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Objects.Line,
                    Padding = UDim.new(0, 2),
                })

                ZIndex = ZIndex + 1
                Objects.Text = Utility.New('TextLabel', {
                    Name = 'Text',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = Library.FontSize,
                    FontFace = Library.Font,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Text = cfg.name,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Objects.Line,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Dark Text',
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Parent = Objects.Text,
                    Padding = UDim.new(0, 2),
                })

                ZIndex = ZIndex + 1
                Objects.SideHolder = Utility.New('Frame', {
                    Name = 'SideHolder',
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Objects.Text,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Parent = Objects.SideHolder,
                    Padding = UDim.new(0, 2),
                })

                List.SideHolder = Objects.SideHolder
                ZIndex = ZIndex + 1

                if cfg.description then
                    Objects.Description = Utility.New('TextLabel', {
                        Name = 'Description',
                        TextStrokeTransparency = 0.8,
                        BackgroundTransparency = 1,
                        TextSize = Library.FontSize - 2,
                        FontFace = Library.Font,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Text = cfg.description,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Objects.Line,
                        ZIndex = ZIndex,
                        TextWrapped = true,
                    }, {
                        TextColor3 = 'Light Text',
                    })
                    ZIndex = ZIndex + 1
                end

                Objects.Outline = Utility.New('TextButton', {
                    Name = 'Outline',
                    Size = UDim2.new(1, 0, 0, cfg.size),
                    Position = UDim2.fromOffset(0, 0),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    Text = '',
                    Parent = Objects.Holder,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Outline,
                })

                ZIndex = ZIndex + 1
                Objects.Background = Utility.New('Frame', {
                    Name = 'Background',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.fromOffset(1, 1),
                    BorderSizePixel = 0,
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                    ClipsDescendants = true,
                }, {
                    BackgroundColor3 = 'Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Background,
                })
                Utility.New('UIPadding', {
                    Name = 'UIPadding',
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                    Parent = Objects.Background,
                })

                ZIndex = ZIndex + 1
                Objects.Scrolling = Utility.New('ScrollingFrame', {
                    Name = 'Scrolling',
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Objects.Background,
                    ZIndex = ZIndex,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    BottomImage = Library.ScrollBar,
                    MidImage = Library.ScrollBar,
                    TopImage = Library.ScrollBar,
                    ScrollBarThickness = 2,
                }, {
                    ScrollBarImageColor3 = 'Accent',
                })
                ZIndex = ZIndex + 1
                Objects.Content = Utility.New('Frame', {
                    Name = 'Content',
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Objects.Scrolling,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Parent = Objects.Content,
                    Padding = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
            end

            List.ZIndex = ZIndex

            function List.Set(value)
                if cfg.multi then
                    if type(value) == 'table' then
                        for _, item in List.Items do
                            item.Select(false)
                        end
                        for _, item in value do
                            for _, item2 in List.Items do
                                if item2.Name == item then
                                    item2.Select(true)
                                end
                            end
                        end

                        List.Value = value

                        cfg.callback(List.Value)

                        Library.Flags[cfg.flag] = List.Value
                    else
                        local Index = table.find(List.Value, value)

                        if Index then
                            table.remove(List.Value, Index)

                            for _, item in List.Items do
                                if item.Name == value then
                                    item.Select(false)
                                end
                            end

                            cfg.callback(List.Value)

                            Library.Flags[cfg.flag] = List.Value
                        else
                            table.insert(List.Value, value)

                            for _, item in List.Items do
                                if item.Name == value then
                                    item.Select(true)
                                end
                            end

                            cfg.callback(List.Value)

                            Library.Flags[cfg.flag] = List.Value
                        end
                    end
                else
                    for _, item in List.Items do
                        item.Select(item.Name == value)
                    end

                    List.Value = value

                    cfg.callback(List.Value)

                    Library.Flags[cfg.flag] = List.Value
                end
            end
            
            function List.Add(name)
                local Item = {
                    Objects = {},
                    Name = name,
                    Selected = false,
                }
                local Objs = Item.Objects

                do
                    Objs.Text = Utility.New('TextButton', {
                        Name = 'Text',
                        TextStrokeTransparency = 0.8,
                        BackgroundTransparency = 1,
                        TextSize = Library.FontSize,
                        FontFace = Library.Font,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Text = name,
                        AutoButtonColor = false,
                        Style = Enum.ButtonStyle.Custom,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Objects.Content,
                        ZIndex = ZIndex,
                    }, {
                        TextColor3 = 'Dark Text',
                    })
                end

                function Item.Select(value)
                    Library.ChangeObjectTheme(Objs.Text, {
                        TextColor3 = value and 'Text' or 'Dark Text',
                    }, true)

                    Item.Selected = value
                end

                Utility.Signal(Objs.Text.MouseButton1Click:Connect(function(
                )
                    List.Set(name)
                end))
                table.insert(List.Items, Item)

                return Item
            end
            
            function List.Refresh(tbl)
                for _, item in List.Items do
                    item.Objects.Text:Destroy()
                end

                List.Items = {}
                List.Value = cfg.multi and {} or nil

                for _, item in tbl do
                    if type(item) == 'string' then
                        List.Add(item)
                    end
                end
            end

            for _, item in cfg.values do
                List.Add(item)
            end

            List.Set(cfg.value)

            Library.ConfigFlags[cfg.flag] = List.Set

            return setmetatable(List, Library)
        end
        
        function Library.Dropdown(self, cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                name = 'New Dropdown',
                description = nil,
                values = {
                    'value1',
                    'value2',
                    'value3',
                    'value4',
                    'value5',
                },
                value = 'value1',
                multi = false,
                flag = nil,
                callback = function() end,
            })

            if not cfg.flag then
                cfg.flag = cfg.name
            end

            local Dropdown = {
                Tweening = false,
                Visible = false,
                ZIndex = self.ZIndex,
                Objects = {},
                Popup = {},
                Items = {},
                Value = nil,
                ParentPopup = self,
            }
            local ZIndex = self.ZIndex
            local Objects = Dropdown.Objects

            do
                Objects.Holder = Utility.New('Frame', {
                    Name = 'Holder',
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    Parent = self.Holder,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Objects.Holder,
                    Padding = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.Line = Utility.New('TextButton', {
                    Name = 'Line',
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Style = Enum.ButtonStyle.Custom,
                    Text = '',
                    Parent = Objects.Holder,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Objects.Line,
                    Padding = UDim.new(0, 2),
                })

                ZIndex = ZIndex + 1
                Objects.Text = Utility.New('TextLabel', {
                    Name = 'Text',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = Library.FontSize,
                    FontFace = Library.Font,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Text = cfg.name,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Objects.Line,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Dark Text',
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Parent = Objects.Text,
                    Padding = UDim.new(0, 2),
                })

                ZIndex = ZIndex + 1
                Objects.SideHolder = Utility.New('Frame', {
                    Name = 'SideHolder',
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Objects.Text,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Parent = Objects.SideHolder,
                    Padding = UDim.new(0, 2),
                })

                Dropdown.SideHolder = Objects.SideHolder
                ZIndex = ZIndex + 1

                if cfg.description then
                    Objects.Description = Utility.New('TextLabel', {
                        Name = 'Description',
                        TextStrokeTransparency = 0.8,
                        BackgroundTransparency = 1,
                        TextSize = Library.FontSize - 2,
                        FontFace = Library.Font,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Text = cfg.description,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Objects.Line,
                        ZIndex = ZIndex,
                        TextWrapped = true,
                    }, {
                        TextColor3 = 'Light Text',
                    })
                    ZIndex = ZIndex + 1
                end

                Objects.Outline = Utility.New('TextButton', {
                    Name = 'Outline',
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.fromOffset(0, 0),
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    Text = '',
                    Parent = Objects.Holder,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.Signal(Objects.Outline.MouseEnter:Connect(function()
                    if not Dropdown.Visible then
                        Library.ChangeObjectTheme(Objects.Text, {
                            TextColor3 = 'Accent',
                        }, true)
                        Library.ChangeObjectTheme(Objects.Value, {
                            TextColor3 = 'Accent',
                        }, true)
                    end
                end))

                Utility.Signal(Objects.Outline.MouseLeave:Connect(function()
                    if not Dropdown.Visible then
                        Library.ChangeObjectTheme(Objects.Text, {
                            TextColor3 = 'Dark Text',
                        }, true)
                        Library.ChangeObjectTheme(Objects.Value, {
                            TextColor3 = 'Text',
                        }, true)
                    end
                end))

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Outline,
                })

                ZIndex = ZIndex + 1
                Objects.Background = Utility.New('Frame', {
                    Name = 'Background',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.fromOffset(1, 1),
                    BorderSizePixel = 0,
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                    ClipsDescendants = true,
                }, {
                    BackgroundColor3 = 'Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Background,
                })
                Utility.New('UIPadding', {
                    Name = 'UIPadding',
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 2),
                    PaddingBottom = UDim.new(0, 2),
                    Parent = Objects.Background,
                })

                ZIndex = ZIndex + 1
                Objects.Value = Utility.New('TextLabel', {
                    Name = 'Text',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = Library.FontSize,
                    FontFace = Library.Font,
                    Size = UDim2.new(1, 0, 1, -2),
                    Text = 'Value',
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Objects.Background,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Text',
                })
                ZIndex = ZIndex + 1
            end

            Dropdown.ZIndex = ZIndex

            local Popup = Dropdown.Popup

            do
                Popup.Outline = Utility.New('Frame', {
                    Name = 'Outline',
                    Size = UDim2.new(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    Parent = Library.ScreenGui,
                    ZIndex = ZIndex,
                    ClipsDescendants = true,
                    Visible = false,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                if self.BoundObjects then
                    table.insert(self.BoundObjects, Popup.Outline)
                end

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Popup.Outline,
                    CornerRadius = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Popup.Background = Utility.New('TextButton', {
                    Name = 'Background',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.fromOffset(1, 1),
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    BorderSizePixel = 0,
                    Parent = Popup.Outline,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Popup.Background,
                    CornerRadius = UDim.new(0, 5),
                })
                Utility.New('UIPadding', {
                    Name = 'UIPadding',
                    Parent = Popup.Background,
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Popup.Scroll = Utility.New('ScrollingFrame', {
                    Name = 'Scroll',
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Popup.Background,
                    ZIndex = ZIndex,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    BottomImage = Library.ScrollBar,
                    MidImage = Library.ScrollBar,
                    TopImage = Library.ScrollBar,
                    ScrollBarThickness = 2,
                }, {
                    ScrollBarImageColor3 = 'Accent',
                })
                Popup.Holder = Utility.New('Frame', {
                    Name = 'Holder',
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Parent = Popup.Scroll,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Popup.Holder,
                    Padding = UDim.new(0, 5),
                })
            end

            Popup.ZIndex = ZIndex

            Utility.Signal(Objects.Outline:GetPropertyChangedSignal('AbsolutePosition'):Connect(function(
            )
                if Dropdown.Visible then
                    local Size = Objects.Outline.AbsoluteSize
                    local Position = Objects.Outline.AbsolutePosition

                    Popup.Outline.Position = UDim2.new(0, Position.X, 0, Position.Y + Size.Y + 5)
                end
            end))
            Utility.Signal(UserInputService.InputBegan:Connect(function(
                input
            )
                if input.UserInputType == Enum.UserInputType.MouseButton1 and Dropdown.Visible then
                    if not Utility.MouseOver(Popup.Outline, input) and not Utility.MouseOver(Objects.Outline, input) then
                        Dropdown.Open()
                    end
                end
            end))

            function Dropdown.Display()
                local Value = Dropdown.Value

                if cfg.multi then
                    local CurrentText = {}

                    if Value and #Value > 0 then
                        for _, item in Value do
                            if type(item) == 'string' then
                                table.insert(CurrentText, item)
                            end
                        end

                        if #CurrentText > 0 then
                            Objects.Value.Text = table.concat(CurrentText, ', ')
                        else
                            Objects.Value.Text = '-'
                        end
                    else
                        Objects.Value.Text = '-'
                    end
                else
                    if type(Value) == 'string' then
                        Objects.Value.Text = Value ~= '' and Value or '-'
                    else
                        Objects.Value.Text = '-'
                    end
                end
            end
            
            function Dropdown.Size()
                local Size = 0
                local Count = 0

                for _, v in Popup.Holder:GetChildren()do
                    Count = Count + 1

                    if v:IsA('TextButton') then
                        Size = Size + v.AbsoluteSize.y + 5
                    end
                    if Count > 4 then
                        break
                    end
                end

                Size = Size + 10

                return Size
            end
            
            function Dropdown.Open()
                if Dropdown.Tweening then
                    return
                end

                Dropdown.Tweening = true
                Dropdown.Visible = not Dropdown.Visible

                if Dropdown.Visible then
                    Popup.Outline.Visible = true
                end

                local ParentObjects = Popup.Outline:GetDescendants()

                table.insert(ParentObjects, Popup.Outline)

                for _, obj in ParentObjects do
                    local Index = Utility.GetTransparency(obj)

                    if not Index then
                    end
                    if type(Index) == 'table' then
                        for _, prop in Index do
                            Library.Fade(obj, prop, Dropdown.Visible)
                        end
                    else
                        Library.Fade(obj, Index, Dropdown.Visible)
                    end
                end

                local Size = Objects.Outline.AbsoluteSize
                local Position = Objects.Outline.AbsolutePosition

                Popup.Outline.Position = UDim2.new(0, Position.X, 0, Position.Y + Size.Y + 5)
                Popup.Outline.Size = Dropdown.Visible and UDim2.new(0, Size.X, 0, 20) or UDim2.new(0, Size.X, 0, Dropdown.Size())

                local Tween = Library.Tween(Popup.Outline, {
                    Size = Dropdown.Visible and UDim2.new(0, Size.X, 0, Dropdown.Size()) or UDim2.new(0, Size.X, 0, 20),
                })

                Utility.Signal(Tween.Completed:Connect(function()
                    Popup.Outline.Visible = Dropdown.Visible
                    Dropdown.Tweening = false
                end))
            end
            
            function Dropdown.Set(value, ignore)
                if cfg.multi then
                    if type(value) == 'table' then
                        for _, item in Dropdown.Items do
                            item.Select(false)
                        end
                        for _, item in value do
                            for _, item2 in Dropdown.Items do
                                if item2.Name == item then
                                    item2.Select(true)
                                end
                            end
                        end

                        Dropdown.Value = value

                        Dropdown.Display()

                        if not ignore then
                            cfg.callback(Dropdown.Value)
                        end

                        Library.Flags[cfg.flag] = Dropdown.Value
                    else
                        local Index = table.find(Dropdown.Value, value)

                        if Index then
                            table.remove(Dropdown.Value, Index)

                            for _, item in Dropdown.Items do
                                if item.Name == value then
                                    item.Select(false)
                                end
                            end

                            Dropdown.Display()

                            if not ignore then
                                cfg.callback(Dropdown.Value)
                            end

                            Library.Flags[cfg.flag] = Dropdown.Value
                        else
                            table.insert(Dropdown.Value, value)

                            for _, item in Dropdown.Items do
                                if item.Name == value then
                                    item.Select(true)
                                end
                            end

                            Dropdown.Display()

                            if not ignore then
                                cfg.callback(Dropdown.Value)
                            end

                            Library.Flags[cfg.flag] = Dropdown.Value
                        end
                    end
                else
                    for _, item in Dropdown.Items do
                        item.Select(item.Name == value)
                    end

                    Dropdown.Value = type(value) == 'string' and value or nil

                    Dropdown.Display()

                    if not ignore then
                        cfg.callback(Dropdown.Value)
                    end

                    Library.Flags[cfg.flag] = Dropdown.Value
                end
            end
            
            function Dropdown.Add(name)
                if type(name) ~= 'string' then
                    return
                end

                local Item = {
                    Objects = {},
                    Name = name,
                    Selected = false,
                }
                local Objects = Item.Objects

                do
                    Objects.Text = Utility.New('TextButton', {
                        Name = 'Text',
                        TextStrokeTransparency = 0.8,
                        BackgroundTransparency = 1,
                        TextSize = Library.FontSize,
                        FontFace = Library.Font,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Text = name,
                        AutoButtonColor = false,
                        Style = Enum.ButtonStyle.Custom,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Popup.Holder,
                        ZIndex = ZIndex,
                    }, {
                        TextColor3 = 'Dark Text',
                    })
                end

                function Item.Select(value)
                    Library.ChangeObjectTheme(Objects.Text, {
                        TextColor3 = value and 'Text' or 'Dark Text',
                    }, true)

                    Item.Selected = value
                end

                Utility.Signal(Objects.Text.MouseButton1Click:Connect(function(
                )
                    Dropdown.Set(name)
                end))
                table.insert(Dropdown.Items, Item)

                return Item
            end
            
            function Dropdown.Refresh(tbl)
                for _, item in Dropdown.Items do
                    item.Objects.Text:Destroy()
                end

                Dropdown.Items = {}
                Dropdown.Value = cfg.multi and {} or nil

                for _, item in tbl do
                    if type(item) == 'string' then
                        Dropdown.Add(item)
                    end
                end

                Dropdown.Display()
            end

            for _, item in cfg.values do
                Dropdown.Add(item)
            end

            Dropdown.Set(cfg.value)
            Utility.Signal(Objects.Outline.MouseButton1Click:Connect(Dropdown.Open))

            Library.ConfigFlags[cfg.flag] = Dropdown.Set

            table.insert(Library.Dropdowns, Dropdown)

            return setmetatable(Dropdown, Library)
        end
        
        function Library.Colorpicker(self, cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                name = 'New Colorpicker',
                value = Color3.new(1, 1, 1),
                alpha = 0,
                flag = nil,
                callback = function() end,
            })

            local Colorpicker = {
                Tweening = false,
                ZIndex = self.ZIndex,
                Objects = {},
                Popup = {},
                Value = cfg.value,
                Alpha = cfg.alpha,
            }
            local ZIndex = Colorpicker.ZIndex
            local Objects = Colorpicker.Objects

            do
                if not self.SideHolder then
                    Objects.Holder = Utility.New('Frame', {
                        Name = 'Holder',
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.fromOffset(0, 0),
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BorderSizePixel = 0,
                        Parent = self.Holder,
                        ZIndex = ZIndex,
                    })

                    Utility.New('UIListLayout', {
                        Name = 'UIListLayout',
                        FillDirection = Enum.FillDirection.Vertical,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = Objects.Holder,
                        Padding = UDim.new(0, 5),
                    })

                    ZIndex = ZIndex + 1
                    Objects.Line = Utility.New('TextButton', {
                        Name = 'Line',
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.fromOffset(0, 0),
                        BackgroundTransparency = 1,
                        AutoButtonColor = false,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Style = Enum.ButtonStyle.Custom,
                        Text = '',
                        Parent = Objects.Holder,
                        ZIndex = ZIndex,
                    })

                    Utility.New('UIListLayout', {
                        Name = 'UIListLayout',
                        FillDirection = Enum.FillDirection.Vertical,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = Objects.Line,
                        Padding = UDim.new(0, 2),
                    })

                    ZIndex = ZIndex + 1
                    Objects.Text = Utility.New('TextLabel', {
                        Name = 'Text',
                        TextStrokeTransparency = 0.8,
                        BackgroundTransparency = 1,
                        TextSize = Library.FontSize,
                        FontFace = Library.Font,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Text = cfg.name,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Objects.Line,
                        ZIndex = ZIndex,
                    }, {
                        TextColor3 = 'Dark Text',
                    })

                    Utility.New('UIListLayout', {
                        Name = 'UIListLayout',
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        Parent = Objects.Text,
                        Padding = UDim.new(0, 2),
                    })

                    ZIndex = ZIndex + 1
                    Objects.SideHolder = Utility.New('Frame', {
                        Name = 'SideHolder',
                        Size = UDim2.new(0, 0, 1, 0),
                        AutomaticSize = Enum.AutomaticSize.X,
                        Position = UDim2.fromOffset(0, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = Objects.Text,
                        ZIndex = ZIndex,
                    })

                    Utility.New('UIListLayout', {
                        Name = 'UIListLayout',
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        Parent = Objects.SideHolder,
                        Padding = UDim.new(0, 2),
                    })

                    Colorpicker.SideHolder = Objects.SideHolder
                    ZIndex = ZIndex + 1
                end

                local Parent = self.SideHolder or Objects.Text

                Objects.Outline = Utility.New('TextButton', {
                    Name = 'Outline',
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 0,
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    Parent = Parent,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })
                Objects.Outline.Size = UDim2.new(0, Parent.AbsoluteSize.Y, 0, Parent.AbsoluteSize.Y)

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Outline,
                })

                ZIndex = ZIndex + 1
                Objects.Background = Utility.New('Frame', {
                    Name = 'Background',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.fromOffset(1, 1),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 0,
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Background,
                })

                ZIndex = ZIndex + 1
            end

            Colorpicker.ZIndex = ZIndex

            local ColorpickerWindow = Library.ColorpickerWindow

            function Colorpicker.Set(value, alpha)
                local Color, Alpha

                if type(value) == 'table' then
                    Color = value.c
                    Alpha = value.a
                else
                    Color = value
                    Alpha = alpha or Colorpicker.Alpha
                end

                Colorpicker.Value = Color

                if Alpha then
                    Colorpicker.Alpha = Alpha
                    Objects.Background.BackgroundTransparency = Alpha
                end

                Objects.Background.BackgroundColor3 = Color
                Library.Flags[cfg.flag] = {
                    c = Color,
                    a = Alpha,
                }

                cfg.callback({
                    c = Color,
                    a = Alpha,
                })
            end

            Utility.Signal(Objects.Outline.MouseButton1Click:Connect(function(
                input
            )
                ColorpickerWindow.Flag = cfg.flag
                ColorpickerWindow.SetFunc = Colorpicker.Set

                ColorpickerWindow.Set(Colorpicker.Value, Colorpicker.Alpha)

                if ColorpickerWindow.Open then
                    ColorpickerWindow.Open(Objects.Outline.AbsolutePosition + Vector2.new(0, Objects.Outline.AbsoluteSize.Y + 2))
                end
            end))
            Utility.Signal(UserInputService.InputBegan:Connect(function(
                input
            )
                if input.UserInputType == Enum.UserInputType.MouseButton1 and ColorpickerWindow.Visible and ColorpickerWindow.Flag == cfg.flag and not (Utility.MouseOver(ColorpickerWindow.Objects.Outline, input) or Utility.MouseOver(Objects.Outline, input)) then
                    if ColorpickerWindow.Open then
                        ColorpickerWindow.Open(Objects.Outline.AbsolutePosition + Vector2.new(0, Objects.Outline.AbsoluteSize.Y + 2))
                    end
                end
            end))
            Utility.Signal(Objects.Outline:GetPropertyChangedSignal('AbsolutePosition'):Connect(function(
            )
                if ColorpickerWindow.Visible and ColorpickerWindow.Flag == cfg.flag then
                    local Position = Objects.Outline.AbsolutePosition + Vector2.new(0, Objects.Outline.AbsoluteSize.Y + 2)

                    ColorpickerWindow.Objects.Outline.Position = UDim2.new(0, Position.x, 0, Position.y)
                end
            end))
            Colorpicker.Set(cfg.value, cfg.alpha)

            Library.ConfigFlags[cfg.flag] = Colorpicker.Set

            return setmetatable(Colorpicker, Library)
        end
        
        function Library.Textbox(self, cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                name = 'New Textbox',
                value = '',
                callback = function() end,
                flag = nil,
            })

            if not cfg.flag then
                cfg.flag = cfg.name
            end

            local Textbox = {
                ZIndex = self.ZIndex,
                Objects = {},
            }
            local ZIndex = Textbox.ZIndex
            local Objects = Textbox.Objects

            do
                Objects.Outline = Utility.New('TextButton', {
                    Name = 'Outline',
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    Parent = self.Holder,
                    TextSize = 0,
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    ZIndex = ZIndex,
                    ClipsDescendants = true,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Outline,
                })

                ZIndex = ZIndex + 1
                Objects.Background = Utility.New('Frame', {
                    Name = 'Background',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.fromOffset(1, 1),
                    BorderSizePixel = 0,
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Background,
                })
                Utility.New('UIPadding', {
                    Name = 'UIPadding',
                    PaddingTop = UDim.new(0, 2),
                    PaddingBottom = UDim.new(0, 5),
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    Parent = Objects.Background,
                })

                ZIndex = ZIndex + 1
                Objects.TextBox = Utility.New('TextBox', {
                    Name = 'TextBox',
                    Size = UDim2.new(1, 0, 0, 0),
                    Text = cfg.value,
                    ClearTextOnFocus = false,
                    PlaceholderText = cfg.name,
                    ClipsDescendants = true,
                    MultiLine = false,
                    TextSize = Library.FontSize,
                    FontFace = Library.Font,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    BackgroundTransparency = 1,
                    TextStrokeTransparency = 0.8,
                    Parent = Objects.Background,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Text',
                    PlaceholderColor3 = 'Dark Text',
                })
                Objects.TextBox.Size = UDim2.new(1, 0, 0, Objects.TextBox.TextBounds.Y - 2)
            end

            Textbox.ZIndex = ZIndex

            function Textbox.Set(value)
                Objects.TextBox.Text = value
                Library.Flags[cfg.flag] = value

                cfg.callback(value)
            end

            Utility.Signal(Objects.TextBox.FocusLost:Connect(function()
                Textbox.Set(Objects.TextBox.Text)
            end))
            Textbox.Set(cfg.value)

            Library.ConfigFlags[cfg.flag] = Textbox.Set

            return setmetatable(Textbox, Library)
        end
        
        function Library.Keybind(self, cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                name = 'New Keybind',
                value = false,
                key = Enum.KeyCode.Unknown,
                mode = 'Toggle',
                callback = function() end,
                flag = nil,
            })

            if not cfg.flag then
                cfg.flag = cfg.name
            end

            local Keybind = {
                Tweening = false,
                Visible = false,
                ZIndex = self.ZIndex,
                Objects = {},
                Popup = {},
                Key = nil,
                Mode = nil,
                Value = false,
                OnHold = nil,
                Listener = nil,
            }
            local ZIndex = Keybind.ZIndex
            local Objects = Keybind.Objects

            do
                if not self.SideHolder then
                    Objects.Holder = Utility.New('Frame', {
                        Name = 'Holder',
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.fromOffset(0, 0),
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BorderSizePixel = 0,
                        Parent = self.Holder,
                        ZIndex = ZIndex,
                    })

                    Utility.New('UIListLayout', {
                        Name = 'UIListLayout',
                        FillDirection = Enum.FillDirection.Vertical,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = Objects.Holder,
                        Padding = UDim.new(0, 5),
                    })

                    ZIndex = ZIndex + 1
                    Objects.Line = Utility.New('TextButton', {
                        Name = 'Line',
                        Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.fromOffset(0, 0),
                        BackgroundTransparency = 1,
                        AutoButtonColor = false,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Style = Enum.ButtonStyle.Custom,
                        Text = '',
                        Parent = Objects.Holder,
                        ZIndex = ZIndex,
                    })

                    Utility.New('UIListLayout', {
                        Name = 'UIListLayout',
                        FillDirection = Enum.FillDirection.Vertical,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = Objects.Line,
                        Padding = UDim.new(0, 2),
                    })

                    ZIndex = ZIndex + 1
                    Objects.Text = Utility.New('TextLabel', {
                        Name = 'Text',
                        TextStrokeTransparency = 0.8,
                        BackgroundTransparency = 1,
                        TextSize = Library.FontSize,
                        FontFace = Library.Font,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Text = cfg.name,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Objects.Line,
                        ZIndex = ZIndex,
                    }, {
                        TextColor3 = 'Dark Text',
                    })

                    Utility.New('UIListLayout', {
                        Name = 'UIListLayout',
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        Parent = Objects.Text,
                        Padding = UDim.new(0, 2),
                    })

                    ZIndex = ZIndex + 1
                    Objects.SideHolder = Utility.New('Frame', {
                        Name = 'SideHolder',
                        Size = UDim2.new(0, 0, 1, 0),
                        AutomaticSize = Enum.AutomaticSize.X,
                        Position = UDim2.fromOffset(0, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = Objects.Text,
                        ZIndex = ZIndex,
                    })

                    Utility.New('UIListLayout', {
                        Name = 'UIListLayout',
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        Parent = Objects.SideHolder,
                        Padding = UDim.new(0, 2),
                    })

                    Keybind.SideHolder = Objects.SideHolder
                    ZIndex = ZIndex + 1
                end

                local Parent = self.SideHolder or Objects.Text

                Objects.Icon = Utility.New('ImageButton', {
                    Name = 'Icon',
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    Image = 'rbxassetid://81471583706380',
                    Parent = Parent,
                    ZIndex = ZIndex,
                    ScaleType = Enum.ScaleType.Crop,
                }, {
                    ImageColor3 = 'Text',
                })
                Objects.Icon.Size = UDim2.new(0, Parent.AbsoluteSize.Y, 0, Parent.AbsoluteSize.Y)
            end

            Keybind.ZIndex = ZIndex

            local Popup = Keybind.Popup

            do
                Popup.Outline = Utility.New('Frame', {
                    Name = 'Outline',
                    Size = UDim2.new(0, 150, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    Parent = Library.ScreenGui,
                    ZIndex = ZIndex,
                    ClipsDescendants = true,
                    Visible = false,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Popup.Outline,
                    CornerRadius = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Popup.Background = Utility.New('TextButton', {
                    Name = 'Background',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.fromOffset(1, 1),
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    BorderSizePixel = 0,
                    Parent = Popup.Outline,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Popup.Background,
                    CornerRadius = UDim.new(0, 5),
                })
                Utility.New('UIPadding', {
                    Name = 'UIPadding',
                    Parent = Popup.Background,
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Popup.Holder = Utility.New('Frame', {
                    Name = 'Holder',
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Parent = Popup.Background,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Popup.Holder,
                    Padding = UDim.new(0, 5),
                })

                Popup.Line = Utility.New('TextButton', {
                    Name = 'Line',
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Style = Enum.ButtonStyle.Custom,
                    Text = '',
                    Parent = Popup.Holder,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Popup.Line,
                    Padding = UDim.new(0, 2),
                })

                ZIndex = ZIndex + 1
                Popup.Text = Utility.New('TextLabel', {
                    Name = 'Text',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = Library.FontSize,
                    FontFace = Library.Font,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Text = 'Key',
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Popup.Line,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Dark Text',
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Parent = Popup.Text,
                    Padding = UDim.new(0, 2),
                })

                ZIndex = ZIndex + 1
                Popup.KeyOutline = Utility.New('TextButton', {
                    Name = 'Outline',
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 0,
                    Parent = Popup.Text,
                    Text = '',
                    AutoButtonColor = false,
                    Style = Enum.ButtonStyle.Custom,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })
                Popup.KeyOutline.Size = UDim2.new(0, 25, 0, Popup.Text.AbsoluteSize.Y)

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Popup.KeyOutline,
                })

                ZIndex = ZIndex + 1
                Popup.KeyBackground = Utility.New('Frame', {
                    Name = 'Background',
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.fromOffset(1, 1),
                    BorderSizePixel = 0,
                    Parent = Popup.KeyOutline,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Popup.KeyBackground,
                })

                ZIndex = ZIndex + 1
                Popup.Key = Utility.New('TextLabel', {
                    Name = 'Text',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = Library.FontSize - 2,
                    FontFace = Library.Font,
                    Size = UDim2.new(1, 0, 1, -2),
                    Text = 'E',
                    Parent = Popup.KeyBackground,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Dark Text',
                })
            end

            Keybind.ZIndex = ZIndex

            function Keybind.Set(value, ignore)
                if type(value) == 'table' then
                    for _, v in value do
                        Keybind.Set(v, true)
                    end

                    return
                end

                local Type = typeof(value)

                if Type == 'EnumItem' then
                    Keybind.Key = value
                    value = (value == Enum.KeyCode.Unknown and 'None' or value.Name)
                    Popup.Key.Text = Library.KeyConverters[value:lower()] or value

                    Library.Tween(Popup.KeyOutline, {
                        Size = UDim2.new(0, Popup.Key.TextBounds.X + 10, 0, Popup.Text.AbsoluteSize.Y),
                    })
                elseif Type == 'boolean' then
                    if Keybind.Mode == 'Always' and not value then
                        value = true
                    end

                    Keybind.Value = value
                elseif Type == 'string' then
                    if Keybind.OnHold and value ~= 'Hold' then
                        Keybind.OnHold:Disconnect()

                        Keybind.OnHold = nil
                    end

                    Keybind.Mode = value

                    if Popup.Dropdown then
                        Popup.Dropdown.Set(Keybind.Mode, true)
                    end
                    if value == 'Always' then
                        Keybind.Value = true
                    end
                end
                if not ignore then
                    Library.Flags[cfg.flag] = Keybind.Value

                    cfg.callback(Keybind.Value)
                end

                Library.Flags[string.format('%s_data', cfg.flag)] = {
                    value = Keybind.Value,
                    key = Keybind.Key,
                    mode = Keybind.Mode,
                }
            end

            Popup.Dropdown = Library.Dropdown({
                ZIndex = ZIndex,
                Holder = Popup.Holder,
            }, {
                Name = 'Mode',
                Values = {
                    'Toggle',
                    'Hold',
                    'Always',
                },
                Value = cfg.mode,
                Callback = function(v)
                    Keybind.Set(v, true)
                end,
            })

            function Keybind.Open()
                if Keybind.Tweening then
                    return
                end

                Keybind.Tweening = true
                Keybind.Visible = not Keybind.Visible

                if Keybind.Visible then
                    Popup.Outline.Visible = true
                end

                local ParentObjects = Popup.Outline:GetDescendants()

                table.insert(ParentObjects, Popup.Outline)

                for _, obj in ParentObjects do
                    local Index = Utility.GetTransparency(obj)

                    if Index then
                        if type(Index) == 'table' then
                            for _, prop in Index do
                                Library.Fade(obj, prop, Keybind.Visible)
                            end
                        else
                            Library.Fade(obj, Index, Keybind.Visible)
                        end
                    end
                end

                local OldSize = Popup.Outline.AbsoluteSize
                local Position = Objects.Icon.AbsolutePosition + Vector2.new(0, Objects.Icon.AbsoluteSize.y + 5)

                Popup.Outline.AutomaticSize = Enum.AutomaticSize.None
                Popup.Outline.Size = Keybind.Visible and UDim2.new(0, OldSize.x, 0, 0) or UDim2.new(0, OldSize.x, 0, OldSize.Y)
                Popup.Outline.Position = UDim2.new(0, Position.X, 0, Position.Y)

                local Tween = Library.Tween(Popup.Outline, {
                    Size = Keybind.Visible and UDim2.new(0, OldSize.x, 0, OldSize.Y) or UDim2.new(0, OldSize.x, 0, 0),
                })

                Utility.Signal(Tween.Completed:Connect(function()
                    Keybind.Tweening = false
                    Popup.Outline.Size = UDim2.new(0, OldSize.x, 0, 0)
                    Popup.Outline.AutomaticSize = Enum.AutomaticSize.Y
                    Popup.Outline.Visible = Keybind.Visible
                end))
            end

            Utility.Signal(Popup.KeyOutline.MouseButton1Click:Connect(function(
                input
            )
                if Keybind.Listener then
                    Library.ChangeObjectTheme(Popup.Key, {
                        TextColor3 = 'Dark Text',
                    }, true)
                    Keybind.Listener:Disconnect()

                    Keybind.Listener = nil

                    return
                end

                Library.ChangeObjectTheme(Popup.Key, {
                    TextColor3 = 'Accent',
                }, true)
                task.wait(2E-2)

                Keybind.Listener = Utility.Signal(UserInputService.InputBegan:Connect(function(
                    input
                )
                    if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                        Keybind.Set(Enum.KeyCode.Unknown)
                        Keybind.Listener:Disconnect()

                        Keybind.Listener = nil

                        Library.ChangeObjectTheme(Popup.Key, {
                            TextColor3 = 'Dark Text',
                        }, true)

                        return
                    end
                    if input.UserInputType == Enum.UserInputType.Keyboard or table.find({
                        Enum.UserInputType.MouseButton1,
                        Enum.UserInputType.MouseButton2,
                        Enum.UserInputType.MouseButton3,
                    }, input.UserInputType) then
                        local Key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType or Enum.KeyCode.Unknown

                        Keybind.Set(Key)
                        Library.ChangeObjectTheme(Popup.Key, {
                            TextColor3 = 'Dark Text',
                        }, true)
                        Keybind.Listener:Disconnect()

                        Keybind.Listener = nil
                    end
                end))
            end))
            Utility.Signal(UserInputService.InputBegan:Connect(function(
                input
            )
                if Keybind.Key ~= Enum.KeyCode.Unknown and (input.KeyCode == Keybind.Key or input.UserInputType == Keybind.Key) then
                    if UserInputService:GetFocusedTextBox() then
                        return
                    end

                    local Value = Keybind.Mode ~= 'Toggle' or not Keybind.Value

                    Keybind.Set(Value)

                    if Keybind.Mode == 'Hold' then
                        if Keybind.OnHold then
                            Keybind.OnHold:Disconnect()
                        end

                        Keybind.OnHold = Utility.Signal(UserInputService.InputEnded:Connect(function(
                            input
                        )
                            if Keybind.Key ~= Enum.KeyCode.Unknown and (input.KeyCode == Keybind.Key or input.UserInputType == Keybind.Key) then
                                Keybind.Set(false)

                                if Keybind.OnHold then
                                    Keybind.OnHold:Disconnect()

                                    Keybind.OnHold = nil
                                end
                            end
                        end))
                    end
                end
            end))
            Utility.Signal(UserInputService.InputBegan:Connect(function(
                input
            )
                if input.UserInputType == Enum.UserInputType.MouseButton1 and Keybind.Visible and not (Utility.MouseOver(Popup.Outline, input) or Utility.MouseOver(Objects.Icon, input) or Utility.MouseOver(Popup.Dropdown.Popup.Outline, input)) then
                    if Keybind.Open then
                        Keybind.Open()
                    end
                end
            end))
            Utility.Signal(Objects.Icon.MouseButton1Click:Connect(function(
            )
                if Keybind.Open then
                    Keybind.Open()
                end
            end))
            Keybind.Set({
                cfg.key,
                cfg.mode,
                cfg.value,
            }, true)

            Library.ConfigFlags[string.format('%s_data', cfg.flag)] = Keybind.Set

            return setmetatable(Keybind, Library)
        end
        
        function Library.Label(self, cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                name = 'New Label',
                bold = true,
                dark = false,
            })

            local Label = {
                Objects = {},
                ZIndex = self.ZIndex,
            }
            local ZIndex = Label.ZIndex
            local Objects = Label.Objects

            do
                Objects.Holder = Utility.New('Frame', {
                    Name = 'Holder',
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    Parent = self.Holder,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Objects.Holder,
                    Padding = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.Text = Utility.New('TextLabel', {
                    Name = 'Text',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = cfg.bold and Library.FontSize or Library.FontSize - 2,
                    FontFace = Library.Font,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Text = cfg.name,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Objects.Holder,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = cfg.dark and 'Light Text' or 'Text',
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Parent = Objects.Text,
                    Padding = UDim.new(0, 2),
                })

                ZIndex = ZIndex + 1
                Objects.SideHolder = Utility.New('Frame', {
                    Name = 'SideHolder',
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Position = UDim2.fromOffset(0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = Objects.Text,
                    ZIndex = ZIndex,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Parent = Objects.SideHolder,
                    Padding = UDim.new(0, 2),
                })

                Label.SideHolder = Objects.SideHolder
                ZIndex = ZIndex + 1
            end

            Label.ZIndex = ZIndex

            return setmetatable(Label, Library)
        end
        
        function Library.Notification(cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                name = 'New Notification',
                description = nil,
                type = 'Normal',
                buttons = nil,
                showbuttons = false,
                time = 5,
            })

            local ZIndex = 100
            local Notification = {
                Objects = {},
                Name = cfg.name,
                Description = cfg.description,
                Type = cfg.type,
                Time = cfg.time,
                Clock = os.clock(),
                Buttons = {},
                ShowButtons = cfg.showbuttons,
                ButtonLerp = 1,
                Lerp = 1,
            }
            local Objects = Notification.Objects

            do
                Objects.Holder = Utility.New('Frame', {
                    Name = 'Holder',
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    ZIndex = ZIndex,
                    Parent = Library.ScreenGui,
                })

                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Objects.Holder,
                    Padding = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.Outline = Utility.New('Frame', {
                    Name = 'Outline',
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Position = UDim2.new(0, 0, 1, 0),
                    Parent = Objects.Holder,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.Outline,
                    CornerRadius = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.Background = Utility.New('Frame', {
                    Name = 'Background',
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.fromOffset(1, 1),
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Background',
                })

                Utility.New('UIPadding', {
                    Name = 'UIPadding',
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 6),
                    Parent = Objects.Background,
                })
                Utility.New('UICorner', {
                    Name = 'UICorner',
                    Parent = Objects.Background,
                    CornerRadius = UDim.new(0, 5),
                })
                Utility.New('UIListLayout', {
                    Name = 'UIListLayout',
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = Objects.Background,
                    Padding = UDim.new(0, 5),
                })

                ZIndex = ZIndex + 1
                Objects.Title = Utility.New('TextLabel', {
                    Name = 'Title',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = Library.FontSize,
                    FontFace = Library.Font,
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Text = cfg.name,
                    Parent = Objects.Background,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Text',
                })
                ZIndex = ZIndex + 1

                if cfg.buttons then
                    Objects.FadeHolder = Utility.New('Frame', {
                        Name = 'ButtonHolder',
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        Parent = Objects.Holder,
                    })
                    Objects.ButtonHolder = Utility.New('Frame', {
                        Name = 'ButtonHolder',
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        Parent = Objects.FadeHolder,
                    })

                    Utility.New('UIListLayout', {
                        Name = 'UIListLayout',
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = Objects.ButtonHolder,
                        Padding = UDim.new(0, 2),
                    })

                    ZIndex = ZIndex + 1
                end
                if cfg.description then
                    Objects.Description = Utility.New('TextLabel', {
                        Name = 'Description',
                        TextStrokeTransparency = 0.8,
                        BackgroundTransparency = 1,
                        TextSize = Library.FontSize - 2,
                        FontFace = Library.Font,
                        Size = UDim2.new(0, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        Text = cfg.description,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Objects.Background,
                        ZIndex = ZIndex,
                        TextWrapped = true,
                    }, {
                        TextColor3 = 'Light Text',
                    })
                    ZIndex = ZIndex + 1
                end
                if cfg.type == 'Time' then
                    Objects.Time = Utility.New('Frame', {
                        Name = 'Time',
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 0, 0, 2),
                        Position = UDim2.new(0, 0, 1, -2),
                        Parent = Objects.Background,
                        ZIndex = ZIndex,
                    }, {
                        BackgroundColor3 = 'Accent',
                    })
                    Objects.Time.Size = UDim2.new(0, 0, 0, 2)
                end
            end

            function Notification.SetTime(time)
                Notification.Time = time
                Notification.Clock = os.clock()
            end
            
            function Notification.Hide()
                Notification.Time = 0
            end
            
            function Notification.Title(text)
                Objects.Title.Text = text
            end
            
            function Notification.Description(text)
                Objects.Description.Text = text
            end
            
            function Notification.ButtonVisiblity(visibility)
                Notification.ShowButtons = visibility
            end
            
            function Notification.CreateButton(bcfg)
                bcfg = bcfg or {}
                bcfg = Library.Config(bcfg, {
                    text = 'undefined',
                    callback = function() end,
                })

                local Button = Library.Button({
                    ZIndex = ZIndex,
                    Holder = Objects.ButtonHolder,
                }, {
                    AutoSize = true,
                    Name = bcfg.text,
                    Callback = bcfg.callback,
                })

                table.insert(Notification.Buttons, Button)

                return Button
            end

            if cfg.buttons then
                for _, button in cfg.buttons do
                    Notification.CreateButton(button)
                end
            end

            table.insert(Library.Notifications, Notification)

            return Notification
        end
        
        function Library.Watermark(cfg)
            cfg = cfg or {}
            cfg = Library.Config(cfg, {
                text = 'Library | {game} | {time} | {date}',
                visible = true,
                rate = 1.6666666666666665E-2,
            })

            local ZIndex = 100
            local Watermark = {
                Objects = {},
                Visible = cfg.visible,
                Rate = cfg.rate,
                Text = cfg.text,
                ZIndex = ZIndex,
                Clock = os.clock(),
            }
            local Objects = Watermark.Objects

            do
                Objects.Outline = Utility.New('Frame', {
                    Name = 'Watermark',
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Position = UDim2.new(0, 10, 0, 0),
                    Parent = Library.ScreenGui,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Inline',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Outline,
                })

                ZIndex = ZIndex + 1
                Objects.Background = Utility.New('Frame', {
                    Name = 'Background',
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    Parent = Objects.Outline,
                    ZIndex = ZIndex,
                }, {
                    BackgroundColor3 = 'Background',
                })

                Utility.New('UICorner', {
                    Name = 'UICorner',
                    CornerRadius = UDim.new(0, 5),
                    Parent = Objects.Background,
                })
                Utility.New('UIPadding', {
                    Name = 'UIPadding',
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 7),
                    Parent = Objects.Background,
                })

                ZIndex = ZIndex + 1
                Objects.Text = Utility.New('TextLabel', {
                    Name = 'Text',
                    TextStrokeTransparency = 0.8,
                    BackgroundTransparency = 1,
                    TextSize = Library.FontSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutomaticSize = Enum.AutomaticSize.X,
                    FontFace = Library.Font,
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Text = Watermark.Text,
                    Parent = Objects.Background,
                    ZIndex = ZIndex,
                }, {
                    TextColor3 = 'Text',
                })
            end

            Watermark.ZIndex = ZIndex

            function Watermark.SetText(text)
                Watermark.Text = text
            end
            
            function Watermark.SetVisible(visibility)
                Watermark.Visible = visibility
            end
            
            function Watermark.SetRate(rate)
                Watermark.Rate = rate
            end
            
            function Watermark.Think()
                Objects.Outline.Visible = Watermark.Visible

                if Watermark.Visible and os.clock() - Watermark.Clock >= Watermark.Rate then
                    Watermark.Clock = os.clock()
                    Objects.Text.Text = Utility.TextTriggers(Watermark.Text)
                    Objects.Text.Size = UDim2.new(0, 0, 0, Objects.Text.TextBounds.Y - 2)
                end
            end

            Utility.Signal(RunService.RenderStepped:Connect(Watermark.Think))

            return Watermark
        end
        
        function Library.HandleNotifications(step)
            Library.Fps = math.floor(1 / step)

            local Clock = os.clock()
            local Watermark = Library.ScreenGui:FindFirstChild('Watermark')
            local Offset = Watermark and Watermark.Visible and Watermark.AbsoluteSize.Y + 5 or 0

            for _, notification in Library.Notifications do
                local Objects = notification.Objects
                local Time = notification.Time

                if Clock - notification.Clock >= Time then
                    notification.Lerp = Utility.Lerp(notification.Lerp, 0, 0.1)
                else
                    notification.Lerp = Utility.Lerp(notification.Lerp, 255, 0.1)
                end

                local Lerp = notification.Lerp
                local Holder = Objects.Holder
                local Outline = Objects.Outline
                local Background = Objects.Background
                local Title = Objects.Title

                Holder.Position = UDim2.new(0, 10 + (-Holder.AbsoluteSize.X * (1 - (Lerp / 255))), 0, Offset)
                Outline.BackgroundTransparency = 1 - (Lerp / 255)
                Background.BackgroundTransparency = 1 - (Lerp / 255)
                Title.TextTransparency = 1 - (Lerp / 255)

                if #notification.Buttons > 0 then
                    notification.ButtonLerp = Utility.Lerp(notification.ButtonLerp, notification.ShowButtons and 255 or 0, 0.1)

                    for _, obj in Objects.ButtonHolder:GetDescendants()do
                        local Index = Utility.GetTransparency(obj)

                        if not Index then
                        end
                        if type(Index) == 'table' then
                            if obj:IsA('TextLabel') then
                                obj[Index[1] ] = 1 - (notification.ButtonLerp / 255)
                            else
                                obj[Index[1] ] = 1 - (notification.ButtonLerp / 255)
                                obj[Index[2] ] = 1 - (notification.ButtonLerp / 255)
                            end
                        else
                            obj[Index] = 1 - (notification.ButtonLerp / 255)
                        end
                    end
                end
                if Objects.Description then
                    Objects.Description.TextTransparency = 1 - (Lerp / 255)
                end
                if Objects.Time then
                    Objects.Time.BackgroundTransparency = 1 - (Lerp / 255)
                    Objects.Time.Size = UDim2.new(0, (Outline.AbsoluteSize.X - 10) * math.clamp(((notification.Clock - Clock) / notification.Time) * 
-1, 0, 1), 0, 2)
                end

                Offset = Offset + (Holder.AbsoluteSize.Y + 5) * (Lerp / 255)

                if Lerp <= 0 then
                    Holder:Destroy()
                    table.remove(Library.Notifications, table.find(Library.Notifications, notification))
                end
            end
        end

        Utility.Signal(RunService.RenderStepped:Connect(Library.HandleNotifications))

        local XOR_PASSWORD = '32visionLibrary'

        local function xorEncrypt(data, password)
            local encrypted = ''
            local passLen = #password

            for i = 1, #data do
                local byte = string.byte(data, i)
                local keyByte = string.byte(password, ((i - 1) % passLen) + 1)

                encrypted = encrypted .. string.char(bit32.bxor(byte, keyByte))
            end

            return encrypted
        end
        
        local function xorDecrypt(data, password)
            return xorEncrypt(data, password)
        end
        
        local function bytesToHex(data)
            local hex = ''

            for i = 1, #data do
                hex = hex .. string.format('%02x', string.byte(data, i))
            end

            return hex
        end
        
        local function hexToBytes(hex)
            local data = ''

            for i = 1, #hex, 2 do
                data = data .. string.char(tonumber(hex:sub(i, i + 1), 16))
            end

            return data
        end

        function Library.GetConfig()
            local Config = {}

            for _, v in Library.ConfigFlags do
                local Value = Library.Flags[_]

                if type(Value) == 'table' and Value['key'] then
                    Config[_] = {
                        value = Value.value,
                        mode = Value.mode,
                        key = tostring(Value.key),
                    }
                elseif type(Value) == 'table' and Value['a'] and Value['c'] then
                    Config[_] = {
                        a = Value.a,
                        c = Value.c:ToHex(),
                    }
                else
                    Config[_] = Value
                end
            end

            local jsonData = HttpService:JSONEncode(Config)
            local encrypted = xorEncrypt(jsonData, XOR_PASSWORD)

            return bytesToHex(encrypted)
        end
        
        function Library.LoadConfig(data)
            data = hexToBytes(data)
            data = xorDecrypt(data, XOR_PASSWORD)
            data = HttpService:JSONDecode(data)

            for i, v in data do
                local Config = Library.ConfigFlags[i]

                if Config then
                    if type(v) == 'table' and v['a'] and v['c'] then
                        Config({
                            a = v.a,
                            c = type(v.c) == 'string' and Color3.fromHex(v.c) or v.c,
                        })
                    elseif type(v) == 'table' and v['key'] then
                        Config({
                            value = v.value,
                            mode = v.mode,
                            key = Utility.StringToEnum(v.key),
                        }, true)
                    else
                        Config(v)
                    end
                end
                if Library.LoadConfigCallbacks[i] then
                    pcall(function()
                        Library.LoadConfigCallbacks[i](v)
                    end)
                end
            end
        end
        
        function Library.CreateConfigManager(tab, options)
            if not tab or type(tab) ~= 'table' then
                return nil
            end

            options = options or {}

            local side = options.side or 'left'
            local sectionName = options.name or 'Config Manager'
            local sectionDesc = options.description or 'Save and load your configurations'
            local folderPath = options.folderPath or (Folder .. '/Games/' .. (Game and Game.Name or 'Universal') .. '/Configs')
            local ZIndex = (tab.ZIndex or 0) + 1

            if not isfolder(folderPath) then
                makefolder(folderPath)
            end

            local ConfigSection = tab:Section({
                name = sectionName,
                description = sectionDesc,
                side = side,
            })
            local configNameTextbox = ConfigSection:Textbox({
                name = 'Config Name',
                placeholder = 'Enter config name...',
                flag = 'ui_config_name',
            })

            local function GetConfigList()
                local configs = {}

                if isfolder(folderPath) then
                    for _, file in ipairs(listfiles(folderPath))do
                        if file:sub(-5) == '.json' then
                            local configName = file:match('([^/\\]+)%.json$')

                            table.insert(configs, configName)
                        end
                    end
                end
                if #configs == 0 then
                    return {
                        'No configs found',
                    }
                end

                return configs
            end

            local configListDropdown = ConfigSection:Dropdown({
                name = 'Saved Configs',
                description = 'Select a saved configuration',
                values = GetConfigList(),
                callback = function(value)
                    if value ~= 'No configs found' then
                        Library.Flags['ui_config_name'] = value
                    end
                end,
                flag = 'ui_selected_config',
            })

            local function RefreshConfigList()
                if configListDropdown and type(configListDropdown) == 'table' then
                    local configs = GetConfigList()

                    if configListDropdown.Refresh and type(configListDropdown.Refresh) == 'function' then
                        configListDropdown:Refresh(configs)
                    end
                    if #configs > 0 and configs[1] ~= 'No configs found' then
                        Library.Flags['ui_selected_config'] = configs[1]
                    else
                        Library.Flags['ui_selected_config'] = 'No configs found'
                    end

                    pcall(function()
                        if Library.Flags['ui_selected_config'] and configListDropdown.Update then
                            configListDropdown:Update(Library.Flags['ui_selected_config'])
                        end
                    end)
                end
            end

            ConfigSection:Button({
                name = 'Save Config',
                description = 'Save current settings to a config file',
                callback = function()
                    local configName = Library.Flags['ui_config_name']

                    if not configName or configName == '' or configName == 'No configs found' then
                        configName = 'default'
                    end

                    local configPath = folderPath .. '/' .. configName .. '.json'
                    local configData = Library.GetConfig()

                    writefile(configPath, configData)
                    Library.Notification({
                        name = 'Config Saved',
                        description = "Configuration '" .. configName .. "' has been saved.",
                    })
                    RefreshConfigList()
                end,
            })
            ConfigSection:Button({
                name = 'Load Config',
                description = 'Load selected configuration',
                callback = function()
                    local configName = Library.Flags['ui_selected_config']

                    if not configName or configName == 'No configs found' then
                        Library.Notification({
                            name = 'Error',
                            description = 'No config selected',
                        })

                        return
                    end

                    local configPath = folderPath .. '/' .. configName .. '.json'

                    if isfile(configPath) then
                        local data = readfile(configPath)

                        Library.LoadConfig(data)
                        Library.Notification({
                            name = 'Config Loaded',
                            description = "Configuration '" .. configName .. "' has been loaded.",
                        })
                    else
                        Library.Notification({
                            name = 'Error',
                            description = 'Config file not found',
                        })
                    end
                end,
            })
            ConfigSection:Button({
                name = 'Delete Config',
                description = 'Delete selected configuration',
                callback = function()
                    local configName = Library.Flags['ui_selected_config']

                    if not configName or configName == 'No configs found' then
                        Library.Notification({
                            name = 'Error',
                            description = 'No config selected',
                        })

                        return
                    end

                    local configPath = folderPath .. '/' .. configName .. '.json'

                    if isfile(configPath) then
                        delfile(configPath)
                        Library.Notification({
                            name = 'Config Deleted',
                            description = "Configuration '" .. configName .. "' has been deleted.",
                        })
                        RefreshConfigList()
                    else
                        Library.Notification({
                            name = 'Error',
                            description = 'Config file not found',
                        })
                    end
                end,
            })
            ConfigSection:Button({
                name = 'Refresh List',
                description = 'Refresh the config list',
                callback = function()
                    RefreshConfigList()
                    Library.Notification({
                        name = 'List Refreshed',
                        description = 'Config list has been updated.',
                    })
                end,
            })

            return {
                Section = ConfigSection,
                RefreshList = RefreshConfigList,
            }
        end
        
        function Library.Unload()
            for _, obj in Utility.Connections do
                obj:Disconnect()
            end
            for _, obj in Utility.Objects do
                obj:Destroy()
            end

            getgenv().Library = nil
        end

        Bin:add(function()
            Library.Unload()
        end)
    end

    getgenv().Library = Library

    return Library
end)()

return Library

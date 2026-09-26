local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")

local IMAGE_ID = "rbxassetid://75149787879884"
local FONT = Enum.Font.Arcade

local RAW_GAMES_URL = "https://raw.githubusercontent.com/samucarapo/Hub/refs/heads/main/J.json"

local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "VerityLoading"
LoadingGui.ResetOnSpawn = false
LoadingGui.IgnoreGuiInset = true
LoadingGui.DisplayOrder = 999999
LoadingGui.Parent = game.CoreGui

local Holder = Instance.new("Frame")
Holder.Size = UDim2.fromOffset(230, 220)
Holder.Position = UDim2.fromScale(.5, .5)
Holder.AnchorPoint = Vector2.new(.5, .5)
Holder.BackgroundTransparency = 1
Holder.Parent = LoadingGui

local Image = Instance.new("ImageLabel")
Image.Size = UDim2.fromOffset(95, 95)
Image.Position = UDim2.fromScale(.5, .4)
Image.AnchorPoint = Vector2.new(.5, .5)
Image.BackgroundColor3 = Color3.fromRGB(45, 125, 255)
Image.BorderSizePixel = 0
Image.Image = IMAGE_ID
Image.Parent = Holder

local ImageCorner = Instance.new("UICorner")
ImageCorner.CornerRadius = UDim.new(1, 0)
ImageCorner.Parent = Image

local Background = Instance.new("Frame")
Background.Size = UDim2.fromOffset(145, 38)
Background.Position = UDim2.fromScale(.5, .68)
Background.AnchorPoint = Vector2.new(.5, 0)
Background.BackgroundColor3 = Color3.new(0, 0, 0)
Background.BorderSizePixel = 0
Background.Parent = Holder

local BackgroundCorner = Instance.new("UICorner")
BackgroundCorner.CornerRadius = UDim.new(0, 7)
BackgroundCorner.Parent = Background

local Text = Instance.new("TextLabel")
Text.Size = UDim2.fromScale(1, 1)
Text.BackgroundTransparency = 1
Text.Text = "LOADING"
Text.TextColor3 = Color3.new(1, 1, 1)
Text.TextSize = 13
Text.Font = FONT
Text.Parent = Background

pcall(function()
    ContentProvider:PreloadAsync({Image})
end)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local function setStatus(status)
    Text.Text = status
end

local function loadGameList()
    local success, result = pcall(function()
        return game:HttpGet(RAW_GAMES_URL)
    end)

    if not success then
        return nil
    end

    local decodeSuccess, games = pcall(function()
        return HttpService:JSONDecode(result)
    end)

    if not decodeSuccess or type(games) ~= "table" then
        return nil
    end

    return games
end

local function executeScript(scriptUrl)
    local success, source = pcall(function()
        return game:HttpGet(scriptUrl)
    end)

    if not success or type(source) ~= "string" then
        return false
    end

    local loadSuccess, scriptFunction = pcall(loadstring, source)

    if not loadSuccess or not scriptFunction then
        return false
    end

    local executeSuccess = pcall(scriptFunction)

    return executeSuccess
end

task.spawn(function()
    setStatus("CONNECTING")

    local games = loadGameList()

    if not games then
        setStatus("ERROR")
        task.wait(2)
        LoadingGui:Destroy()
        return
    end

    local placeId = tostring(game.PlaceId)
    local scriptUrl = games[placeId]

    if not scriptUrl then
        setStatus("NOT FOUND")
        task.wait(1.5)
        LoadingGui:Destroy()
        return
    end

    setStatus("LOADING")

    if executeScript(scriptUrl) then
        LoadingGui:Destroy()
    else
        setStatus("SCRIPT ERROR")
        task.wait(2)
        LoadingGui:Destroy()
    end
end)

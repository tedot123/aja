--==================================================
-- EXTREME FPS / BURIQ MODE
-- CHARACTER + FLOOR ONLY
--==================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- SETTINGS
--==================================================

local DARK_GRAY = Color3.fromRGB(48, 48, 48)
local FLOOR_Y = 8

--==================================================
-- LIGHTING
--==================================================

pcall(function()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 0.3
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.FogEnd = 100000
end)

for _, v in ipairs(Lighting:GetChildren()) do
    if v:IsA("PostEffect") then
        v.Enabled = false
    end
end

--==================================================
-- DISABLE EFFECTS
--==================================================

local function DisableEffect(obj)

    if obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam")
        or obj:IsA("Smoke")
        or obj:IsA("Fire")
        or obj:IsA("Sparkles") then

        obj.Enabled = false

    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1

    elseif obj:IsA("SurfaceAppearance") then
        obj:Destroy()
    end
end

--==================================================
-- OWN CHARACTER
--==================================================

local function MakeCharacterBuriq(character)

    if not character then
        return
    end

    for _, obj in ipairs(character:GetDescendants()) do

        if obj:IsA("BasePart") then

            obj.Color = DARK_GRAY
            obj.Material = Enum.Material.Slate
            obj.CastShadow = false
            obj.Reflectance = 0

        elseif obj:IsA("Decal")
            or obj:IsA("Texture") then

            obj.Transparency = 1

        elseif obj:IsA("SurfaceAppearance") then

            obj:Destroy()

        elseif obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Beam")
            or obj:IsA("Smoke")
            or obj:IsA("Fire")
            or obj:IsA("Sparkles") then

            obj.Enabled = false
        end
    end
end

local function CharacterAdded(character)

    task.wait(0.5)
    MakeCharacterBuriq(character)

    character.DescendantAdded:Connect(function(obj)

        if obj:IsA("BasePart") then
            obj.Color = DARK_GRAY
            obj.Material = Enum.Material.Slate
            obj.CastShadow = false
            obj.Reflectance = 0

        else
            DisableEffect(obj)
        end
    end)
end

if LocalPlayer.Character then
    task.spawn(CharacterAdded, LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(CharacterAdded)

--==================================================
-- HIDE OTHER PLAYERS
--==================================================

local function HideOtherCharacter(character)

    if not character then
        return
    end

    for _, obj in ipairs(character:GetDescendants()) do

        if obj:IsA("BasePart") then
            obj.LocalTransparencyModifier = 1
            obj.CastShadow = false

        else
            DisableEffect(obj)
        end
    end
end

local function SetupPlayer(player)

    if player == LocalPlayer then
        return
    end

    if player.Character then
        task.spawn(HideOtherCharacter, player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        task.wait(0.2)
        HideOtherCharacter(character)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    SetupPlayer(player)
end

Players.PlayerAdded:Connect(SetupPlayer)

--==================================================
-- MAP
--==================================================

local function OptimizeMapPart(obj)

    if not obj:IsA("BasePart") then
        return
    end

    -- Jangan sentuh character
    local model = obj:FindFirstAncestorOfClass("Model")

    if model and model:FindFirstChildOfClass("Humanoid") then
        return
    end

    -- FLOOR
    if obj.Position.Y <= FLOOR_Y then

        obj.LocalTransparencyModifier = 0
        obj.Color = DARK_GRAY
        obj.Material = Enum.Material.Slate
        obj.CastShadow = false
        obj.Reflectance = 0

    else

        -- SEMUA BANGUNAN / OBJECT MAP HILANG
        obj.LocalTransparencyModifier = 1
        obj.CastShadow = false
    end
end

--==================================================
-- INITIAL MAP SCAN
--==================================================

task.spawn(function()

    local objects = Workspace:GetDescendants()
    local total = #objects

    local index = 1

    while index <= total do

        local endIndex = math.min(index + 100, total)

        while index <= endIndex do
            OptimizeMapPart(objects[index])
            DisableEffect(objects[index])

            index += 1
        end

        task.wait()
    end
end)

--==================================================
-- NEW OBJECTS
--==================================================

Workspace.DescendantAdded:Connect(function(obj)

    if obj:IsA("BasePart") then

        task.defer(function()
            OptimizeMapPart(obj)
        end)

    else

        task.defer(function()
            DisableEffect(obj)
        end)
    end
end)

--==================================================
-- TERRAIN
--==================================================

local Terrain = Workspace:FindFirstChildOfClass("Terrain")

if Terrain then
    pcall(function()
        Terrain.Decoration = false
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.GrassLength = 0
    end)
end

print("EXTREME BURIQ FPS MODE LOADED")

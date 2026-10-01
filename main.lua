--========================================================
--        ULTRA FPS - FULL GRAY / MAP HIDDEN
--========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local GRAY = Color3.fromRGB(55, 55, 55)

--========================================================
-- CHARACTER SENDIRI = FULL GRAY
--========================================================

local function GrayCharacter(character)
    if not character then return end

    for _, obj in ipairs(character:GetDescendants()) do

        if obj:IsA("BasePart") then

            pcall(function()
                obj.Color = GRAY
                obj.Material = Enum.Material.SmoothPlastic
                obj.CastShadow = false
                obj.LocalTransparencyModifier = 0
            end)

        elseif obj:IsA("Decal")
        or obj:IsA("Texture") then

            pcall(function()
                obj.Transparency = 1
            end)

        elseif obj:IsA("SpecialMesh") then

            pcall(function()
                obj.TextureId = ""
            end)

        elseif obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam")
        or obj:IsA("Smoke")
        or obj:IsA("Fire")
        or obj:IsA("Sparkles") then

            pcall(function()
                obj.Enabled = false
            end)

        end
    end
end

--========================================================
-- PLAYER LAIN = HILANG
--========================================================

local function HidePlayer(character)
    if not character then return end
    if character == LocalPlayer.Character then return end

    for _, obj in ipairs(character:GetDescendants()) do

        if obj:IsA("BasePart") then

            pcall(function()
                obj.LocalTransparencyModifier = 1
            end)

        elseif obj:IsA("Decal")
        or obj:IsA("Texture") then

            pcall(function()
                obj.Transparency = 1
            end)

        end
    end
end

--========================================================
-- DETEKSI KARAKTER / NPC
--========================================================

local function IsCharacterPart(obj)

    local model = obj:FindFirstAncestorOfClass("Model")

    if model and model:FindFirstChildOfClass("Humanoid") then
        return true, model
    end

    return false, nil
end

--========================================================
-- DETEKSI LANTAI
--========================================================

local function IsGround(part)

    if not part:IsA("BasePart") then
        return false
    end

    local s = part.Size

    -- Lantai biasanya lebar dan relatif tipis
    if s.Y <= 8 and (s.X >= 80 or s.Z >= 80) then
        return true
    end

    return false
end

--========================================================
-- SEMBUNYIKAN MAP
--========================================================

local function HideMapPart(part)

    if not part:IsA("BasePart") then
        return
    end

    -- Jangan sentuh karakter sendiri
    if LocalPlayer.Character
    and part:IsDescendantOf(LocalPlayer.Character) then
        return
    end

    -- Jangan sentuh player/NPC
    local isChar = IsCharacterPart(part)

    if isChar then
        return
    end

    -- Lantai tetap ada
    if IsGround(part) then

        pcall(function()
            part.Color = GRAY
            part.Material = Enum.Material.SmoothPlastic
            part.CastShadow = false
            part.LocalTransparencyModifier = 0
        end)

        return
    end

    -- SEMUA MAP SELAIN LANTAI = HILANG
    pcall(function()
        part.LocalTransparencyModifier = 1
    end)
end

--========================================================
-- MATIKAN EFFECT
--========================================================

local function DisableEffect(obj)

    if obj:IsA("ParticleEmitter")
    or obj:IsA("Trail")
    or obj:IsA("Beam")
    or obj:IsA("Smoke")
    or obj:IsA("Fire")
    or obj:IsA("Sparkles") then

        pcall(function()
            obj.Enabled = false
        end)

    end
end

--========================================================
-- PROSES MAP SEKALI
--========================================================

task.spawn(function()

    local objects = Workspace:GetDescendants()
    local counter = 0

    for _, obj in ipairs(objects) do

        if obj:IsA("BasePart") then

            local isChar, model = IsCharacterPart(obj)

            if isChar then

                if model == LocalPlayer.Character then
                    GrayCharacter(model)
                else
                    HidePlayer(model)
                end

            else

                HideMapPart(obj)

            end

        else

            DisableEffect(obj)

        end

        counter += 1

        -- Mencegah freeze ketika pertama execute
        if counter >= 250 then
            counter = 0
            task.wait()
        end
    end

    -- Pastikan karakter sendiri FULL GRAY
    GrayCharacter(LocalPlayer.Character)

end)

--========================================================
-- KARAKTER SENDIRI SPAWN ULANG
--========================================================

LocalPlayer.CharacterAdded:Connect(function(character)

    task.wait(0.5)

    GrayCharacter(character)

end)

--========================================================
-- PLAYER BARU
--========================================================

Players.PlayerAdded:Connect(function(player)

    if player == LocalPlayer then
        return
    end

    player.CharacterAdded:Connect(function(character)

        task.wait(0.3)

        HidePlayer(character)

    end)

end)

--========================================================
-- OBJECT BARU DARI SERVER
--========================================================

Workspace.DescendantAdded:Connect(function(obj)

    task.defer(function()

        -- Effect baru
        DisableEffect(obj)

        if not obj:IsA("BasePart") then
            return
        end

        -- Karakter sendiri
        if LocalPlayer.Character
        and obj:IsDescendantOf(LocalPlayer.Character) then

            GrayCharacter(LocalPlayer.Character)
            return
        end

        -- Player/NPC
        local isChar, model = IsCharacterPart(obj)

        if isChar then

            if model == LocalPlayer.Character then
                GrayCharacter(model)
            else
                HidePlayer(model)
            end

            return
        end

        -- MAP BARU
        HideMapPart(obj)

    end)

end)

--========================================================
-- TERRAIN = GRAY
--========================================================

pcall(function()

    local Terrain = Workspace.Terrain

    Terrain:SetMaterialColor(
        Enum.Material.Grass,
        GRAY
    )

    Terrain:SetMaterialColor(
        Enum.Material.LeafyGrass,
        GRAY
    )

    Terrain:SetMaterialColor(
        Enum.Material.Ground,
        GRAY
    )

    Terrain:SetMaterialColor(
        Enum.Material.Mud,
        GRAY
    )

end)

--========================================================
-- LIGHTING BOOST
--========================================================

pcall(function()

    Lighting.GlobalShadows = false

    for _, effect in ipairs(Lighting:GetChildren()) do

        if effect:IsA("BloomEffect")
        or effect:IsA("BlurEffect")
        or effect:IsA("DepthOfFieldEffect")
        or effect:IsA("SunRaysEffect") then

            effect.Enabled = false

        end
    end

end)

--========================================================
-- DONE
--========================================================

print("======================================")
print("       ULTRA FPS MODE AKTIF")
print("======================================")
print("BUILDING  : HIDDEN")
print("MAP       : HIDDEN")
print("GROUND    : GRAY")
print("CHARACTER : FULL GRAY")
print("PLAYERS   : HIDDEN")
print("EFFECTS   : OFF")
print("SHADOW    : OFF")
print("======================================")

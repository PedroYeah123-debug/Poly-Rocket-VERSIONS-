local FadeSpeed = 0.01
local TargetVolume = 1

local Environment = game["Environment"]
local Players = game["Players"]
local LocalPlayer = Players.LocalPlayer
local Parent = script.Parent
local Sound = Parent["Sound"]
local Inside = false
local Fading = false

Sound.Volume = 0

local function FadeTo(volume)
    if Fading then return end
    Fading = true

    while math.abs(Sound.Volume - volume) > 0.01 do
        if Sound.Volume < volume then
            Sound.Volume = Sound.Volume + FadeSpeed
        else
            Sound.Volume = Sound.Volume - FadeSpeed
        end
        wait()
    end

    Sound.Volume = volume
    Fading = false

    if volume == 0 then
        Sound:Stop()
    end
end

game.Rendered:Connect(function()
    local pos = Parent.Position
    local size = Parent.Size
    local hits = Environment:OverlapBox(pos, size, Vector3.New(0, 0, 0))

    local IsInside = false

    for _, V in ipairs(hits) do
        if V == LocalPlayer then
            IsInside = true
            break
        end
    end

    if IsInside and not Inside then
        if not Sound.Playing then
            Sound:Play()
        end

        FadeTo(TargetVolume)
    elseif not IsInside and Inside then
        FadeTo(0)
    end

    Inside = IsInside
end)
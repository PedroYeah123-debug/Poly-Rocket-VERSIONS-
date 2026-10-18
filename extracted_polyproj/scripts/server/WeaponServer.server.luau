local bombScript = game["Hidden"]:FindChild("Bomb")
local tool = script.Parent
local Sound = tool:FindChild('Beep')
local handle = tool:FindChild("Ball")
local cooldownActive = false
local cooldownTime = 0.5 -- Normal is 6 seconds

function plant()
    local player = tool.Parent
    -- Polytoria method to get player
    
    if not player then return end

    -- Create the Bomb Part
    local bomb2 = Instance.New('Part')
    local spawnPos = handle.Position

    -- Setup Physics and Visuals
    bomb2.Position = spawnPos + ((player.Forward or Vector3.New(0, 0, 0)) * 2) + Vector3.New(0, 3, 0)
    bomb2.Size = Vector3.New(2, 2, 2)
    bomb2.Color = Color.New(0, 0, 0) -- Black (BrickColor 21 equivalent)
    bomb2.Shape = PartShape.Ball
    bomb2.Material = PartMaterial.Grass
    bomb2.Name = "TimeBomb"
    bomb2.Anchored = false

    -- Setup Sound
    local beep2 = Sound:Clone()
    beep2.Position = bomb2.Position
    beep2.Parent = bomb2
    
    -- Create the Creator Tag (ValueBase)
    -- In Polytoria, we use ObjectValue to store the player reference
    local creatorTag = Instance.New("InstanceValue")
    creatorTag.Value = player
    creatorTag.Name = "creator"
    creatorTag.Parent = bomb2
    
    local newScript = bombScript:Clone()
    newScript.Parent = bomb2
end

function onActivated()
    if cooldownActive then
        return
    end
    -- Visual feedback: Hide the bomb in the hand while it's "planted"
    cooldownActive = true
    handle.Size = Vector3.New(0,0,0)
    plant()

    -- Cooldown: The bomb "reloads" after 6 seconds
    wait(cooldownTime)
    cooldownActive = false
    handle.Size = Vector3.New(0.8,0.8,0.8)
end

tool.Activated:Connect(onActivated)
local tool = script.Parent
local netEvent = tool:FindChild("GetMouse")
local slingSound = tool:FindChild('SlingSound')

-- Configuration
local FIRE_FORCE = 120
local COOLDOWN = 0.1
local PELLET_SIZE = Vector3.New(0.6, 0.6, 0.6)
local PELLET_BOUNCINESS = 0.8 

local colors = {
    Color.New(1, 0, 0), -- Red
    Color.New(0, 1, 0), -- Green
    Color.New(0, 0, 1), -- Blue
    Color.New(1, 1, 0), -- Yellow
    Color.New(1, 0, 1)  -- Pink
}

-- Local variable to track time for this specific tool instance
local lastFireTime = 0

netEvent.InvokedServer:Connect(function(player, msg)
    -- 1. Cooldown Check using os.clock()
    local currentTime = os.clock()
    if currentTime - lastFireTime < COOLDOWN then
        return
    end
    lastFireTime = currentTime

    -- 2. Extract Target Position
    local targetPos = msg:GetVector3(1)
    
    -- 3. Create the Pellet
    local pellet = Instance.New("Part")
    pellet.Name = "SlingshotPellet"
    pellet.Shape = PartShape.Ball
    pellet.Size = PELLET_SIZE
    pellet.Bounciness = PELLET_BOUNCINESS
    pellet.Color = colors[math.random(1, #colors)]

    slingSound:PlayOneShot()
    
    -- Using game['Environment']
    pellet.Parent = game['Environment']

    -- 4. Launch Direction & Origin (Front of Player)
    -- Origin at eye-level (1.5 units up from player center)
    local spawnOrigin = player.Position + Vector3.New(0, 1.5, 0)
    
    -- Using .normalized (lowercase)
    local direction = (targetPos - spawnOrigin).normalized
    
    -- Spawn 3 studs in front of player to ensure it clears the hitbox
    pellet.Position = spawnOrigin + (direction * 3)

    -- 5. Creator Tag
    local creatorTag = Instance.New("InstanceValue")
    creatorTag.Name = "creator"
    creatorTag.Value = player
    creatorTag.Parent = pellet

    -- 6. Physics
    pellet.Anchored = false
    pellet.Velocity = direction * FIRE_FORCE

    -- 7. Cleanup & Damage Logic
    spawn(function()
        wait(3)
        if pellet then pellet:Destroy() end
    end)

    pellet.Touched:Connect(function(hit)
        
        -- Player == Character check
        if hit:IsA("Player") and hit ~= player then
            hit.Health = hit.Health - 15
            if hit:FindChild('creator') then
                local killtag = hit:FindChild('creator')
                killtag:Destroy()
                creatorTag.Parent = hit
            end
            pellet:Destroy()
        end
    end)
end)
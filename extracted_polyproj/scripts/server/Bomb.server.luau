-- If the script is still inside the Tool, don't start the fuse!
if script.Parent.Parent:IsA("Tool") then
    return
end

-- If we made it here, we are inside the 'TimeBomb' part

local updateInterval = 0.4
local currentColor = 1
local colors = {Color.New(1, 0, 0), Color.New(0, 0, 0)} -- Red and Black

-- Sound setup
local tickSound = script.Parent:FindChild("Beep") -- Assumes you have a sound named Tick

function update()
    -- Makes the ticking faster each time (0.4 -> 0.36 -> 0.32...)
    updateInterval = updateInterval * 0.9
    script.Parent.Color = colors[currentColor]
    
    currentColor = currentColor + 1
    if currentColor > 2 then currentColor = 1 end
end

function blowUp()
    local explosionPos = script.Parent.Position
    local creator = script.Parent:FindChild("creator")
    local shooter = creator and creator.Value

    -- Polytoria's Explosion Method
    game['Environment']:CreateExplosion(
        explosionPos, 
        15,     -- Blast Radius
        15000, -- Blast Pressure
        true,    -- Break joints/Apply force
        function(obj)
            -- This runs for every object hit
            if obj['DontUnanchor'] then
                obj.Anchored = true
                return
            end
            if obj:IsA("Player") and obj ~= shooter then
                local dist = (obj.Position - explosionPos).magnitude
                -- Classic falloff damage
                local damage = 100 * (1 - dist/12)
                obj.Health = obj.Health - damage
                
                -- Tagging for the killfeed
                if shooter then
                    if obj:FindChild('creator') then
                        obj:FindChild('creator'):Destroy()
                    end
                    local tag = creator:Clone()
                    tag.Parent = obj
                    -- Note: You'd usually untag after 2 seconds
                end
            elseif obj:IsA('Truss') then
                obj:Destroy()
            end
        end,
        0
    )

    -- Play boom sound
    local boom = script.Parent:FindChild("Boom")
    if boom then
        boom.Parent = game['Environment']
        boom:Play()
    end

    script.Parent.Color = Color.New(0,0,0,0)
    script.Parent.CanCollide = false
end

-----------------
--| MAIN LOOP |--
-----------------

-- The "Fuse" logic
while updateInterval > 0.1 do
    wait(updateInterval)
    update()
    if tickSound then tickSound:Play() end
end

blowUp()

-- Wait for sound to finish before deleting
wait(2)
script.Parent:Destroy()
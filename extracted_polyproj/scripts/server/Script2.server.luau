--[[
    Classic_Sword_Polytoria_Final_V18.lua
    MassaHex: Server-Stabilized Velocity and FOV Fix.
    Movement: Lowered Initial Pop + Preferred +2 Additive Loop.
]]

local Tool = script.Parent
local Handle = Tool:FindChild("Handle")
local Hitbox = Handle:FindChild("Hitbox")
local Sounds = Tool:FindChild("Sounds")

-- Combat Settings
local damage = 5
local slash_damage = 10
local lunge_damage = 30
local enabled = true
local isLungeReady = false
local canHit = true 

-- Grip Settings
local swordUp = Vector3.new(0, 0, 0) 
local swordOut = Vector3.new(90, 0, 0) 

local function setGrip(rotationVector)
    Handle.LocalRotation = rotationVector
end

local function lunge()
    enabled = false 
    damage = lunge_damage
    
    local player = Tool.Parent
    if player then
        -- local oldSpeed = player.WalkSpeed or 16
        -- player.WalkSpeed = 0 
        
        if Sounds and Sounds["Lunge"] then Sounds["Lunge"]:PlayOneShot() end
        setGrip(swordOut)

        -- STABILIZED PHYSICS
        -- Lowered initial burst to 10 to prevent FOV snapping
        player.Velocity = player.Velocity + Vector3.new(0, 10, 0)
        
        -- PREFERRED ADDITIVE LOOP (+2)
        -- Spreading the force out prevents the server from rubber-banding you
        for i = 1, 8 do
            player.Velocity = player.Velocity + Vector3.new(0, 2, 0)
            wait(0.06) -- Slightly longer wait for server sync
        end
        
        wait(0.4) -- Recovery
        setGrip(swordUp)
        -- player.WalkSpeed = oldSpeed
    end
    
    damage = 5
    enabled = true
end

local function attack()
    damage = slash_damage
    if Sounds and Sounds["Slash"] then Sounds["Slash"]:PlayOneShot() end
    
    Tool:Play("slash")
    setGrip(swordUp) 
    
    isLungeReady = true
    wait(0.3) 
    isLungeReady = false
    
    wait(0.1)
    damage = 5
end

local function onActivated()
    if not enabled then return end
    local player = Tool.Parent
    if not player or player:IsA("Player") == false then return end

    if isLungeReady then
        isLungeReady = false 
        lunge()
    else
        attack()
    end
end

local function onHitboxTouched(hit)
    if not hit or not canHit then return end
    
    local attacker = Tool.Parent
    local currentObj = hit
    local targetFound = nil

    while currentObj ~= nil and currentObj ~= workspace do
        if currentObj:IsA("Player") or currentObj:IsA("NPC") then
            targetFound = currentObj
            break
        end
        currentObj = currentObj.Parent
    end

    if targetFound and targetFound ~= attacker then
        targetFound.Health = targetFound.Health - damage
        print("MassaHex hit: " .. targetFound.Name .. " | Damage: " .. tostring(damage))
        
        canHit = false
        wait(0.4)
        canHit = true
    end
end

local function onEquipped()
    if Sounds and Sounds["Unsheath"] then Sounds["Unsheath"]:Play() end
    setGrip(swordUp)
    enabled = true
    isLungeReady = false
    canHit = true
    damage = 5
end

Tool.Activated:Connect(onActivated)
Tool.Equipped:Connect(onEquipped)
Hitbox.Touched:Connect(onHitboxTouched)
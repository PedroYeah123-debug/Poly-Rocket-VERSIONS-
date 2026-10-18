-- Only run if the script has been moved into the Rocket part
if script.Parent:IsA("Script") or script.Parent:IsA("Tool") then return end

-----------------
-- | Constants |--
-----------------

local BLAST_RADIUS = 15
local BLAST_DAMAGE = 150
local ARM_DISTANCE = 5 -- The rocket won't explode until it has traveled 5 studs

-- Rocket will fly through things named these
local IGNORE_LIST = {rocket = true, handle = true, effect = true, water = true}

-----------------
-- | Variables |--
-----------------

local rocket = script.Parent
local creatorTag = rocket:FindChild("creator")
local swooshSound = rocket:FindChild("Swoosh")
local isDestroyed = false
local spawnPos = Vector3.new(0, 0, 0)
if rocket and rocket:IsA("BasePart") then spawnPos = rocket.Position end

-----------------
-- | Functions |--
-----------------

local function OnTouched(otherPart)
    if not rocket or not otherPart then return end

    -- 1. Ignore List Check
    if IGNORE_LIST[string.lower(otherPart.Name)] then return end

    -- 2. Creator Check (RE-ENABLED & FIXED)
    local myPlayer = creatorTag and creatorTag.Value
    if myPlayer then
        -- This stops the rocket from exploding if it touches YOU
        if otherPart == myPlayer or otherPart.Parent == myPlayer then
            return
        end
    end

    -- 3. Distance Gate (Safety Arming)
    -- If the rocket hits something too close to where it was born, ignore it.
    -- This prevents the rocket from hitting your own launcher or the floor inside your feet.
    local travelDist = (rocket.Position - spawnPos).magnitude
    if travelDist < ARM_DISTANCE then return end

    -- 4. The Explosion
    local explosionPos = rocket.Position

    game['Environment']:CreateExplosion(explosionPos, BLAST_RADIUS, 10000, true,
                                        function(obj)
        -- Handle Players (Humanoids)
        if obj['DontUnanchor'] then
            obj.Anchored = true
            return
        end
        if obj:IsA("Player") and obj ~= myPlayer then
            local dist = (obj.Position - explosionPos).magnitude
            local damage = BLAST_DAMAGE * (1 - dist / BLAST_RADIUS)
            obj.Health = obj.Health - damage
            if myPlayer then
                if obj:FindChild('creator') then
                    obj:FindChild('creator'):Destroy()
                end
                local creatorTag = creator:Clone()
                creatorTag.Parent = myPlayer
                -- Note: You'd usually untag after 2 seconds
            end
        elseif obj:IsA('Truss') then
            obj:Destroy()
        end
    end, 0)

    isDestroyed = true
    rocket:Destroy()
end

--------------------
-- | Script Logic |--
--------------------

if swooshSound then swooshSound:Play() end

rocket.Touched:Connect(OnTouched)

-- Cleanup if it never hits anything
spawn(function()
    wait(10)
    -- Check if 'rocket' variable still points to something and has a parent
    if rocket and not isDestroyed then rocket:Destroy() end
end)
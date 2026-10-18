-----------------
-- | Constants |--
-----------------
local RELOAD_TIME = 0.5 -- Normal is 6 seconds

local ROCKET_SPEED = 100

local ROCKET_PART_SIZE = Vector3.New(1, 1, 3)

-----------------

-- | Variables |--

-----------------

local tool = script.Parent

local barrel = tool['Barrel']

local netEvent = tool['GetMouse']

local fire = game['Hidden']['Fire']

local brain = game['Hidden']:FindChild("Rocket")

local canFire = true

-----------------

-- | Functions |--

-----------------

-- The server now listens for the client to SEND the position first

netEvent.InvokedServer:Connect(function(player, message)

    -- Security and Debounce check

    if not canFire or not player or player.Health <= 0 then return end

    local targetPos = message:GetVector3(1)

    if not targetPos then return end

    canFire = false

    -----------------------

    -- | Rocket Spawning |--

    -----------------------

    local rocket = Instance.New("Part")

    rocket.Name = "Rocket"

    rocket.Size = ROCKET_PART_SIZE

    rocket.CanCollide = false

    rocket.Anchored = false

    rocket.Parent = game['Environment']

    -- Fire trail

    local fireClone = fire:Clone()

    fireClone.Position = rocket.Position

    fireClone.Parent = rocket

    -- Using the player who sent the message

    rocket.Color = Color.New(player.ChatColor.r, player.ChatColor.g, player.ChatColor.b) or Color.New(1, 0, 0)

    rocket.UseGravity = false

    -- Calculate direction from the tool to the target

    local lookDir = (targetPos - barrel.Position).normalized

    local spawnPos = barrel.Position - lookDir

    rocket.Position = spawnPos

    rocket.LookAt(targetPos)

    rocket.Velocity = lookDir * ROCKET_SPEED

    --------------------------

    -- | The Classic Clone |--

    --------------------------

    -- 1. Create the Creator Tag (ObjectValue/InstanceValue)

    local creator = Instance.New("InstanceValue")

    creator.Name = "creator"

    creator.Value = player

    creator.Parent = rocket

    -- 2. Clone the Sounds from the Tool

    local swoosh = tool:FindChild("Swoosh")

    if swoosh then

        local s = swoosh:Clone()

        s.Parent = rocket

    end

    local boom = tool:FindChild("Boom")

    if boom then

        local b = boom:Clone()

        b.Parent = rocket

    end

    -- 3. Clone the "Brain" Script from this script

    if brain then

        local brainClone = brain:Clone()

        brainClone.Parent = rocket

    end

    -- Reload

    wait(RELOAD_TIME)

    canFire = true

end)
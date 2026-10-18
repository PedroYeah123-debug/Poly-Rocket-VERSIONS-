local wallHeight = 4
local brickSpeed = 0.04
local wallWidth = 12
local canBuild = true
local lastTargetPos = nil 

local tool = script.Parent
local netEvent = tool["GetMouse"] -- We only need this one object

-- 1. Listen for the CLIENT'S REPLY on the same event
netEvent.InvokedServer:Connect(function(player, message)
    lastTargetPos = message:GetVector3(1)
end)

function placeBrick(pos, wallForward, color)
    local brick = Instance.New("Part")
    brick.Parent = game['Environment']
    brick.Color = color
    brick.Size = Vector3.New(2, 1.2, 1)
    brick.Position = pos
    brick.LookAt(pos + wallForward)
    brick.Anchored = false 
    brick.Friction = 0.5
    
    spawn(function()
        wait(20)
        if brick then brick:Destroy() end
    end)
    return brick
end

function buildWall(centerPos, forwardVec)
    local color = Color.New(math.random(), math.random(), math.random())
    local rightVec = Vector3.New(-forwardVec.z, 0, forwardVec.x).normalized
    
    local y = 0
    while y < wallHeight do
        local x = -wallWidth / 2
        while x < wallWidth / 2 do
            local offsetPos = centerPos + (rightVec * x) + Vector3.New(0, y + 0.6, 0)
            placeBrick(offsetPos, forwardVec, color)
            x = x + 2 
            wait(brickSpeed)
        end
        y = y + 1.2
    end
end

function snap(v)
    if math.abs(v.x) > math.abs(v.z) then
        return Vector3.New(v.x > 0 and 1 or -1, 0, 0)
    else
        return Vector3.New(0, 0, v.z > 0 and 1 or -1)
    end
end

tool.Activated:Connect(function()
    if not canBuild then return end
    canBuild = false

    local player = tool.Parent
    if not player:IsA("Player") then 
        canBuild = true
        return 
    end

    lastTargetPos = nil
    local request = NetMessage.New()
    
    -- STEP 1: Signal the Client
    netEvent:InvokeClient(request, player)

    -- STEP 2: Wait for the Client to fire the SAME event back
    local timeout = 0
    while lastTargetPos == nil and timeout < 20 do
        wait(0.1)
        timeout = timeout + 1
    end

    if lastTargetPos then
        local lookDir = (lastTargetPos - player.Position).normalized
        local snappedDir = snap(lookDir)

        if tool["BuildSound"] then
            tool["BuildSound"]:Play()
        end

        buildWall(lastTargetPos, snappedDir)
    end

    wait(5)
    canBuild = true
end)
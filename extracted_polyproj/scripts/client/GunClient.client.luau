-----------------
--| Constants |--
-----------------

local tool = script.Parent
local netEvent = tool:FindChild("GetMouse")
local player = game['Players'].LocalPlayer
local camera = game['Environment']['Camera']

-----------------
--| Functions |--
-----------------

local function OnActivated()
    -- 1. CRITICAL OWNERSHIP CHECK
    -- This ensures that if Player B clicks, Player A's script doesn't run.
    -- tool.Parent is the Character when equipped.
    if tool.Parent ~= player then 
        return 
    end

    -- 2. GET TARGET POSITION
    -- Using the Input class method you found:
    local targetPos = Input.GetMouseWorldPosition()
    
    -- 3. SKY CHECK / FALLBACK
    -- If GetMouseWorldPosition returns a zeroed or invalid vector because of the sky,
    -- we use the ViewportPointToRay or simple Camera projection.
    -- Polytoria's GetMouseWorldPosition usually returns a very far point if hitting sky,
    -- but this fallback ensures accuracy:
    if targetPos.magnitude == 0 then
        targetPos = camera.CoordinateFrame.p + (camera.CoordinateFrame.lookVector * 500)
    end
    
    -- 4. SEND TO SERVER
    local msg = NetMessage.New()
    msg:AddVector3(1, targetPos)
    
    -- This sends the signal to the ServerScript's netEvent.InvokedServer
    netEvent:InvokeServer(msg)
end

--------------------
--| Script Logic |--
--------------------

tool.Activated:Connect(OnActivated)
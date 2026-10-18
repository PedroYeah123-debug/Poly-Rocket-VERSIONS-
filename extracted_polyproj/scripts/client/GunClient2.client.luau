-----------------
--| Constants |--
-----------------

local tool = script.Parent
local netEvent = tool:FindChild("GetMouse") -- Match the Server Script
local player = game['Players'].LocalPlayer
local camera = game['Environment']['Camera']

-----------------
--| Functions |--
-----------------

local function OnActivated()
    -- 1. Ownership Check
    if tool.Parent ~= player then 
        return 
    end

    -- 2. Get Target Position
    local targetPos = Input.GetMouseWorldPosition()
    
    -- 3. Sky Fallback
    -- If targetPos is 0,0,0 (aiming at sky), project 500 units forward
    if targetPos.magnitude == 0 then
        targetPos = camera.CoordinateFrame.p + (camera.CoordinateFrame.lookVector * 500)
    end
    
    -- 4. Send to Server
    -- We pack the Vector3 into the message and invoke the server
    local msg = NetMessage.New()
    msg:AddVector3(1, targetPos)
    
    -- This triggers the 'InvokedServer' connection in the Server Script
    netEvent:InvokeServer(msg)
end

--------------------
--| Script Logic |--
--------------------

tool.Activated:Connect(OnActivated)
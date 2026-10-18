local tool = script.Parent

-- Listen for the server's "Request"
tool["GetMouse"].InvokedClient:Connect(function()
    local mousePos = Input.MousePosition
    local ray = Input:ScreenPointToRay(mousePos)
    
    local reply = NetMessage.New()
    
    if ray then
        reply.AddVector3(1, ray.Position)
    else
        reply.AddVector3(1, Vector3.New(0, 0, 0))
    end
    
    -- 3. Instead of 'return', fire a DIFFERENT event back to the server
    tool["GetMouse"]:InvokeServer(reply)
end)
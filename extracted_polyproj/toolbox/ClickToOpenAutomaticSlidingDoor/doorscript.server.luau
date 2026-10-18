local doorModel = script.Parent
local canOpen = true
local auto = true -- true for automatic closing, false if you want it to stay open until clicked again

--DECLARING SCRIPT WITH DOOR OPEN FUNCTION AND DOOR ITSELF
local door = doorModel:FindChild("door")
local doorScript = door:FindChild("doorOpenScript")

door.Clicked:Connect(function(plr) -- you can probably change this function with something else to make a proximity based or button controlled door
    if (canOpen == true) then
    	doorScript:Call("doorEval")
        if (auto == true) then
            wait(3) -- change number if you want to modify the time waited before autoclosing
            doorScript:Call("autoClose")
        else return end
    end
end)
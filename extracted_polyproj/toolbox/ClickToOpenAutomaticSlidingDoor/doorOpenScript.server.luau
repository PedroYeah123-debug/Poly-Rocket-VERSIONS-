--[[
parent heirarchy:
dooropenscript should be in door
door should be in doormodel
doormodel should be in environment
environment should be in game
SFX should be in game

if you want to change this
you will need to change the parents that are being called in the local thingies
you know what to do man I believe in you
]]

local door = script.Parent
local doorModel = script.Parent.Parent
local doorlight = doorModel:FindChild("doorLight")

-- SFX are in a folder in game for all doors to use, to avoid cloning 900 sound parts
-- I could probably do this more efficiently but I don't know how to!
-- TODO: make sound play where door is, not where the original sound is
-- commenting out until I figure it out because I don't need SFX right now

--[[
local SFX = script.Parent.Parent.Parent.Parent:FindChild("SFX")
local openSFX = SFX:FindChild("openSound")
local closeSFX = SFX:FindChild("closeSound")
]]

local doorDir = door.Forward -- which direction the door moves in
local distance = 4 -- how many studs the door moves
local status = "closed"

function openDoor()
    --openSFX.PlayOneShot()
    status = "opening"
    doorlight.Color=Color.new(75/255,151/255,75/255) -- change doorlights to green when open
    wait(0.5) -- time before the door animation plays
    Tween:TweenPosition(
        door,
        door.Position + (doorDir * distance),
        0.5, -- length of the door animation
        TweenType.easeOutQuad, -- animation type
        function()
    end)
    wait(0.5) -- time waited before the door is allowed to be closed
    status = "open"
end

function closeDoor() --closes the door
    --closeSFX.PlayOneShot()
    status = "closing"
    doorlight.Color=Color.new(196/255,40/255,28/255) -- change doorlights to red when closed
    wait(0.5) -- time before the door animation plays
    Tween:TweenPosition(
        door,
        door.Position + (doorDir * -distance),
        1, -- length of the door animation
        TweenType.easeOutQuad,
        function()
    end)
    wait(0.5) -- time waited before the door is allowed to be opened
    status = "closed"
end

function doorEval() --opens the door if closed, closes the door if open
    if status == "closed" then
       openDoor()
    elseif status == "open" then
        closeDoor()
    else 
        return
    end
end

function autoClose() --closes the door if already open
    if status == "open" then
       closeDoor()
    elseif status == "closed" then
        return
    else 
        return
    end
end

function _update(dt) --idk lol
    --print(status)
    --print(openSFX.Playing)
end
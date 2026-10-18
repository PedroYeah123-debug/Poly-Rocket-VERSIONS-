NPC = script.Parent
--NPC.WalkSpeed = 11 -- BUG: WalkSpeed is not transferred to cloned models, so we set the speed inside a script

Respawntime = 6 -- Respawn time in seconds
DeathSound = script.Parent["DeathSound"]
Spawnposition = NPC.Position

NPC.Touched:Connect(function (other)
  if NPC.Health > 0 and other:IsA("Player") then
    other.Health = other.health - 10
  elseif other:IsA("Part") then
    NPC:Jump()
  end
end)

NPC.Died:Connect(function(other)
  DeathSound:Play()
  NPC.MoveTarget = nil
  wait(Respawntime)
  NPC.Position = Spawnposition
  NPC:Respawn()
  NPC.Anchored = false
end)

while true do
  local closest = nil

  local Players = game["Players"]:GetChildren()
  for k, v in pairs(Players) do
    if closest ~= nil then
      if (NPC.Position - v.Position).magnitude < (NPC.Position - closest).magnitude then
        closest = v
      end
    else
      closest = v
    end
  end

  --RandomPosOffset = Vector3:New(math.random(-1,1),math.random(-1,1),math.random(-1,1))
  --RandomPosOffset = Vector3:New(0,0,0)

  --closest = Vector3:New(closest.x + RandomPosOffSet.x,closest.y + RandomPosOffSet.y,closest.z + RandomPosOffSet.z)

  --TargetPos = Vector3:New(closest.x,closest.y,closest.z)

  --closest = closest + RandomPosOffSet
  --closest.x = closest.x + RandomPosOffset.x
  --closest.y = closest.y + RandomPosOffset.y
  --closest.z = closest.z + RandomPosOffset.z

  if NPC.Health > 0 then
    NPC.MoveTarget = closest
  end
  wait(2)
end
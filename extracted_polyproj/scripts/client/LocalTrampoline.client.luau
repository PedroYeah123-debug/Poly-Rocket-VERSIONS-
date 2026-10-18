-- I'm newbie for scripts, sorry for errors - by Dilanio
wait(2) -- 'loading' Parts

-- values
local jumpForce = 70
local lastTouch = os.clock()

for part in (script.Parent:GetChildren()) do
	if part~=nil and part:IsA("Part") then

		part.Touched:Connect(function(hit)
			if not hit then return end
			if not hit:IsA('Player') then return end
			if hit ~= game["Players"].LocalPlayer then return end

			local now = os.clock()
			if lastTouch and (now - lastTouch < 1) then return end
			lastTouch = now

			script.Parent["Bouncer_mei"]["Sound"].Position = hit.Position
			script.Parent["Bouncer_mei"]["Sound"]:PlayOneShot()
			hit.Velocity = Vector3.new(0, jumpForce, 0)
		end)
	end
end
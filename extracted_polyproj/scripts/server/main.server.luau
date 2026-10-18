local plr=script.Parent.Parent local tool=script.Parent local active=false local ws=plr.WalkSpeed

local function main()
	active=true
	ws=plr.WalkSpeed
	plr.WalkSpeed=script.Parent["Speed"].Value
end

local function stop()
	active=false
	plr.WalkSpeed=ws
end

plr.Died:Connect(function() stop() end)

script.Parent.Equipped:Connect(main)
script.Parent.Unequipped:Connect(stop)
main()
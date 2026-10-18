local plr=script.Parent.Parent local tool=script.Parent local active=false

local function main()
	if plr:FindChild("_gravchanger") then return end
	active=true
	local grav=Instance.new("BodyPosition") grav.Parent=plr
	grav.Force=script.Parent["Strength"].Value grav.Name="_gravchanger"
	local temp=NetMessage.new() temp:AddInstance("grav",grav)
	script.Parent["gravchangesignal"]:InvokeClient(temp,plr)
end

local function stop()
	active=false
	if plr:FindChild("_gravchanger") then
		plr["_gravchanger"]:Destroy()
	end
end

plr.Died:Connect(function() stop() end)

script.Parent.Equipped:Connect(main)
script.Parent.Unequipped:Connect(stop)
main()
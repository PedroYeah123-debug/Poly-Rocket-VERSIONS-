script.Parent.InvokedClient:Connect(function(nul,b)
	local grav=b:GetInstance("grav")
	while grav~=nil and wait() do grav.TargetPosition=game["Players"].LocalPlayer.Position+Vector3.new(0,1,0) end
end)
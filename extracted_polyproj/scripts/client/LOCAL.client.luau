local tool=script.Parent local hold=false local maxammo=script.Parent["DATA1"].Value.z local ammo=maxammo
local debounce=true local firerate=script.Parent["DATA1"].Value.x local handle=script.Parent["Handle"] local reloading=false
local gunname=script.Parent.Name local inac=script.Parent["DATA2"].Value.z plr=game["Players"].LocalPlayer
local eng=game["Environment"]["hvkGunENG"]
local function updatename()
	script.Parent.Name=gunname.." ("..ammo..")"
end
local function guion(num)
	game["PlayerGUI"]["hvkGunMain"]["engage"]:Invoke(num)
end
local function localbullet(bul)
	local stoptouch=false
	bul.Touched:Connect(function(hit) if stoptouch then return end
		if not hit:IsDescendantOf(plr) and not hit:IsDescendantOf(tool) and not hit:IsDescendantOf(game["Environment"]["hvkGunENG"]) and hit.Name~="projectile" then
		if hit:IsA("Player") or hit:IsA("NPC") then
		eng["DEBRIS"]:Invoke(bul.Position,nil)
		hit.Health=hit.Health-15
		else
		if not hit.CanCollide or hit.Color.a==0 then return end
		eng["DEBRIS"]:Invoke(bul.Position,hit.Color)
		end
		stoptouch=true wait(0.2)
		bul:Destroy() end
	end)
	spawn(function() wait(5) if bul~=nil then bul:Destroy() end end)
end
local function paintball()
	local bul=Instance.new("Part") bul.Size=Vector3.new(1,1,1) bul.Color=script.Parent["COL"..math.random(1,3)].Value bul.Parent=game["Environment"]["hvkBullets"]
	bul.Position=plr.Position+plr.Right*1.5+plr.Forward*2.5+Vector3.new(0,0.5,0) bul.Anchored=false bul.UseGravity=false bul.Name="projectile"
	bul:LookAt(Input:GetMouseWorldPosition()) bul.Velocity=bul.Forward*script.Parent["DATA2"].Value.x+Vector3.new(math.random(-inac,inac),math.random(-inac,inac),math.random(-inac,inac))
	bul.Shape=PartShape.Brick bul.Mass=0.2 localbullet(bul)
end
local function fireanim()
	local shell=Instance.new("Part") shell.Parent=game["Environment"]["hvkGunENG"]["DebrisFolder"] shell.Anchored=false
	shell.Size=Vector3.new(0.2,0.5,0.2) shell.Position=tool.Position+tool.Right+tool.Up*0.5 shell.Rotation=tool.Rotation+Vector3.new(270,0,math.random(-30,30))
	shell.Color=Color.new(245/255,205/255,48/255) shell.Velocity=tool.Right*math.random(10,20)+tool.Forward*math.random(-2,2)+tool.Up*math.random(1,15) shell.Mass=0 shell.Shape=PartShape.Cylinder
	shell.Name="case"
	wait(2)
	shell:Destroy()
end
local function reloadanim()
	local mag=script.Parent["Mag"] local oricol=mag.Color
	local reloader=(script.Parent["DATA1"].Value.y/2)
	local falsemag=Instance.new("Part") falsemag.Parent=game["Environment"]["hvkGunENG"]["DebrisFolder"]
	falsemag.CanCollide=true falsemag.Mass=0 falsemag.Anchored=false falsemag.Name="mag"
	falsemag.Size=mag.Size falsemag.Position=mag.Position falsemag.Color=mag.Color falsemag.Rotation=mag.Rotation
	falsemag.Velocity=falsemag.Right*5
	mag.Color=Color.new(mag.Color.r,mag.Color.g,mag.Color.b,0)
	tool:Play("slash")
	wait(reloader)
	tool:Play("slash")
	mag.Color=oricol
	wait(2)
	falsemag:Destroy()
end
local function reload()
	guion(3)
	reloading=true
	handle["Reload"]:Play()
	spawn(reloadanim)
	wait(script.Parent["DATA1"].Value.y)
	ammo=maxammo
	reloading=false
	updatename()
	guion(2)
end
local function fire()
	if not debounce or not script.Parent.Parent:IsA("Player") or reloading then return end
	while hold do
		if ammo>0 then --MAINFIRE
			debounce=false
			ammo=ammo-1
			spawn(fireanim)
			handle["Fire"]:Play()
			for i=1,script.Parent["DATA3"].Value.y do
			paintball()
			end
			updatename()
			guion(2)
		else
			reload()
			break
		end
		if script.Parent["DATA3"].Value.x==0 then hold=false end
		wait(script.Parent["DATA1"].Value.x)
		debounce=true
	end
end


local function keydown(key)
	if not script.Parent.Parent:IsA("Player") then return end
	if key=="Mouse0" then hold=true fire() end
end
local function keyup(key)
	if not script.Parent.Parent:IsA("Player") then return end
	if key=="Mouse0" then hold=false end
end

tool.Equipped:Connect(function() guion(1) end)
tool.Unequipped:Connect(function() guion(0) end)
Input.KeyDown:Connect(keydown)
Input.KeyUp:Connect(keyup)
updatename()
guion(1)
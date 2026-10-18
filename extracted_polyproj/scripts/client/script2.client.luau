local tool = script.Parent
local Input = game:GetService("Input")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local indicador = nil
local estaEquipado = false
local function criarIndicador(pos)
if indicador then indicador:Destroy() end
local part = Instance.new("Part")
part.Size = Vector3.new(2.5, 0.1, 2.5)
part.Position = pos + Vector3.new(0, 0.05, 0)
part.Color = Color3.fromRGB(0, 255, 255)
part.Anchored = true
part.CanCollide = false
part.Parent = workspace
indicador = part
task.delay(0.8, function()
if part then part:Destroy() end
end)
end
tool.Equipped:Connect(function()
estaEquipado = true
end)
tool.Unequipped:Connect(function()
estaEquipado = false
if indicador then indicador:Destroy() end
end)
Input.InputBegan:Connect(function(inputObject)
if not estaEquipado then return end
if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
local pontoNoChao = Input:GetMouseWorldPosition()
if pontoNoChao and localPlayer then
criarIndicador(pontoNoChao)
localPlayer:MoveTo(pontoNoChao)
end
end
end)


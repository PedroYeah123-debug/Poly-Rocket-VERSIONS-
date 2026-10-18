local tool = script.Parent
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local canTeleport = true
local cooldown = 1.5 -- Tempo de espera entre os cliques (em segundos)

-- Função que roda quando o jogador clica com a ferramenta equipada
local function onActivated()
    if not canTeleport then return end
    
    local character = localPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    if not rootPart then return end
    
    -- Pega a posição atual do mouse na tela do jogador
    local mousePosition = UserInputService:GetMouseLocation()
    
    -- Cria um raio da câmera em direção ao clique do mouse
    local cameraRay = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
    
    -- Faz o cálculo (Raycast) para descobrir onde o clique bateu no cenário
    local raycastResult = workspace:Raycast(cameraRay.Origin, cameraRay.Direction * 500)
    
    -- Se o clique acertou o chão ou um bloco do mapa...
    if raycastResult then
        canTeleport = false
        
        -- Altera a posição do jogador para o local exato do clique
        -- Adicionamos 3 studs para cima (Vector3.new(0, 3, 0)) para o personagem não nascer enterrado no chão
        rootPart.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
        
        -- Ativa o tempo de recarga
        task.wait(cooldown)
        canTeleport = true
    end
end

tool.Activated:Connect(onActivated)

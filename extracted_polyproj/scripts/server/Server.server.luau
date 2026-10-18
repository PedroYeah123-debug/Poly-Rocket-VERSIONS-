local TestingMode = false

local Datastore = script:FindChild("DataHandler")
local PlayerData = game["Environment"]:FindChild("PlayerData")
local Networking = game["Hidden"]:FindChild("Networking")
local ClientInit = Networking:FindChild("ClientInit")
local PlayerConnected = Networking:FindChild("PlayerConnected")

local LoadedPlayers = {}--{[Player] = true}

function SetTeam(player, teamName)
    if player == nil then return false end
    local playerFolder = PlayerData:FindChild(player.Name)
    if not playerFolder then
        print("Player data folder not found for " .. player.Name)
        return false
    end

    local teamValue = playerFolder:FindChild("Team")
    if not teamValue then
        print("Team value not found for " .. player.Name)
        return false
    end

    if teamName ~= nil then
        teamValue.Value = teamName
    else
        teamValue.Value = ""
    end
    return true
end

ClientInit.InvokedServer:Connect(function(player)
    repeat wait(0.1) until player == nil or LoadedPlayers[player] == true
    if player then
        ClientInit:InvokeClient(NetMessage.New(), player)
    end
end)

local PlayerAchievements = {} -- {[Player] = {[BadgeId]: true}}
local Badges = {
    Welcome = 155043;
}

local function AwardBadge(Player, Badge)
    if not PlayerAchievements[Player] or not PlayerAchievements[Player][Badge] then
        if not PlayerAchievements[Player] then PlayerAchievements[Player] = {} end
        Achievements:Award(Player.UserID, Badge, function(success, error) end)
        PlayerAchievements[Player][Badge] = true
    end
end

local function InitializePlayer(Player)
    Datastore:Call("LoadPlayerData", Player) --{Kills = 0; Deaths = 0;}
    wait(2)
    PlayerAchievements[Player] = {}
    for i,badgeId in pairs(Badges) do
        Achievements:HasAchievement(Player.UserID, badgeId, function(has, success, error) PlayerAchievements[Player][badgeId] = true end)
    end
    AwardBadge(Player, Badges.Welcome)

    LoadedPlayers[Player] = true
    PlayerConnected:Invoke(Player)
end

game["Players"].PlayerAdded:Connect(InitializePlayer)
game["Players"].PlayerRemoved:Connect(function(Player)
    LoadedPlayers[Player] = nil
    PlayerAchievements[Player] = nil
end)

for i,v in pairs(game["Players"]:GetChildren()) do
    InitializePlayer(v)
end

while true do
    wait(3)
    for i,v in pairs(PlayerData:GetChildren()) do
        if not game["Players"]:GetPlayer(v.Name) then
            Datastore:Call("ReleasePlayerData", v) --Force release data in the rare exception that it isn't naturally released on player disconnection
        end
    end
end
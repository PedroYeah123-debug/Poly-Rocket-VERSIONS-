local Store = Datastore:GetDatastore("SagStore");

local DefaultTeam = "" -- "" - no team

local LoadedPlayers = {};
local PlayerData = game["Environment"]:FindChild("PlayerData")

local DEFAULT_PLAYER_DATA = {
    -- This is where you define player data defaults as well as the keys used in player data
    -- if you want to display the value on the leaderboard, make sure to create a corresponding TextLabel in the Leaderboard local script. (string/number only)
    Deaths = 0;
    Kills = 0;
    Wins = 0;
    IsBanned = false;
};

local ValueInstances = { -- Supported value types that go into DEFALT_PLAYER_DATA
    number = "IntValue";
    string = "StringValue";
    boolean = "BoolValue";
}

local IconConditions = {
    {
        ImageID = 53102;
        Conditional = function(Player, ProfileData)
            return ProfileData.isStaff or Player.UserID == 1144
        end;
    };
    {
        ImageID = 53101;
        Conditional = function(Player, ProfileData)
            return ProfileData.membershipType == "plusDeluxe"
        end;
    };
    {
        ImageID = 53100;
        Conditional = function(Player, ProfileData)
            return ProfileData.membershipType == "plus"
        end;
    };
};

local function deepClone(original, seen)
    seen = seen or {}

    if type(original) ~= 'table' then
        return original
    end

    if seen[original] then
        return seen[original]
    end

    local copy = {}
    seen[original] = copy

    for key, value in pairs(original) do
        copy[deepClone(key, seen)] = deepClone(value, seen)
    end

    local originalMetatable = getmetatable(original)
    if originalMetatable then
        setmetatable(copy, deepClone(originalMetatable, seen))
    end

    return copy
end

local function YieldForDatastore()
    local seconds = 0
    local isYielding = false
    while Store.Loading do
        isYielding = true
        print("[Datastore] Yielding for Store.Loading ("..tostring(Store.Loading)..") ["..tostring(seconds).."]")
        wait(1)
        seconds = seconds + 1
    end
    if isYielding then print("[Datastore] Yielded for",seconds,"seconds") end
end

local function Reconcile(player, playerData)
    local TargetData = DEFAULT_PLAYER_DATA;
    if not playerData then return TargetData end
    for key, value in pairs(TargetData) do
        if playerData[key] == nil then
            playerData[key] = value;
        end
    end
    return playerData
end

function LoadPlayerData(player)
    YieldForDatastore()
    local userId = tostring(player.UserID)
    if LoadedPlayers[userId] then print("Getting cached info for: "..userId) return LoadedPlayers[userId] end

    local playerData = nil;
    local yielded = false;
    Store:Get(userId, function(data, success, error)
        if not success then
            print("Datastore Error: " .. tostring(error))
            yielded = true;
        elseif success then
            local processed = string.gsub(string.sub(string.sub(data, 2), 1, #data-2), "\\", "")

            local parsed = json.parse(processed)
            playerData = parsed
            yielded = true;
        end
    end)
    local yieldTimeout = 0
    while not yielded and yieldTimeout < 10 do
        wait(0.1)
        yieldTimeout = yieldTimeout + 0.1
    end
    if yieldTimeout >= 10 then
        print("Playerdata Yield exceeded 10 seconds, defaulting to nil.")
    end

    local returningValue = nil
    if playerData ~= nil then
        if playerData.IsBanned then
            player:Kick("You have been banned from the game.")
            returningValue = nil
        else
            local reconciled = Reconcile(player, playerData)
            returningValue = reconciled
        end
    else
        returningValue = CreateDefaultPlayerData(player)
        if returningValue then
            returningValue.UserID = player.UserID
        end
    end

    if returningValue then
        LoadedPlayers[userId] = deepClone(returningValue)

        local Data = Instance.New("Folder")
        Data.Name = player.Name
        
        -- Fix: Create the UserID Value so CleanupPlayer doesn't fail
        local userIdVal = Instance.New("IntValue")
        userIdVal.Name = "UserID"
        userIdVal.Value = player.UserID
        userIdVal.Parent = Data

        for i,v in pairs(DEFAULT_PLAYER_DATA) do
            local Value = Instance.New(ValueInstances[type(v)])
            Value.Name = i
            Value.Value = v
            if returningValue[i] ~= nil then
                Value.Value = returningValue[i]
            end
            Value.Parent = Data
        end
        local ListIcon = Instance.New("IntValue")
        ListIcon.Name = "_ListIcon"
        ListIcon.Value = 0
        ListIcon.Parent = Data
        local TeamValue = Instance.New("StringValue")
        TeamValue.Name = "Team"
        TeamValue.Value = DefaultTeam
        TeamValue.Parent = Data

        local Processed = false
        Http:Get("https://api.polytoria.com/v1/users/"..userId, function (data, error, errmsg)
            if not error then
                local decoded = json.parse(data)
                for i,v in pairs(IconConditions) do
                    if v.Conditional(player, decoded) then
                        ListIcon.Value = v.ImageID
                        break
                    end
                end
            end
            Processed = true
        end,{})

        repeat wait(0.1) until Processed

        Data.Parent = PlayerData
    end

    return returningValue
end

function CreateDefaultPlayerData(player, callback)
    YieldForDatastore()
    local userId = tostring(player.UserID)
    local defaultData = deepClone(DEFAULT_PLAYER_DATA)
    
    local success = SavePlayerData(player, defaultData)
    if success then
        LoadedPlayers[userId] = defaultData
        return defaultData
    else
        return nil
    end
end

function SavePlayerData(player, data)
    YieldForDatastore()
    local userId = tostring(player.UserID)
    data = Reconcile(player, data)
    local result = nil
    local yielded = false;
    Store:Set(userId, json.serialize(data), function(success, error)
        result = success
        if not success then
            print("Datastore Error: " .. tostring(error))
        end
        yielded = true;
    end)
    local yieldTimeout = 0
    while not yielded and yieldTimeout < 10 do
        wait(0.1)
        yieldTimeout = yieldTimeout + 0.1
    end
    return result
end

function UpdatePlayerData(player, updates)
    YieldForDatastore()
    local userId = "0"
    if player:IsA("Player") then
        userId = tostring(player.UserID)
    else
        local idVal = player:FindChild("UserID")
        if idVal then
            userId = tostring(idVal.Value)
        end
    end

    if not LoadedPlayers[userId] then
        return false
    end

    for key, value in pairs(updates) do
        LoadedPlayers[userId][key] = value
    end

    local result = false
    local yielded = false;
    Store:Set(userId, json.serialize(LoadedPlayers[userId]), function(success, error)
        result = success    
        if not success then
            print("Datastore Error: " .. tostring(error))
        end
        yielded = true;
    end)
    local yieldTimeout = 0
    while not yielded and yieldTimeout < 10 do
        wait(0.1)
        yieldTimeout = yieldTimeout + 0.1
    end

    return result
end

function GetPlayerData(player)
    local userId = tostring(player.UserID)
    return LoadedPlayers[userId]
end

function SetPlayerBanStatus(player, isBanned)
    YieldForDatastore()
    local userId = tostring(player.UserID)

    if not LoadedPlayers[userId] then
        print("Player data not loaded for " .. player.Name)
        return false
    end

    LoadedPlayers[userId].IsBanned = isBanned

    local result = nil
    local yielded = false
    Store:Set(userId, json.serialize(LoadedPlayers[userId]), function(success, error)
        if not success then
            print("Datastore Error: " .. tostring(error))
        end
        result = success
        yielded = true
    end)
    local yieldTimeout = 0
    while not yielded and yieldTimeout < 10 do
        wait(0.1)
        yieldTimeout = yieldTimeout + 0.1
    end

    return result
end

local function CleanupPlayer(playerFolder)
    local userIdObj = playerFolder:FindChild("UserID")
    if userIdObj == nil then
        print("Unremoved userdata appears nil or missing UserID.")
    else
        local userId = tostring(userIdObj.Value)
        LoadedPlayers[userId] = nil
        print("Released: ".. userId)
    end

    playerFolder:Destroy()
end

function ReleasePlayerData(playerFolder, finalUpdates)
    if finalUpdates then
        UpdatePlayerData(playerFolder, finalUpdates)
    end

    CleanupPlayer(playerFolder)
end

-- Main Save/Cleanup Loop
while true do
    wait(60)
    for _, playerFolder in pairs(PlayerData:GetChildren()) do
        local player = game["Players"]:GetPlayer(playerFolder.Name);
        
        if player == nil then
            ReleasePlayerData(playerFolder)
        else
            local data = GetPlayerData(player);
            
            -- Fix: Added nil checks for data and the specific value instances
            if data then
                for dataName, _ in pairs(data) do
                    local valInstance = playerFolder:FindChild(dataName)
                    if valInstance then
                        data[dataName] = valInstance.Value
                    end
                end
                
                local userId = tostring(player.UserID);
                Reconcile(player, data);
                
                Store:Set(userId, json.serialize(data), function(success, error)
                    if not success then
                        print("Datastore Auto-save Error: " .. tostring(error))
                    end
                end)
            end
        end
    end
end
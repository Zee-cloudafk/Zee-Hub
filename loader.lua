local Games = {
    [286090429] = "arsenal"
}

local scriptName = Games[game.PlaceId]

if not scriptName then
    warn("Game not supported")
    return
end

local BaseURL = "https://raw.githubusercontent.com/Zee-cloudafk/Zee-Hub/main/games/"
loadstring(game:HttpGet(BaseURL .. scriptName .. ".lua"))()
local Games = {
    [286090429] = "arsenal",
    [97598239454123] = "grow_a_garden_2" 
}

local scriptName = Games[game.PlaceId]

if not scriptName then
    warn("Game not supported by Zee-Hub")
    return
end

local BaseURL = "https://raw.githubusercontent.com/Zee-cloudafk/Zee-Hub/main/games/"

-- Pesan di console executor agar kamu tahu script berhasil terdeteksi
print("Mencoba memuat script untuk: " .. scriptName)

loadstring(game:HttpGet(BaseURL .. scriptName .. ".lua"))()

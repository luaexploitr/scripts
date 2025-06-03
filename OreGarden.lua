--[[

Ore Garden v1.0
by luaexploitr
discord.gg/qCkVDZ5txf

yes this is open source i didn't
forget to obfuscate it

--]]

--// Essential Variables

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local remotes = replicatedStorage.Remotes
local playerPlot = require(replicatedStorage.Source.Shared.PlotHandler).GetPlot(localPlayer)

local orePurchasePriority = {
    { name = "Obsidian", price = 1000000, id = 11 },
    { name = "Diamond", price = 350000, id = 10 },
    { name = "Emerald", price = 100000, id = 9 },
    { name = "Ruby", price = 20000, id = 8 },
    { name = "RoseQuartz", price = 3500, id = 7 },
    { name = "Lapis", price = 650, id = 6 },
    { name = "Gold", price = 400, id = 5 },
    { name = "Sapphire", price = 300, id = 4 },
    { name = "Iron", price = 125, id = 3 },
    { name = "Quartz", price = 45, id = 2 },
    { name = "Coal", price = 5, id = 1 },
}

local configuration = {
    AutoMining = false,
    AutoSelling = false,
    StaffDetection = false,
    AutoBuying = {
        Coal = false,
        Quartz = false,
        Iron = false,
        Sapphire = false,
        Gold = false,
        Lapis = false,
        RoseQuartz = false,
        Ruby = false,
        Emerald = false,
        Diamond = false,
        Obsidian = false
    },
    ClearOres = {
        Coal = false,
        Quartz = false,
        Iron = false,
        Sapphire = false,
        Gold = false,
        Lapis = false,
        RoseQuartz = false,
        Ruby = false,
        Emerald = false,
        Diamond = false,
        Obsidian = false
    }
}

--// Essential Functions

local function getMoney()
    return tonumber(
        (string.gsub(playerGui.ScreenGui.MoneyHolder.Amount.Text, "[$,]", ""))
    )
end

local function extractStock(plainText)
    return tonumber(string.match(plainText, "%d+"))
end

local function containsCapitals(text)
    return string.match(text, "%u") ~= nil
end

--// Ore Shop Sorting

local orePurchases = {}
local orePurchasesFrame

for _, child in next, playerGui.MainGUI:GetDescendants() do
    if (child:IsA("ViewportFrame")) then
        orePurchasesFrame = child.Parent.Parent.Parent.Parent
        break
    end
end

for _, orePurchase in next, orePurchasesFrame:GetChildren() do
    if (orePurchase:IsA("Frame")) then
        orePurchase = orePurchase.Frame

        local oreName
        local oreStock

        for _, child in next, orePurchase:GetChildren() do
            if (child:IsA("TextLabel")) then
                local childPosition = math.round(child.Position.Y.Scale  * 100) / 100
                
                if (childPosition == 0) then
                    oreName = child
                elseif (childPosition == 0.68) then
                    oreStock = child
                end
            end
        end

        if (oreName and oreStock) then
            orePurchases[string.gsub(string.gsub(oreName.Text, "Ore", ""), " ", "")] = oreStock
        else
            error("Failed to get oreName and oreStock")
        end
    end
end

--[[

Main Script

--]]

--// UI Elements

local rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local window = rayfield:CreateWindow({
    Name = "[💎] Ore Garden v1.0",
    Icon = "scroll-text",
    LoadingTitle = "[💎] Ore Garden v1.0",
    LoadingSubtitle = "by luaexploitr",
    Theme = "Amethyst",

    ToggleUIKeybind = Enum.KeyCode.Delete,

    ConfigurationSaving = {
        Enabled = true,
        FolderName = "luaexploitr",
        FileName = "OreGarden"
    },

    Discord = {
        Enabled = true,
        Invite = "qCkVDZ5txf",
        RememberJoins = true
    }
})

local autoShopTab = window:CreateTab("Auto Mine / Sell", "pickaxe")
local autoShopSection = autoShopTab:CreateSection("Configuration")

autoShopTab:CreateParagraph({
    Title = "[⚠️] Caution",
    Content = "Beware to use these functions at your own risk as they're pretty blatant. I've personally been manually banned by developers whilst in the development of the scripts already."
})

local autoMineToggle = autoShopTab:CreateToggle({
    Name = "Auto Mine Ores",
    CurrentValue = false,
    Flag = "AutoMine",
    Callback = function(value)
        configuration.AutoMining = value
    end
})

local autoSellToggle = autoShopTab:CreateToggle({
    Name = "Auto Sell Ores",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(value)
        configuration.AutoSelling = value
    end
})

local autoBuyTab = window:CreateTab("Auto Buy", "dollar-sign")
local autoBuySection = autoBuyTab:CreateSection("Configuration")

for oreName, value in next, configuration.AutoBuying do
    autoBuyTab:CreateToggle({
        Name = oreName,
        CurrentValue = value,
        Flag = "AutoBuy" .. oreName,
        Callback = function(value)
            configuration.AutoBuying[oreName] = value
        end
    })
end

local clearPlotTab = window:CreateTab("Clear Plot", "bomb")
local clearPlotSection = clearPlotTab:CreateSection("Configuration")

clearPlotTab:CreateParagraph({
    Title = "[⚠️] Caution",
    Content = "Double clicking any of these buttons will destroy every ore of that type on your plot. Be careful and be sure not to fat finger anything."
})

local recentClickTimes = {}

for oreName, value in next, configuration.ClearOres do
    clearPlotTab:CreateButton({
        Name = oreName,
        Callback = function()
            local currentTime = tick()
            local recentClickTime = recentClickTimes[oreName]

            if (
                not recentClickTime or
                currentTime - recentClickTime > 3
            ) then
                recentClickTimes[oreName] = currentTime

                rayfield:Notify({
                    Title = "[⚠️] Confirmation",
                    Content = "Click again within 3 seconds to clear " .. oreName,
                    Duration = 3
                })

                return
            end

            recentClickTimes[oreName] = nil

            for _, ore in next, playerPlot.OreVeins:GetChildren() do
                local oreType = string.split(ore:GetAttribute("id"), "_")[1]

                if (oreType == string.lower(oreName)) then
                    remotes.ExplodeOre:FireServer(ore)
                end
            end
        end
    })
end

local miscTab = window:CreateTab("Miscellaneous", "settings") -- staff detection, destroy rayfield
local miscSection = miscTab:CreateSection("Configuration")

miscTab:CreateToggle({
    Name = "Staff Detection",
    CurrentValue = false,
    Flag = "StaffDetection",
    Callback = function(value)
        configuration.StaffDetection = value
    end
})

miscTab:CreateButton({
    Name = "Join Discord | discord.gg/qCkVDZ5txf",
    Callback = function()
        local success = pcall(function() setclipboard("discord.gg/qCkVDZ5txf") end)

        if (success) then
            rayfield:Notify({
                Title = "[✅] Success",
                Content = "Discord invite has been copied to your clipboard.",
                Duration = 5
            })
        else
            rayfield:Notify({
                Title = "[❌] Error",
                Content = "Error occurred when copying discord to your clipboard.",
                Duration = 5
            })
        end
    end
})

--// Main Loop

spawn(function()
    while (task.wait(1)) do

        --// Auto Mining
        if (configuration.AutoMining) then
            for _, ore in next, playerPlot.OreVeins:GetChildren() do
                if (ore:FindFirstChild("Ores")) then
                    pcall(
                        function() -- Sometimes registers "Ores" for some reason?
                            for _, growOre in next, ore.GrowOres:GetChildren() do
                                if (growOre:GetAttribute("percent") == 100) then
                                    remotes.MineOre:FireServer(growOre)
                                end
                            end
                        end
                    )
                else
                    if (ore:GetAttribute("percent") == 100) then
                        remotes.MineOre:FireServer(ore)
                    end
                end
            end
        end

        --// Auto Selling
        if (configuration.AutoSelling) then
            local dialoguePosition = math.round(
                playerGui.MainGUI.Frame.Position.Y.Scale * 10
            ) / 10
                
            if (dialoguePosition ~= 0) then
                local sell = false

                for _, item in next, localPlayer.Backpack:GetChildren() do
                    if (item:GetAttribute("weight")) then
                        sell = true
                        break
                    end
                end

                if (sell) then
                    remotes.AnswerDialog:FireServer("butch1", 2)
                    remotes.AnswerDialog:FireServer("butch4", 0)
                end
            end
        end

        --// Auto Buying
        if (configuration.AutoBuying) then
            local money = getMoney()

            for _, ore in next, orePurchasePriority do
                local stock = extractStock(orePurchases[ore.name].Text)

                if (
                    stock > 0
                    and money >= ore.price
                    and configuration.AutoBuying[ore.name]
                ) then
                    for i = 1, stock do
                        if (money >= ore.price) then
                            remotes.BuyVeinCore:FireServer(ore.id)
                            money = money - ore.price
                        else
                            break
                        end
                    end
                end
            end
        end
    end
end)

--// Staff Detection

spawn(function()
    players.PlayerAdded:Connect(function(player)
        if (configuration.StaffDetection) then
            local groupRole = player:GetRoleInGroup(36004320)

            if (groupRole ~= "Guest" and groupRole ~= "Member") then
                localPlayer:Kick(
                    "Staff Detection | "
                        .. player.DisplayName
                        .. " (@"
                        .. player.Name
                        .. ")"
                )
            end
        end
    end)
end)

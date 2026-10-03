local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local rEvents = ReplicatedStorage:WaitForChild("rEvents")

local MuscleEvent =
    LocalPlayer:FindFirstChild("muscleEvent")
    or ReplicatedStorage:WaitForChild("muscleEvent")

local EquipPetEvent =
    rEvents:WaitForChild("equipPetEvent")

local RebirthRemote =
    rEvents:WaitForChild("rebirthRemote")

local leaderstats =
    LocalPlayer:WaitForChild("leaderstats")

local Strength =
    leaderstats:WaitForChild("Strength")

local Rebirths =
    leaderstats:WaitForChild("Rebirths")

local petsFolder =
    LocalPlayer:WaitForChild("petsFolder")

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/memejames/elerium-v2-ui-library/main/Library",
    true
))()

local Window = Library:AddWindow(
    "Fast Farm | " .. LocalPlayer.DisplayName,
    {
        main_color = Color3.fromRGB(0, 170, 255),
        min_size = Vector2.new(460, 360),
        can_resize = true
    }
)

local RebirthTab = Window:AddTab("REBIRTHS")
RebirthTab:Show()

RebirthTab:AddLabel("Training: 2 Mythic Boss + 4 Swift + 2 Rainbow Golem")
RebirthTab:AddLabel("Rebirth: 4 Tribal Overlord")

local fastFarm = false
local fastRebirth = false

local farmGeneration = 0
local rebirthGeneration = 0

local FastFarmToggle
local FastRebirthToggle

local function getRequiredStrength()
    return 5000 + Rebirths.Value * 2550
end

local function getPetsByName(name)
    local pets = {}

    for _, folder in ipairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(folder:GetChildren()) do
                if pet.Name:lower() == name:lower() then
                    table.insert(pets, pet)
                end
            end
        end
    end

    return pets
end

local function unequipAllPets()
    for _, folder in ipairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(folder:GetChildren()) do
                pcall(function()
                    EquipPetEvent:FireServer(
                        "unequipPet",
                        pet
                    )
                end)
            end
        end
    end

    task.wait(0.2)
end

local function equipAmount(name, amount)
    local pets = getPetsByName(name)
    local equipped = 0

    for _, pet in ipairs(pets) do
        if equipped >= amount then
            break
        end

        pcall(function()
            EquipPetEvent:FireServer(
                "equipPet",
                pet
            )
        end)

        equipped += 1
        task.wait(0.08)
    end

    return equipped
end

local function equipTrainingPets()
    unequipAllPets()

    local mythic =
        equipAmount(
            "Mythic Boss Pet",
            2
        )

    local swift =
        equipAmount(
            "Swift Samurai",
            4
        )

    local rainbow =
        equipAmount(
            "Rainbow Golem",
            2
        )

    print(
        "[TRAINING]",
        mythic .. "/2 Mythic Boss Pet",
        swift .. "/4 Swift Samurai",
        rainbow .. "/2 Rainbow Golem"
    )
end

local function equipRebirthPets()
    unequipAllPets()

    local tribal =
        equipAmount(
            "Tribal Overlord",
            4
        )

    print(
        "[REBIRTH]",
        tribal .. "/4 Tribal Overlord"
    )
end

local function trainSlow()
    for _ = 1, 5 do
        pcall(function()
            MuscleEvent:FireServer("rep")
        end)
    end
end

local function startFastFarm()
    farmGeneration += 1

    local generation =
        farmGeneration

    task.spawn(function()
        equipTrainingPets()

        while fastFarm
            and generation == farmGeneration do

            trainSlow()

            task.wait(0.08)
        end
    end)
end

local function doRebirth()
    if Strength.Value < getRequiredStrength() then
        return false
    end

    equipRebirthPets()

    task.wait(0.4)

    local oldRebirths =
        Rebirths.Value

    local timeout =
        tick() + 8

    while fastRebirth
        and Rebirths.Value <= oldRebirths
        and tick() < timeout do

        pcall(function()
            RebirthRemote:InvokeServer(
                "rebirthRequest"
            )
        end)

        task.wait(0.1)
    end

    return Rebirths.Value > oldRebirths
end

local function startFastRebirth()
    rebirthGeneration += 1

    local generation =
        rebirthGeneration

    task.spawn(function()
        equipTrainingPets()

        while fastRebirth
            and generation == rebirthGeneration do

            if Strength.Value < getRequiredStrength() then
                trainSlow()

                task.wait(0.08)
            else
                doRebirth()

                if not fastRebirth
                    or generation ~= rebirthGeneration then

                    break
                end

                task.wait(0.3)

                equipTrainingPets()
            end
        end
    end)
end

FastFarmToggle =
    RebirthTab:AddSwitch(
        "Fast Farm",
        function(state)
            fastFarm = state
            farmGeneration += 1

            if state then
                if fastRebirth then
                    fastRebirth = false
                    rebirthGeneration += 1

                    if FastRebirthToggle then
                        FastRebirthToggle:Set(false)
                    end
                end

                startFastFarm()
            end
        end
    )

FastFarmToggle:Set(false)

FastRebirthToggle =
    RebirthTab:AddSwitch(
        "Fast Rebirth",
        function(state)
            fastRebirth = state
            rebirthGeneration += 1

            if state then
                if fastFarm then
                    fastFarm = false
                    farmGeneration += 1

                    if FastFarmToggle then
                        FastFarmToggle:Set(false)
                    end
                end

                startFastRebirth()
            end
        end
    )

FastRebirthToggle:Set(false)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local rEvents = ReplicatedStorage:WaitForChild("rEvents")
local muscleEvent = Player:WaitForChild("muscleEvent")
local petsFolder = Player:WaitForChild("petsFolder")

local leaderstats = Player:WaitForChild("leaderstats")
local Rebirths = leaderstats:WaitForChild("Rebirths")
local Strength = leaderstats:WaitForChild("Strength")

local equipPetEvent = rEvents:WaitForChild("equipPetEvent")
local rebirthRemote = rEvents:WaitForChild("rebirthRemote")

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/silencedevs/SilenceScripts/refs/heads/main/librarys/eleriumv2.luau"
))()

local Window = Library:AddWindow(
    "Fast Rebirth | " .. Player.DisplayName,
    {
        main_color = Color3.fromRGB(138, 0, 0),
        min_size = Vector2.new(500, 350),
        can_resize = false
    }
)

local RebirthTab = Window:AddTab("Rebirths")

RebirthTab:Show()

local running = false
local workerActive = false
local currentPhase = "Inactive"

local Status =
    RebirthTab:AddLabel(
        "Status: Inactive"
    )

local StrengthLabel =
    RebirthTab:AddLabel(
        "Strength: 0 / 0"
    )

local RebirthLabel =
    RebirthTab:AddLabel(
        "Rebirths: " .. tostring(Rebirths.Value)
    )

local PetLabel =
    RebirthTab:AddLabel(
        "Pets: None"
    )

local function getRequiredStrength()
    return 5000 + Rebirths.Value * 2550
end

local function getPetsByName(name)
    local result = {}

    for _, folder in ipairs(
        petsFolder:GetChildren()
    ) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(
                folder:GetChildren()
            ) do
                if pet.Name == name then
                    table.insert(
                        result,
                        pet
                    )
                end
            end
        end
    end

    return result
end

local function unequipAllPets()
    for _, folder in ipairs(
        petsFolder:GetChildren()
    ) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(
                folder:GetChildren()
            ) do
                pcall(function()
                    equipPetEvent:FireServer(
                        "unequipPet",
                        pet
                    )
                end)
            end
        end
    end

    task.wait(0.12)
end

local function equipAmount(
    name,
    amount
)
    local pets =
        getPetsByName(name)

    local equipped = 0

    for _, pet in ipairs(pets) do
        if equipped >= amount then
            break
        end

        equipPetEvent:FireServer(
            "equipPet",
            pet
        )

        equipped += 1

        task.wait(0.04)
    end

    return equipped
end

local function equipTrainingPets()
    currentPhase =
        "Equipping Training Pets"

    Status.Text =
        "Status: Equipping Training Pets"

    unequipAllPets()

    local swift =
        equipAmount(
            "Swift Samurai",
            4
        )

    local rare =
        equipAmount(
            "Rare Boss Pet",
            4
        )

    PetLabel.Text =
        "Pets: "
        .. tostring(swift)
        .. "/4 Swift Samurai | "
        .. tostring(rare)
        .. "/4 Rare Boss Pet"

    currentPhase =
        "Training"

    Status.Text =
        "Status: Training"
end

local function equipRebirthPets()
    currentPhase =
        "Equipping Rebirth Pets"

    Status.Text =
        "Status: Equipping Tribal Overlords"

    unequipAllPets()

    local tribal =
        equipAmount(
            "Tribal Overlord",
            4
        )

    PetLabel.Text =
        "Pets: "
        .. tostring(tribal)
        .. "/4 Tribal Overlord"

    currentPhase =
        "Rebirth"
end

local function trainUntilReady()
    local target =
        getRequiredStrength()

    while running
        and Strength.Value < target do

        for _ = 1, 12 do
            if not running then
                break
            end

            muscleEvent:FireServer(
                "rep"
            )
        end

        task.wait(0.02)
    end
end

local function performRebirth()
    if not running then
        return
    end

    local target =
        getRequiredStrength()

    if Strength.Value < target then
        return
    end

    equipRebirthPets()

    task.wait(0.25)

    local oldRebirths =
        Rebirths.Value

    Status.Text =
        "Status: Rebirthing"

    repeat
        pcall(function()
            rebirthRemote:InvokeServer(
                "rebirthRequest"
            )
        end)

        task.wait(0.05)

    until Rebirths.Value > oldRebirths
        or not running
end

local function startWorker()
    if workerActive then
        return
    end

    workerActive = true

    task.spawn(function()
        while running do
            equipTrainingPets()

            trainUntilReady()

            if running then
                performRebirth()
            end

            task.wait(0.15)
        end

        currentPhase =
            "Inactive"

        Status.Text =
            "Status: Inactive"

        workerActive = false
    end)
end

RebirthTab:AddSwitch(
    "Fast Rebirth",
    function(state)
        running = state

        if state then
            Status.Text =
                "Status: Starting"

            startWorker()
        else
            Status.Text =
                "Status: Stopped"

            currentPhase =
                "Inactive"
        end
    end
):Set(false)

task.spawn(function()
    while task.wait(0.1) do
        local target =
            getRequiredStrength()

        StrengthLabel.Text =
            "Strength: "
            .. tostring(
                math.floor(
                    Strength.Value
                )
            )
            .. " / "
            .. tostring(
                math.floor(
                    target
                )
            )

        RebirthLabel.Text =
            "Rebirths: "
            .. tostring(
                Rebirths.Value
            )
    end
end)

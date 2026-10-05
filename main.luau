local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local rEvents = ReplicatedStorage:WaitForChild("rEvents")

local MuscleEvent =
    Player:FindFirstChild("muscleEvent")
    or ReplicatedStorage:WaitForChild("muscleEvent")

local EquipPetEvent = rEvents:WaitForChild("equipPetEvent")
local RebirthRemote = rEvents:WaitForChild("rebirthRemote")

local leaderstats = Player:WaitForChild("leaderstats")
local Strength = leaderstats:WaitForChild("Strength")
local Rebirths = leaderstats:WaitForChild("Rebirths")
local petsFolder = Player:WaitForChild("petsFolder")

local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title = "Muscle Legends",
    Author = "Fast Farm",
    Folder = "MuscleLegendsFastFarm",
    Size = UDim2.fromOffset(580, 520),
    ToggleKey = Enum.KeyCode.F,
    Transparent = true,
    Theme = "Dark"
})

local FarmTab = Window:Tab({
    Title = "Farming",
    Icon = "dumbbell"
})

local RebirthTab = Window:Tab({
    Title = "Rebirths",
    Icon = "repeat"
})

local fastFarm = false
local fastRebirth = false

local farmLoopRunning = false
local rebirthLoopRunning = false

local farmRPS = 654

local LIFT_BAR = CFrame.new(
    -2068.689208984375,
    176.39474487304688,
    4490.54052734375
)

local function getCharacter()
    return Player.Character
        or Player.CharacterAdded:Wait()
end

local function getRoot()
    return getCharacter():FindFirstChild(
        "HumanoidRootPart"
    )
end

local function teleport(cf)
    local root = getRoot()

    if root then
        root.CFrame = cf
    end
end

local function getPets(name)
    local pets = {}

    for _, folder in ipairs(
        petsFolder:GetChildren()
    ) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(
                folder:GetChildren()
            ) do
                if pet.Name:lower() == name:lower() then
                    table.insert(pets, pet)
                end
            end
        end
    end

    return pets
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
                    EquipPetEvent:FireServer(
                        "unequipPet",
                        pet
                    )
                end)
            end
        end
    end

    task.wait(0.15)
end

local function equipAmount(name, amount)
    local equipped = 0

    for _, pet in ipairs(
        getPets(name)
    ) do
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
        task.wait(0.04)
    end
end

local function equipTrainingPets()
    unequipAllPets()

    equipAmount("Mythic Boss Pet", 2)
    equipAmount("Epic Boss Pet", 3)
    equipAmount("Legendary Boss Pet", 1)
    equipAmount("Swift Samurai", 4)
end

local function equipRebirthPets()
    unequipAllPets()

    equipAmount("Tribal Overlord", 4)
end

local function requiredStrength()
    return 5000 + Rebirths.Value * 2550
end

local function findLiftPrompt()
    local closestPrompt = nil
    local closestDistance = 30

    for _, object in ipairs(
        workspace:GetDescendants()
    ) do
        if object:IsA("ProximityPrompt") then
            local part = nil

            if object.Parent
                and object.Parent:IsA("BasePart") then

                part = object.Parent

            elseif object.Parent
                and object.Parent:IsA("Attachment")
                and object.Parent.Parent
                and object.Parent.Parent:IsA("BasePart") then

                part = object.Parent.Parent
            end

            if part then
                local distance =
                    (
                        part.Position
                        - LIFT_BAR.Position
                    ).Magnitude

                if distance < closestDistance then
                    closestDistance = distance
                    closestPrompt = object
                end
            end
        end
    end

    return closestPrompt
end

local function useLiftBar()
    teleport(
        LIFT_BAR * CFrame.new(0, 2, 0)
    )

    task.wait(0.6)

    local prompt = findLiftPrompt()

    if prompt and fireproximityprompt then
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end

    task.wait(0.6)
end

local function sendReps(mode)
    local accumulator = 0
    local last = os.clock()

    while true do
        if mode == "farm" and not fastFarm then
            break
        end

        if mode == "rebirth" and not fastRebirth then
            break
        end

        if mode == "rebirth"
            and Strength.Value >= requiredStrength() then

            break
        end

        local now = os.clock()
        local delta = math.min(
            now - last,
            0.1
        )

        last = now

        accumulator += farmRPS * delta

        local amount =
            math.floor(accumulator)

        if amount > 0 then
            accumulator -= amount

            amount = math.min(
                amount,
                50
            )

            for _ = 1, amount do
                if mode == "farm"
                    and not fastFarm then

                    break
                end

                if mode == "rebirth"
                    and not fastRebirth then

                    break
                end

                pcall(function()
                    MuscleEvent:FireServer(
                        "rep"
                    )
                end)
            end
        end

        RunService.Heartbeat:Wait()
    end
end

local function doRebirth()
    if Strength.Value
        < requiredStrength() then

        return
    end

    equipRebirthPets()

    task.wait(0.25)

    local oldRebirths =
        Rebirths.Value

    local timeout =
        os.clock() + 8

    while fastRebirth
        and Rebirths.Value <= oldRebirths
        and os.clock() < timeout do

        pcall(function()
            RebirthRemote:InvokeServer(
                "rebirthRequest"
            )
        end)

        task.wait(0.08)
    end

    if fastRebirth then
        equipTrainingPets()

        task.wait(0.25)

        useLiftBar()
    end
end

local function startFarm()
    if farmLoopRunning then
        return
    end

    farmLoopRunning = true

    task.spawn(function()
        equipTrainingPets()

        if not fastFarm then
            farmLoopRunning = false
            return
        end

        useLiftBar()

        if fastFarm then
            sendReps("farm")
        end

        farmLoopRunning = false
    end)
end

local function startRebirth()
    if rebirthLoopRunning then
        return
    end

    rebirthLoopRunning = true

    task.spawn(function()
        equipTrainingPets()

        task.wait(0.25)

        useLiftBar()

        while fastRebirth do
            if Strength.Value
                >= requiredStrength() then

                doRebirth()
            else
                sendReps("rebirth")
            end

            task.wait(0.05)
        end

        rebirthLoopRunning = false
    end)
end

FarmTab:Input({
    Title = "Farm Speed",
    Desc = "Target reps per second",
    Value = "654",
    Placeholder = "654",
    Type = "Input",

    Callback = function(value)
        local number =
            tonumber(value)

        if number then
            farmRPS = math.clamp(
                math.floor(number),
                1,
                1000
            )
        end
    end
})

FarmTab:Toggle({
    Title = "Fast Farm",
    Desc = "2 Mythic + 3 Epic + 1 Legendary + 4 Swift",
    Value = false,

    Callback = function(value)
        fastFarm = value

        if value then
            startFarm()
        end
    end
})

RebirthTab:Toggle({
    Title = "Fast Rebirth",
    Desc = "Training Pets -> 4 Tribal Overlord -> Rebirth",
    Value = false,

    Callback = function(value)
        fastRebirth = value

        if value then
            startRebirth()
        end
    end
})

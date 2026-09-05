local Workspace = game:GetService("Workspace");
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");

local LocalPlayer = Players.LocalPlayer;

local CollisionSize = Vector3.new(0, 0, 0);
local HitboxSize = Vector3.new(80, 10, 80); -- Side-Pass Range for Combo & Points/Money
local TrafficSize = Vector3.new(0, 0, 0);

local CollisionParts = {
    TrafficCollisionFront = true,

    TrafficCollisionRear = true,

    TrafficCollisionLeft = true,

    TrafficCollisionRight = true
};

local HitboxParts = {
    TrafficHitboxLeft = true,

    TrafficHitboxRight = true
};

local VehicleData = nil;
local ModifiedParts = {};
local LastCar = nil;
local TrafficFolder = nil;
local TrafficDefaultSize = nil;

GetCar = function()

    local prefix = LocalPlayer.Name .. "_";

    for _, Object in pairs(Workspace:GetChildren()) do

        if Object:IsA("Model") and Object.Name:sub(1, #prefix) == prefix then
            return Object
        end;

    end;

    return nil

end;

ResizePart = function(Part, Size)

    if not Part or not Part.Parent then
        return
    end;

    if ModifiedParts[Part] == nil then

        local Success, OldSize = pcall(function()
            return Part.Size
        end);

        if Success and typeof(OldSize) == "Vector3" then
            ModifiedParts[Part] = OldSize;
        else
            ModifiedParts[Part] = false;
        end;

    end;

    pcall(function()
        Part.Size = Size;
    end);

end;

SetupCar = function(Car)

    if not Car then
        return
    end;

    local Body = Car:FindFirstChild("Body");

    if not Body then
        return
    end;

    local collisions = {};
    local hitboxes = {};

    for _, Object in pairs(Body:GetDescendants()) do

        if CollisionParts[Object.Name] then
            collisions[Object.Name] = Object;
        elseif HitboxParts[Object.Name] then
            hitboxes[Object.Name] = Object;
        end;

    end;

    VehicleData = {
        Model = Car,

        Collisions = collisions,

        Hitboxes = hitboxes
    };

    ModifiedParts = {};
    LastCar = Car;

end;

RestoreCar = function()

    for Part, OldSize in pairs(ModifiedParts) do

        if OldSize and Part and Part.Parent then

            pcall(function()
                Part.Size = OldSize;
            end);

        end;

    end;

    ModifiedParts = {};

end;

CheckCar = function()

    local Car = GetCar();

    if not Car then

        if LastCar then

            RestoreCar();

            VehicleData = nil;
            LastCar = nil;

        end;

        return

    end;

    if VehicleData and VehicleData.Model == Car then
        return
    end;

    if LastCar and LastCar ~= Car then
        RestoreCar();
    end;

    SetupCar(Car);

end;

local LastCheck = 0;

RunService.Heartbeat:Connect(function()

    local Now = tick();

    if Now - LastCheck >= 0.35 then

        LastCheck = Now;

        CheckCar();

    end;

    if VehicleData and VehicleData.Model and VehicleData.Model.Parent then

        for _, Part in pairs(VehicleData.Collisions) do
            ResizePart(Part, CollisionSize);
        end;

        for _, Part in pairs(VehicleData.Hitboxes) do
            ResizePart(Part, HitboxSize);
        end;

        if not TrafficFolder or not TrafficFolder.Parent then
            TrafficFolder = Workspace:FindFirstChild("TrafficFolder");
        end;

        if TrafficFolder then

            for _, Vehicle in pairs(TrafficFolder:GetChildren()) do

                local Hitbox = Vehicle:FindFirstChild("CoreHitbox");

                if Hitbox then

                    if not TrafficDefaultSize then

                        local Success, Size = pcall(function()
                            return Hitbox.Size
                        end);

                        if Success and typeof(Size) == "Vector3" then
                            TrafficDefaultSize = Size;
                        end;

                    end;

                    pcall(function()

                        Hitbox.Size = TrafficSize;
                        Hitbox.CanCollide = false;

                    end);

                end;

            end;

        end;

    end;

end);

print("Ready")

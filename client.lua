local currentFloor = 1

-- Asansör konumları ve hareket hızları
local function MoveElevator(targetFloor)
    local ped = PlayerPedId()
    local elevatorPos = Config.ElevatorLocations[targetFloor]
    
    -- Asansörün hareket etmesini simüle et
    TaskGoStraightToCoord(ped, elevatorPos.x, elevatorPos.y, elevatorPos.z, 1.0, -1, 0.0, 0.0)
    Citizen.Wait(5000) -- 5 saniye bekle (eğer hızlı hareket ediyorsa bu süreci ayarlayın)
    
    -- Kat değiştiğinde konumu güncelle
    currentFloor = targetFloor
end

-- Kullanıcının asansörü çağırabilmesi için tuş kontrolü
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        
        for i, location in ipairs(Config.ElevatorLocations) do
            local distance = Vdist(pedCoords.x, pedCoords.y, pedCoords.z, location.x, location.y, location.z)
            
            if distance < Config.ElevatorInteractionDistance then
                DrawText3D(location.x, location.y, location.z, "[E] - Call Elevator")
                
                if IsControlJustPressed(1, 38) then -- 'E' tuşuna basıldı
                    local targetFloor = (currentFloor % #Config.ElevatorLocations) + 1
                    MoveElevator(targetFloor)
                end
            end
        end
    end
end)

-- Ekranda 3D yazı göstermek için fonksiyon
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    local dist = Vdist(pX, pY, pZ, x, y, z)
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    
    if onScreen then
        SetTextScale(0.0, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
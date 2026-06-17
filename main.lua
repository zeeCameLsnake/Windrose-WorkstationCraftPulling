local UEHelpers = require("UEHelpers")

local ModName = "WorkstationCraftPulling"
local function Log(msg)
    print("[" .. ModName .. "] " .. tostring(msg))
end

-- Default radius, incase it can't be read from HearthVolume (approx. 50m)
local DEFAULT_SEARCH_RADIUS_SQ = 5000.0 * 5000.0

local running = false

local function UpdateWorkstationPulling()
    if not running then return end
    
    -- Execute the logic
    pcall(function()
        local bonfires = FindAllOf("R5BuildingBlock_BuildingCenter")
        local craftStations = FindAllOf("R5CraftStation")
        
        local numBonfires = bonfires and #bonfires or 0
        local numStations = craftStations and #craftStations or 0
        --  Log("Update Loop... Bonfires: " .. numBonfires .. ", Stations: " .. numStations)
        
        if bonfires and craftStations then
            for _, bonfire in ipairs(bonfires) do
                if bonfire and bonfire:IsValid() then
                    local okCenter, storageCenter = pcall(function() return bonfire.StorageCenter end)
                    if okCenter and storageCenter and storageCenter:IsValid() then
                        local okInv, inventoriesComp = pcall(function() return storageCenter.Inventories end)
                        if okInv and inventoriesComp and inventoriesComp:IsValid() then
                            local okViews, invViews = pcall(function() return inventoriesComp.InventoryViews end)
                            if okViews and type(invViews) == "userdata" then
                                
                                local okOwnerLoc, bonfireLoc = pcall(function() return bonfire:K2_GetActorLocation() end)
                                if okOwnerLoc and bonfireLoc then
                                    
                                    local radiusSq = DEFAULT_SEARCH_RADIUS_SQ
                                    pcall(function()
                                        local vol = storageCenter.HearthVolume
                                        if vol and vol:IsValid() then
                                            local radius = vol.SphereRadius
                                            if radius and radius > 0 then
                                                radiusSq = radius * radius
                                            end
                                        end
                                    end)
                                    
                                    local addedCount = 0
                                    for _, station in ipairs(craftStations) do
                                        if station and station:IsValid() then
                                            local okStatLoc, statLoc = pcall(function() return station:K2_GetActorLocation() end)
                                            if okStatLoc and statLoc then
                                                local dx = statLoc.X - bonfireLoc.X
                                                local dy = statLoc.Y - bonfireLoc.Y
                                                local dz = statLoc.Z - bonfireLoc.Z
                                                local distSq = dx*dx + dy*dy + dz*dz
                                                
                                                if distSq <= radiusSq then
                                                    local okView, view = pcall(function() return station:GetInventoryView() end)
                                                    if okView and view and view:IsValid() then
                                                        local exists = false
                                                        
                                                        -- Safe array check without UE4SS TArray special functions
                                                        pcall(function()
                                                            local targetAddr = view:GetAddress()
                                                            local len = #invViews
                                                            for i = 1, len do
                                                                local curView = invViews[i]
                                                                if curView and curView:IsValid() then
                                                                    if curView:GetAddress() == targetAddr then
                                                                        exists = true
                                                                        break
                                                                    end
                                                                end
                                                            end
                                                        end)
                                                        
                                                        if not exists then
                                                            -- Added via normal # operator
                                                            local success = false
                                                            pcall(function()
                                                                invViews[#invViews + 1] = view
                                                                success = true
                                                            end)
                                                            
                                                            if success then
                                                                addedCount = addedCount + 1
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    if addedCount > 0 then
                                        Log("Added " .. addedCount .. " station inventories to Bonfire network!")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Reschedule (2 seconds interval is resource-saving)
    ExecuteWithDelay(2000, UpdateWorkstationPulling)
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function(Context)
    if not running then
        running = true
        Log("ClientRestart hooked. Starting workstation update loop...")
        ExecuteWithDelay(3000, UpdateWorkstationPulling)
    end
end)

-- Manual start/stop via console (F10 -> "togglepull") for debugging
RegisterConsoleCommandHandler("togglepull", function(FullCommand, Parameters)
    running = not running
    Log("Workstation Pulling is now: " .. tostring(running))
    if running then
        UpdateWorkstationPulling()
    end
    return true
end)

Log("Initialized.")

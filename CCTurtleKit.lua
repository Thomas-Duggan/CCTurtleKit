--- CCTurtleKit  Copyright (c) 2026 Thomas Duggan 
--- This work is licenced under CC BY-SA 4.0 

--- TO FiX:
--- mineTree() does not account for multiple branches on the same Z level
--- Make sure refuel on start works as expected
--- ADD note about mathimatical coordinate system
--- Finish sweep (rename vacumn to sweep) function

-------------- Preamble --------------
local t = turtle ---redefinition
local sh = shell ---redefiniton
local fctnList = {} ---module table for importing

currentX = 0 ---relative coordinates of turtle (use overloaded movement functions, or they will not work correctly)
currentY = 0 
currentZ = 0
currentDirection = "+y"

backupX = 0 ---updatible relative coordinates of turtle
backupY = 0 
backupZ = 0
backupDirection = "+y"

-------------- Status and Refueling --------------
fctnList.disableOperationMessage = false ---Status can be disable if you want
if fctnList.disableOperationMessage == false then
    shell.run('clear')
    local id = os.getComputerID()
    print("Computer #"..id.." is currently operating")
    print("(Hold CTRL+T stop operation)")
end

ftcnList.disableRefuelOnStart = false
if fctnList.disableRefuelOnStart == false then
    shell.run('refuels')
end

-------------- Overloaded Movement Functions --------------
function fctnList.up() ---these must be used in replacement of default movement functions in order for returnHome to work properly
    t.up()
    currentZ = currentZ + 1
end                   

function fctnList.down()
    t.down()
    currentZ = currentZ - 1
end

function fctnList.forward()
    t.forward()
    if currentDirection == "+x" then
        currentX = currentX + 1
    elseif currentDirection == "-y" then
        currentY = currentY - 1
    elseif currentDirection == "-x" then
        currentX = currentX - 1
    elseif currentDirection == "+y" then
        currentY = currentY + 1
    end
end

function fctnList.back()
    t.back()
    if currentDirection == "+x" then
        currentX = currentX - 1
    elseif currentDirection == "-y" then
        currentY = currentY + 1
    elseif currentDirection == "-x" then
        currentX = currentX + 1
    elseif currentDirection == "+y" then
        currentY = currentY - 1
    end
end

function fctnList.turnRight()
    t.turnRight()
    if currentDirection == "+x" then
        currentDirection = "+y"
    elseif currentDirection == "+y" then
        currentDirection = "-x"
    elseif currentDirection == "-x" then
        currentDirection = "-y"
    elseif currentDirection == "-y" then
        currentDirection = "+x"
    end
end

function fctnList.turnLeft()
    t.turnLeft()
    if currentDirection == "+x" then
        currentDirection = "-y"
    elseif currentDirection == "-y" then
        currentDirection = "-x"
    elseif currentDirection == "-x" then
        currentDirection = "+y"
    elseif currentDirection == "+y" then
        currentDirection = "+x"
    end
end

-------------- Functions --------------
function fctnList.fuelCheck(fuelMinimum, fuelSlots)

    ---Failsafes
    if type(fuelSlots) ~= "table" then
        fuelSlots = {15, 16} ---last 2
    end

    if type(fuelMinimum) ~= "number" then
        fuelMinimum = 100 
    end

    ---Logic
    local fuel = t.getFuelLevel()
    if fuel <= fuelMinimum then
        local previousSlot = t.getSelectedSlot() ---saves previous slot
        
        for i=1, #fuelSlots do
            local fuelAmount = t.getItemCount(fuelSlots[i])
            if fuelAmount ~= 0 then ---not equal to 0
                t.select(fuelSlots[i])
                while t.getFuelLevel() < t.getFuelLimit() do
                    t.refuel()
                end
                t.select(previousSlot)
                return true
            end
        end
        return false
    end
end

function fctnList.mineSquare(width, height, direction)
    
    local cctk = fctnList

    ---Failsafes
    if type(height) ~= "number" or height % 2 ~= 0 then
        height = 2
    end

    if type(width) ~= "number" then
        width = 1
    end

    if type(direction) ~= "string" then
        direction = "left"
    end

    local otherDirection
    if direction == "left" then
        otherDirection = "right"
    elseif direction == "right" then
        otherDirection = "left"
    end

    ---Helper Function
    local function mineWidth(direction, _width)
        if direction == "left" then
            for i=1, _width do
                t.turnLeft()
                t.dig()
                t.forward()
                t.turnRight()
                t.dig()
            end
        elseif direction == "right" then
            for i=1, _width do
                t.turnRight()
                t.dig()
                t.forward()
                t.turnLeft()
                t.dig()
            end
        end
    end

    ---Logic
    t.dig()
    t.digUp()
    for i=1, height-2 do
        t.up()
        t.dig()
        t.digUp()
    end
    t.up()
    t.dig()

    mineWidth(direction, width-1) --first block is mined out already
    t.digDown()
    t.down()
    t.dig()
    mineWidth(otherDirection, width-2) --first column is disregarded and first block is mined out already

    for i=1, math.floor(height/2)-1 do
        t.digDown()
        t.down()
        t.dig()
        mineWidth(direction, width-2)
        t.digDown()
        t.down()
        t.dig()
        mineWidth(otherDirection, width-2)
    end
    if width ~= 1 then
        if direction == "left" then
            t.turnRight()
            t.forward()
            t.turnLeft()
        elseif direction == "right" then
            t.turnLeft()
            t.forward()
            t.turnRight()
        end
    end
end

function fctnList.mineTree(replant)

    local cctk = fctnList

    ---Failsafe
    if type(replant) ~= "boolean" then
        replant = false
    end

    ---Initial position
    local xOffset = 0 ---front and back
    local yOffset = 0 ---left and right
    local zOffset = 0 ---up and down
    local direction = "+y"

    ---Movement Function Overloads
    local function up()
        t.digUp()
        cctk.up()
        zOffset = zOffset + 1
    end

    local function down()
        t.digDown()
        cctk.down()
        zOffset = zOffset - 1
    end

    local function forward()
        t.dig()
        cctk.forward()
        if direction == "+x" then
            xOffset = xOffset + 1
        elseif direction == "-y" then
            yOffset = yOffset - 1
        elseif direction == "-x" then
            xOffset = xOffset - 1
        elseif direction == "+y" then
            yOffset = yOffset + 1
        end
    end

    local function turnRight()
        cctk.turnRight()
        if direction == "+x" then
            direction = "+y"
        elseif direction == "+y" then
            direction = "-x"
        elseif direction == "-x" then
            direction = "-y"
        elseif direction == "-y" then
            direction = "+x"
        end
    end

    local function turnLeft()
        cctk.turnLeft()
        if direction == "+x" then
            direction = "-y"
        elseif direction == "-y" then
            direction = "-x"
        elseif direction == "-x" then
            direction = "+y"
        elseif direction == "+y" then
            direction = "+x"
        end
    end

    ---Helper Functions
    local function lookingAtLog(direction) ---Accepts: "front", "down", "up"

        if direction == "front" then
            success, block = t.inspect()
        end
        if direction == "down" then
            success, block = t.inspectDown()
        end
        if direction == "up" then
            success, block = t.inspectUp()
        end

        if success and string.find(block.name,"log") then
            return true
        else
            return false
        end  
    end

    local trunkXOffset = 0
    local trunkYOffset = 0
    local function goToTrunk()

        if yOffset < trunkYOffset then
            while direction ~= "+y" do
                turnRight()
            end
            while yOffset < trunkYOffset do
                t.dig()
                forward()
            end
        elseif yOffset > trunkYOffset then
            while direction ~= "-y" do
                turnRight()
            end
            while yOffset > trunkYOffset do
                t.dig()
                forward()
            end
        end

        if xOffset < trunkXOffset then
            while direction ~= "+x" do
                turnRight()
            end
            while xOffset < trunkXOffset do
                t.dig()
                forward()
            end
        elseif xOffset > trunkXOffset then
            while direction ~= "-x" do
                turnRight()
            end
            while xOffset > trunkXOffset do
                t.dig()
                forward()
            end
        end

        while zOffset ~= 0 do
            t.digDown()
            down()
        end      
    end

    local branchZValues = {}
    local rotations = 0
    local function scan(memory) ---Accepts: true or false

        if lookingAtLog("front") == true and memory == true then
            branchZValues[#branchZValues+1] = zOffset
            rotations = 0
            return true

        elseif lookingAtLog("front") == true and memory == false then
            rotations = 0
            return true

        else
            turnRight()
            rotations = rotations +1
            if rotations >= 4 then
                rotations = 0
                return false
            else
                scan(memory)
            end
        end            
    end

    local function branchRemover()
        if lookingAtLog("up") == true then
            t.digUp()
            up()
            branchRemover()
        elseif lookingAtLog("front") == true then
            t.dig()
            forward()
            branchRemover()
        else
            t.digUp()
            up()
            if lookingAtLog("front") == true then
                branchRemover()
            else
                return
            end
        end
    end

    ---Logic 
    if lookingAtLog("front") then
        t.dig()
        forward()
        trunkXOffset = xOffset
        trunkYOffset = yOffset

        while lookingAtLog("up") do ---removes the main trunk
            t.digUp()
            up()
            scan(true)
        end
        t.digUp() ---checks one block above trunk for acacia trees
        up()
        scan(true)

        goToTrunk()
        
        for i=1, #branchZValues do ---removes branches
            for i=1, branchZValues[i] do
                up()
            end
            scan(false)
            branchRemover()
            goToTrunk()
        end
        while direction ~= "+y" do
            turnLeft()
        end
        t.back()
    end

    if replant == true then
        success, block = t.inspect()
        if success ~= true then
            previousSlot = t.getSelectedSlot()
            for i=1, 16 do
                item = t.getItemDetail(i)
                if item ~= nil then
                    if string.find(item.name,"sapling") then
                        t.select(i)
                        t.place()
                        t.select(previousSlot)
                        break
                    end
                end
            end
        elseif string.find(block.name,"sapling") then
            previousSlot = t.getSelectedSlot()
            for i=1, 16 do
                item = t.getItemDetail(i)
                if item ~= nil then
                    if string.find(item.name,"bone_meal") then
                        t.select(i)
                        while lookingAtLog("front") == false do
                            t.place()
                        end
                        t.select(previousSlot)
                        break
                    end
                end
            end
        end
    end
end

function fctnList.store(slots)

    backupDirection = currentDirection

    ---Failsafe
    if type(slots) ~= "table" then
        slots = {1,  2,  3,  4, ---All but last 2 slots
                 5,  6,  7,  8,
                 9,  10, 11, 12,
                 13, 14} 
    end

    ---Helper Function
    local previousSlot = t.getSelectedSlot() ---saves previous slot
    local rotations = 0
    local function doTheThing()

        success, block = t.inspect()

        if success and string.find(block.name,"chest") then
            for i=1, #slots do
                t.select(slots[i])
                local item = t.getItemDetail()
                if item ~= nil then
                    t.drop(item.count)
                end
            end
            t.select(previousSlot)
            while currentDirection ~= backupDirection do
                fctnList.turnLeft()
            end
            return
        else
            rotations = rotations +1
            if rotations <= 4 then
                fctnList.turnRight()
                doTheThing()
            else
                while currentDirection ~= backupDirection do
                    fctnList.turnLeft()
                end
                return
            end
        end  
    end

    ---Logic
    doTheThing()
end

function fctnList.returnHome()

    ---Logic
    backupX = currentX
    backupY = currentY
    backupZ = currentZ
    backupDirection = currentDirection

    if currentY < 0 then
        while currentDirection ~= "+y" do
            fctnList.turnRight()
        end
        while currentY < 0 do
            t.dig()
            fctnList.forward()
        end
    elseif currentY > 0 then
        while currentDirection ~= "-y" do
            fctnList.turnRight()
        end
        while currentY > 0 do
            t.dig()
            fctnList.forward()
        end
    end

    if currentX < 0 then
        while currentDirection ~= "+x" do
            fctnList.turnRight()
        end
        while currentX < 0 do
            t.dig()
            fctnList.forward()
        end
    elseif currentX > 0 then
        while currentDirection ~= "-x" do
            fctnList.turnRight()
        end
        while currentX > 0 do
            t.dig()
            fctnList.forward()
        end
    end

    while currentZ ~= 0 do
        t.digDown()
        fctnList.down()
    end 

    while currentDirection ~= "+y" do
        fctnList.turnLeft()
    end
end

function fctnList.backToWork()

    ---Logic
    if currentY < backupY then
        while currentDirection ~= backupDirection do
            fctnList.turnRight()
        end
        while currentY < backupY do
            t.dig()
            fctnList.forward()
        end
    elseif currentY > backupY then
        while currentDirection ~= backupDirection do
            fctnList.turnRight()
        end
        while currentY > backupY do
            t.dig()
            fctnList.forward()
        end
    end

    if currentX < backupX then
        while currentDirection ~= backupDirection do
            fctnList.turnRight()
        end
        while currentX < backupX do
            t.dig()
            fctnList.forward()
        end
    elseif currentX > backupX then
        while currentDirection ~= backupDirection do
            fctnList.turnRight()
        end
        while currentX > backupX do
            t.dig()
            fctnList.forward()
        end
    end

    while currentZ ~= backupZ do
        t.digDown()
        fctnList.down()
    end 

    while currentDirection ~= backupDirection do
        fctnList.turnLeft()
    end
end

function fctnList.storageFull(slots)

    ---Failsafe
    if type(slots) ~= "table" then
        slots = {1,  2,  3,  4, ---All but bottom 4 slots
                 5,  6,  7,  8,
                 9,  10, 11, 12,
                 13, 14} 
    end

    ---Logic
    local slotsFull = 0
    local previousSlot = t.getSelectedSlot() ---saves previous slot

    for i=1, #slots do
        t.select(slots[i])
        local item = t.getItemDetail()
        if item ~= nil then
            slotsFull = slotsFull +1
        end
    end
    if slotsFull == #slots then
        t.select(previousSlot)
        return true
    else
        t.select(previousSlot)
        return false
    end      
end

return fctnList

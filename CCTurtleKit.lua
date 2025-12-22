--- CCTurtleKit  Copyright (c) 2026 Thomas Duggan 
--- This work is licenced under CC BY-SA 4.0 

-------------- Preamble --------------
local t = turtle ---redefinition
local sh = shell ---redefiniton
local fctnList = {} ---module table for importing


-------------- Aliases --------------
sh.setAlias('c','clear')
sh.setAlias('q','exit')
sh.setAlias('h','help')
sh.setAlias('r','reboot')
sh.setAlias('e','edit')
sh.setAlias('man','help')
sh.setAlias('xed','edit')
sh.setAlias('vim','edit')

-------------- Functions --------------
function fctnList.fuelCheck(fuelMinimum, fuelSlots)

    ---Default Values
    fuelMinimum = fuelMinimum or 100
    fuelSlots = fuelSlots or {13, 14, 15, 16} --bottom 4 slots

    ---Failsafes
    if type(fuelSlots) ~= "table" then
        fuelSlots = {13, 14, 15, 16}
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
                break
            end
        end
    end
end

function fctnList.mineSquare(width, height, direction)

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

function fctnList.mineTree()

    ---Initial position
    local xOffset = 0 ---front and back
    local yOffset = 0 ---left and right
    local zOffset = 0 ---up and down
    local direction = "+x"

    ---Helper Functions
    local function lookingAtLog(direction)

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

    local function up()
        t.up()
        zOffset = zOffset + 1
    end

    local function down()
        t.down()
        zOffset = zOffset - 1
    end

    local function turnRight()
        t.turnRight()
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
        t.turnLeft()
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

    local function forward()
        t.forward()
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

    local function backward()
        t.backward()
        if direction == "+x" then
            xOffset = xOffset - 1
        elseif direction == "-y" then
            yOffset = yOffset + 1
        elseif direction == "-x" then
            xOffset = xOffset + 1
        elseif direction == "+y" then
            yOffset = yOffset - 1
        end
    end

    branchZValues = {}
    rotations = 0
    local function scan(memory)

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
            if rotations >= 3 then
                rotations = 0
                return true
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
        elseif scan(false) == true then
            t.dig()
            forward()
            branchRemover()
        else
            return
        end
    end


    ------------------- Logic -------------------
    local trunkXValue = 0
    local trunkYValue = 0
    local trunkTop = 0

    if lookingAtLog("front") == true then
        t.dig()
        forward()
        trunkXValue = xOffset
        trunkYValue = yOffset
        t.digUp()
        up()
        t.digUp()
        up()
    end

    while lookingAtLog("up") == true do
        scan(true)
        t.digUp()
        up()
    end
    scan(true)
    trunkTop = zOffset
    for i=#branchZValues, 1, -1  do 
        local goal = branchZValues[i]
        
        while zOffset ~= goal do
            down()
        end

        branchRemover()

        sleep(10)

        if xOffset > trunkXValue then
            while direction ~= "-x" do
                turnRight()
            end
            while xOffset > trunkXValue do
                t.dig()
                forward()
            end

        elseif xOffset < trunkXValue then
            while direction ~= "+x" do
                turnRight()
            end
            while xOffset < trunkXValue do
                t.dig()
                forward()
            end
        end

        
        if yOffset > trunkYValue then
            while direction ~= "-Y" do
                turnRight()
            end
            while yOffset > trunkYValue do
                t.dig()
                forward()
            end

        elseif yOffset < trunkYValue then
            while direction ~= "+y" do
                turnRight()
            end
            while yOffset < trunkYValue do
                t.dig()
                forward()
            end
        end

        while zOffset < trunkTop do up() end
        while zOffset > trunkTop do down() end    
    end        

    for i = 1, zOffset do
        down()
    end

    while direction ~= "+x" do
        t.turnRight()
    end
    if trunkXValue == 1 then
        backward()
    elseif trunkXValue == -1 then
        forward()
    elseif trunkYValue == 1 then
        t.turnRight()
        backward()
        t.turnLeft()
    elseif trunkYValue == -1 then
        t.turnRight()
        forward()
        t.turnLeft()
        t.turnLeft()
    end
    
    print(true)
end

return fctnList

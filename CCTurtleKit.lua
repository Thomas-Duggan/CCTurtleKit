--- CCTurtleKit  Copyright (c) 2026 Thomas Duggan 
--- This work is licenced under CC BY-SA 4.0 

--- To Fix:
--- mineTree() does not account for multiple branches on the same Z level
--- Make sure refuel on start works as expected
--- Finish sweep (rename vacumn to sweep) function

-------------- Preamble --------------
local t = turtle ---redefinition
local sh = shell ---redefiniton
local cctk = {} ---module table for importing


currentX = 0 ---relative coordinates of turtle (use overloaded movement functions, or they will not work correctly)
currentY = 0 
currentZ = 0
currentDirection = "+y"

backupX = 0 ---stored relative coordinates of turtle for returning to the value
backupY = 0 
backupZ = 0
backupDirection = "+y"

--- Please note that my coordiate system uses the mathematical standard, where:
---     +X = right    -X = left
---     +Y = forward  -Y = backward
---     +Z = up       -Z = down
--- More importantly, this is NOT the Minecraft standard and may require getting used to if not familiar with it.

-------------- Status Information --------------

shell.run('clear')
local id = os.getComputerID()
print("Computer #"..id.." is currently operating")
print("(Hold CTRL+T stop operation)")


if fs.exists("/rom/programs/refuel") then
    shell.run('refuel')
end

-------------- Overloaded Movement Functions --------------
function cctk.up() ---these must be used in replacement of default movement functions in order for returnHome to work properly
    if t.inspectUp() == false then
        t.up()
        currentZ = currentZ + 1
        return true
    end
    return false
end                   

function cctk.down()
    if t.inspectDown() == false then
        t.down()
        currentZ = currentZ - 1
        return true
    end
    return false
end

function cctk.forward()
    if t.inspect() == false then
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
        return true
    end
    return false
end

function cctk.back()
    cctk.turnRight()
    cctk.turnRight()
    if t.inspect() == false then
        cctk.turnRight()
        cctk.turnRight()
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
        return true
    end
    cctk.turnRight()
    cctk.turnRight()
    return false
end

function cctk.turnRight()
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
    return true
end

function cctk.turnLeft()
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
    return true
end

-------------- Functions --------------
function cctk.fuelCheck(fuelMinimum, fuelSlots)

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

function cctk.mineTunnel(width, height, direction)
    
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
                cctk.turnLeft()
                t.dig()
                cctk.forward()
                cctk.turnRight()
                t.dig()
            end
        elseif direction == "right" then
            for i=1, _width do
                cctk.turnRight()
                t.dig()
                cctk.forward()
                cctk.turnLeft()
                t.dig()
            end
        end
    end

    ---Logic
    t.dig()
    t.digUp()
    for i=1, height-2 do
        cctk.up()
        t.dig()
        t.digUp()
    end
    cctk.up()
    t.dig()

    mineWidth(direction, width-1) --first block is mined out already
    t.digDown()
    cctk.down()
    t.dig()
    mineWidth(otherDirection, width-2) --first column is disregarded and first block is mined out already

    for i=1, math.floor(height/2)-1 do
        t.digDown()
        cctk.down()
        t.dig()
        mineWidth(direction, width-2)
        t.digDown()
        cctk.down()
        t.dig()
        mineWidth(otherDirection, width-2)
    end
    if width ~= 1 then
        if direction == "left" then
            cctk.turnRight()
            cctk.forward()
            cctk.turnLeft()
        elseif direction == "right" then
            cctk.turnLeft()
            cctk.forward()
            cctk.turnRight()
        end
    end
    cctk.forward()
end

function cctk.mineQuarry(rows, columns, side)

    ---Failsafes
    if type(rows) ~= "number" then
        rows = 1
    end

    if type(columns) ~= "number" then
        columns = 1
    end

    if type(side) ~= "string" then ---Accepts: "left" and "right"
        side = "left"
    end

    ---Helper Functions
    local function turn(side, otherSide)

        if side == "left" and otherSide == false then
            cctk.turnLeft()
        elseif side == "left" and otherSide == true then
            cctk.turnRight()

        elseif side == "right" and otherSide == false then
            cctk.turnRight()
        elseif side == "right" and otherSide == true then
            cctk.turnLeft()
        end
    end

    local function dig()

        t.dig()
        t.digDown()
        cctk.forward()
        t.digDown()
    end

    ---Logic
    for i=1, columns-1 do ---first column
        dig()
    end 
    turn(side, false)

    for i=1, rows-1 do ---first row
        dig()
    end
    turn(side, false)

    for i=1, rows-1 do ---for each column;

        for i=1, columns-1 do ---mines column down from where it is
            dig()
        end

        cctk.turnRight() cctk.turnRight() --- rotates 180

        for i=1, columns-1 do ---Goes back up to the top row
            cctk.forward()
        end

        turn(side, true) ---moves to the next column
        cctk.forward()
        turn(side, true)
    end

    for i=1, columns-1 do
        cctk.forward()
    end

    cctk.turnRight() cctk.turnRight() --- rotates 180

    cctk.down()

end

function cctk.mineTree(replant)

    ---Local Global Variables
    backupX = currentX
    backupY = currentY
    backupZ = currentZ
    backupDirection = currentDirection
    local trunkXOffset = 0
    local trunkYOffset = 0

    ---Failsafe
    if type(replant) ~= "boolean" then
        replant = false
    end

    ---Helper Functions
    local success = nil
    local block = nil
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

    local function goToTrunk()

        if currentY < trunkYOffset then
            while currentDirection ~= "+y" do
                cctk.turnRight()
            end
            while currentY < trunkYOffset do
                t.dig()
                cctk.forward()
            end

        elseif currentY > trunkYOffset then
            while currentDirection ~= "-y" do
                cctk.turnRight()
            end
            while currentY > trunkYOffset do
                t.dig()
                cctk.forward()
            end
        end

        
        if currentX < trunkXOffset then
            while currentDirection ~= "+x" do
                cctk.turnRight()
            end
            while currentX < trunkXOffset do
                t.dig()
                cctk.forward()
            end

        elseif currentX > trunkXOffset then
            while currentDirection ~= "-x" do
                cctk.turnRight()
            end
            while currentX > trunkXOffset do
                t.dig()
                cctk.forward()
            end
        end


        while currentZ ~= backupZ do
            t.digDown()
            cctk.down()
        end      
    end

    local branchZValues = {}
    local rotations = 0
    local function scan(memory) ---Accepts: true or false

        if lookingAtLog("front") == true and memory == true then
            branchZValues[#branchZValues+1] = currentZ
            rotations = 0
            return true

        elseif lookingAtLog("front") == true and memory == false then
            rotations = 0
            return true

        else
            cctk.turnRight()
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
            cctk.up()
            branchRemover()
        elseif lookingAtLog("front") == true then
            t.dig()
            cctk.forward()
            branchRemover()
        else
            t.digUp()
            cctk.up()
            if lookingAtLog("front") == true then
                branchRemover()
            else
                return
            end
        end
    end

    ---Logic 
    if lookingAtLog("front") == true then
        t.dig()
        cctk.forward()
        trunkXOffset = currentX
        trunkYOffset = currentY

        while lookingAtLog("up") do ---removes the main trunk
            t.digUp()
            cctk.up()
            scan(true)
        end
        t.digUp() ---checks one block above trunk for acacia trees
        cctk.up()
        scan(true)

        goToTrunk()
        
        for i=1, #branchZValues do ---removes branches
            for i=1, branchZValues[i] do
                cctk.up()
            end
            scan(false)
            branchRemover()
            goToTrunk()
        end
        while currentDirection ~= "+y" do
            cctk.turnLeft()
        end
        cctk.back()
    end

    if replant == true then

        local success, block = t.inspect()

        if success == false then
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
        elseif success == true and string.find(block.name,"sapling") then
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

function cctk.store(slots)

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

        local success, block = t.inspect()

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
                cctk.turnLeft()
            end
            return
        else
            rotations = rotations +1
            if rotations <= 4 then
                cctk.turnRight()
                doTheThing()
            else
                while currentDirection ~= backupDirection do
                    cctk.turnLeft()
                end
                return
            end
        end  
    end

    ---Logic
    doTheThing()
end

function cctk.returnHome()

    ---Logic
    backupX = currentX
    backupY = currentY
    backupZ = currentZ
    backupDirection = currentDirection

    if currentY < 0 then
        while currentDirection ~= "+y" do
            cctk.turnRight()
        end
        while currentY < 0 do
            t.dig()
            cctk.forward()
        end
    elseif currentY > 0 then
        while currentDirection ~= "-y" do
            cctk.turnRight()
        end
        while currentY > 0 do
            t.dig()
            cctk.forward()
        end
    end

    if currentX < 0 then
        while currentDirection ~= "+x" do
            cctk.turnRight()
        end
        while currentX < 0 do
            t.dig()
            cctk.forward()
        end
    elseif currentX > 0 then
        while currentDirection ~= "-x" do
            cctk.turnRight()
        end
        while currentX > 0 do
            t.dig()
            cctk.forward()
        end
    end

    while currentZ ~= 0 do
        t.digDown()
        cctk.down()
    end 

    while currentDirection ~= "+y" do
        cctk.turnLeft()
    end
end

function cctk.backToWork()

    ---Logic
    if currentY < backupY then
        while currentDirection ~= backupDirection do
            cctk.turnRight()
        end
        while currentY < backupY do
            t.dig()
            cctk.forward()
        end
    elseif currentY > backupY then
        while currentDirection ~= backupDirection do
            cctk.turnRight()
        end
        while currentY > backupY do
            t.dig()
            cctk.forward()
        end
    end

    if currentX < backupX then
        while currentDirection ~= backupDirection do
            cctk.turnRight()
        end
        while currentX < backupX do
            t.dig()
            cctk.forward()
        end
    elseif currentX > backupX then
        while currentDirection ~= backupDirection do
            cctk.turnRight()
        end
        while currentX > backupX do
            t.dig()
            cctk.forward()
        end
    end

    while currentZ ~= backupZ do
        t.digDown()
        cctk.down()
    end 

    while currentDirection ~= backupDirection do
        cctk.turnLeft()
    end
end

function cctk.storageFull(slots)

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

function cctk.vacumn(X,Y,spin) ---UNFINISHED

    ---Failsafes
    if type(X) ~= "number" then
        height = 0
    end

    if type(Y) ~= "number" then
        width = 0
    end

    if type(Y) ~= "bool" then
        width = true
    end

    ---Logic
    backupX = currentX
    backupY = currentY
    backupDirection = currentDirection

    while currentY <= Y do
        cctk.forward()
    end
end

function cctk.jukebox(folderName) ---HIGHLY ESOTERIC. READ DOCUMENTATION: https://github.com/Thomas-Duggan/CCTurtleKit/tree/main

    ---Local Global Variables
    local dataFile = "df.txt" 

    local songs = {}
    local songLength = -1

    local songID = -1
    local nextSongID = -1


    ---Failsafes
    if type(folderName) ~= "string" then
        folderName = "music"
    end


    ---Helper Functions
    local function play(song)
        local speaker = peripheral.find("speaker")

        print(speaker)
        if speaker ~= nil then
            shell.run("speaker play "..folderName.."/"..song)
        else
            shell.run("clear")
            print("SPEAKER NOT CONNECTED")
        end
    end

    local function handleInput(song)
        shell.run('clear')
        print("Playing: "..song)
        print()
        print("Options:")
        print()
        print("   n: Next song        r: Repeat current song")
        print()
        print("   s: Stop playback    q: Queue specific song")
        print()
        print()
        print("   g: Get all available songs (requires Printer)")
        print()
        print("   e: Exit to terminal")
        print()
        print()
        write("Awaiting letter > ")
        while true do
            local input = read()


            if input == "n" then --- Next Song
                    os.reboot()

            elseif input == "r" then --- queue current song
                local file = fs.open(dataFile,"w") 
                file.write(songID)
                file.close()
                nextSongID = songID
                print(" Current song queued!")
                sleep(1)
                handleInput(song)

            elseif input == "s" then --- Stop playback
                local monitor = peripheral.find("monitor")
                monitor.clear()
                monitor.setCursorPos(99,99)
                os.shutdown()
                
            elseif input == "q" then --- Queue specific song
                print()
                print("Song IDs available from 'g' command")
                print("Enter nothing to cancel")
                print()
                write("Enter Song ID > ")
                input = read()
                if input ~= "" then
                    nextSongID = tonumber(input)

                    local file = fs.open(dataFile,"w") ---Writes next song to file
                    file.write(nextSongID)
                    file.close()
                end

                handleInput(song)

            elseif input == "g" then --- Get all available songs
                print(" Printing")
                local printer = peripheral.find("printer")
                printer.newPage()
                local line = 1
                for i = 1, #songs do
                    printer.setCursorPos(1,line)
                    printer.write(i)
                    printer.write(". ")
                    printer.write(songs[i])    
                    line = line +1
                
                    if i%21 == 0 then
                        printer.newPage()
                        line = 1  
                    end
                end
                sleep(1)
                print(" Done!")
                sleep(0.5)
                handleInput(song)
            
            elseif input == "e" then --- exit to terminal
                shell.run("clear")
                print("Reboot to continue listening.")
                print("(Your queue has been saved)")
                print()
                print("      --======= DISREGARD ERROR: =======--")
                jukebox.closed() --FAKE FUNCTION that fails at runtime, forcing the terminal to open

            else
                print(" Input unknown")
                sleep(1)
                handleInput(song)
            end
        end
    end

    local function display(song, songLength)
        local monitor = peripheral.find("monitor")
        if monitor ~= nil then

            local cursorY = 1
            local splicedSongName = {}
            local minutesTotal = math.floor(songLength / 60)
            local secondsTotal = math.floor(songLength % 60)

            local function mPrint(text)
                monitor.setCursorPos(1, cursorY)
                monitor.write(text)
                cursorY = cursorY + 1
            end

            monitor.clear()

            for i=1, #song do                
                splicedSongName[i] = song:sub(i,i)
            end
            for i = 1, 6 do
                table.remove(splicedSongName, #splicedSongName)
            end
            splicedSongName[#splicedSongName+1] = ' '

            for timeElapsed = 1, (songLength +6)*2 do
                local progressRatio = (timeElapsed/2)/songLength
                local minutesElapsed = math.floor((timeElapsed/2) / 60)
                local secondsElapsed = math.floor((timeElapsed/2) % 60)

                local partitions = {}
                local step = songLength / 20
                for i = 1, 20 do
                    table.insert(partitions, math.floor(i * step))
                end

                mPrint("")
                monitor.setCursorPos(1, cursorY)
                for i=1, #splicedSongName do
                    monitor.write(splicedSongName[i])
                end
                cursorY = cursorY + 1
                mPrint("")
                mPrint("")
                mPrint(
                    minutesElapsed..":"..(secondsElapsed < 10 and "0" .. secondsElapsed or secondsElapsed)
                    .."                     "..
                    minutesTotal..":"..(secondsTotal < 10 and "0" .. secondsTotal or secondsTotal)
                )
                mPrint("")
                mPrint(string.rep("#", progressRatio*30)..string.rep("-", 30-progressRatio*30))
                mPrint("") 
                mPrint("") 
                mPrint("")
                mPrint("")
                mPrint("Up next: "..songs[nextSongID])

                if #splicedSongName > 30 then
                    local first = table.remove(splicedSongName, 1) --shifts song name to imitate scrolling
                    table.insert(splicedSongName, first)
                end
                
                cursorY = 1
                sleep(0.5)
            end
        else
            sleep(songLength)
        end
        cctk.music(folderName)
    end


    ---Logic
    shell.run("clear")

    for i, file in ipairs(fs.list(folderName)) do ---Saves songs + files to list
        if file:match("%.dfpwm$") then
            table.insert(songs, file)
        end
    end

    if fs.exists(dataFile) == false then ---Failsafe in case file DNE
        print()
        print("ERROR: storage file "..dataFile.." does not exist!")
        print()
        print("Please press Win+E and go to this path:")
        print("C:\\Users\\<YourUsername>\\Documents\\CurseForge\\")
        print("  instances\\<ModpackName>\\minecraft\\saves\\")
        print("    <WorldName>\\computercraft\\computer\\"..id)
        print()
        print("Then, create a new text file named: "..dataFile)
        print()
        print("Once complete, enter command 'reboot'")

    else
        local file = fs.open(dataFile,"r")
        songID = tonumber(file.readAll())
        file.close()
        if songID == '' then --- if file is empty, choose a random song
            songID = math.random(1, #songs)
        end

        local file = fs.open(dataFile,"w") ---Writes next song to file
        nextSongID = math.random(1, #songs)
        while nextSongID == songID do ---prevents queuing the same song twice
            nextSongID = math.random(1, #songs)
        end
        file.write(nextSongID)
        file.close()

        -- Determining song length
        print("The following file cannot be played:")
        print(songs[songID])
        print('')
        print("Most likely reasons:")
        print(" - Wrong file type (.dfpwm extension is missing)")
        print(" - Unrecognized characters (look for '?'s above)")
        print('')
        print("To disregard the error, run 'reboot' command")
        print('')
        local f = fs.open(folderName.."/"..songs[songID], "rb")
        local size = -1
        while f.read(16384) do
            size = size + 16384
        end
        f.close()
        songLength = size * 8 / 48000


        parallel.waitForAny( ---Run music, input, and display concurrently
            function() play(songs[songID]) end,
            function() handleInput(songs[songID]) end,
            function() display(songs[songID], songLength) end
        )
        sleep(0.5)
        os.reboot()
    end
end


return cctk

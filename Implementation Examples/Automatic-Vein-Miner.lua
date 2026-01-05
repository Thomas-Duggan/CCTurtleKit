local cctk = require("CCTurtleKit")

local usedSlots = {1,  2,  3,  4,
                   5,  6,  7,  8,
                   9,  10, 11, 12,
                   13, 14        }

local fuelSlots = {15, 16}

while true do
    cctk.fuelCheck(100, fuelSlots) ---If fuel is below 100, take fuel from the last 4 slots and refuel
    cctk.mineTunnel(3,4,"left") ---Mines a 3 wide by 4 high hole to the left side of the turtle (NOTE: HEIGHT MUST BE AN EVEN NUMBER)

    if cctk.storageFull(usedSlots) == true then ---Once the storage is full,
        cctk.returnHome() ---Return to location where turtle was placed
        cctk.store(usedSlots) ---Deposit all items
        cctk.backToWork() ---Return to where it was last mining
    end
end
local cctk = require("CCTurtleKit")

local usedSlots = {            4,
                   5,  6,  7,  8,
                   9,  10, 11, 12,
                   13, 14, 15    }

local fuelSlots = {16}

while true do
    cctk.fuelCheck(100,fuelSlots) ---If fuel is below 100, take fuel from the last slot and refuel
    cctk.mineTree(true) ---Mines a tree and replants the sapling
    cctk.store(usedSlots) ---Stores all items but the first, second, and last
end
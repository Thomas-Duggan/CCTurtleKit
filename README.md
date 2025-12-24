## Purpose

A header file that can be used in other scripts by typing this at the top of the file:
```
local cctk = require("CCTurtleKit")
```
Note: run "import" and drag and drop the file into Minecraft to import header file


Note for startup.lua:

This file is NOT neccessary for proper usage of CCTurtleKit.lua. It is exclusively for ease of setup and ease of use. **IF YOU HAVE AN EXISTING startup.lua DO NOT IMPORT MINE AS IT WILL OVERWRITE YOURS.**

## Implementation Examples
<details>
<summary>Click me!</summary>
(Preamble: comments `---` do not need to be typed)
### Automatic Tree Farm
  
```
local cctk = require("CCTurtleKit")

usedSlots = {            4,
             5,  6,  7,  8,
             9,  10, 11, 12,
             13, 14, 15    }

fuelSlots = {16}

while true do
    cctk.mineTree(true) ---Mines a tree and replants the sapling
    cctk.fuelCheck(100,fuelSlots) ---If fuel is below 100, take fuel from the last slot and refuel
    cctk.store(usedSlots) ---Stores all items but the first, second, and last
    end
end
```
Inventory layout: Slot 1: Saplings (NOT DARK OAK), Slots 2-3: and Bone meal; Slot 15: Coal 

Physical layout: A dirt block in front and down 1 block for the sapling and a chest directly behind the turtle. Make sure the turtle has a diamond axe.

### Automatic Vein Miner

```
local cctk = require("CCTurtleKit")

usedSlots = {1,  2,  3,  4,
             5,  6,  7,  8,
             9,  10, 11, 12}

fuelSlots = {13, 14, 15, 16}

while true do
    cctk.mineSquare(3,4,"left") ---Mines a 3 wide by 4 high hole (NOTE: HEIGHT MUST BE AN EVEN NUMBER)
    cctk.forward()  ---Moves forward after mining (MUST USE cctk.forward(), NOT turtle.forward() !!!)
    cctk.fuelCheck(100, fuelSlots) ---If fuel is below 100, take fuel from the last 4 slots and refuel

    if cctk.storageFull(usedSlots) == true then ---Once the storage is full,
        cctk.returnHome() ---Return to location where script was activated
        cctk.store(usedSlots) ---Deposit all items
        cctk.backToWork() ---Return to where it was last mining
    end
end
```
Inventory layout: Slots 13-16: Coal

Physical layout: A chest directly to the right of the turtle. Make sure the turtle has a diamond pickaxe.


</details>


## Copyright

[Creative Commons Attribution-ShareAlike 4.0 International Public
License](https://creativecommons.org/licenses/by-sa/4.0/deed.en)

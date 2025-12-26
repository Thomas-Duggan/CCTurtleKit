## Purpose

A header file that can be used in other scripts by typing this at the top of the file:
```
local cctk = require("CCTurtleKit")
```
Note: run "import" and drag and drop the file into Minecraft to import header file.

---

Note for `startup.lua`: This file is NOT necessary for proper usage of `CCTurtleKit.lua`. It is exclusively for ease of setup and ease of use. It is only required if you want it. 

**IMPORTANT: IF YOU HAVE AN EXISTING `startup.lua` DO NOT IMPORT MINE AS IT WILL OVERWRITE YOURS.**

## Implementation Examples
<details>
<summary>Click me!</summary>
  
**Preamble: comments (** `---This is a comment` **) do not need to be typed for proper functionality.**

Its best to paste these into a .txt file, rename it to a .lua file, then import it like you did with `CCTurtleKit.lua`. However, it is possible to type this verbatim, but it may be difficult to do so.
  
### Automatic Tree Farm
  
```
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
```
Inventory layout: Slot 1: Saplings (NOT DARK OAK), Slots 2-3: Bone meal; Slot 16: Coal 

Physical layout: A dirt block in front and down 1 block for the sapling and a chest directly behind the turtle. Make sure the turtle has a diamond axe.

### Automatic Vein Miner

```
local cctk = require("CCTurtleKit")

local usedSlots = {1,  2,  3,  4,
             5,  6,  7,  8,
             9,  10, 11, 12}

local fuelSlots = {13, 14, 15, 16}

while true do
    cctk.fuelCheck(100, fuelSlots) ---If fuel is below 100, take fuel from the last 4 slots and refuel
    cctk.mineSquare(3,4,"left") ---Mines a 3 wide by 4 high hole (NOTE: HEIGHT MUST BE AN EVEN NUMBER)
    cctk.forward()  ---Moves forward after mining (MUST USE cctk.forward(), NOT turtle.forward() !!!)

    if cctk.storageFull(usedSlots) == true then ---Once the storage is full,
        cctk.returnHome() ---Return to location where turtle was placed
        cctk.store(usedSlots) ---Deposit all items
        cctk.backToWork() ---Return to where it was last mining
    end
end
```
Inventory layout: Slots 13-16: Coal

Physical layout: A chest directly to the right of the turtle. Make sure the turtle has a diamond pickaxe.


</details>


## Copyright

[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

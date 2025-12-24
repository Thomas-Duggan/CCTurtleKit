## Purpose

A header file that can be imported using:
```
local cctk = require("CCTurtleKit")
```
Note: run "import" and drag and drop the file into Minecraft to import header file


Note for startup.lua:

This file is NOT neccessary for proper usage of CCTurtleKit.lua. It is exclusively for ease of setup and ease of use. **IF YOU HAVE AN EXISTING startup.lua DO NOT IMPORT MINE AS IT WILL OVERWRITE YOURS.**

## Issues

- HIGHLY UNFINISHED

## Implementation Examples
<details>
<summary>**Click me!**</summary>
### Automatic Tree Farm
  
```
local cctk = require("CCTurtleKit")

usedSlots = {        3,  4,
             5,  6,  7,  8,
             9,  10, 11, 12,
             13, 14, 15    }

fuelSlots = {16}

while true do
    cctk.mineTree(true) ---Mines a tree and replants the sapling
    cctk.store(usedSlots) ---Stores all items but the first, second, and last
    cctk.fuelCheck(100,fuelSlots) ---If fuel is below 100, take fuel from the last slot and refuel
end
```
Inventory layout: Slot 1: Saplings (any kind); Slot 2: Bone meal; Slot 15: Coal 

Physical layout: A dirt block in front and down 1 block for the sapling and a chest directly behind the turtle

</details>


## Copyright

[Creative Commons Attribution-ShareAlike 4.0 International Public
License](https://creativecommons.org/licenses/by-sa/4.0/deed.en)

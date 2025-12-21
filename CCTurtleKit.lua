--- CCTurtleKit  Copyright (c) 2026 Thomas Duggan 
--- This work is licenced under CC BY-SA 4.0 

-------------- Preamble --------------
local t = turtle
local sh = shell

-------------- Aliases --------------
sh.setAlias('c','clear')
sh.setAlias('q','exit')
sh.setAlias('man','help')
sh.setAlias('h','help')
sh.setAlias('r','reboot')
sh.setAlias('e','edit')
sh.setAlias('cct','CCTurtleKit')

-------------- Functions --------------
function fuelCheck()

    local fuelSlots = {13, 14, 15, 16}
    local fuelMinimum = 100

    local fuel = t.getFuelLevel()
    if fuel <= fuelMinimum then
        previousSlot = t.getSelectedSlot() ---saves previous slot
        
        for i=1, #fuelSlots do
            fuelAmount = t.getItemCount(fuelSlots[i])
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


-------------- Main --------------
while true do

    fuelCheck()
    t.forward()

end



--- CCTurtleKit  Copyright (c) 2026 Thomas Duggan 
--- This work is licenced under CC BY-SA 4.0 

---Aliases
shell.setAlias('c','clear')
shell.setAlias('q','exit')
shell.setAlias('r','reboot')

shell.setAlias('h','help')
shell.setAlias('man','help')

shell.setAlias('e','edit')
shell.setAlias('xed','edit')
shell.setAlias('vim','edit')

shell.setAlias('g','go')
shell.setAlias('move','go')
shell.setAlias('m','go')

---System Initialization
shell.run('c')
local id = os.getComputerID()
print("Computer #"..id.." is now online")
print("Please enter a label for Computer #"..id..":")
local label = io.read()
if label == "" then
    print("Computer label not updated")
else
    shell.run("label set \""..label.."\"")
end
print("Setup complete!")

local function clearconsole()
    os.execute("cls")
end

--- Makes a directory in the path specified
--- May only work on windows
--- @param path string
--- @author: Heaven Williams 2024-11-29 19:24:00
local function mkdir(path)
    if os.execute("powershell mkdir " .. path) == 0 then
        return true
        else 
    return false
    end
end

--- Function that checks through a table and returns true if the specified value is found
---@param t table
---@param val any
---@author: Heaven Williams 2024-11-29 19:10:44
local function contains(t, val)
    for key, value in pairs(t) do
        if(val == value) then
            return true
        end
    end
    return false
end
--- returns true if a file exists, returns false if it does not
---@param path string
---@author: Heaven Williams 2024-11-29 19:10:38
local function fileexists(path)
    local file = io.open(path, "r")
    if file then 
        file:close()
        return true 
    else 
        return false
    end
end

--- Creates a file in the path
--- Returns true if successful otherwise false
---@param path string
---@author: Heaven Williams 2024-11-29 19:59:54
local function mkfile(path)
    local newfile = io.open(path ,"w")
        if newfile then
            newfile:write()
            newfile:close()
            return true
        else
            return false
        end
end

--- Returns true if a directory exists, returns false if it does not.
--- Input a directory as a parameter
--- May only work on windows
---@param dir string
---@author: Heaven Williams 2024-11-29 19:10:15
local function direxis(dir)
    if(os.execute("cd " .. dir .. " 2>nul") == 0) then
        return true
    else
        return false
    end
end



 local list = setmetatable({
    option1 = {
        title = "1 - Create a new Program"
    },
    option2 = {
        title = "2 - Update A Existing Program",
    },
    option3 = {
        title = "3 - Remove A program",
    },
    option4 = {
        title = "4 - Load a Program into main",
    },
    option5 = {
        title = "5 - Quit"
    }
}, {
    __tostring = function (t)
        local text = "";
        for i = 1, getmetatable(t).getSize(t), 1 do
            local index = "option" .. i
            text = text .. t[index].title .. "\n"
        end
        return text , getmetatable(t).getSize(t)
    end,
    getSize = function (t)
        local size = 0
        for key, value in pairs(t) do
            size = size + 1
        end
        return size;
    end,
    getPrograms = function ()
        local filenames = ""
        local filenum = 0;
        local filetable = {}
        local handle = io.popen("dir /b " .. "programs") 
        local result = handle:read("*a") 
        handle:close() 
        for filename in string.gmatch(result, "[^\r\n]+") do 
            if (string.sub(filename, #filename - 3, #filename)) == ".lua" then
            filenum = filenum + 1
            filenames = filenames .. "[" .. filenum .. "] " ..  filename .. "\n"
            table.insert(filetable, filename)
            
            end
        end
        filenames = filenames .. "\n{" .. filenum .."}" .. " total files"
        
            return {filestring = filenames, filetable = filetable, filenums = filenum}
        
end,
    getMainFileData = function ()
        local filedata = ""
        local mainfile = io.open("main.lua", "r")
        if mainfile then
            filedata = mainfile:read("*all")
            mainfile:close()
    else
        print("Failed to open main file")
    end
    return filedata
end
})

local function init()

    if not direxis("programs") then
       mkdir("programs")
    end

    if not fileexists("main.lua") then 
        mkfile("main.lua")
    end

    function list.option1:action()
        print("Enter the name of the program currently in main")
        local validation = false
        local filename 
        while validation == false do
             filename = io.read() .. ".lua"
                if(contains(getmetatable(list).getPrograms().filetable, filename)) then
                    print("That file already exists! If you want to overwrite the file use the 'update' option.\n")
                    print("Enter another name.")
                    validation = false
                else
                    print("Valid name")
                    validation = true
                end
        end
        
        local newfile = io.open("programs/".. filename, "w")
        
        if newfile then
            newfile:write(getmetatable(list).getMainFileData())
            newfile:close()
            print("Program has succesfully been created!")
        else
            print("could not complete operation...")
        end
    end

    function list.option2:action()
        if(getmetatable(list).getPrograms().filenums == 0) then
            print("You currently dont have any programs! Please add at least 1.")
            os.exit()
        end
    print("Select a file from the list and it will be replaced with whats currently in main.\n")
    print(getmetatable(list).getPrograms().filestring .. "\n")
    local validation = false
    local fileName = ""
    local selectedFile = ""

    while not validation == true  do
        local selection = tonumber(io.read())
        if(type(selection) == "number")then
        if getmetatable(list).getPrograms().filetable[selection] then
            print("Valid entry!")
            print("Working...")

            local filename = getmetatable(list).getPrograms().filetable[selection]

            local newfile = io.open("programs/".. filename , "w")     
            if newfile then
            newfile:write(getmetatable(list).getMainFileData())
            newfile:close()
            end
            print("Finished!")
            
            validation = true
        else
            print("Not a valid entry!\nTry Again!")
        end
    else
        print("Thats not a number.\nTry again.")
    end
end
end
    function list.option3:action()
        if(getmetatable(list).getPrograms().filenums == 0) then
            print("You currently dont have any programs! Please add at least 1.")
            os.exit()
        end
        print("Select a file from the list and it will be deleted.\n")
        print(getmetatable(list).getPrograms().filestring .. "\n")
        local validation = false
        local fileName = ""
        local selectedFile = ""
    
        while not validation == true  do
            local selection = tonumber(io.read())
            if(type(selection) == "number")then
            if getmetatable(list).getPrograms().filetable[selection] then
                print("Valid entry!")
                print("Working...")
    
                local success, err = os.remove("programs/" .. getmetatable(list).getPrograms().filetable[selection]) 
                if success then 
                    print("File deleted successfully!") 
                else 
                    print("Error deleting file: " .. err) 
                end
    
                validation = true
            else
                print("Not a valid entry!\nTry Again!")
            end
        else 
            print("Thats not a number.\nTry again.")
        end
    end
    end
    function list.option4:action()
        if(getmetatable(list).getPrograms().filenums == 0) then
            print("You currently dont have any programs! Please add at least 1.")
            os.exit()
        end
        print("Select a file from the list and it will be loaded into main.\n WARNING!!! THIS WILL DELETE EVERYTHING IN MAIN, if there is anything important in main create a new program out of it first!\n")
        print(getmetatable(list).getPrograms().filestring .. "\n")
        local validation = false

        
        while not validation == true  do
            local selection = tonumber(io.read())
            if(type(selection) == "number")then

            
            if getmetatable(list).getPrograms().filetable[selection] then
                print("Valid entry!")
                print("Working...")
    

                local selectedfile = io.open("programs/" .. getmetatable(list).getPrograms().filetable[selection], "r")
                local filedata = ""
                if selectedfile then
                    filedata = selectedfile:read("*all")
                    selectedfile:close()
                    print("retrieved date from " .. "'" ..getmetatable(list).getPrograms().filetable[selection] .. "'")
                else
                    print("Failed to open '" ..getmetatable(list).getPrograms().filetable[selection] .. "'.")
                end
                
            local mainfile = io.open("main.lua", "w")
            
            if mainfile then
                mainfile:write(filedata)
                mainfile:close()
                print("Data written to main")
            else
                print("Failed to write data to main")
            end
            
            print("Done!")

                validation = true
            else
                print("Not a valid entry! Try Again!")
            end
        else
            print("Thats not a number\nTry again")
        end
        end
    end
    function list.option5:action()
        print("GoodBye!")
        os.exit()
    end
    
    print("Welcome to program manager! - (created by heaven)\n")
    print("Select an option to get Started.\n")

    print(list)

    local selectedOption
    local validation = false

    while validation == false do
        selectedOption = tonumber(io.read())
        if(type(selectedOption) == "number")then
            if (not (selectedOption <= 0)) and (not (selectedOption > (getmetatable(list).getSize(list)))) then
            validation = true
            else
            print("Invalid selection.\nPlease try again")
        end
        else
            print("Thats not a number.\nTry again.")
        end
        
    end

    list["option" .. selectedOption]:action()
end

init()
--list.option1:action()
--list.option2:action();
--list.option3:action();
--list.option4:action()
--print()

--print(list)
local plrservice = game:GetService("Players")

repeat task.wait() until plrservice.LocalPlayer and game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts") and game:GetService("StarterPlayer"):FindFirstChild("StarterCharacterScripts")

local me = plrservice.LocalPlayer

if not decompile then
    me:Kick("your executor doesnt has decompile function noob")
    return
end

local noobworkspace = game:GetService("Workspace")
local noobreplicatedstorage = game:GetService("ReplicatedStorage")
local noobreplicatedfirst = game:GetService("ReplicatedFirst")
local noobstarterplayer = nil 
local noobstartercharacter = nil

if game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts") then 
    noobstarterplayer = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
end 

if game:GetService("StarterPlayer"):FindFirstChild("StarterCharacterScripts") then 
    noobstartercharacter = game:GetService("StarterPlayer"):FindFirstChild("StarterCharacterScripts")
end 


local noobstartergui = game:GetService("StarterGui")
local noobnilinstances = getnilinstances() 


local DecompileStartTime = os.time()
local ScriptsFailedToDecompile = 0
local ScriptsSuccesfullyDecompiled = 0
local ScriptDumpingCompleted = false 


local ScriptDumperDirFolderName = tostring(game.PlaceId)

if not isfolder(ScriptDumperDirFolderName) then
    makefolder(ScriptDumperDirFolderName)
end
local ServicesCrap = {
    ["StarterPlayerScripts"]={DecompileState=true,Path=noobstarterplayer},
    ["StarterCharacterScripts"]={DecompileState=true,Path=noobstartercharacter},
    ["ReplicatedStorage"]={DecompileState=true,Path=noobreplicatedstorage},
    ["ReplicatedFirst"]={DecompileState=true,Path=noobreplicatedfirst},
    ["StarterGui"]={DecompileState=true,Path=noobstartergui},
    ["Nil_Instances"]={DecompileState=true,Path=noobnilinstances}
}

function DecompileScriptGrr(ScriptToDecompile)
    local Success, ReturnedData
    local DecompiledOutput = nil 
    local ScriptByteCode = nil 

    Success, ReturnedData = pcall(function()
        ScriptByteCode = getscriptbytecode(ScriptToDecompile)
        if ScriptByteCode and string.len(ScriptByteCode) > 0 then
             DecompiledOutput = decompile(ScriptToDecompile)
         end
    end)

    return {
        ["Success"] = Success,
        ["Output"] = DecompiledOutput or "Unknown Bytecode"
    }
end

local function SafeDecompileScript(Script, Category)
    local ScriptDecompiled = DecompileScriptGrr(Script)
    if ScriptDecompiled.Success and ScriptDecompiled.Output ~= "Unknown Bytecode" then
        ScriptsSuccesfullyDecompiled = ScriptsSuccesfullyDecompiled + 1 
        local ScriptName = Script.Name..tostring(ScriptsSuccesfullyDecompiled)
        writefile(ScriptDumperDirFolderName .. "/" .. Category .. "/" .. ScriptName .. ".lua", ScriptDecompiled.Output)
    else
        ScriptsFailedToDecompile = ScriptsFailedToDecompile + 1
    end
end 

local function DumpServiceScripts(Path,ServiceName)
    for i, v in pairs(Path) do
        if v:IsA("ModuleScript") or v:IsA("LocalScript") then
            SafeDecompileScript(v,ServiceName)
        end
    end
end

task.spawn(function()
    for i, v in pairs(ServicesCrap) do
        if v.DecompileState == true then
            makefolder(ScriptDumperDirFolderName .. "/" .. i)
            if v.Path ~= nil then
                if typeof(v.Path) == "Instance" then
                    DumpServiceScripts(v.Path:GetDescendants(), i)
                elseif typeof(v.Path) == "table" then
                    DumpServiceScripts(v.Path, i)
                end
            end
        end
    end

    ScriptDumpingCompleted = true
end)



repeat task.wait() until ScriptDumpingCompleted == true 

local DecompileEndTimeStamp = os.time()-DecompileStartTime

print("Decompiling Finished in : "..DecompileEndTimeStamp.." Seconds")
print("Folder dir name: "..ScriptDumperDirFolderName)
print("Scripts failed to decompile : "..tostring(ScriptsFailedToDecompile))
print("Scripts decompiled : "..tostring(ScriptsSuccesfullyDecompiled))



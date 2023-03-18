# HatLib v2  

Made by topit  
Does funky stuff with your hats  

## What is HatLib?  

HatLib is a simple library that helps you make hat-based scripts. Instead of having to manually manage every single accessory instance and make sure you're setting everything properly, HatLib takes care of that for you.  

## How does it work?
Here's an example of how to use HatLib, line by line.  

First, load in the library by loadstringing the main library script.  
```lua
local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/HatLib/main/library.lua'))()
```
Next, initialize the library by creating a new instance using the `.new` function. It takes in a table of parameters, which can be found in the API docs section.

```lua
local module = library.new({
    DisableFlicker = true,
    BlockifyHats = true
})
```
Now the module can be used. You can create a new HatObject by using the module:CreateHat() function. If you'd like to create a hat with a specific mesh, you can use module:CreateHatById(), which takes in a specific mesh id.

Here's an example use case:
```lua
local fedoraHat = module:CreateHatById('rbxassetid://4489232754') -- Create a HatObject of a specific fedora
if ( not fedoraHat ) then -- It couldn't be created, fallback to another hat
    fedoraHat = module:CreateHat()
end
```
Once a HatObject is created, you can move it to wherever you'd like.
```lua
fedoraHat:SetCFrame(CFrame.new(0, 10, 0))
```
When you're done with the library, you can call Module:Destroy(), which exits everything out
```lua
task.wait(10)
module:Destroy()
```


## Example  
```lua
local HatLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/HatLib/main/library.lua'))()

local HatModule = HatLib.new({
    CustomVelocity = Vector3.new(0, 0, 30),
    DisableFlicker = true,
    BlockifyHats = true,
    HatLocation = 'workspace',
}) 

while HatModule:CreateHat() do end -- simple trick that creates as many hats as possible 

local Hats = HatModule:GetHatArray()
if ( #Hats == 0 ) then
    -- no hats found, return
    return HatModule:Destroy() 
end

local RunService = game:GetService('RunService')
local Time = 0 
local RootPart = game:GetService('Players').LocalPlayer.Character.HumanoidRootPart

local Connection = RunService.Heartbeat:Connect(function(DeltaTime: number)
    Time += DeltaTime
    
    local Position = RootPart.Position 
    
    for idx, hat in ipairs(Hats) do 
        local thisTime = Time + idx * ( math.pi / (#Hats / 2 ) )
        
        local posX = math.sin(thisTime) * 5
        local posY = ( math.cos(thisTime + Time) )
        local posZ = math.cos(thisTime) * 5 
        
        local thisCFrame = CFrame.new(Position + Vector3.new(posX, posY, posZ), Position) 
        
        hat:SetCFrame(thisCFrame)    
    end
end)

task.wait(10)
Connection:Disconnect()
HatModule:Destroy() 
```

## Api docs  

### HatModule (methods)  

```lua
<nil> function HatModule.Notify(Title: string, Text: string, Duration: number)
```
*Sends a generic StarterGui notification. Notify gets used internally by the library, but is exposed to the user for convience.*  
```lua
<self> function HatModule:ClearHats()  
```
*Destroys every HatObject created by this HatModule*  
```lua
<table> function HatModule:GetHatArray()  
```
*Returns the internal _hats array, which contains each HatObject*  
```lua
<number> function HatModule:GetHatCount() 
```
*Returns the length of the _hats array*  
```lua
<boolean> function HatModule:IsRunning()  
```
*Returns true if this module is actively processing it's hats*  
```lua
<Accessory, Part> function HatModule:GetNextAccessory(keepInvalidAccessories: boolean)  
```
*Returns the next valid accessory instance (and it's handle) that's found. If an invalid accessory is found, and `keepInvalidAccessories` isn't true, it will automatically be deleted so the next GetNextAccessory call will work*  
```lua
<table {Accessory} > function HatModule:GetAllAccessories()  
```
*Returns all valid accessory instances found*  
```lua
<HatObject> function HatModule:CreateHat()
```
*Creates and returns a new HatObject*  
```lua
<HatObject> function HatModule:CreateHatById(targetMeshId: string)
```
*Creates and returns a new HatObject that has a meshId equal to `targetMeshId`*    
```lua
<self> function HatModule:SetSetting(SettingName: string, SettingValue: any)
```
*Sets the setting `SettingName` to `SettingValue`. Only works on settings marked as **Live***  
```lua
<nil> function HatModule:Destroy(NoNotify: boolean)
```
*Destroys this HatModule instance. If `NoNotify` is true, then it will not send a goodbye notification.*  
```lua
<HatModule> function HatModule.new(Settings: table)
```
*Creates a new HatModule instance using settings `Settings`*   

### HatModule (properties)  

`HatModule`s do not have any public properties.  

### HatModule (settings)  

```lua
<boolean> DisableFlicker = true
```
*Removes the flickering effect clientside by hiding the real hats and showing fake ones instead. If a real hat gets destroyed, then the fake hat will turn red*  
```lua
<boolean> BlockifyHats = true
```
*Removes meshes from hats, making them into blocks. Only works for R6*  
```lua
<boolean> ShowRoots = false
```
*Debug testing mode that shows both roots and 'real' hats*  
```lua
<boolean> UpdateLegacy = false
```
*Uses a different method of updating hats. Try changing this to `true` if you experience any stability issues*  
```lua
<string | Instance?> HatLocation = 'workspace'
```
*Determines where hats get parented to. Use 'Character' for Character, 'workspace' for Workspace, or pass an instance of your choosing*  
```lua
[LIVE] <Vector3> CustomVelocity = nil
```
*Sets a custom direction in which the hats move on velocity frames. Used for cases where the default velocity is undesirable. **This setting is live, and can be changed during runtime***  
```lua
[LIVE] <number> NetIntensity = 80
```
*Controls the intensity of the default "net" - not CustomVelocity. Higher numbers make the hats more stable and less likely to 'break', but will have more flicker. **This setting is live, and can be changed during runtime***  
```lua
<boolean> UpdateSmooth = false
```
*Interpolates :SetCFrame calls, making hats move more smoothly.*  
```lua
[LIVE] <number> SmoothnessValue = 10
```
*Controls the smoothness of the interpolation. **This setting is live, and can be changed during runtime***  

### HatObject (methods)  

```lua
<self> function HatObject:SetCFrame(NewCFrame: CFrame)
```
*Sets this hat's CFrame to `NewCFrame`*  
```lua
<nil> function HatObject:Destroy()
```
*Destroys this HatObject instance*  
```lua
<HatObject> function HatObject.new(ParentModule: HatModule, HatAccessory: Accessory)
```
*Creates a new HatObject instance, with `ParentModule` as the parent and HatAccessory as the target accessory. **It is recommended to use `HatModule:CreateHat()` instead of this function.***  

### HatObject (properties)  
```lua
<string> HatId
```
*The MeshId that this hat uses. Unlike HatLib v1, the HatId property is the entire string and not just the digits*  

```lua
<Vector3> HatSize
```
*The size of this hat. For international fedoras, this is (1, 1, 1)*  


## Issues & Fixes  
- **My character got stuck and won't respawn.** This usually happens whenever you mess with the Player.Character property. I don't know of any perfect fix, but killing your humanoid, setting your .Character property to nil, waiting a bit, then setting .Character back to your character model mostly works.  
- **The hats just instantly disappear.** This can happen for a number of reasons. Make sure that you're consistently setting each hat's CFrame and the `NetIntensity` setting is turned up. If the hats are idle for too long, they can get deleted. You can also try enabling the `UpdateLegacy` setting. It may also be game specific or hat specific, make an issue if you're not sure.  
- **The hats won't turn into blocks.** Make sure you're in an R6 game, as R15 is not supported.  

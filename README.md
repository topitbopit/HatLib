# HatLib v2  

Made by topit  
Does funky stuff with your hats  

## What is HatLib?  

HatLib is a simple library that helps you make hat-based scripts. Instead of having to manually manage every single hat instance and make sure you're setting everything properly, HatLib *mostly* does it for you.  

## Example  
```lua
local HatLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/HatLib/main/library.lua'))()

local HatModule = HatLib.new({
    CustomVelocity = Vector3.new(0, 0, 30),
    DisableFlicker = true,
    BlockifyHats = true,
    HatLocation = 'workspace',
}) 

while HatModule:CreateHat() do end -- simple "exploit" to create as many hats as the player has 

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

## Docs  

### HatModule (methods)  

```lua
<nil> function HatModule.Notify(Title: string, Text: string, Duration: number)
```
*Sends a generic StarterGui notification.*  
```lua
<self> function HatModule:ClearHats()
```
*Destroys every HatObject created by this HatModule*  
```lua
<table> function HatModule:GetHatArray()
```
*Returns the internal _hats array, containing each HatObject*  
```lua
<number> function HatModule:GetHatCount() 
```
*Returns the length of the _hats array*  
```lua
<boolean> function HatModule:IsRunning()
```
*Returns true if this module is actively processing it's hats*  
```lua
<HatObject> function HatModule:CreateHat()
```
*Creates and returns a new HatObject*  
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
<HatObject> function HatObject.new(ParentModule: HatModule)
```
*Creates a new HatObject instance, with `ParentModule` as the parent. **It is recommended to use `HatModule:CreateHat()` instead of this function.***  

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
- **The hats just instantly disappear.** This can happen for a number of reasons. Make sure that you're consistently setting each hat's CFrame and the `NetIntensity` setting is turned up. If the hats are idle for too long, they can get deleted. You can also try enabling the `UpdateLegacy` setting.  
- **The hats won't turn into blocks.** Make sure you're in an R6 game, as R15 is not supported.  

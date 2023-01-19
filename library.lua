--- Hatlib 
-- Remade by topit
-- January 18 2023

local HatlibVersion = 'v2.0.0'

if ( not game:IsLoaded() ) then
    game.Loaded:Wait()
end

local runService = game:GetService('RunService')
local playerService = game:GetService('Players')
local starterGui = game:GetService('StarterGui')

local eventCons = {} -- table of events that are to be cleaned up later 
local moduleCount = 0 -- amount of initialized HatModules; used to indicate if the script should clean itself up when a module is destroyed 

local localPlayer = playerService.LocalPlayer 
local localChar = localPlayer.Character
local localRoot = localChar and localChar:FindFirstChild('HumanoidRootPart')

eventCons.respawn = localPlayer.CharacterAdded:Connect(function(newCharacter) 
    localChar = newCharacter
    localRoot = newCharacter:WaitForChild('HumanoidRootPart')
end)

local function Notify(title: string, text: string, duration: number) 
    starterGui:SetCore('SendNotification', {
        Title = title;
        Text = text;
        Duration = duration;
    })
end


--- HatObject class 
-- Created for each hat, designed to make managing them easier 
local HatObject = {} 
HatObject._class = 'HatObject'
HatObject.__index = HatObject 

do 
    -- ._root: hidden part that acts as an "anchor" for the real part
    -- ._handle: actual hat object that typically gets made hidden
    
    local smoothFuncs = {
        SetCFrame = function(self: HatObject, newCFrame: CFrame)
            self._targetCFrame = newCFrame
            
            return self
        end;
        
        _UpdateCFrame = function(self: HatObject, deltaTime: number) 
            local curCFrame = self._root.CFrame
            local targetCFrame = self._targetCFrame 
            
            local newCFrame = curCFrame:Lerp(targetCFrame, 1 - math.exp(-self._settings.SmoothnessValue * deltaTime))
            
            self._root.CFrame = newCFrame 
            self._handle.CFrame = newCFrame
            
            return self
        end;
    } 
    local normalFuncs = {
        SetCFrame = function(self: HatObject, newCFrame: CFrame) 
            self._root.CFrame = newCFrame 
            
            return self
        end;
        
        _UpdateCFrame = function(self: HatObject, deltaTime: number) 
            self._handle.CFrame = self._root.CFrame

            return self
        end;
    } 
    
    function HatObject:_UpdateVelocity() 
        local settings = self._settings 
        local customVelocity = settings.CustomVelocity 
        
        if ( customVelocity ) then
            self._handle.Velocity = customVelocity 
        else
            self._handle.Velocity = ( localRoot.Position - self._root.Position ).Unit * settings.NetIntensity
        end
        
        return self
    end
    
    function HatObject:Destroy(remainEntry: boolean) 
        local hatArray = self._parent._hats
        
        if ( not remainEntry ) then -- Check if the HatObject is meant to be removed from the table 
            local index = table.find(hatArray, self) -- Check if this HatObject is in the HatModule _hats array 
            if ( index ) then
                table.remove(hatArray, index) -- If so, remove it so it won't be referenced
            end 
        end 
        
        self._root:Destroy()
        self._handle:Destroy()
        
        setmetatable(self, nil)
    end
    
    function HatObject.new(parentModule: HatModule) 
        local self = setmetatable({}, HatObject)
        self._parent = parentModule
        
        local settings = self._parent._settings
        self._settings = settings 
        
        if ( not localChar ) then
            localPlayer.CharacterAdded:Wait() -- hopefully this works fine
        end
        
        -- Check for an existing accessory (object thing that holds your hat) 
        local hatAccessory = localChar:FindFirstChildOfClass('Accessory')
        if ( not hatAccessory ) then
            -- If none exist, delete this hatobject and return an error message
            setmetatable(self, nil)
            
            return false, 'No valid hat was found'
        end 
        
        -- Check for an existing hat handle 
        local hatHandle = hatAccessory:FindFirstChild('Handle')
        if ( not hatHandle ) then
            -- If it doesnt exist, delete this hatobject and return an error message
            -- Delete the accessory too, so the next CreateHat call will work 
            setmetatable(self, nil)
            hatAccessory:Destroy() 
            
            return false, 'Found hat is missing a handle'
        end 
        
        local hatSize, meshId
        local hatMesh = hatHandle:FindFirstChildOfClass('SpecialMesh') or hatHandle:FindFirstChildOfClass('Mesh') -- Might add filemesh support later 
        
        do 
            hatSize = hatHandle.Size 
            
            if ( hatMesh ) then
                meshId = hatMesh.MeshId
                
                if ( settings.BlockifyHats ) then
                    hatMesh:Destroy() 
                end
            elseif ( hatHandle.ClassName == 'MeshPart' ) then 
                meshId = hatHandle.MeshId 
            end
        end 
        
        -- Check for smooth updating 
        if ( settings.UpdateSmooth == true ) then
            -- If smooth updating is enabled then use the smooth update functions
            self.SetCFrame = smoothFuncs.SetCFrame 
            self._UpdateCFrame = smoothFuncs._UpdateCFrame 
        else
            -- otherwise, switch to the normal update functions 
            self.SetCFrame = normalFuncs.SetCFrame 
            self._UpdateCFrame = normalFuncs._UpdateCFrame 
        end
        
        local hatRoot = Instance.new('Part')
        hatRoot.Anchored = true
        hatRoot.BottomSurface = 'Smooth'
        hatRoot.CFrame = localRoot.CFrame 
        hatRoot.CanCollide = false
        hatRoot.CanTouch = false
        hatRoot.Size = Vector3.one
        hatRoot.TopSurface = 'Smooth'
        hatRoot.Transparency = 1 
        
        if ( settings.DisableFlicker ) then
            hatRoot.Transparency = 0 
            hatRoot.Size = hatSize
            
            hatHandle.Transparency = 1
        elseif ( settings.ShowRoots ) then  
            hatRoot.Color = Color3.fromRGB(0, 0, 255)
            hatRoot.Size = Vector3.one * 0.8
            hatRoot.Transparency = 0.5 
            
            hatHandle.Transparency = 0.3
        end
        
        self._root = hatRoot
        self._handle = hatHandle 
        self.HatSize = hatSize 
        self.HatId = meshId 
        
        local hatWeld = hatHandle:FindFirstChildOfClass('Weld')
        if ( hatWeld ) then 
            hatWeld:Destroy() 
        end
        
        local parentLocation = self._settings.HatLocation
        if ( parentLocation == 'Character' ) then 
            hatRoot.Parent = localChar
        elseif ( typeof(parentLocation) == 'Instance' ) then
            hatRoot.Parent = parentLocation 
        else
            hatRoot.Parent = workspace 
        end
        
        hatHandle.Parent = hatRoot
        hatAccessory:Destroy() 
        
        local changedCn
        changedCn = hatHandle.AncestryChanged:Connect(function(_, newParent: Instance)
            if ( not newParent ) then
                if ( hatRoot ) then 
                    hatRoot.Color = Color3.fromRGB(255, 0, 0)
                    hatRoot.Transparency = 0.3  
                end
                
                changedCn:Disconnect() 
            end
        end)
        
        self._targetCFrame = hatRoot.CFrame
        
        table.insert(parentModule._hats, self)
        
        return self 
    end
end

--- HatModule class
-- Handles interactions that are done to all of the hats 
local HatModule = {}
HatModule._class = 'HatModule'
HatModule.__index = HatModule

do
    HatModule.Notify = Notify -- just leaving this here so I dont need to remake the function in every script 
    
    -- Deletes every existing hat 
    function HatModule:ClearHats() 
        if ( self._hats ) then
            for _, hat in ipairs(self._hats) do 
                hat:Destroy(true)
            end
        end
        
        return self 
    end
    
    -- Returns the internal _hats array
    function HatModule:GetHatArray() 
        return self._hats 
    end
    
    -- Returns the length of the internal hats array. Super useless function, but I don't care 
    function HatModule:GetHatCount() 
        return #( self:GetHatArray() )
    end

    -- Returns true if this module is currently updating, and false if not 
    function HatModule:IsRunning() 
        return self._running 
    end
    
    -- Creates a new HatObject and returns it 
    function HatModule:CreateHat() 
        return HatObject.new(self)
    end
    
    -- Destroys this current HatModule instance, clearing every hat and disabling the update connection.
    -- If this is the last HatModule, then the entire script is cleaned up 
    function HatModule:Destroy(NoNotif: boolean) 
        -- Destroy all hat objects 
        self:ClearHats()
        
        -- Set running flag to false 
        self._running = false
        
        -- Disable update connection 
        if ( self._settings.UpdateLegacy ) then 
            task.cancel(self._updateThread)
        else 
            self._updateCon:Disconnect() 
        end
        
        -- Decrement modulecount 
        moduleCount -= 1
        
        -- Check if there are no more running modules. If so, clean up the script so it stops updating variables 
        if ( moduleCount <= 0 ) then
            -- As of now, the only thing to clean up is the respawn event. If I ever add more features, I'd clean them up here
            eventCons.respawn:Disconnect() 
            
            if ( not NoNotif ) then 
                Notify('HatLib v2', 'Successfully destroyed!')
            end
        end
        
        setmetatable(self, nil)
    end
    
    -- Sets the setting `settingName` to `settingValue`. This will only work with settings marked as live!
    function HatModule:SetSetting(settingName: string, settingValue: any) 
        self._settings[settingName] = settingValue
        
        return self 
    end
    
    local defaultSettings = {
        DisableFlicker = true; -- boolean ; Removes the flickering effect by hiding the 'real' hats and showing the fake roots. Only affects your client. If a real hat gets destroyed, then the fake root will turn red.
        BlockifyHats = true; -- boolean ; Removes meshes from hats, making them into blocks. Only works for R6
        ShowRoots = false; -- boolean ; Debug testing mode that shows both roots and 'real' hats.
        
        UpdateLegacy = false; -- boolean ; Uses a loop to update everything rather than a connection. Keep disabled, but try enabling in case it breaks.
        HatLocation = 'workspace'; -- string | Instance ; determines where hats get parented to. Use 'Character' for Character, 'workspace' for Workspace, or pass an instance of your choosing.
        
        -- [LIVE]
        CustomVelocity = nil; -- Vector3? ; Sets a custom direction in which the hats move on velocity frames. Used for cases where the default velocity is undesirable
        -- [LIVE]
        NetIntensity = 80; -- number ; Controls the intensity of the "net". Higher numbers make the hats more stable and less likely to 'break', but will have more flicker.
        
        UpdateSmooth = false; -- boolean ; Smoothly interpolates :SetCFrame calls, making hats move more smoothly.
        -- [LIVE]
        SmoothnessValue = 10; -- number ; How smooth to interpolate
    }
    
    -- Creates and returns a new HatModule instance. Takes a dictionary containing settings.
    -- Check docs for info on each setting.
    function HatModule.new(settings: table) 
        local self = setmetatable({}, HatModule)
        self._running = true 
        self._hats = {}

        --- Handle settings 
        local settings = settings or defaultSettings -- If a table isnt passed, just grab default settings
        for k, v in pairs(defaultSettings) do 
            -- Check each default setting and see if that entry was specified
            if ( settings[k] == nil ) then
                -- If not, then set the default value 
                settings[k] = defaultSettings[k]
            end
        end
        self._settings = settings 
        
        --- Main update loop
        -- For the "net" or whatever to function, the hats need to be updated every other frame
        -- I.e., pos gets updated on frame 1, velocity on frame 2, pos on frame 3, etc.
        -- Both update methods accomplish this, but with different ways
        if ( settings.UpdateLegacy ) then 
            -- UpdateLegacy uses a while loop that waits 2 frames each iteration, just like how the old library worked.
            -- Use this as a backup mode incase the default one fails
            
            local deltaTime = 0 
            self._updateThread = task.spawn(function() 
                
                while ( true ) do
                    if ( not self._running ) then
                        break
                    end 
                    
                    -- Position update 
                    for _, hat in ipairs(self._hats) do 
                        hat:_UpdateCFrame(deltaTime)
                    end
                    deltaTime = 0 
                    deltaTime += task.wait()
                    
                    if ( not self._running ) then
                        break
                    end 
                    
                    -- Velocity update 
                    for _, hat in ipairs(self._hats) do 
                        hat:_UpdateVelocity()
                    end
                    
                    deltaTime += task.wait()
                end
            end)
        else
            -- The new method uses a Heartbeat connection. Functionally, it should be same to the while loop, but 
            -- its more performant than the loop since theres less done per iteration
             
            local wholeDelta = 0 
            local updateParity = false 
            self._updateCon = runService.Heartbeat:Connect(function(deltaTime: number) 
                updateParity = not updateParity
                wholeDelta += deltaTime 
                
                if ( updateParity ) then
                    -- Position update 
                    for _, hat in ipairs(self._hats) do 
                        hat:_UpdateCFrame(wholeDelta)
                    end
                    wholeDelta = 0 
                else
                    -- Velocity update 
                    for _, hat in ipairs(self._hats) do 
                        hat:_UpdateVelocity()
                    end
                end 
            end)
        end
        
        moduleCount += 1 
        
        return self 
    end
end

return HatModule

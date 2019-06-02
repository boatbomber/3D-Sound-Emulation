-- Services
local RunService	= game:GetService("RunService")

if not RunService:IsClient() then
	error("Sound System 3D is to be run on the client. Use RemoteEvents to have the client create the sound.")
end

-- Localize maths for optimization
local acos, clamp	= math.acos, math.clamp
local v3,cf			= Vector3.new,CFrame.new
local dot			= v3().Dot
local newInst,getType	= Instance.new,typeof

-- Camera setup
local Camera	= workspace.CurrentCamera
local FoV		= Camera.FieldOfView
Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
	FoV = Camera.FieldOfView
end)

-- Create container object
local SoundContainer	= newInst("Part")
	SoundContainer.Name			= "SoundContainer"
	SoundContainer.CFrame		= cf()
	SoundContainer.Anchored		= true
	SoundContainer.CanCollide	= false
	SoundContainer.Transparency	= 1
	SoundContainer.Parent	= Camera
	
-- Setup system
local SoundSystem		= {}
local CurrentObjects	= {}

function SoundSystem:Create(ID, Target, Looped)
	
	local TargetType
	
	--------------------------
	-- Sanity checks
	--------------------------
	
	if not ID or getType(ID) ~= "string" or not ID:match("%d+") then -- Must exist, be a string, and have numbers
		error("Invalid ID: ".. tostring(ID))
	end
	if Target then -- Must exist
		TargetType = getType(Target)
		if TargetType ~= "Instance" and TargetType ~= "Vector3" and TargetType ~= "CFrame" then -- Must be valid type
			error("Invalid Target: ".. tostring(Target))
		end
	else
		error("Invalid Target: ".. tostring(Target))
	end
	Looped = Looped or false
	
	--------------------------
	-- Object creation
	--------------------------
	
	local Emitter	= newInst("Attachment")
		--Emitter.Visible	= true
		
		if TargetType == "Instance" and Target.Position then
			-- Sound follows object
			RunService.RenderStepped:Connect(function()
				Emitter.WorldPosition	= Target.Position
			end)
			
		elseif TargetType == "Vector3" then
			-- Sound in static position
			Emitter.WorldPosition	= Target
			
		elseif TargetType == "CFrame" then
			-- Sound in static position
			Emitter.WorldPosition	= Target.Position
			
		end
	
	local Sound		= newInst("Sound")
		Sound.Looped		= Looped
		Sound.SoundId		= "rbxassetid://".. ID:match("%d+")
		
	local Equalizer	= newInst("EqualizerSoundEffect")
		Equalizer.LowGain	= 0
		Equalizer.MidGain	= 0
		Equalizer.HighGain	= 0
		
	
	--------------------------
	-- Effect controller
	--------------------------
	
	CurrentObjects[Emitter]	= true
	if not Looped then
		Sound.Ended:Connect(function()
			CurrentObjects[Emitter]	= nil
			Emitter:Destroy()
		end)
	end
	
	--------------------------
	-- Finalization
	--------------------------
	
	Equalizer.Parent	= Sound
	Sound.Parent		= Emitter
	Emitter.Parent		= SoundContainer
	
	Sound:Play()
	
	return Emitter
end

--------------------------
-- 3D-Effect management
--------------------------

RunService.RenderStepped:Connect(function()
	for Emitter, _ in pairs(CurrentObjects) do
		Emitter.Sound.EqualizerSoundEffect.HighGain = clamp(
			acos(
				dot(
					cf(Camera.CFrame.Position,v3(Camera.CFrame.LookVector.X,Camera.CFrame.Position.Y,Camera.CFrame.LookVector.Z)).LookVector.Unit,
					v3(Emitter.WorldPosition.Unit.X,Camera.CFrame.Position.Y,Emitter.WorldPosition.Unit.Z)
				)
			)*-8.2,
			-25,0
		)
	end
end)

return SoundSystem

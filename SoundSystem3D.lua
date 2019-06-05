-- Services
local Workspace = game:GetService("Workspace")
local RunService	= game:GetService("RunService")

if not RunService:IsClient() then
	error("Sound System 3D is to be run on the client. Use RemoteEvents to have the client create the sound.")
end

-- Localize maths for optimization
local acos,cos,pi	= math.acos,math.cos,math.pi
local v3,cf			= Vector3.new,CFrame.new
local dot			= v3().Dot
local newInst,getType	= Instance.new,typeof

local type = type
local string_match = string.match
local next = next
local error = error
local tostring = tostring

local RenderStepped = RunService.RenderStepped

-- Camera setup
local Camera	= Workspace.CurrentCamera

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
	
	if not ID or type(ID) ~= "string" or not string_match(ID, "%d+") then -- Must exist, be a string, and have numbers
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
			RenderStepped:Connect(function()
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
		Sound.SoundId		= "rbxassetid://".. string_match(ID, "%d+")
		
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


RenderStepped:Connect(function()
	for Emitter in next, CurrentObjects do
		local CameraCFrame = Camera.CFrame
		local EmitterWorldPosition = Emitter.WorldPosition.Unit
		Emitter.Sound.EqualizerSoundEffect.HighGain = -(-25 * cos(acos(dot(cf(CameraCFrame.Position,v3(CameraCFrame.LookVector.X,CameraCFrame.Position.Y,CameraCFrame.LookVector.Z)).LookVector.Unit,v3(EmitterWorldPosition.X,CameraCFrame.Position.Y,EmitterWorldPosition.Z))) / 3.141592653589793115997963468544185161590576171875 * 1.5707963267948965579989817342720925807952880859375) + 25)
	end
end)

return SoundSystem

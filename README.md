# 3D-Sound-Emulation

Usage is super simple, with just a single function.
```
local SoundSystem3D = require(script.SoundSystem3D)

local Sound = SoundSystem3D:Create(ID, Target, Looped)
```
`:Create()` returns an Attachment with a Sound in it.

ID can be:
* A string of numbers
* A string of the whole Id ("rbxassetid://" included)

Target can be:
* CFrame (will create a sound that stays at that CFrame)
* Vector3 (will create a sound that stays at that Vector3)
* Instance with a Position property (will create a sound that follows the Instance)

Looped can be:
* A boolean (defaults to false)
Note: If Looped is false, it will automatically delete the Attachment once the Sound has played

Because this must be run from the client, you should use RemoteEvents to tell the client when and where to play sounds.

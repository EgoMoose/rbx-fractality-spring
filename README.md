# rbx-fractality-spring

A high-performance fully typed spring class based on [Fractality's spr library](https://github.com/Fraktality/spr/blob/master/spr.lua) for use in Roblox.

Visualizer: https://www.desmos.com/calculator/rzvw27ljh9

Get it here:

* [Wally](https://wally.run/package/egomoose/fractality-spring)
* [Releases](https://github.com/EgoMoose/rbx-fractality-spring/releases)

## Example

```luau
local spring = FractalitySpring.new(0.1, 4, movingPart.CFrame, targetPart.CFrame)

game:GetService("RunService").Heartbeat:Connect(function(dt)
	spring:setGoal(targetPart.CFrame)
	movingPart.CFrame = spring:step(dt)
end)
```
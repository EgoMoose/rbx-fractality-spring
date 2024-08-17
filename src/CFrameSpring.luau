--!strict

local RbxLinearSpring = require(script.Parent.RbxLinearSpring)
local RotationSpring = require(script.Parent.Primitives.RotationSpring)

local CFrameSpringClass = {}
CFrameSpringClass.__index = CFrameSpringClass
CFrameSpringClass.ClassName = "CFrameSpring"

export type CFrameSpring = typeof(setmetatable(
	{} :: {
		posInternal: RbxLinearSpring.RbxLinearSpring<Vector3>,
		rotInternal: RotationSpring.RotationSpring,
	},
	CFrameSpringClass
))

-- Constructors

function CFrameSpringClass.new(dampingRatio: number, frequency: number, position: CFrame, goal: CFrame)
	local self = setmetatable({}, CFrameSpringClass) :: CFrameSpring

	self.posInternal = RbxLinearSpring.new(dampingRatio, frequency, position.Position, goal.Position)
	self.rotInternal = RotationSpring.new(dampingRatio, frequency, position.Rotation, goal.Rotation)

	return self
end

-- Public Methods

function CFrameSpringClass.getDampingRatio(self: CFrameSpring)
	return self.posInternal:getDampingRatio()
end

function CFrameSpringClass.getFrequency(self: CFrameSpring)
	return self.posInternal:getFrequency()
end

function CFrameSpringClass.getPosition(self: CFrameSpring)
	local pos = self.posInternal:getPosition()
	local rot = self.rotInternal:getPosition()

	return CFrame.new(pos) * rot
end

function CFrameSpringClass.getVelocity(self: CFrameSpring)
	local pVel = self.posInternal:getVelocity()
	local rVel = self.rotInternal:getVelocity()

	return { pVel[1], pVel[2], pVel[3], rVel.X, rVel.Y, rVel.Z }
end

function CFrameSpringClass.getGoal(self: CFrameSpring)
	local pos = self.posInternal:getGoal()
	local rot = self.rotInternal:getGoal()

	return CFrame.new(pos) * rot
end

function CFrameSpringClass.setDampingRatio(self: CFrameSpring, dampingRatio: number)
	self.posInternal:setDampingRatio(dampingRatio)
	self.rotInternal:setDampingRatio(dampingRatio)
end

function CFrameSpringClass.setFrequency(self: CFrameSpring, frequency: number)
	self.posInternal:setFrequency(frequency)
	self.rotInternal:setFrequency(frequency)
end

function CFrameSpringClass.setPosition(self: CFrameSpring, position: CFrame)
	self.posInternal:setPosition(position.Position)
	self.rotInternal:setPosition(position.Rotation)
end

function CFrameSpringClass.setVelocity(self: CFrameSpring, velocity: { number })
	self.posInternal:setVelocity({ velocity[1], velocity[2], velocity[3] })
	self.rotInternal:setVelocity(Vector3.new(velocity[4], velocity[5], velocity[6]))
end

function CFrameSpringClass.setGoal(self: CFrameSpring, goal: CFrame)
	self.posInternal:setGoal(goal.Position)
	self.rotInternal:setGoal(goal.Rotation)
end

function CFrameSpringClass.canSleep(self: CFrameSpring)
	return self.posInternal:canSleep() and self.rotInternal:canSleep()
end

function CFrameSpringClass.step(self: CFrameSpring, dt: number)
	local pos = self.posInternal:step(dt)
	local rot = self.rotInternal:step(dt)

	return CFrame.new(pos) * rot
end

--

return CFrameSpringClass

--!strict

local RbxLinearSpring = require(script.RbxLinearSpring)
local CFrameSpring = require(script.CFrameSpring)

local FraktalitySpringClass = {}
FraktalitySpringClass.__index = FraktalitySpringClass
FraktalitySpringClass.ClassName = "FraktalitySpring"

export type Supported = RbxLinearSpring.Supported | CFrame

export type FraktalitySpring<T> = typeof(setmetatable(
	{} :: {
		internal: RbxLinearSpring.RbxLinearSpring<T>,
	},
	FraktalitySpringClass
))

-- Constructors

function FraktalitySpringClass.new<T>(
	dampingRatio: number,
	frequency: number,
	position: T & Supported,
	goal: T & Supported
)
	local self = setmetatable({}, FraktalitySpringClass) :: FraktalitySpring<T>

	if typeof(position) == "CFrame" then
		self.internal = (
			CFrameSpring.new(dampingRatio, frequency, position, goal) :: any
		) :: RbxLinearSpring.RbxLinearSpring<T>
	else
		local supportedPos = (position :: any) :: RbxLinearSpring.Supported
		local supportedGoal = (goal :: any) :: RbxLinearSpring.Supported
		self.internal = RbxLinearSpring.new(dampingRatio, frequency, supportedPos, supportedGoal)
	end

	return self
end

-- Public Methods

function FraktalitySpringClass.getDampingRatio<T>(self: FraktalitySpring<T>)
	return self.internal:getDampingRatio()
end

function FraktalitySpringClass.getFrequency<T>(self: FraktalitySpring<T>)
	return self.internal:getFrequency()
end

function FraktalitySpringClass.getPosition<T>(self: FraktalitySpring<T>)
	return self.internal:getPosition()
end

function FraktalitySpringClass.getVelocity<T>(self: FraktalitySpring<T>)
	return self.internal:getVelocity()
end

function FraktalitySpringClass.getGoal<T>(self: FraktalitySpring<T>)
	return self.internal:getGoal()
end

function FraktalitySpringClass.setDampingRatio<T>(self: FraktalitySpring<T>, dampingRatio: number)
	self.internal:setDampingRatio(dampingRatio)
end

function FraktalitySpringClass.setFrequency<T>(self: FraktalitySpring<T>, frequency: number)
	self.internal:setFrequency(frequency)
end

function FraktalitySpringClass.setPosition<T>(self: FraktalitySpring<T>, position: T)
	self.internal:setPosition(position)
end

function FraktalitySpringClass.setVelocity<T>(self: FraktalitySpring<T>, velocity: { number })
	self.internal:setVelocity(velocity)
end

function FraktalitySpringClass.setGoal<T>(self: FraktalitySpring<T>, goal: T)
	self.internal:setGoal(goal)
end

function FraktalitySpringClass.canSleep<T>(self: FraktalitySpring<T>)
	return self.internal:canSleep()
end

function FraktalitySpringClass.step<T>(self: FraktalitySpring<T>, dt: number)
	return self.internal:step(dt)
end

--

return FraktalitySpringClass

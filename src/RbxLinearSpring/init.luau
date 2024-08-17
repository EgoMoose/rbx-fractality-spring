--!strict

local LinearSpring = require(script.Parent.Primitives.LinearSpring)
local Conversion = require(script.Conversion)

-- Class

local RbxLinearSpringClass = {}
RbxLinearSpringClass.__index = RbxLinearSpringClass
RbxLinearSpringClass.ClassName = "RbxLinearSpring"

export type Supported = Conversion.Supported

export type RbxLinearSpring<T> = typeof(setmetatable(
	{} :: {
		metaType: string,
		converter: Conversion.Converter<T>,
		internal: LinearSpring.LinearSpring,
	},
	RbxLinearSpringClass
))

-- Constructors

function RbxLinearSpringClass.new<T>(dampingRatio: number, frequency: number, position: T & Supported, goal: T & Supported)
	local self = setmetatable({}, RbxLinearSpringClass) :: RbxLinearSpring<T>

	self.metaType = typeof(position)
	self.converter = Conversion[self.metaType]

	local convertedPosition = self.converter.serialize(position)
	local convertedGoal = self.converter.serialize(goal)

	self.internal = LinearSpring.new(dampingRatio, frequency, convertedPosition, convertedGoal)

	return self
end

-- Public Methods

function RbxLinearSpringClass.getDampingRatio<T>(self: RbxLinearSpring<T>)
	return self.internal:getDampingRatio()
end

function RbxLinearSpringClass.getFrequency<T>(self: RbxLinearSpring<T>)
	return self.internal:getFrequency()
end

function RbxLinearSpringClass.getPosition<T>(self: RbxLinearSpring<T>)
	return self.converter.deserialize(self.internal.position)
end

function RbxLinearSpringClass.getVelocity<T>(self: RbxLinearSpring<T>)
	return self.internal:getVelocity()
end

function RbxLinearSpringClass.getGoal<T>(self: RbxLinearSpring<T>)
	return self.converter.deserialize(self.internal:getGoal())
end

function RbxLinearSpringClass.setDampingRatio<T>(self: RbxLinearSpring<T>, dampingRatio: number)
	self.internal:setDampingRatio(dampingRatio)
end

function RbxLinearSpringClass.setFrequency<T>(self: RbxLinearSpring<T>, frequency: number)
	self.internal:setFrequency(frequency)
end

function RbxLinearSpringClass.setPosition<T>(self: RbxLinearSpring<T>, position: T)
	self.internal:setPosition(self.converter.serialize(position))
end

function RbxLinearSpringClass.setVelocity<T>(self: RbxLinearSpring<T>, velocity: { number })
	self.internal:setVelocity(velocity)
end

function RbxLinearSpringClass.setGoal<T>(self: RbxLinearSpring<T>, goal: T)
	self.internal:setGoal(self.converter.serialize(goal))
end

function RbxLinearSpringClass.canSleep<T>(self: RbxLinearSpring<T>)
	return self.internal:canSleep()
end

function RbxLinearSpringClass.step<T>(self: RbxLinearSpring<T>, dt: number)
	return self.converter.deserialize(self.internal:step(dt))
end

--

return RbxLinearSpringClass

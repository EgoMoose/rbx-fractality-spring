--!strict

local RbxLinearSpring = require(script.RbxLinearSpring)
local CFrameSpring = require(script.CFrameSpring)

--[=[
	@class FractalitySpring

	A high-performance fully typed spring class based on Fractality's spr library for use in Roblox.
	
	Visualizer: https://www.desmos.com/calculator/rzvw27ljh9
]=]

local FractalitySpringClass = {}
FractalitySpringClass.__index = FractalitySpringClass
FractalitySpringClass.ClassName = "FractalitySpring"

export type Supported = RbxLinearSpring.Supported | CFrame

export type FractalitySpring<T> = typeof(setmetatable(
	{} :: {
		internal: RbxLinearSpring.RbxLinearSpring<T>,
	},
	FractalitySpringClass
))

-- Constructors

--[=[
	@within FractalitySpring
	@function new

	Creates a new spring.

	Supports the following types:
	boolean, number, NumberRange, UDim, UDim2, Vector2, Vector3, Color3, CFrame

	@param dampingRation number
	@param frequency number
	@param position T
	@param goal T
	@return FractalitySpring<T>
]=]
function FractalitySpringClass.new<T>(
	dampingRatio: number,
	frequency: number,
	position: T & Supported,
	goal: T & Supported
)
	local self = setmetatable({}, FractalitySpringClass) :: FractalitySpring<T>

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

--[=[
	@within FractalitySpring
	@method getDampingRatio

	Returns the spring's current damping ratio value.

	@return number
]=]
function FractalitySpringClass.getDampingRatio<T>(self: FractalitySpring<T>)
	return self.internal:getDampingRatio()
end

--[=[
	@within FractalitySpring
	@method getFrequency

	Returns the spring's current frequency value.

	@return number
]=]
function FractalitySpringClass.getFrequency<T>(self: FractalitySpring<T>)
	return self.internal:getFrequency()
end

--[=[
	@within FractalitySpring
	@method getPosition

	Returns the spring's current position.

	@return T
]=]
function FractalitySpringClass.getPosition<T>(self: FractalitySpring<T>)
	return self.internal:getPosition()
end

--[=[
	@within FractalitySpring
	@method getVelocity

	Returns the spring's current velocity. The length of this array depends on the value type of the spring.

	@return { number }
]=]
function FractalitySpringClass.getVelocity<T>(self: FractalitySpring<T>)
	return self.internal:getVelocity()
end

--[=[
	@within FractalitySpring
	@method getGoal

	Returns the spring's current goal.

	@return T
]=]
function FractalitySpringClass.getGoal<T>(self: FractalitySpring<T>)
	return self.internal:getGoal()
end

--[=[
	@within FractalitySpring
	@method setDampingRatio

	Sets the spring's damping ratio.

	@param dampingRatio number
]=]
function FractalitySpringClass.setDampingRatio<T>(self: FractalitySpring<T>, dampingRatio: number)
	self.internal:setDampingRatio(dampingRatio)
end

--[=[
	@within FractalitySpring
	@method setFrequency

	Sets the spring's frequency.

	@param frequency number
]=]
function FractalitySpringClass.setFrequency<T>(self: FractalitySpring<T>, frequency: number)
	self.internal:setFrequency(frequency)
end

--[=[
	@within FractalitySpring
	@method setPosition

	Sets the spring's position.

	@param position T
]=]
function FractalitySpringClass.setPosition<T>(self: FractalitySpring<T>, position: T)
	self.internal:setPosition(position)
end

--[=[
	@within FractalitySpring
	@method setVelocity

	Sets the spring's velocity. The length of this array depends on the value type of the spring.

	@param velocity { number }
]=]
function FractalitySpringClass.setVelocity<T>(self: FractalitySpring<T>, velocity: { number })
	self.internal:setVelocity(velocity)
end

--[=[
	@within FractalitySpring
	@method setGoal

	Sets the spring's goal.

	@param goal T
]=]
function FractalitySpringClass.setGoal<T>(self: FractalitySpring<T>, goal: T)
	self.internal:setGoal(goal)
end

--[=[
	@within FractalitySpring
	@method canSleep

	Provides whether or not the spring can be considered moving or not.

	@return boolean -- if true then the spring is not moving.
]=]
function FractalitySpringClass.canSleep<T>(self: FractalitySpring<T>)
	return self.internal:canSleep()
end

--[=[
	@within FractalitySpring
	@method step

	Steps the spring forward and returns the newly calculated position.

	@param dt number -- the delta-time between last step
	@return T
]=]
function FractalitySpringClass.step<T>(self: FractalitySpring<T>, dt: number)
	return self.internal:step(dt)
end

--

return FractalitySpringClass

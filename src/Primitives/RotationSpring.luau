--!strict

local pi = math.pi
local exp = math.exp
local sin = math.sin
local cos = math.cos
local max = math.max
local sqrt = math.sqrt
local atan2 = math.atan2

local SLEEP_ROTATION_DIFF = math.rad(0.01) -- rad
local SLEEP_ROTATION_VELOCITY = math.rad(0.1) -- rad/s

-- Class

local RotationSpringClass = {}
RotationSpringClass.__index = RotationSpringClass
RotationSpringClass.ClassName = "RotationSpring"

export type RotationSpring = typeof(setmetatable(
	{} :: {
		dampingRatio: number,
		frequency: number,
		position: CFrame,
		velocity: Vector3,
		goal: CFrame,
	},
	RotationSpringClass
))

-- Constructors

function RotationSpringClass.new(dampingRatio: number, frequency: number, position: CFrame, goal: CFrame)
	local self = setmetatable({}, RotationSpringClass) :: RotationSpring

	self.dampingRatio = dampingRatio
	self.frequency = frequency

	self.goal = goal:Orthonormalize()
	self.position = position:Orthonormalize()
	self.velocity = Vector3.zero

	return self
end

-- Private

-- evaluate dot products in high precision
local function dot(v0: Vector3, v1: Vector3)
	return v0.X * v1.X + v0.Y * v1.Y + v0.Z * v1.Z
end

local function areRotationsClose(c0: CFrame, c1: CFrame)
	local rx = dot(c0.XVector, c1.XVector)
	local ry = dot(c0.YVector, c1.YVector)
	local rz = dot(c0.ZVector, c1.ZVector)
	local trace = rx + ry + rz
	return trace > 1 + 2 * cos(SLEEP_ROTATION_DIFF)
end

local function angleDiff(c0: CFrame, c1: CFrame)
	local x = dot(c0.XVector, c1.XVector)
	local y = dot(c0.YVector, c1.YVector)
	local z = dot(c0.ZVector, c1.ZVector)
	local w = x + y + z - 1
	return atan2(sqrt(max(0, 1 - w * w * 0.25)), w * 0.5)
end

-- gives approx. 21% accuracy improvement over CFrame.fromAxisAngle near poles
local function fromAxisAngle(axis: Vector3, angle: number)
	local c = cos(angle)
	local s = sin(angle)
	local x, y, z = axis.X, axis.Y, axis.Z

	local mxy = x * y * (1 - c)
	local myz = y * z * (1 - c)
	local mzx = z * x * (1 - c)

	local rx = Vector3.new(x * x * (1 - c) + c, mxy + z * s, mzx - y * s)
	local ry = Vector3.new(mxy - z * s, y * y * (1 - c) + c, myz + x * s)
	local rz = Vector3.new(mzx + y * s, myz - x * s, z * z * (1 - c) + c)

	return CFrame.fromMatrix(Vector3.zero, rx, ry, rz):Orthonormalize()
end

local function rotateAxis(r0: Vector3, c1: CFrame)
	local c0 = CFrame.identity
	local mag = r0.Magnitude
	if mag > 1e-6 then
		c0 = fromAxisAngle(r0.Unit, mag)
	end
	return c0 * c1
end

-- axis*angle difference between two cframes
local function axisAngleDiff(c0: CFrame, c1: CFrame)
	-- use native axis (stable enough)
	local axis = (c0 * c1:Inverse()):ToAxisAngle()

	-- use full-precision angle calculation to minimize truncation
	local angle = angleDiff(c0, c1)
	return axis.Unit * angle
end

-- Public Methods

function RotationSpringClass.getDampingRatio(self: RotationSpring)
	return self.dampingRatio
end

function RotationSpringClass.getFrequency(self: RotationSpring)
	return self.frequency
end

function RotationSpringClass.getPosition(self: RotationSpring)
	return self.position
end

function RotationSpringClass.getVelocity(self: RotationSpring)
	return self.velocity
end

function RotationSpringClass.getGoal(self: RotationSpring)
	return self.goal
end

function RotationSpringClass.setDampingRatio(self: RotationSpring, dampingRatio: number)
	self.dampingRatio = dampingRatio
end

function RotationSpringClass.setFrequency(self: RotationSpring, frequency: number)
	self.frequency = frequency
end

function RotationSpringClass.setPosition(self: RotationSpring, position: CFrame)
	self.position = position
end

function RotationSpringClass.setVelocity(self: RotationSpring, velocity: Vector3)
	self.velocity = velocity
end

function RotationSpringClass.setGoal(self: RotationSpring, goal: CFrame)
	self.goal = goal
end

function RotationSpringClass.canSleep(self: RotationSpring)
	local sleepP = areRotationsClose(self.position, self.goal)
	local sleepV = self.velocity.Magnitude < SLEEP_ROTATION_VELOCITY
	return sleepP and sleepV
end

function RotationSpringClass.step(self: RotationSpring, dt: number)
	local d = self.dampingRatio
	local f = self.frequency * (2 * pi)
	local g = self.goal
	local p0 = self.position
	local v0 = self.velocity

	local offset = axisAngleDiff(p0, g)
	local decay = exp(-d * f * dt)

	local pt: CFrame
	local vt: Vector3

	if d == 1 then
		-- critically damped
		pt = rotateAxis((offset * (1 + f * dt) + v0 * dt) * decay, g)
		vt = (v0 * (1 - dt * f) - offset * (dt * f * f)) * decay
	elseif d < 1 then
		-- underdamped
		local c = sqrt(1 - d * d)

		local i = cos(dt * f * c)
		local j = sin(dt * f * c)

		local y = j / (f * c)
		local z = j / c

		pt = rotateAxis((offset * (i + z * d) + v0 * y) * decay, g)
		vt = (v0 * (i - z * d) - offset * (z * f)) * decay
	else
		-- overdamped
		local c = sqrt(d * d - 1)

		local r1 = -f * (d + c)
		local r2 = -f * (d - c)

		local co2 = (v0 - offset * r1) / (2 * f * c)
		local co1 = offset - co2

		local e1 = co1 * exp(r1 * dt)
		local e2 = co2 * exp(r2 * dt)

		pt = rotateAxis(e1 + e2, g)
		vt = e1 * r1 + e2 * r2
	end

	self.position = pt
	self.velocity = vt

	return pt
end

--

return RotationSpringClass

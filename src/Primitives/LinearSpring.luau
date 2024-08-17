--!strict

local pi = math.pi
local exp = math.exp
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

local SLEEP_OFFSET_SQ_LIMIT = (1 / 3840) ^ 2 -- square of the offset sleep limit
local SLEEP_VELOCITY_SQ_LIMIT = 1e-2 ^ 2 -- square of the velocity sleep limit
local EPS = 1E-5 -- epsilon for stability checks around pathological frequency/damping values

-- Class

local LinearSpringClass = {}
LinearSpringClass.__index = LinearSpringClass
LinearSpringClass.ClassName = "LinearSpring"

export type LinearSpring = typeof(setmetatable(
	{} :: {
		dampingRatio: number,
		frequency: number,
		position: { number },
		velocity: { number },
		goal: { number },
	},
	LinearSpringClass
))

-- Constructors

function LinearSpringClass.new(dampingRatio: number, frequency: number, position: { number }, goal: { number })
	local self = setmetatable({}, LinearSpringClass) :: LinearSpring

	self.dampingRatio = dampingRatio
	self.frequency = frequency

	self.goal = goal
	self.position = position
	self.velocity = table.create(#position, 0)

	return self
end

-- Private

local function magnitudeSq(vec: { number })
	local out = 0
	for _, v in vec do
		out += v ^ 2
	end
	return out
end

local function distanceSq(vec0: { number }, vec1: { number })
	local out = 0
	for i0, v0 in vec0 do
		out += (vec1[i0] - v0) ^ 2
	end
	return out
end

-- Public Methods

function LinearSpringClass.getDampingRatio(self: LinearSpring)
	return self.dampingRatio
end

function LinearSpringClass.getFrequency(self: LinearSpring)
	return self.frequency
end

function LinearSpringClass.getPosition(self: LinearSpring)
	return self.position
end

function LinearSpringClass.getVelocity(self: LinearSpring)
	return self.velocity
end

function LinearSpringClass.getGoal(self: LinearSpring)
	return self.goal
end

function LinearSpringClass.setDampingRatio(self: LinearSpring, dampingRatio: number)
	self.dampingRatio = dampingRatio
end

function LinearSpringClass.setFrequency(self: LinearSpring, frequency: number)
	self.frequency = frequency
end

function LinearSpringClass.setPosition(self: LinearSpring, position: { number })
	self.position = position
end

function LinearSpringClass.setVelocity(self: LinearSpring, velocity: { number })
	self.velocity = velocity
end

function LinearSpringClass.setGoal(self: LinearSpring, goal: { number })
	self.goal = goal
end

function LinearSpringClass.canSleep(self: LinearSpring)
	if magnitudeSq(self.velocity) > SLEEP_VELOCITY_SQ_LIMIT then
		return false
	end

	if distanceSq(self.position, self.goal) > SLEEP_OFFSET_SQ_LIMIT then
		return false
	end

	return true
end

function LinearSpringClass.step(self: LinearSpring, dt: number)
	--[[
	Advance the spring simulation by dt seconds.
	Take the damped harmonic oscillator ODE:
		f^2*(X[t] - g) + 2*d*f*X'[t] + X''[t] = 0

	Where X[t] is position at time t, g is target position,
	f is undamped angular frequency, and d is damping ratio.
	Apply constant initial conditions:
		X[0] = p0
		X'[0] = v0

	Solve the IVP to get analytic expressions for X[t] and X'[t].
	The solution takes one of three forms for 0<=d<1, d=1, and d>1
	--]]

	local d = self.dampingRatio
	local f = self.frequency * (2 * pi) -- Hz -> Rad/s
	local g = self.goal
	local p = self.position
	local v = self.velocity

	if d == 1 then
		-- critically damped
		local q = exp(-f * dt)
		local w = dt * q

		local c0 = q + w * f
		local c2 = q - w * f
		local c3 = w * f * f

		for idx = 1, #p do
			local o = p[idx] - g[idx]
			p[idx] = o * c0 + v[idx] * w + g[idx]
			v[idx] = v[idx] * c2 - o * c3
		end
	elseif d < 1 then
		-- underdamped
		local q = exp(-d * f * dt)
		local c = sqrt(1 - d * d)

		local i = cos(dt * f * c)
		local j = sin(dt * f * c)

		--[[
		Damping ratios approaching 1 can cause division by very small numbers.
		To mitigate that, group terms around z=j/c and find an approximation for z.
		Start with the definition of z:
			z = sin(dt*f*c)/c

		Substitute a=dt*f:
			z = sin(a*c)/c

		Take the Maclaurin expansion of z with respect to c:
			z = a - (a^3*c^2)/6 + (a^5*c^4)/120 + O(c^6)
			z ≈ a - (a^3*c^2)/6 + (a^5*c^4)/120

		Rewrite in Horner form:
			z ≈ a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6
		--]]

		local z
		if c > EPS then
			z = j / c
		else
			local a = dt * f
			z = a + ((a * a) * (c * c) * (c * c) / 20 - c * c) * (a * a * a) / 6
		end

		--[[
		Frequencies approaching 0 present a similar problem.
		We want an approximation for y as f approaches 0, where:
			y = sin(dt*f*c)/(f*c)

		Substitute b=dt*c:
			y = sin(b*c)/b

		Now reapply the process from z.
		--]]

		local y
		if f * c > EPS then
			y = j / (f * c)
		else
			local b = f * c
			y = dt + ((dt * dt) * (b * b) * (b * b) / 20 - b * b) * (dt * dt * dt) / 6
		end

		for idx = 1, #p do
			local o = p[idx] - g[idx]
			p[idx] = (o * (i + z * d) + v[idx] * y) * q + g[idx]
			v[idx] = (v[idx] * (i - z * d) - o * (z * f)) * q
		end
	else
		-- overdamped
		local c = sqrt(d * d - 1)

		local r1 = -f * (d + c)
		local r2 = -f * (d - c)

		local ec1 = exp(r1 * dt)
		local ec2 = exp(r2 * dt)

		for idx = 1, #p do
			local o = p[idx] - g[idx]
			local co2 = (v[idx] - o * r1) / (2 * f * c)
			local co1 = ec1 * (o - co2)

			p[idx] = co1 + co2 * ec2 + g[idx]
			v[idx] = co1 * r1 + co2 * ec2 * r2
		end
	end

	return self.position
end

--

return LinearSpringClass

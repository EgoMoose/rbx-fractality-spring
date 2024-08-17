--!strict

export type Converter<T> = {
	serialize: (T) -> { number },
	deserialize: ({ number }) -> T,
}

export type Supported = boolean | number | NumberRange | UDim | UDim2 | Vector2 | Vector3 | Color3

local Conversion = {}

-- Data types

Conversion.boolean = {
	serialize = function(value)
		return if value then { 1 } else { 0 }
	end,
	deserialize = function(value)
		return value[1] >= 0.5
	end,
} :: Converter<boolean>

Conversion.number = {
	serialize = function(value)
		return { value }
	end,
	deserialize = function(value)
		return value[1]
	end,
} :: Converter<number>

Conversion.NumberRange = {
	serialize = function(value)
		return { value.Min, value.Max }
	end,
	deserialize = function(value)
		return NumberRange.new(value[1], value[2])
	end,
} :: Converter<NumberRange>

Conversion.UDim = {
	serialize = function(value)
		return { value.Scale, value.Offset }
	end,
	deserialize = function(value)
		return UDim.new(value[1], value[2])
	end,
} :: Converter<UDim>

Conversion.UDim2 = {
	serialize = function(value)
		return { value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset }
	end,
	deserialize = function(value)
		return UDim2.new(value[1], value[2], value[3], value[4])
	end,
} :: Converter<UDim2>

Conversion.Vector2 = {
	serialize = function(value)
		return { value.X, value.Y }
	end,
	deserialize = function(value)
		return Vector2.new(value[1], value[2])
	end,
} :: Converter<Vector2>

Conversion.Vector3 = {
	serialize = function(value)
		return { value.X, value.Y, value.Z }
	end,
	deserialize = function(value)
		return Vector3.new(value[1], value[2], value[3])
	end,
} :: Converter<Vector3>

Conversion.Color3 = {
	serialize = function(value)
		return { value.R, value.G, value.B }
	end,
	deserialize = function(value)
		return Color3.new(value[1], value[2], value[3])
	end,
} :: Converter<Color3>

--

return Conversion

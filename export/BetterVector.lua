local BetterVector = {}
BetterVector.__index = BetterVector

local prefix = "[BetterVector]"

--- Represents a 2D or 3D vector with utility methods
export type Vector = {
    x: number,
    y: number,
    z: number?,
    dim: number,
    _magnitude: number?,

    --- Returns the magnitude (length) of the vector. Cached for performance.
    Magnitude: (self: Vector) -> number,
    --- Returns a unit vector (same direction, magnitude 1). 
    Unit: (self: Vector) -> Vector,
    --- Computes the dot product between this vector and another.
    Dot: (self: Vector, other: Vector) -> number,
    --- Computes the cross product between this vector and another (3D only).
    Cross: (self: Vector, other: Vector) -> Vector,
    --- Converts BetterVector to built-in vec2 or vec3 (for RG API compatibility).
    Convert: (self: Vector) -> vec2 | vec3,
    --- Linearly interpolates between this vector and another by t (0..1).
    Lerp: (self: Vector, v: Vector, t: number) -> Vector,
    --- Returns the distance between this vector and another.
    Distance: (self: Vector, v: Vector) -> number,

    --- Sets the coordinates of the vector in-place.
    Set: (self: Vector, x: number, y: number, z: number?) -> (),
    --- Adds another vector or number to this vector in-place.
    AddSelf: (self: Vector, other: Vector | number) -> (),
    --- Subtracts another vector or number from this vector in-place.
    SubSelf: (self: Vector, other: Vector | number) -> (),
    --- Multiplies this vector by a number in-place.
    MulSelf: (self: Vector, n: number) -> (),
    --- Divides this vector by a number in-place.
    DivSelf: (self: Vector, n: number) -> (),
}

-- PRIVATE FUNCTIONS --
local function eq_dim(a,b) return a.dim == b.dim end
local function is_number(n) return type(n) == "number" end

--- Creates a new BetterVector
--- @param dim number 2 or 3
--- @param x number
--- @param y number
--- @param z number? optional for 3D
--- @return Vector
function BetterVector.new(dim: number, x: number, y: number, z: number?) : Vector?
    if dim ~= 2 and dim ~= 3 then
        error(string.format("%s Unknown dimension", prefix))
    end
    local vec = setmetatable({}, BetterVector)
    vec.dim = dim
    vec.x = x or 0
    vec.y = y or 0
    vec.z = z or 0
    vec._magnitude = nil
    return vec
end

-- ===========================
-- IN-PLACE METHODS
-- ===========================

--- Sets coordinates of the vector
function BetterVector:Set(x,y,z)
    self.x = x or self.x
    self.y = y or self.y
    if self.dim == 3 then self.z = z or self.z end
    self._magnitude = nil
end

--- Adds a vector or number to this vector in-place
function BetterVector:AddSelf(other)
    if getmetatable(other) == BetterVector then
        if not eq_dim(self,other) then error(prefix.." AddSelf: dimension mismatch") end
        self.x += other.x
        self.y += other.y
        if self.dim == 3 then self.z += other.z end
    elseif is_number(other) then
        self.x += other
        self.y += other
        if self.dim == 3 then self.z += other end
    else
        error(prefix.." AddSelf: unsupported type")
    end
    self._magnitude = nil
end

--- Subtracts a vector or number from this vector in-place
function BetterVector:SubSelf(other)
    if getmetatable(other) == BetterVector then
        if not eq_dim(self,other) then error(prefix.." SubSelf: dimension mismatch") end
        self.x -= other.x
        self.y -= other.y
        if self.dim == 3 then self.z -= other.z end
    elseif is_number(other) then
        self.x -= other
        self.y -= other
        if self.dim == 3 then self.z -= other end
    else
        error(prefix.." SubSelf: unsupported type")
    end
    self._magnitude = nil
end

--- Multiplies this vector by a number in-place
function BetterVector:MulSelf(n)
    if not is_number(n) then error(prefix.." MulSelf: n must be number") end
    self.x *= n
    self.y *= n
    if self.dim == 3 then self.z *= n end
    self._magnitude = nil
end

--- Divides this vector by a number in-place
function BetterVector:DivSelf(n)
    if not is_number(n) then error(prefix.." DivSelf: n must be number") end
    self.x /= n
    self.y /= n
    if self.dim == 3 then self.z /= n end
    self._magnitude = nil
end

-- ===========================
-- OPERATORS
-- ===========================

--- Vector addition
function BetterVector.__add(a,b)
    local res = BetterVector.new(a.dim, a.x, a.y, a.z)
    res:AddSelf(b)
    return res
end

--- Vector subtraction
function BetterVector.__sub(a,b)
    local res = BetterVector.new(a.dim, a.x, a.y, a.z)
    res:SubSelf(b)
    return res
end

--- Vector multiplication by number
function BetterVector.__mul(a,b)
    local res = BetterVector.new(a.dim, a.x, a.y, a.z)
    if is_number(b) then res:MulSelf(b)
    elseif is_number(a) then res:MulSelf(a) end
    return res
end

--- Vector division by number
function BetterVector.__div(a,b)
    local res = BetterVector.new(a.dim, a.x, a.y, a.z)
    res:DivSelf(b)
    return res
end

--- Unary minus (negate vector)
function BetterVector.__unm(a)
    local res = BetterVector.new(a.dim, a.x, a.y, a.z)
    res:MulSelf(-1)
    return res
end

--- Converts vector to string for debugging
function BetterVector.__tostring(v)
    if v.dim == 2 then
        return string.format("BetterVector2(%f, %f)", v.x, v.y)
    else
        return string.format("BetterVector3(%f, %f, %f)", v.x, v.y, v.z)
    end
end

-- ===========================
-- CORE METHODS
-- ===========================

--- Returns magnitude (length) of vector
function BetterVector:Magnitude()
    if self.dim == 2 then
        self._magnitude = math.sqrt(self.x^2 + self.y^2)
    else
        self._magnitude = math.sqrt(self.x^2 + self.y^2 + self.z^2)
    end
    return self._magnitude
end

--- Returns normalized unit vector
function BetterVector:Unit()
    local mag = self:Magnitude()
    if mag == 0 then return BetterVector.new(self.dim,0,0,0) end
    local res = BetterVector.new(self.dim, self.x/mag, self.y/mag, self.z and self.z/mag or nil)
    return res
end

--- Computes dot product with another vector
function BetterVector:Dot(other)
    if not eq_dim(self,other) then error(prefix.." Dot: dimension mismatch") end
    if self.dim == 2 then
        return self.x*other.x + self.y*other.y
    else
        return self.x*other.x + self.y*other.y + self.z*other.z
    end
end

--- Computes cross product with another vector (3D only)
function BetterVector:Cross(other)
    if self.dim ~= 3 or other.dim ~= 3 then error(prefix.." Cross only for 3D vectors") end
    return BetterVector.new(3,
        self.y*other.z - self.z*other.y,
        self.z*other.x - self.x*other.z,
        self.x*other.y - self.y*other.x
    )
end

--- Returns distance between this vector and another
function BetterVector:Distance(other)
    return (self - other):Magnitude()
end

--- Linearly interpolates between this vector and another
function BetterVector:Lerp(other,t)
    if not eq_dim(self,other) then error(prefix.." Lerp: dimension mismatch") end
    return self + (other - self) * t
end

--- Reflects this vector along a normal vector
function BetterVector:Reflect(normal)
    return self - normal * (2*self:Dot(normal))
end

--- Converts Vector into vec2/vec3
function BetterVector:Convert()
		if self.dim == 2 then
				return vec2(self.x,self.y)
		else
				return vec3(self.x,self.y,self.z)
		end
end

return BetterVector

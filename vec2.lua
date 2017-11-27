local vec2 = {}
do
    local meta = {
			_metatable = "Private metatable",
			_DESCRIPTION = "vec2s in 2D"
    }

    meta.__index = meta

    function meta:__add( v )
			return vec2(self.x + v.x, self.y + v.y)
    end

    function meta:__sub( v )
			return vec2(self.x - v.x, self.y - v.y)
    end

    function meta:__mul( v )
			if type(v) == "table" then return vec2(self.x * v.x, self.y * v.y) end
			return vec2(self.x * v, self.y * v)
    end

    function meta:__div( v )
			if type(v) == "table" then return vec2(self.x / v.x, self.y / v.y) end
			return vec2(self.x / v, self.y / v)
    end

    function meta:dot( v )
			return self.x * v.x + self.y * v.y
    end

    function meta:length()
			return math.sqrt(self.x * self.x + self.y * self.y)
    end

    function meta:normalized()
			length = self:length()
			if length == 0 then
				return vec2(0, 0)
			end
			return vec2(self.x / length, self.y / length)
    end

    function meta:__tostring()
			return ("<%g, %g>"):format(self.x, self.y)
    end

    function meta:magnitude()
			return math.sqrt( self * self )
    end

    setmetatable( vec2, {
			__call = function( V, x ,y )
				return setmetatable( {x = x or 0, y = y or 0}, meta )
			end
    } )
end

vec2.__index = vec2

return vec2

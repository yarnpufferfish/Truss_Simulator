Load = Object:extend()

local normalize = require("normalize")
local direction = require("direction")
local iso = require("iso")

-- create new instance of Load
function Load:new(index,node,axis,magnitude)
    self.index = index
    self.node = node
    self.axis = axis
    self.magnitude = magnitude

    -- add self to global Loads list
    Loads[index] = self

    -- add load to Loads
    local n1 = Nodes[node]
    n1:add_load(axis,magnitude)
end

-- draw the load
function Load:draw()
    local s = 0.5 -- scale
    local node = Nodes[self.node]
    local x = node.x
    local y = node.y
    local dx, dy,dz = direction(self.axis)

    dx, dy, dz = normalize(dx * self.magnitude, dy * self.magnitude,dz * self.magnitude)

    love.graphics.setColor(settings.load_color)
    love.graphics.setLineWidth(0.01)
    love.graphics.line(x,y,x + dx * s, y + dy * s)

    -- print magnitude
    if settings.draw_load_magnitude then
        local N = math.abs(self.magnitude)
        love.graphics.setColor({0.8, 0.8, 0, 1})
        love.graphics.print(N .. " N",x + dx * s * 1.2,y + dy * s * 1.2,0,0.005,-0.005)
    end
end

-- draw the load
function Load:draw3d()
    local s = 0.5 -- scale
    local node = Nodes[self.node]
    local x = node.x
    local y = node.y
    local z = node.z
    local dx, dy,dz = direction(self.axis)

    dx, dy, dz = normalize(dx * self.magnitude, dy * self.magnitude,dz * self.magnitude)
    x,y = iso(x,y,z)
    dx,dy = iso(dx * s,dy  * s,dz  * s)

    love.graphics.setColor(settings.load_color)
    love.graphics.setLineWidth(0.01)
    love.graphics.line(x,y,x + dx, y + dy)

    -- print magnitude
    if settings.draw_load_magnitude then
        local N = math.abs(self.magnitude)
        love.graphics.setColor({0.8, 0.8, 0, 1})
        love.graphics.print(N .. " N",x + dx * 1.2,y + dy * 1.2,0,0.005,-0.005)
    end
end
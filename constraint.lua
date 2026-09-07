Constraint = Object:extend()

local iso = require("iso")

-- creates new instance of Constraint
function Constraint:new(index,node,axis)
    self.index = index
    self.node = node
    self.axis = axis

    -- add self to global Nodes list
    Constraints[index] = self

    -- add constraint to node
    local n1 = Nodes[node]
    n1:add_constraint(axis)
end

-- draws the constraint
function Constraint:draw()
    love.graphics.setColor(settings.constraints_color)
    local node = Nodes[self.node]
    local x = node.x
    local y = node.y
    local s = 0.1

    if self.axis == "Y" then
        y = y - 0.075
        -- Pin resisting Y movement
        love.graphics.polygon("fill",
            x,     y,
            x - s * 0.5, y - s,
            x + s * 0.5, y - s
        )

    elseif self.axis == "X" then
        x = x - 0.075
        -- Pin resisting X movement
        love.graphics.polygon("fill",
            x,     y,
            x - s, y + s * 0.5,
            x - s, y - s * 0.5
        )
    end
end


-- draws the constraint
function Constraint:draw3d()
    love.graphics.setColor(settings.constraints_color)
    local node = Nodes[self.node]
    local x = node.x
    local y = node.y
    local z = node.z
    local s = 0.1

    if self.axis == "X" then
        y = y - 0.075
        -- Pin resisting Y movement
        local x1,y1 = iso(x,y,z)
        local x2,y2 = iso(x - s * 0.5,y - s,z)
        local x3,y3 = iso(x + s * 0.5,y - s,z)
        love.graphics.polygon("fill",
            x1, y1,
            x2, y2,
            x3, y3
        )

    elseif self.axis == "Y" then
        x = x - 0.075
        -- Pin resisting Y movement
        local x1,y1 = iso(x,y,z)
        local x2,y2 = iso(x - s,y - s * 0.5,z)
        local x3,y3 = iso(x - s,y + s * 0.5,z)
        love.graphics.polygon("fill",
            x1, y1,
            x2, y2,
            x3, y3
        )
    elseif self.axis == "Z" then
        z = z - 0.075
        -- Pin resisting Y movement
        local x1,y1 = iso(x,y,z)
        local x2,y2 = iso(x,y - s * 0.5,z - s)
        local x3,y3 = iso(x,y + s * 0.5,z - s)
        love.graphics.polygon("fill",
            x1, y1,
            x2, y2,
            x3, y3
        )
    end
end
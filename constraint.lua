Constraint = Object:extend()

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
    love.graphics.setColor({0.8, 0, 0.8, 0.8})
    love.graphics.setLineWidth(0.05)
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
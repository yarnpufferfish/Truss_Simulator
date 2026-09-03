Member = Object:extend()

local mats = require("material")
local pi = math.pi
local Pa_to_Pa = require("Pa_to_Pa")

-- creates a new instance of Member
function Member:new(index,node_1,node_2,r,material)
    self.index = index
    self.node_1 = node_1
    self.node_2 = node_2

    local n1 = Nodes[node_1]
    local n2 = Nodes[node_2]

    -- material properties
    self.r = r
    self.material = material
    self.L_nom = math.sqrt((n1.spawn_x - n2.spawn_x)^2 + (n1.spawn_y - n2.spawn_y)^2) -- unstretched length
    self.E = mats[material].E -- Modulus of elasticity ,Pa
    self.I = 0.5 * pi * r^4-- moment of intertia m^4
    self.A = pi * r * r -- m^2

    self.strain = 0
    self.stress = 0
    self.axial_force = 0

    -- yield force
    self.yield_stress = mats[material].Y

    -- buckling criteria
    self.critical_axial_force = pi * pi * self.E * self.I / (self.L_nom^2)
    self.critical_stress = self.critical_axial_force / self.A
    self.critical_strain = self.critical_stress / self.E

    -- add self to global Members list
    Members[index] = self

    -- append connection to nodes 1 and 2
    n1:add_connection(node_2,r,material)
    n2:add_connection(node_1,r,material)
end

-- update the stress conditions
function Member:update()

    local n1 = Nodes[self.node_1]
    local n2 = Nodes[self.node_2]

    local L = math.sqrt((n1.x - n2.x)^2 + (n1.y - n2.y)^2)
    local dL = L - self.L_nom
    self.strain = dL / self.L_nom
    self.stress = self.strain * self.E
    self.axial_force = self.stress * self.A
end

-- draw the member
function Member:draw()
    love.graphics.setColor({0.8,0.8,0.8,1})
    love.graphics.setLineWidth(self.r * 2)
    local x1 = Nodes[self.node_1].x
    local x2 = Nodes[self.node_2].x
    local y1 = Nodes[self.node_1].y
    local y2 = Nodes[self.node_2].y
    love.graphics.line(x1,y1,x2,y2)
    if settings.draw_member_stress then
        local Pa,Units = Pa_to_Pa(self.stress)
        love.graphics.setColor({0,1,0.6,1})
        love.graphics.print(Pa .. Units,(x1 + x2) * 0.5,(y1 + y2) * 0.5,0,0.005,-0.005)
    end
    if settings.draw_member_number then
        love.graphics.setColor({0,0,0,1})
        love.graphics.print(self.index,(x1 + x2) * 0.5 - 0.1,(y1 + y2) * 0.5 + 0.1,0,0.005,-0.005)
    end
end

function Member:draw_original()
    love.graphics.setColor({1,1,1,0.5})
    love.graphics.setLineWidth(self.r * 2)
    local x1 = Nodes[self.node_1].spawn_x
    local x2 = Nodes[self.node_2].spawn_x
    local y1 = Nodes[self.node_1].spawn_y
    local y2 = Nodes[self.node_2].spawn_y
    love.graphics.line(x1,y1,x2,y2)
end
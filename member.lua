Member = Object:extend()

local color = require("colors")
local mats = require("material")
local pi = math.pi
local Pa_to_Pa = require("Pa_to_Pa")
local iso = require("iso")

-- creates a new instance of Member
function Member:new(index,node_1,node_2,r,material)
    self.index = index
    self.node_1 = node_1
    self.node_2 = node_2

    self.is_safe = true
    self.failure_mode = "ERROR"
    self.failure_percentage = 0

    local n1 = Nodes[node_1]
    local n2 = Nodes[node_2]

    -- material properties
    self.r = r
    self.material = material
    self.L_nom = math.sqrt((n1.spawn_x - n2.spawn_x)^2 + (n1.spawn_y - n2.spawn_y)^2 + (n1.spawn_z - n2.spawn_z)^2) -- unstretched length
    self.E = mats[material].E -- Modulus of elasticity ,Pa
    self.I = 0.5 * pi * r^4-- moment of intertia m^4
    self.A = pi * r * r -- m^2
    self.poisson_ratio = mats[material].nu
    self.volume = self.A * self.L_nom -- m^3
    self.density = mats[material].rho -- kg/m^3
    self.m = self.volume * self.density -- kg
    self.strain = 0 -- m/m
    self.stress = 0 -- Pa
    self.axial_force = 0 -- N

    -- yield force
    self.yield_stress = mats[material].Y

    -- buckling criteria
    self.buckling_axial_force = pi * pi * self.E * self.I / (self.L_nom^2)
    self.buckling_stress = self.buckling_axial_force / self.A
    self.buckling_strain = self.buckling_stress / self.E

    -- add self to global Members list
    Members[index] = self

    -- append connection to nodes 1 and 2
    n1:add_connection(node_2,r,material)
    n2:add_connection(node_1,r,material)
end

function Member:delete_self()
    -- delete self from member list
    for i,member in pairs(Members) do
        if member == self then
            table.remove(Members,i)
            break
        end
    end
    -- remove connections from nodes
    local n1 = Nodes[self.node_1]
    local n2 = Nodes[self.node_2]
    n1:remove_connection(self.node_2)
    n2:remove_connection(self.node_1)
end

-- update the stress conditions
function Member:update()

    local n1 = Nodes[self.node_1]
    local n2 = Nodes[self.node_2]

    local L = math.sqrt((n1.x - n2.x)^2 + (n1.y - n2.y)^2 + (n1.z - n2.z)^2)
    local dL = L - self.L_nom
    self.strain = dL / self.L_nom
    self.stress = self.strain * self.E
    self.axial_force = self.stress * self.A

    self:test_for_failure()
    if settings.delete_members_on_failure and not self.is_safe then
        self:delete_self()
    end
end

-- draw the member
function Member:draw()
    local c
    if self.stress < 0 then
        c = color.lerp(settings.zero_stress_color,settings.compression_color,self.failure_percentage)
    else
        c = color.lerp(settings.zero_stress_color,settings.tension_color,self.failure_percentage)
    end

    love.graphics.setColor(c)

    if settings.draw_member_true_size then
        love.graphics.setLineWidth(self.r * 2)
    else
        love.graphics.setLineWidth(settings.not_true_size)
    end

    local x1 = Nodes[self.node_1].x
    local x2 = Nodes[self.node_2].x
    local y1 = Nodes[self.node_1].y
    local y2 = Nodes[self.node_2].y

    love.graphics.line(x1,y1,x2,y2)
    if settings.draw_member_stress then
        local Pa,Units = Pa_to_Pa(self.stress)
        love.graphics.setColor({0,1,0.6,1})
        love.graphics.print(Pa .. Units,(x1 + x2) * 0.5 + 0.1,(y1 + y2) * 0.5 + 0.1,0,0.005,-0.005)
    end
    if settings.draw_member_number then
        love.graphics.setColor(settings.text_color)
        love.graphics.print(self.index,(x1 + x2) * 0.5 - 0.2,(y1 + y2) * 0.5 + 0.1,0,0.005,-0.005)
    end
end

-- draw the member
function Member:draw3d()
    local c
    if self.stress < 0 then
        c = color.lerp(settings.zero_stress_color,settings.compression_color,self.failure_percentage)
    else
        c = color.lerp(settings.zero_stress_color,settings.tension_color,self.failure_percentage)
    end
    
    love.graphics.setColor(c)

    if settings.draw_member_true_size then
        love.graphics.setLineWidth(self.r * 2)
    else
        love.graphics.setLineWidth(settings.not_true_size)
    end

    local x1 = Nodes[self.node_1].x
    local x2 = Nodes[self.node_2].x
    local y1 = Nodes[self.node_1].y
    local y2 = Nodes[self.node_2].y
    local z1 = Nodes[self.node_1].z
    local z2 = Nodes[self.node_2].z
    x1, y1 = iso(x1,y1,z1)
    x2, y2 = iso(x2,y2,z2)
    love.graphics.line(x1,y1,x2,y2)
    if settings.draw_member_stress then
        local Pa,Units = Pa_to_Pa(self.stress)
        love.graphics.setColor({0,1,0.6,1})
        love.graphics.print(Pa .. Units,(x1 + x2) * 0.5 + 0.1,(y1 + y2) * 0.5 + 0.1,0,0.005,-0.005)
    end
    if settings.draw_member_number then
        love.graphics.setColor(settings.text_color)
        love.graphics.print(self.index,(x1 + x2) * 0.5 - 0.2,(y1 + y2) * 0.5 + 0.1,0,0.005,-0.005)
    end
end

function Member:draw_original()
    love.graphics.setColor({1,1,1,0.5})

    if settings.draw_member_true_size then
        love.graphics.setLineWidth(self.r * 2)
    else
        love.graphics.setLineWidth(settings.not_true_size)
    end

    local x1 = Nodes[self.node_1].spawn_x
    local x2 = Nodes[self.node_2].spawn_x
    local y1 = Nodes[self.node_1].spawn_y
    local y2 = Nodes[self.node_2].spawn_y
    love.graphics.line(x1,y1,x2,y2)
end


function Member:draw_original3d()
    love.graphics.setColor({1,1,1,0.5})

    if settings.draw_member_true_size then
        love.graphics.setLineWidth(self.r * 2)
    else
        love.graphics.setLineWidth(settings.not_true_size)
    end

    local x1 = Nodes[self.node_1].spawn_x
    local x2 = Nodes[self.node_2].spawn_x
    local y1 = Nodes[self.node_1].spawn_y
    local y2 = Nodes[self.node_2].spawn_y
    local z1 = Nodes[self.node_1].spawn_z
    local z2 = Nodes[self.node_2].spawn_z
    x1, y1 = iso(x1,y1,z1)
    x2, y2 = iso(x2,y2,z2)
    love.graphics.line(x1,y1,x2,y2)
end

-- determine if the member has failed and why. update yield percentage
function Member:test_for_failure()
    local stress_mag = math.abs(self.stress)
    self.is_safe = true
    self.failure_mode = "ERROR"
    if self.stress < 0 then
        -- under compression, test for buckling, and yielding
        if self.yield_stress > self.buckling_stress then
            -- buckling will occur first
            if stress_mag > self.buckling_stress then
                self.is_safe = false
                self.failure_mode = "buckling"
            end
            self.failure_percentage = stress_mag / self.buckling_stress
        else
            -- yielding will occur first
            if stress_mag > self.yield_stress then
                self.is_safe = false
                self.failure_mode = "compressive yielding"
            end
            self.failure_percentage = stress_mag / self.yield_stress
        end
    else
        if stress_mag > self.yield_stress then
            self.is_safe = false
            self.failure_mode = "tensile yielding"
        end
        self.failure_percentage = stress_mag / self.yield_stress
    end
end
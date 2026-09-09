Node = Object:extend()

local direction = require("direction")
local normalize = require("normalize")
local round = require("round")
local iso = require("iso")
local N_to_N = require("N_to_N")
local mats = require("material")
local pi = math.pi

-- create new instance of Node
function Node:new(index,x,y,z)
    self.index = index
    if not x then
        x = 0
        self.spawn_x = x
    else
        self.spawn_x = x
    end
    if not y then
        y = 0
        self.spawn_y = y
    else
        self.spawn_y = y
    end
    if not z then
        z = 0
        self.spawn_z = z
    else
        self.spawn_z = z
    end
    self.x = x
    self.y = y
    self.z = z

    self.vx = 0
    self.vy = 0
    self.vz = 0

    self.ax = 0
    self.ay = 0
    self.az = 0

    self.fx = 0
    self.fy = 0
    self.fz = 0

    self.m = settings.node_mass -- FIX ME : include this in truss_data
    self.g = settings.g

    self.connections = {}
    self.constraints = {}
    self.loads = {}

    -- add self to global Nodes list
    Nodes[index] = self
end

-- update the physics
function Node:update()
    local dt = Truss_data.time_step
    local alpha = Truss_data.alpha
    -- reset forces
    self.fx = 0
    self.fy = 0
    self.fz = 0

    -- apply gravity loads turn into forces against effective mass
    if settings.apply_gravity then
        self.ax = 0
        self.ay = settings.g
        self.az = 0
    else
        self.ax = 0
        self.ay = 0
        self.az = 0
    end


    -- apply loads
    for _,load in pairs(self.loads) do
        local dx, dy, dz = direction(load.axis)
        dx, dy, dz = normalize(dx,dy,dz)
        self.fx = self.fx + dx * load.magnitude
        self.fy = self.fy + dy * load.magnitude
        self.fz = self.fz + dz * load.magnitude
    end

    -- apply connection loads
    for _,con in pairs(self.connections) do
        local dx = con.x - self.x
        local dy = con.y - self.y
        local dz = con.z - self.z
        con.dL = math.sqrt((dx)^2 + (dy)^2 + (dz)^2) - con.L_nom

        con.strain = con.dL / con.L_nom
        local p_mag = con.strain * con.A * con.E
        dx, dy, dz = normalize(dx,dy,dz)
        self.fx = self.fx + dx * p_mag
        self.fy = self.fy + dy * p_mag
        self.fz = self.fz + dz * p_mag
    end

    -- update acceleration
    self.ax = self.ax + self.fx / self.m
    self.ay = self.ay + self.fy / self.m
    self.az = self.az + self.fz / self.m
    -- update velocity
    self.vx = (self.vx + self.ax * dt) * alpha
    self.vy = (self.vy + self.ay * dt) * alpha
    self.vz = (self.vz + self.az * dt) * alpha
    -- update position
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    self.z = self.z + self.vz * dt
    
    -- apply constraints
    for _,constraint in pairs(self.constraints) do
        if constraint.axis == "X" then
            self.x = self.spawn_x
            self.vx = 0
            self.rx = -self.ax * self.m
        elseif constraint.axis == "Y" then
            self.y = self.spawn_y
            self.vy = 0
            self.ry = -self.ay * self.m
        elseif constraint.axis == "Z" then
            self.z = self.spawn_z
            self.vz = 0
            self.rz = -self.az * self.m
        end
    end
end

-- updates the x and y of each connection
function Node:update_connections()
    for _,con in pairs(self.connections) do
        local n = Nodes[con.node]
        con.x = n.x
        con.y = n.y
        con.z = n.z
    end
end

-- adds a connection
function Node:add_connection(index,r,material)
    local node = Nodes[index]
    local nx = node.spawn_x
    local ny = node.spawn_y
    local nz = node.spawn_z
    local sx = self.spawn_x
    local sy = self.spawn_y
    local sz = self.spawn_z
    table.insert(self.connections,
    {
    node = index, -- index of conneciton
    x = nx,
    y = ny,
    z = nz,
    dL = 0,
    r = r,
    L_nom = math.sqrt((nx - sx)^2 + (ny - sy)^2 + (nz - sz)^2), -- unstretched length
    E = mats[material].E, -- Modulus of elasticity ,Pa
    I = 0.5 * pi * r^4,-- moment of intertia m^4
    A = pi * r * r -- m^2
    }
    )
end

function Node:remove_connection(node)
    for i,connection in pairs(self.connections) do
        if connection.node == node then
            table.remove(self.connections,i)
            break
        end
    end
end

-- adds a constrain axis
function Node:add_constraint(axis)
    table.insert(self.constraints,
    {
    axis = axis
    })
end

-- adds a load on an axis
function Node:add_load(axis,magnitude)
    table.insert(self.loads,
    {
    axis = axis,
    magnitude = magnitude
    })
end

-- draws the node in 2d
function Node:draw()
    love.graphics.setColor(settings.node_color)
    love.graphics.circle("fill",self.x,self.y,settings.node_radius)
    if settings.draw_node_number then
        love.graphics.setColor(settings.text_color)
        love.graphics.print(self.index,self.x + 0.05,self.y - 0.05,0,0.005,-0.005)
    end
end

-- draw the spawn location of the node in 2d
function Node:draw_original()
    love.graphics.setColor({1,1,1,0.5})
    love.graphics.circle("fill",self.spawn_x,self.spawn_y,settings.node_radius)
end


-- draws the node in 3d
function Node:draw3d()
    love.graphics.setColor(settings.node_color)
    local x, y = iso(self.x,self.y,self.z)

    love.graphics.circle("fill",x,y,settings.node_radius)
    if settings.draw_node_number then
        love.graphics.setColor(settings.text_color)
        love.graphics.print(self.index,x + 0.05,y + 0.05,0,0.005,-0.005)
    end
end

-- draw the spawn location of the node in 3d
function Node:draw_original3d()
    love.graphics.setColor({1,1,1,0.5})
    local x,y = iso(self.spawn_x,self.spawn_y,self.spawn_z)
    love.graphics.circle("fill",x,y,settings.node_radius)
end

function Node:draw_reactions3d()
    local x, y = iso(self.x,self.y,self.z)
    if self.rx then
        local s = 0.5 -- scale
        local dx, dy, dz = direction("X")
        if round(self.rx) == 0 then
            s = 0
        else
            dx, dy, dz = normalize(dx * self.rx, dy * self.rx, dz * self.rx)
        end
        dx, dy = iso(dx  * s,dy  * s,dz  * s)
        love.graphics.setColor(settings.reaction_color)
        love.graphics.setLineWidth(0.01)
        love.graphics.line(x,y,x + dx,y + dy)

        -- print magnitude
        if settings.draw_load_magnitude then
            local N,Units = N_to_N(self.rx)
            N = math.abs(N)
            love.graphics.setColor(settings.reaction_color)
            love.graphics.print(N .. Units,x + dx * 1.2,y + dy * 1.2,0,0.005,-0.005)
        end
    end
    if self.ry then
        local s = 0.5 -- scale
        local dx, dy, dz = direction("Y")
        if round(self.ry) == 0 then
            s = 0
        else
            dx, dy, dz = normalize(dx * self.ry, dy * self.ry, dz * self.ry)
        end
        dx, dy = iso(dx * s,dy * s,dz * s)
        love.graphics.setColor(settings.reaction_color)
        love.graphics.setLineWidth(0.01)
        love.graphics.line(x,y,x + dx,y + dy)

        -- print magnitude
        if settings.draw_load_magnitude then
            local N,Units = N_to_N(self.ry)
            N = math.abs(N)
            love.graphics.setColor(settings.reaction_color)
            love.graphics.print(N .. Units,x + dx * 1.2,y + dy * 1.2,0,0.005,-0.005)
        end
    end
    if self.rz and Truss_data.dimensions == 3 then
        local s = 0.5 -- scale
        local dx, dy, dz = direction("Z")
        if round(self.rz) == 0 then
            s = 0
        else
            dx, dy, dz = normalize(dx * self.rz, dy * self.rz, dz * self.rz)
        end
        dx, dy = iso(dx * s,dy * s,dz * s)
        love.graphics.setColor(settings.reaction_color)
        love.graphics.setLineWidth(0.01)
        love.graphics.line(x,y,x + dx,y + dy)

        -- print magnitude
        if settings.draw_load_magnitude then
            local N,Units = N_to_N(self.rz)
            N = math.abs(N)
            love.graphics.setColor(settings.reaction_color)
            love.graphics.print(N .. Units,x + dx * 1.2,y + dy * 1.2,0,0.005,-0.005)
        end
    end
end

function Node:draw_reactions()
    if self.rx then
        local s = 0.5 -- scale
        local dx, dy, dz = direction("X")
        if round(self.rx) == 0 then
            s = 0
        else
            dx, dy, dz = normalize(dx * self.rx, dy * self.rx, dz * self.rx)
        end
        love.graphics.setColor(settings.reaction_color)
        love.graphics.setLineWidth(0.01)
        love.graphics.line(self.x,self.y,self.x + dx * s,self.y + dy * s)

        -- print magnitude
        if settings.draw_load_magnitude then
            local N,Units = N_to_N(self.rx)
            N = math.abs(N)
            love.graphics.setColor(settings.reaction_color)
            love.graphics.print(N .. Units,self.x + dx * 1.2 * s,self.y + dy * 1.2 * s,0,0.005,-0.005)
        end
    end
    if self.ry then
        local s = 0.5 -- scale

        local dx, dy, dz = direction("Y")
        if round(self.ry) == 0 then
            s = 0
        else
            dx, dy = normalize(dx * self.ry, dy * self.ry,  dz * self.ry)
        end

        love.graphics.setColor(settings.reaction_color)
        love.graphics.setLineWidth(0.01)
        love.graphics.line(self.x,self.y,self.x + dx * s,self.y + dy * s)

        -- print magnitude
        if settings.draw_load_magnitude then
            local N,Units = N_to_N(self.ry)
            N = math.abs(N)
            love.graphics.setColor(settings.reaction_color)
            love.graphics.print(N .. Units,self.x + dx * 1.2 * s,self.y + dy * 1.2 * s,0,0.005,-0.005)
        end
    end
end
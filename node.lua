Node = Object:extend()

local direction = require("direction")
local normalize = require("normalize")
local mats = require("material")
local pi = math.pi

-- create new instance of Node
function Node:new(index,x,y)
    self.index = index
    self.spawn_x = x
    self.spawn_y = y

    self.x = x
    self.y = y

    self.vx = 0
    self.vy = 0

    self.ax = 0
    self.ay = 0

    self.fx = 0
    self.fy = 0

    self.m = settings.node_mass
    self.g = settings.g

    self.connections = {}
    self.constraints = {}
    self.loads = {}

    -- add self to global Nodes list
    Nodes[index] = self
end

-- update the physics
function Node:update(dt)
    -- reset forces
    self.fx = 0
    self.fy = 0
    self.ax = 0
    self.ay = 0

    -- apply loads
    for _,load in pairs(self.loads) do
        local dx, dy = direction(load.axis)
        dx,dy = normalize(dx,dy)
        self.fx = self.fx + dx * load.magnitude
        self.fy = self.fy + dy * load.magnitude
    end

    -- apply connection loads
    for _,con in pairs(self.connections) do
        con.dL = math.sqrt((self.x - con.x)^2 + (self.y - con.y)^2) - con.L_nom

        con.strain = con.dL / con.L_nom
        local p_mag = con.strain * con.A * con.E
        local dx, dy = normalize(con.x - self.x,con.y - self.y)
        self.fx = self.fx + dx * p_mag
        self.fy = self.fy + dy * p_mag
    end

    -- apply gravity loads
    if settings.apply_gravity then
        self.fy = self.fy + self.m * settings.g
    end

    -- apply dampening to velocity
    local damping = settings.node_damping
    --self.fx = self.fx - damping * self.vx
    --self.fy = self.fy - damping * self.vy


    -- update acceleration
    self.ax = self.fx / self.m
    self.ay = self.fy / self.m
    -- update velocity
    self.vx = (self.vx + self.ax * dt) * damping
    self.vy = (self.vy + self.ay * dt) * damping
    -- update position
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    
    
    -- apply constraints
    for _,constraint in pairs(self.constraints) do
        if constraint.axis == "X" then
            self.x = self.spawn_x
        elseif constraint.axis == "Y" then
            self.y = self.spawn_y
        end
    end
end

-- updates the x and y of each connection
function Node:update_connections()
    for _,con in pairs(self.connections) do
        local n = Nodes[con.node]
        con.x = n.x
        con.y = n.y
    end
end

-- adds a connection
function Node:add_connection(index,r,material)
    local node = Nodes[index]
    local nx = node.spawn_x
    local ny = node.spawn_y
    local sx = self.spawn_x
    local sy = self.spawn_y
    table.insert(self.connections,
    {
    node = index, -- index of conneciton
    x = nx,
    y = ny,
    dL = 0,
    r = r,
    L_nom = math.sqrt((nx - sx)^2 + (ny - sy)^2), -- unstretched length
    E = mats[material].E, -- Modulus of elasticity ,Pa
    I = 0.5 * pi * r^4,-- moment of intertia m^4
    A = pi * r * r -- m^2
    }
    )
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

-- draws the node 
function Node:draw()
    love.graphics.setColor(settings.node_color)
    love.graphics.circle("fill",self.x,self.y,settings.node_radius)
    if settings.draw_node_number then
        love.graphics.setColor({0,0,0,1})
        love.graphics.print(self.index,self.x,self.y,0,0.005,-0.005)
    end
end

-- draw the spawn location of the node
function Node:draw_original()
    love.graphics.setColor({1,1,1,0.5})
    love.graphics.circle("fill",self.spawn_x,self.spawn_y,settings.node_radius)
end
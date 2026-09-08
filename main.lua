-- main.lua

--- Taj Clark
--- Sept 1, 2026
--- 2D Structural simulator

-- ENTER FILE NAME HERE
-- example files: "truss_3d_extruded.txt" , "truss_2d.txt" , "truss_3d.txt", "pratt_bridge"
text_file_name = "truss_3d.txt"

-- Class Building Tool
Object = require("classic")

-- Initiate classes
require("node")
require("member")
require("load")
require("constraint")
accumulator = 0
local round = require("round")
local iso = require("iso")
local parse_truss_data = require("parse_truss_data")
local direction = require("direction")

function love.load()
    -- Simulation settings
    Load_Tools()

    -- Load Truss Data
    data, size = love.filesystem.read(text_file_name)
    Truss_data = parse_truss_data(data)

    settings.view_dimension = Truss_data.dimensions

    -- Build the simulation
    Reset_Truss()
    Build_Truss()
    Calculate_Mass()
end

function love.update(dt)


    if settings.run_simulation then
        local time_step = Truss_data.time_step
        local simulation_speed = settings.simulation_speed
        accumulator = accumulator + dt * simulation_speed
        while accumulator >= time_step do
            -- Simulation step
            Update_Connections()
            Update_Nodes(time_step)
            Update_Members()

            accumulator = accumulator - time_step
            Truss_data.total_timesteps = Truss_data.total_timesteps + 1
        end
        Truss_data.total_time = Truss_data.total_timesteps * time_step
        Calculate_Equilibrium()
    end

    -- update the game
    mouse:update(dt)
    InputHandler(dt)
    camera:update(dt)
end

function love.draw()
    love.graphics.setCanvas()
    love.graphics.clear(settings.background_color)

    camera:attach()

    if settings.view_dimension == 2 then
        -- Draw gridlines
        gridlines:draw2d()

        -- Draw orginal structure
        Draw_Spawn_Nodes()
        Draw_Spawn_Members()

        -- Draw current structure
        Draw_Members()
        Draw_Nodes()
        Draw_Constraints()
        Draw_Loads()
        Draw_Reactions()
        Draw_Axis()

    else
        -- Draw gridlines
        gridlines:draw3d()

        -- Draw orginal structure
        Draw_Spawn_Nodes3d()
        Draw_Spawn_Members3d()

        -- Draw current structure
        
        Draw_Nodes3d()
        Draw_Members3d()
        Draw_Constraints3d()
        Draw_Loads3d()
        Draw_Reactions3d()
        Draw_Axis3d()

    end

    camera:detach()

    mouse:draw()

    love.graphics.setColor(settings.text_color)
    local kg = math.floor(Truss_data.total_mass * 1000 + 0.5) / 1000
    love.graphics.print("Total mass : " .. kg .. " kg",10,10)
    --love.graphics.print(Truss_data.v_total,400,10)
    if Truss_data.solved then
        love.graphics.print("SOLVED",10,20)
    end

    if settings.run_simulation then
        love.graphics.print("Simulation : RUNNING",300,10)
    else
        love.graphics.print("Simulation : PAUSED",300,10)
    end

    if Truss_data.total_timesteps then
        love.graphics.print("Time Steps : " .. Truss_data.total_timesteps,300,20)
    end
    
    if Truss_data.total_time then
        love.graphics.print("Total Time : " .. round(Truss_data.total_time) .. " s",300,30)
    end
    local offset = 0
    for i,member in pairs(Members) do
        if not member.is_safe then
            love.graphics.print("Member " .. i .. " failed via " .. member.failure_mode,500,10 + offset)
            offset = offset + 10
        end
    end
end

-- create all truss data objects
function Build_Truss()
    Truss_data.alpha = math.exp(-Truss_data.node_damping * Truss_data.time_step)

    local num_joints = #Truss_data.joints
    local num_members = #Truss_data.members

    local extrude = Truss_data.extrude
    local pattern = Truss_data.pattern
    local layers = Truss_data.layers
    local depth = Truss_data.depth
    local dx, dy, dz
    if extrude then
        dx, dy, dz = direction(extrude)
    else
        dx,dy,dz = 0,0,0
    end
    dx, dy, dz = dx * depth, dy * depth, dz * depth

    for i = 0,layers do
        if Truss_data.dimensions == 1 then
            -- create nodes
            for _,j in pairs(Truss_data.joints) do
                Node(j[1] + i * num_joints,j[2] + dx * i,0,0)
            end
        elseif Truss_data.dimensions == 2 then
            -- create nodes
            for _,j in pairs(Truss_data.joints) do
                Node(j[1] + i * num_joints,j[2] + dx * i,j[3] + dy * i,0)
            end
        elseif Truss_data.dimensions == 3 then
            -- create nodes
            for _,j in pairs(Truss_data.joints) do
                Node(j[1] + i * num_joints,j[2] + dx * i,j[3] + dy * i,j[4] + dz * i)
            end
        end
    end

    -- create members
    for i = 0,layers do
        for _,m in pairs(Truss_data.members) do
            Member(m[1] + i * num_members,m[2] + i * num_joints,m[3] + i * num_joints,m[4],m[5])
        end
    end

    -- create extrude members
    local r = settings.extrude_member_r
    local material = settings.extrude_member_material
    for i = 0,layers - 1 do
        for _,j in pairs(Truss_data.joints) do
            Member(#Members + 1,j[1] + i * num_joints,j[1] + (i + 1) * num_joints,r,material)
        end
    end

    local pattern_r = settings.extrude_member_r
    local pattern_material = settings.extrude_member_material
    if pattern then
        for i = 1,layers do
            for j = 1,num_joints do
                local n1 = j + (i - 1) * num_joints
                local k
                if j == num_joints then
                    k = 1
                else
                    k = j + 1
                end
                local nplus =  k + (i) * num_joints
                local b
                if j == 1 then
                    b = num_joints
                else
                    b = j - 1
                end
                local nminus = b + (i) * num_joints
                if pattern == "FORWARD" then
                    Member(#Members + 1, n1, nplus, pattern_r, pattern_material)
                elseif pattern == "BACKWARD" then
                    Member(#Members + 1, n1, nminus, pattern_r, pattern_material)
                elseif pattern == "CROSS" then
                    Member(#Members + 1, n1, nplus, pattern_r, pattern_material)
                    Member(#Members + 1, n1, nminus, pattern_r, pattern_material)
                end
            end
        end
    end

    -- sort the order of Members by draw order

    SortMembersForDrawing()



    -- create constraints
    for _,c in pairs(Truss_data.constraints) do
        Constraint(c[1],c[2],c[3])
    end

    -- create loads
    for _,l in pairs(Truss_data.loads) do
        Load(l[1],l[2],l[3],l[4])
    end

    -- dimensionality (if 2 dimensions apply Z constrain to all nodes)
    if Truss_data.dimensions == 2 then
        for i,_ in ipairs(Nodes) do
            Constraint(#Constraints + 1,i,"Z")
        end
    elseif Truss_data.dimensions == 1 then
        for i,_ in ipairs(Nodes) do
            Constraint(#Constraints + 1,i,"Z")
        end
        for i,_ in ipairs(Nodes) do
            Constraint(#Constraints + 1,i,"Y")
        end
    end
end

-- resets the list of all objects
function Reset_Truss()
    Truss_data.total_timesteps = 0
    Truss_data.total_time = 0
    Nodes = {}
    Members = {}
    Loads = {}
    Constraints = {}
end

-- calculates the mass of the truss
function Calculate_Mass()
    Truss_data.total_mass = 0
    if settings.include_nodes_in_mass_calc then
        for _,node in pairs(Nodes) do
            Truss_data.total_mass = Truss_data.total_mass + node.m
        end
    end
    if settings.include_members_in_mass_calc then
        for _,mem in pairs(Members) do
            Truss_data.total_mass = Truss_data.total_mass + mem.m
        end
    end
end

-- determines if the truss has reached equilibrium
function Calculate_Equilibrium()
    Truss_data.v_total = 0
    Truss_data.solved = false
    for _,node in pairs(Nodes) do
        local nvx, nvy, nvz = node.vx, node.vy, node.vz
        local v_mag = math.sqrt(nvx * nvx + nvy * nvy + nvz * nvz)
        Truss_data.v_total = Truss_data.v_total + v_mag
    end
    if Truss_data.v_total < settings.v_total_max then
        Truss_data.solved = true
    end
end

-- load mouse and camera and settings
function Load_Tools()
    -- set settings
    settings = require("settings")
    tool_mode = "move"
    require("camera")
    camera = Camera()
    require("mouse")
    mouse = Mouse()
    require("gridlines")
    gridlines = Gridlines()
end

-- update the connections of each node
function Update_Connections()
    for _,node in pairs(Nodes) do
        node:update_connections()
    end
end

-- updates the physics of each node
function Update_Nodes(dt)
    for _,node in pairs(Nodes) do
        node:update()
    end
end

-- updates the conditions of each member
function Update_Members()
    for _,member in pairs(Members) do
        member:update()
    end
end

-- draw the X and Y axis to the screen in 2d
function Draw_Axis()
    if settings.draw_axis then
        local L = settings.axis_length
        local size = settings.text_size
        love.graphics.setLineWidth(settings.axis_line_width)
        love.graphics.setColor(settings.x_axis_color)
        love.graphics.line(0,0,L,0) -- draw x axis
        love.graphics.print("X",L,0,0,size * 0.005,-size * 0.005)

        love.graphics.setColor(settings.y_axis_color)
        love.graphics.line(0,0,0,L) -- draw x axis
        love.graphics.print("Y",0,L + 0.1 * size,0,size * 0.005,-size * 0.005)
    end
end

-- draw the X and Y axis to the screen in 3d
function Draw_Axis3d()
    if settings.draw_axis then
        love.graphics.setLineWidth(settings.axis_line_width)
        local size = settings.text_size
        local L = settings.axis_length
        local xx,xy = iso(L,0,0)
        love.graphics.setColor(settings.x_axis_color)
        love.graphics.line(0,0,xx,xy) -- draw x axis
        love.graphics.print("X",xx * 1.1,xy,0,size * 0.005,-size * 0.005)

        local yx,yy = iso(0,L,0)
        love.graphics.setColor(settings.y_axis_color)
        love.graphics.line(0,0,yx,yy) -- draw Y axis
        love.graphics.print("Y",yx,yy * 1.3,0,size * 0.005,-size * 0.005)

        local zx,zy = iso(0,0,L)
        love.graphics.setColor(settings.z_axis_color)
        love.graphics.line(0,0,zx,zy) -- draw Z axis
        love.graphics.print("Z",zx * 1.2,zy,0,size * 0.005,-size * 0.005)
    end
end

-- draw all nodes in 2d
function Draw_Nodes()
    if settings.draw_nodes then
        for _,node in pairs(Nodes) do
            node:draw()
        end
    end
end

-- draw all nodes in 3d
function Draw_Nodes3d()
    if settings.draw_nodes then
        for _,node in pairs(Nodes) do
            node:draw3d()
        end
    end
end

-- draw starting nodes in 2d
function Draw_Spawn_Nodes()
    if settings.draw_original_structure then
        for _,node in pairs(Nodes) do
            node:draw_original()
        end
    end
end

-- draw starting nodes in 3d
function Draw_Spawn_Nodes3d()
    if settings.draw_original_structure then
        for _,node in pairs(Nodes) do
            node:draw_original3d()
        end
    end
end

-- draw starting members in 2d
function Draw_Spawn_Members()
    if settings.draw_original_structure then
        for _,member in pairs(Members) do
            member:draw_original()
        end
    end
end

-- draw starting members in 3d
function Draw_Spawn_Members3d()
    if settings.draw_original_structure then
        for _,member in pairs(Members) do
            member:draw_original3d()
        end
    end
end


-- draw all members in 2d
function Draw_Members()
    if settings.draw_members then
        for _,member in pairs(Members) do
            member:draw()
        end
    end
end

-- draw all members in 3d
function Draw_Members3d()
    if settings.draw_members then
        for _,member in pairs(Members) do
            member:draw3d()
        end
    end
end

-- draw all constraints in 2d
function Draw_Constraints()
    if settings.draw_constraints then
        for _,constraint in pairs(Constraints) do
            constraint:draw()
        end
    end
end


-- draw all constraints in 3d
function Draw_Constraints3d()
    if settings.draw_constraints then
        for _,constraint in pairs(Constraints) do
            constraint:draw3d()
        end
    end
end

-- draw all loads in 2d
function Draw_Loads()
    if settings.draw_loads then
        for _,load in pairs(Loads) do
            load:draw()
        end
    end
end

-- draw all loads in 3d
function Draw_Loads3d()
    if settings.draw_loads then
        for _,load in pairs(Loads) do
            load:draw3d()
        end
    end
end

-- draw all reaction in 2d
function Draw_Reactions()
    if settings.draw_node_reactions then
        for _,node in pairs(Nodes) do
            node:draw_reactions()
        end
    end
end
-- draw all reaction in 3d
function Draw_Reactions3d()
    if settings.draw_node_reactions then
        for _,node in pairs(Nodes) do
            node:draw_reactions3d()
        end
    end
end
-- use mouse tool
function InputHandler(dt)
    -- TOOL HANDLER
    -- if we can use the mouse tools
    if not mouse.disable_tool_this_frame then
        -- choose the correct mouse tool to use
        if tool_mode == "move" then
            mouse:tool_move_camera(dt)
        elseif tool_mode == "push" then
            mouse:tool_push()
        elseif tool_mode == "follow" then
            mouse:tool_fish_food()
        elseif tool_mode == "select" then
            mouse:tool_select()
        end
    end
end

-- calls functions when keys are pressed
function love.keypressed(key)
    if key == "1" then
        tool_mode = "move"
    elseif key == "2" then
        settings.view_dimension = 2
    elseif key == "3" then
        settings.view_dimension = 3
    elseif key == "space" then
        Toggle_Pause()
    elseif key == "w" then
        settings.camera_pitch = settings.camera_pitch + 0.05
        SortMembersForDrawing()
    elseif key == "s" then
        settings.camera_pitch = settings.camera_pitch - 0.05
        SortMembersForDrawing()
    elseif key == "a" then
        settings.camera_yaw = settings.camera_yaw - 0.05
        SortMembersForDrawing()
    elseif key == "d" then
        settings.camera_yaw = settings.camera_yaw + 0.05
        SortMembersForDrawing()

    elseif key == "r" then
        -- Build the simulation
        Reset_Truss()
        Build_Truss()
        Calculate_Mass()
        settings.run_simulation = false
    end
end

-- calls functions when mouse wheel is scrolled
function love.wheelmoved(x, y)
    if mouse then
        mouse:wheelmoved(x, y)
    end
end

-- toggle settings.run_simulation
function Toggle_Pause()
    if settings.run_simulation then
        settings.run_simulation = false
    else
        settings.run_simulation = true
    end
end

function SortMembersForDrawing()
    table.sort(Members, function(a, b)

        local a1 = Nodes[a.node_1]
        local a2 = Nodes[a.node_2]
        local b1 = Nodes[b.node_1]
        local b2 = Nodes[b.node_2]

        local depth_a =
            (-a1.x - a1.y - a1.z
             -a2.x - a2.y - a2.z) * 0.5

        local depth_b =
            (-b1.x - b1.y - b1.z
             -b2.x - b2.y - b2.z) * 0.5

        return depth_a > depth_b
    end)
end
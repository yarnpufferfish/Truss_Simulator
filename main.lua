-- main.lua

--- Taj Clark
--- Sept 1, 2026
--- 2D structural simulator

-- Class Building Tool
Object = require("classic")

-- Initiate classes
require("node")
require("member")
require("load")
require("constraint")

function love.load()
    -- ENTER FILE NAME HERE
    file_name = "user_inputs"

    -- DO NOT CHANGE ANYTHING DOWN FROM HERE
    Truss_data = require(file_name)
    Load_Tools()

    -- build the simulation
    Reset_Truss()
    Build_Truss()
end

function love.update()
    local dt = settings.time_step

    -- Simulation
    Update_Connections()
    Update_Nodes(dt)
    Update_Members()

    -- update the game
    mouse:update(dt)
    InputHandler(dt)
    camera:update(dt)
end

function love.draw()
    love.graphics.setCanvas()
    love.graphics.clear(settings.background_color)

    camera:attach()

    -- Draw gridlines
    gridlines:draw()

    -- Draw axis'
    Draw_Axis()

    -- Draw orginal structure
    Draw_Spawn_Nodes()
    Draw_Spawn_Members()

    -- Draw current structure
    Draw_Nodes()
    Draw_Constraints()
    Draw_Members()
    Draw_Loads()

    camera:detach()

    mouse:draw()

    love.graphics.setColor({1,1,1,1})
    love.graphics.print(camera.zoom,10,10)
end

-- create all truss data objects
function Build_Truss()
    -- create nodes
    for _,j in pairs(Truss_data.joints) do
        Node(j[1],j[2],j[3])
    end

    -- create members
    for _,m in pairs(Truss_data.members) do
        Member(m[1],m[2],m[3],m[4],m[5])
    end

    -- create constraints
    for _,c in pairs(Truss_data.constraints) do
        Constraint(c[1],c[2],c[3])
    end

    -- create loads
    for _,l in pairs(Truss_data.loads) do
        Load(l[1],l[2],l[3],l[4])
    end
end

-- resets the list of all objects
function Reset_Truss()
    Nodes = {}
    Members = {}
    Loads = {}
    Constraints = {}
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
        node:update(dt)
    end
end

-- updates the conditions of each member
function Update_Members()
    for _,member in pairs(Members) do
        member:update()
    end
end

-- draw the X and Y axis to the screen
function Draw_Axis()
    if settings.draw_axis then
        love.graphics.setLineWidth(settings.axis_line_width)
        love.graphics.setColor(settings.x_axis_color)
        love.graphics.line(0,0,settings.axis_length,0) -- draw x axis
        love.graphics.setColor(settings.y_axis_color)
        love.graphics.line(0,0,0,settings.axis_length) -- draw x axis
    end
end

-- draw all nodes
function Draw_Nodes()
    if settings.draw_nodes then
        for _,node in pairs(Nodes) do
            node:draw()
        end
    end
end

-- draw starting nodes
function Draw_Spawn_Nodes()
    if settings.draw_original_structure then
        for _,node in pairs(Nodes) do
            node:draw_original()
        end
    end
end

-- draw starting members
function Draw_Spawn_Members()
    if settings.draw_original_structure then
        for _,member in pairs(Members) do
            member:draw()
        end
    end
end

-- draw all members
function Draw_Members()
    if settings.draw_members then
        for _,member in pairs(Members) do
            member:draw_original()
        end
    end
end

-- draw all constraints
function Draw_Constraints()
    if settings.draw_constraints then
        for _,constraint in pairs(Constraints) do
            constraint:draw()
        end
    end
end

-- draw all loads
function Draw_Loads()
    if settings.draw_loads then
        for _,load in pairs(Loads) do
            load:draw()
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
        tool_mode = "move"
    elseif key == "3" then
        tool_mode = "move"
    elseif key == "4" then
        tool_mode = "move"
    end
end

-- calls functions when mouse wheel is scrolled
function love.wheelmoved(x, y)
    if mouse then
        mouse:wheelmoved(x, y)
    end
end

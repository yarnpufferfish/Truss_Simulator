local truss_data = {}
-- Simulation
truss_data.time_step = 0.0001
truss_data.node_damping = 1

-- Dimension
truss_data.dimensions = 2

-- For 3D
truss_data.extrude = nil
truss_data.pattern = nil
truss_data.layers = nil
truss_data.depth = nil

truss_data.joints = {
    --[[
    input data as 
    {index, x , y}
    example {1, 10, 10}
    ]]--
    {1, 0.0, 0.0},
    {2, 1.0, 2.0},
    {3, 2, 4},
    {4, 3, 7},
}

-- all members are assumed to be circular rods
truss_data.members = {
    --[[
    input data as 
    {index, node 1 index, node 2 index, radius, material}
    example {1, 1, 2, 1e-2, "Aluminum"}
    ]]--
    {1, 1, 2, 1e-2, "Aluminum"},
    {2, 2, 3, 1e-2, "Aluminum"},
    {3, 3, 4, 1e-2, "Aluminum"}
}

truss_data.constraints = {
    --[[
    input data as 
    {index, node index, axis}
    example {1, 1, "X"}
    ]]--
    {1, 1, "X"},
    {2, 1, "Y"},
}

-- loads are defaulted to newtons
truss_data.loads = {
    --[[
    input data as 
    {index, node index, axis, force}
    example {1, 3, "Y", 1e4}
    ]]--
}

return truss_data

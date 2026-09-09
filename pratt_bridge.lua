local truss_data = {}

-- Simulation
truss_data.time_step = 0.0001
truss_data.node_damping = 10

-- Dimension
truss_data.dimensions = 3

-- For 3D
truss_data.extrude = nil
truss_data.pattern = nil
truss_data.layers = nil
truss_data.depth = nil


truss_data.joints = {

    -- Bottom chord / deck joints
    {1,  0.0, 0.0},
    {2,  6.0, 0.0},
    {3, 12.0, 0.0},
    {4, 18.0, 0.0},
    {5, 24.0, 0.0},
    {6, 30.0, 0.0},
    {7, 36.0, 0.0},
    {8, 42.0, 0.0},
    {9, 48.0, 0.0},

    -- Top chord joints
    {10,  0.0, 8.0},
    {11,  6.0, 8.0},
    {12, 12.0, 8.0},
    {13, 18.0, 8.0},
    {14, 24.0, 8.0},
    {15, 30.0, 8.0},
    {16, 36.0, 8.0},
    {17, 42.0, 8.0},
    {18, 48.0, 8.0}
}


-- all members are assumed to be circular rods
truss_data.members = {

    --========================================================
    -- Bottom chord
    --========================================================

    {1,  1, 2, 0.18, "Steel"},
    {2,  2, 3, 0.18, "Steel"},
    {3,  3, 4, 0.18, "Steel"},
    {4,  4, 5, 0.18, "Steel"},
    {5,  5, 6, 0.18, "Steel"},
    {6,  6, 7, 0.18, "Steel"},
    {7,  7, 8, 0.18, "Steel"},
    {8,  8, 9, 0.18, "Steel"},


    --========================================================
    -- Top chord
    --========================================================

    {9,  10, 11, 0.22, "Steel"},
    {10, 11, 12, 0.22, "Steel"},
    {11, 12, 13, 0.22, "Steel"},
    {12, 13, 14, 0.22, "Steel"},
    {13, 14, 15, 0.22, "Steel"},
    {14, 15, 16, 0.22, "Steel"},
    {15, 16, 17, 0.22, "Steel"},
    {16, 17, 18, 0.22, "Steel"},


    --========================================================
    -- Vertical members
    --========================================================

    {17, 1, 10, 0.14, "Steel"},
    {18, 2, 11, 0.14, "Steel"},
    {19, 3, 12, 0.14, "Steel"},
    {20, 4, 13, 0.14, "Steel"},
    {21, 5, 14, 0.16, "Steel"},
    {22, 6, 15, 0.14, "Steel"},
    {23, 7, 16, 0.14, "Steel"},
    {24, 8, 17, 0.14, "Steel"},
    {25, 9, 18, 0.14, "Steel"},


    --========================================================
    -- Pratt diagonals
    --
    -- Left half:
    -- top -> bottom toward center
    --
    -- Right half:
    -- top -> bottom toward center
    --========================================================

    {26, 10, 2, 0.15, "Steel"},
    {27, 11, 3, 0.15, "Steel"},
    {28, 12, 4, 0.15, "Steel"},
    {29, 13, 5, 0.15, "Steel"},

    {30, 18, 8, 0.15, "Steel"},
    {31, 17, 7, 0.15, "Steel"},
    {32, 16, 6, 0.15, "Steel"},
    {33, 15, 5, 0.15, "Steel"}
}


truss_data.constraints = {

    --========================================================
    -- Left support: pinned support
    --
    -- Prevents horizontal and vertical translation.
    --========================================================

    {1, 1, "X"},
    {2, 1, "Y"},


    --========================================================
    -- Right support: roller support
    --
    -- Prevents vertical translation but allows the bridge
    -- to expand/contract horizontally.
    --========================================================

    {4, 9, "X"},
    {5, 9, "Y"},
}


-- loads are defaulted to newtons
truss_data.loads = {

    --========================================================
    -- Dead + live loading on deck
    --
    -- Loads are applied to bottom chord joints because the
    -- deck transfers its load into the truss at these points.
    --
    -- Interior joints:
    -- ~300 kN downward
    --
    -- End joints:
    -- ~150 kN downward
    --========================================================

    {1,  1, "Y", -1e6},
    {2,  2, "Y", -2e6},
    {3,  3, "Y", -3e6},
    {4,  4, "Y", -8e6},
    {5,  5, "Y", -9e6}, -- center node
    {6,  6, "Y", -4e6},
    {7,  7, "Y", -3e6},
    {8,  8, "Y", -2e6},
    {9,  9, "Y", -1e6},
    --{10,  13, "Z", -1e4},
}

return truss_data
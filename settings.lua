
local settings = {}

-- simulation
settings.time_step = 0.0001

-- gravity
settings.g = -9.80665 -- m/s/s
settings.apply_gravity = false -- apply gravity to nodes?

-- node simulation
settings.node_damping = 0.95
settings.node_mass = 1 -- kg -- weight of each node
settings.node_color = {1,1,1,1}
settings.node_radius = 0.025

-- display color
settings.background_color = {0.2,0.2,0.2,1}

-- Draw Settings
-- axis settings
settings.draw_axis = true
settings.x_axis_color = {1,0,0,1}
settings.y_axis_color = {0,1,0,1}
settings.axis_line_width = 0.01
settings.axis_length = 0.25

-- node settings
settings.draw_nodes = true
settings.draw_node_number = true

-- member settings
settings.draw_members = true
settings.draw_member_stress = true
 settings.draw_member_number = true

-- load settings
settings.draw_loads = true
settings.draw_load_magnitude = true

-- constrain settings
settings.draw_constraints = true

-- og structure view
settings.draw_original_structure = true

-- gridline settings
settings.gridlines_spacing = 1
settings.gridlines_thickness = 0.01
settings.gridlines_color = {1,1,1,0.2}

return settings
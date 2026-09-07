
local settings = {}

local color = require("colors")

-- simulation
settings.v_total_max = 1e-5
settings.node_mass = 100 -- kg -- weight of each node
settings.apply_gravity = true -- apply gravity loads to nodes
settings.delete_members_on_failure = false -- not recommended
settings.simulation_speed = 1

-- general
settings.text_size = 1
settings.draw_original_structure = false
settings.view_dimension = 3
settings.g = -9.80665 -- m/s/s
settings.v_total_max = 1e-5 -- the lowest total velocity of a "solved" system

-- mass calculation
settings.draw_mass_calc = true
settings.include_nodes_in_mass_calc = false
settings.include_members_in_mass_calc = true

-- display color
settings.background_color = {0.2,0.2,0.3,1}
settings.text_color = color.invert(settings.background_color)

-- axis settings
settings.draw_axis = true
settings.x_axis_color = {1,0,0,1}
settings.y_axis_color = {0,1,0,1}
settings.z_axis_color = {0,0,1,1}
settings.axis_line_width = 0.01
settings.axis_length = 0.25

-- node settings
settings.draw_nodes = true
settings.node_color = {1,1,1,1}
settings.node_radius = 0.05 -- visual radius

settings.draw_node_number = true

settings.draw_node_reactions = true
settings.reaction_color = {0.7,0,0,1}

-- member settings
settings.draw_members = true
settings.draw_member_stress = true
settings.draw_member_number = true
settings.draw_member_true_size = false
settings.not_true_size = 0.05

-- load settings
settings.draw_loads = true
settings.draw_load_magnitude = true
settings.load_color = {1, 1, 0, 1}

-- constrain settings
settings.draw_constraints = true
settings.constraints_color = {1, 0, 1, 0.6}

-- gridline settings
settings.gridlines_spacing = 1
settings.gridlines_thickness = 0.01
settings.gridlines_color = color.invert(settings.background_color)

return settings
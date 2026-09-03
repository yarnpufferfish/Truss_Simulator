local materials = {}

--[[
required properties of materials:
Name
E = modulus of elasticity
nu = poisson's ratio
Y = yield strength
rho = density

]]


materials.Aluminum = {
    name = "Aluminum",
    E = 7e10,
    nu = 0.33,
    Y = 2.76e8,
    rho = 2.7e3
}

materials.Steel = {
    name = "Steel",
    E = 2.1e11,
    nu = 0.3,
    Y = 5e8,
    rho = 7.85e3
}

materials.Wood = {
    name = "Wood",
    E = 1e10,
    nu = 0.4,
    Y = 3.5e7,
    rho = 5e2
}

return materials
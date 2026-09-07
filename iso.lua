local sqrt3d2 = math.sqrt(3) / 2
local function iso(x, y, z)
    local sx = (-z + x) * sqrt3d2
    local sy = (-z - x) * 0.5 + y

    return sx, sy
end

return iso
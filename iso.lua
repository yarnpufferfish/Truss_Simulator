local sqrt3d2 = math.sqrt(3) / 2
local sqrt2d2 = math.sqrt(2) / 2
local function iso1(x, y, z)
    local sx = (-z + x) * sqrt3d2
    local sy = (-z - x) * 0.5 + y

    return sx, sy
end

local function iso2(x, y, z)
    local sx = (x - z) * sqrt2d2
    local sy = y - (x + z) * sqrt2d2

    return sx, sy
end

local function isoA(x, y, z)
    local angle = settings.camera_angle
    local sx = x * math.cos(angle) - z * math.cos(angle)
    local sy = y - (x + z) * math.sin(angle)

    return sx, sy
end

local function isoCam(x, y, z)
    local yaw = settings.camera_yaw
    local pitch = settings.camera_pitch

    local cy = math.cos(yaw)
    local sy = math.sin(yaw)

    local cp = math.cos(pitch)
    local sp = math.sin(pitch)

    -- Yaw rotation around Y axis
    local x1 = x * cy - z * sy
    local z1 = x * sy + z * cy

    -- Pitch rotation around X axis
    local y2 = y * cp - z1 * sp

    return x1, y2
end

return isoCam

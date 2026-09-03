local function normalize(x,y)
    local mag = math.sqrt(x * x + y * y)
    if mag == 0 then
        return 0,0
    end
    local inv_mag = 1 / mag
    return x * inv_mag, y * inv_mag
end

return normalize

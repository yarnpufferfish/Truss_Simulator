local function Pa_to_Pa(Pa)
    local absPa = math.abs(Pa)

    if absPa < 1e3 then
        return math.floor(Pa * 1000 + 0.5) / 1000, " Pa"
    elseif absPa < 1e6 then
        return math.floor(Pa / 1e3 * 1000 + 0.5) / 1000, " kPa"
    elseif absPa < 1e9 then
        return math.floor(Pa / 1e6 * 1000 + 0.5) / 1000, " MPa"
    else
        return math.floor(Pa / 1e9 * 1000 + 0.5) / 1000, " GPa"
    end
end

return Pa_to_Pa
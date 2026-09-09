local function N_to_N(N)
    local absN = math.abs(N)

    if absN < 1e3 then
        return math.floor(N * 1000 + 0.5) / 1000, " N"
    elseif absN < 1e6 then
        return math.floor(N / 1e3 * 1000 + 0.5) / 1000, " kN"
    elseif absN < 1e9 then
        return math.floor(N / 1e6 * 1000 + 0.5) / 1000, " MN"
    else
        return math.floor(N / 1e9 * 1000 + 0.5) / 1000, " GN"
    end
end

return N_to_N
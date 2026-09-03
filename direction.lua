local function direction(axis)
    if axis == "X" then
        return 1, 0
    elseif axis == "Y" then
        return 0, 1
    end
end

return direction

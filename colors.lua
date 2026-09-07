local colors = {}

function colors.new(n)
    return {colors[n][1],colors[n][2],colors[n][3],colors[n][4]}
end

function colors.random()
    return {math.random(),math.random(),math.random(),1}
end

function colors.invert(c)
    return {math.abs(1 - c[1]),math.abs(1 - c[2]),math.abs(1 - c[3]),1}
end

function colors.copy(c)
    return {c[1],c[2],c[3],c[4]}
end

function colors.lerp(c1, c2, t)
    return {
        c1[1] + (c2[1] - c1[1]) * t,
        c1[2] + (c2[2] - c1[2]) * t,
        c1[3] + (c2[3] - c1[3]) * t,
        c1[4] + (c2[4] - c1[4]) * t,
    }
end

return colors
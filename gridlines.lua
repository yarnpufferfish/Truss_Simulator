Gridlines = Object:extend()

local iso = require("iso")

function Gridlines:new()
    self.spacing = settings.gridlines_spacing
    self.thickness = settings.gridlines_thickness
    self.color = settings.gridlines_color
end

function Gridlines:draw()

    -- world bounds of the screen
    local left   = camera.left
    local right  = camera.right
    local top    = camera.top
    local bottom = camera.bottom
    --local spacing = math.max(self.spacing,self.spacing * 2 ^ math.ceil(0.1 / camera.zoom))
    local spacing = self.spacing
    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(self.thickness)

    -- snap to grid in WORLD space
    local start_x = math.floor(left / spacing) * spacing
    local start_y = math.floor(top / spacing) * spacing

    -- vertical lines (WORLD space iteration)
    for x = start_x, right, spacing do
        local sx = x
        love.graphics.line(sx, top, sx, bottom)
    end

    -- horizontal lines (WORLD space iteration)
    for y = start_y, bottom, spacing do
        local sy = y
        love.graphics.line(left, sy, right, sy)
    end
end


function Gridlines:draw2d()

    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(self.thickness)

    local inf = 10000

    love.graphics.line(inf,0,-inf,0)

    love.graphics.line(0,inf,0,-inf)
end

function Gridlines:draw3d()

    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(self.thickness)

    local inf = 10000
    -- draw x axis
    local x1, y1 = iso(inf,0,0)
    local x2, y2 = iso(-inf,0,0)
    love.graphics.line(x1,y1,x2,y2)
    -- draw y axis
    x1, y1 = iso(0,inf,0)
    x2, y2 = iso(0,-inf,0)
    love.graphics.line(x1,y1,x2,y2)
    -- draw z axis
    x1, y1 = iso(0,0,inf)
    x2, y2 = iso(0,0,-inf)
    love.graphics.line(x1,y1,x2,y2)

end
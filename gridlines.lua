Gridlines = Object:extend()

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
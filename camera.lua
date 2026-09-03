Camera = Object:extend()

function Camera:new()

    self.x = 0
    self.y = 0
    self.zoom = 100

    self.vx = 0
    self.vy = 0

    -- limits to the camera bounds (center of the screen)
    self.limit_x1 = -10000
    self.limit_y1 = -10000

    self.limit_x2 = 10000
    self.limit_y2 = 10000

    -- target for moving center to certain locations
    self.target_x = nil
    self.target_y = nil
    self.lock_to_target = false

    self.damping = 2
    self.max_speed = 300

    self.bounds_stiffness = 10
    self.camera_target_speed = 20

    self.left = 0
    self.right = 0
    self.top = 0
    self.bottom = 0
end

function Camera:update(dt)

    -- movement of the camera
    local absvx = math.abs(self.vx)
    local absvy = math.abs(self.vy)

    if absvx < 0.1 then
        self.vx = 0
    end
    if absvy < 0.1 then
        self.vy = 0
    end

    -- physics
    self:physics(dt)

    self:update_camera_bounds()
end

function Camera:draw()

    -- if there are camera limits then draw them
    if self.limit_x1 and self.limit_y1 and self.limit_x2 and self.limit_y2 then
        love.graphics.setLineWidth(10)
        love.graphics.setColor({1,1,1,1})
        love.graphics.rectangle("line",self.limit_x1,self.limit_y1,self.limit_x2 - self.limit_x1, self.limit_y2 - self.limit_y1)
    end

    --love.graphics.rectangle("line",self.left,self.top,self.right - self.left, self.bottom - self.top)

end

function Camera:physics(dt)
    -- update the physics of scrolling
    self.vx = self.vx * math.exp(-self.damping * dt)
    self.vy = self.vy * math.exp(-self.damping * dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt
    
    -- decay
    local k = self.bounds_stiffness
    local alpha = 1 - math.exp(-k * dt)

    local b = self.camera_target_speed
    local beta = 1 - math.exp(-b * dt)

    if self.target_x and self.target_y then
        local dx = (self.target_x - self.x)
        local dy = (self.target_y - self.y)

        -- if not locking to target, release the hold when we arrive
        if math.sqrt(dx * dx + dy * dy) < 1 then
            if not self.lock_to_target then
            -- release the target
            self.target_x = nil
            self.target_y = nil
            end

            -- move to the target
            self.x = self.x + dx
            self.y = self.y + dy
            self.vx = 0
            self.vy = 0

        else
            -- move the camera normally
            self.x = self.x + dx * beta
            self.y = self.y + dy * beta
        end
    end

    if self.limit_x1 and self.x < self.limit_x1 then
        self.x = self.x + (self.limit_x1 - self.x) * alpha
    end
    if self.limit_y1 and self.y < self.limit_y1 then
        self.y = self.y + (self.limit_y1 - self.y) * alpha
    end

    if self.limit_x2 and self.x > self.limit_x2 then
        self.x = self.x + (self.limit_x2 - self.x) * alpha
    end
    if self.limit_y2 and self.y > self.limit_y2 then
        self.y = self.y + (self.limit_y2 - self.y) * alpha
    end
end

function Camera:set_limits(x1,y1,x2,y2)
    self.limit_x1 = x1
    self.limit_y1 = y1
    self.limit_x2 = x2
    self.limit_y2 = y2
end

function Camera:attach()

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    love.graphics.push()

    -- center screen
    love.graphics.translate(w/2, h/2)

    -- zoom
    love.graphics.scale(self.zoom,-self.zoom)

    -- move camera
    love.graphics.translate(-self.x, self.y)

end

function Camera:detach()
    love.graphics.pop()
end

function Camera:update_camera_bounds()
    local w = love.graphics.getWidth() / self.zoom
    local h = love.graphics.getHeight() / self.zoom
    self.left = self.x - w / 2
    self.right = self.x + w / 2
    self.top = -self.y - h / 2
    self.bottom = -self.y + h / 2
end
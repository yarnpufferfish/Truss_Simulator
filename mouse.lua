Mouse = Object:extend()

local normalize = require "normalize"

function Mouse:new()
self.x = 0
self.y = 0
self.r = 50
self.color = {1,1,1,1}

self.world_x = 0
self.world_y = 0

self.collision_pushback = 3
self.collision_pushback_velocity = 3
self.max_r = 200
self.min_r = 10

self.scroll_sensitivity = 2

self.now_state1 = false
self.last_state1 = false

self.now_state2 = false
self.last_state2 = false

self.selected_dragon = nil
self.selected_segment = nil

self.disable_tool_this_frame = false

self.is_hovering = false
end

function Mouse:update()
    -- get mouse position
    self.last_x , self.last_y = self.x , self.y
    self.x , self.y = love.mouse.getPosition()
    self.world_x = camera.left + self.x / camera.zoom
    self.world_y = camera.top + self.y / camera.zoom

    -- if left click
    self.last_state1 = self.now_state1
    if love.mouse.isDown(1) then
        self.now_state1 = true
    else
        self.now_state1 = false
        self.disable_tool_this_frame = false

    end
    
    -- if right click
    self.last_state2 = self.now_state2
    if love.mouse.isDown(2) then
        self.now_state2 = true
    else
        self.now_state2 = false
    end

    -- reset mouse to is not hovering
    self.is_hovering = false
end

function Mouse:draw()
    
    -- if left click
    if love.mouse.isDown(1) then
        love.graphics.setColor(self.color)
        love.graphics.setLineWidth(3)
        -- draw a circle around the mouse
        
        love.graphics.circle("line",self.x,self.y,50)
    end
end

function Mouse:wheelmoved(x, y)

    --self.r = self.r + y * self.scroll_sensitivity

    -- clamp so it doesn't go negative or tiny
    --if self.r < self.min_r then
        --self.r = self.min_r
    --end

    --if self.r > self.max_r then
        --self.r = self.max_r
    --end


    if y > 0 then
        camera.zoom = camera.zoom * 1.1
    elseif y < 0 then
        camera.zoom = camera.zoom / 1.1
    end

    self.r = 50 / camera.zoom

end

function Mouse:tool_move_camera(dt)

    -- if the mouse is still held add dx dy to camera
    if self.now_state1 and self.last_state1 then
        local dx = (self.x - self.last_x) / camera.zoom
        local dy = (self.y - self.last_y) / camera.zoom

        -- move the camera
        camera.x = camera.x - dx
        camera.y = camera.y - dy
        camera.vx = 0
        camera.vy = 0
    end

    -- if the mouse is released
    if not self.now_state1 and self.last_state1 then

        local dx = (self.x - self.last_x)  / camera.zoom
        local dy = (self.y - self.last_y) / camera.zoom

        local vx = -dx / dt
        local vy = -dy / dt

        local speed = math.sqrt(vx * vx + vy * vy)

        if speed > camera.max_speed then
            local scale = camera.max_speed / speed
            vx = vx * scale
            vy = vy * scale
        end

        camera.vx = vx
        camera.vy = vy
    end


end

function Mouse:tool_push()
    if mouse.now_state1 then
        local collision_pushback = self.collision_pushback
        local collision_pushback_velocity = self.collision_pushback_velocity

        if DebugFlags.fishmousecollisions then
            for _, other in ipairs(Dragons) do
                for i, segment in ipairs(other.segments) do

                    local dx = self.world_x - segment.x
                    local dy = self.world_y - segment.y

                    local dist_sq = dx*dx + dy*dy
                    local min_dist = self.r + segment.r

                    if dist_sq < min_dist*min_dist then

                        local dist = math.sqrt(dist_sq)

                        local nx, ny = normalize(dx,dy)

                        local overlap = min_dist - dist

                        -- push the other.segment[i].x 
                        other.segments[i].x = other.segments[i].x - nx * overlap * collision_pushback / other.segments[i].r
                        other.segments[i].y = other.segments[i].y - ny * overlap * collision_pushback / other.segments[i].r

                        other.vx = other.vx - nx * overlap * collision_pushback_velocity / other.segments[i].r
                        other.vy = other.vy - ny * overlap * collision_pushback_velocity / other.segments[i].r
                    end
                end
            end

            for _, other in ipairs(Leafs) do
                for i, segment in ipairs(other.segments) do

                    local dx = self.world_x - segment.x
                    local dy = self.world_y - segment.y

                    local dist_sq = dx*dx + dy*dy
                    local min_dist = self.r + segment.r

                    if dist_sq < min_dist*min_dist then

                        local dist = math.sqrt(dist_sq)

                        local nx, ny = normalize(dx,dy)

                        local overlap = min_dist - dist

                        -- push the other.segment[i].x 
                        other.segments[i].x = other.segments[i].x - nx * overlap * collision_pushback / other.segments[i].r
                        other.segments[i].y = other.segments[i].y - ny * overlap * collision_pushback / other.segments[i].r
                    end
                end
            end





        end
    end
end

function Mouse:tool_fish_food()
    if self.now_state1 and not self.last_state1 then
        FishFood(self.world_x,self.world_y,10,999)
    end
end

function Mouse:tool_select()

    if self.now_state1 and not self.last_state1 then
        for _, dragon in ipairs(Dragons) do
            if dragon.is_renderable then
                for _,segment in ipairs(dragon.segments) do
                    local dx = self.world_x - segment.x
                    local dy = self.world_y - segment.y
                    if dx * dx + dy * dy < segment.r * segment.r then
                        if self.selected_object == dragon then
                            self.selected_object = nil
                            return
                        else
                            self.selected_object = dragon
                            return
                        end
                    end
                end
            end
        end

        for _, leaf in ipairs(Leafs) do
            if leaf.is_renderable then
                for _,segment in ipairs(leaf.segments) do
                    local dx = self.world_x - segment.x
                    local dy = self.world_y - segment.y
                    if dx * dx + dy * dy < segment.r * segment.r then
                        if self.selected_object == leaf then
                            self.selected_object = nil
                            return
                        else
                            self.selected_object = leaf
                            return
                        end
                    end
                end
            end
        end

        
        for _, plant in ipairs(Plants) do
            if plant.is_renderable then
                for _,segment in ipairs(plant.segments) do
                    local dx = self.world_x - segment.x
                    local dy = self.world_y - segment.y
                    if dx * dx + dy * dy < segment.r * segment.r then
                        if self.selected_object == plant then
                            self.selected_object = nil
                            return
                        else
                            self.selected_object = plant
                            return
                        end
                    end
                end
            end
        end




    end
end
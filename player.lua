local class = require "class"
local StateMachine = require "state_machine"

Player = class()

Player.R = 8
Player.V = 75 
Player.F = 10
Player.I = 5

Player.ACCEL = 50

Player.STANDING = "standing"
Player.JUMPING = "jumping"
Player.FALLING = "falling"

function Player:init(world, x, y)
    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.body:setUserData(self)
    self.body:setFixedRotation(true)
    self.fixtures = {}
    self.fixtures.main = love.physics.newFixture(
        self.body,
        love.physics.newCircleShape(self.R)
    )
    self.fixtures.jumpSensor = love.physics.newFixture(
        self.body,
        love.physics.newCircleShape(0, self.R, 3),
        0
    )
    self.fixtures.jumpSensor:setSensor(true)

    self.sm = StateMachine(self.FALLING)

    self.desiredVx = 0
    self.grounded = false
end

function Player:draw()
    -- debugDrawBody(self.body)
    local x, y = self.body:getPosition()

    love.graphics.circle("fill", x, y, self.R)
end

function Player:update(dt)
    self.sm:update(dt)

    if self.sm:is(self.STANDING) then
        if love.keyboard.isDown("up") then
            self.sm:setNext(self.JUMPING)
        elseif not self.grounded then
            self.sm:setNext(self.FALLING)
        end
    end

    if self.sm:is(self.FALLING) then
        if self.grounded then
            self.sm:setNext(self.STANDING)
        end
    end

    if self.sm:enter(self.JUMPING) then
        print("Enter - JUMPING")
    end

    if self.sm:changed(self.STANDING, self.JUMPING) then
        local vx, _ = self.body:getLinearVelocity()
        self.body:setLinearVelocity(vx, 0)
        self.body:applyLinearImpulse(0, -20)
    end

    if self.sm:enter(self.FALLING) then
        print("Enter - Falling")
    end

    if self.sm:enter(self.STANDING) then
        print("Enter - Standing")
    end

    if self.sm:is(self.JUMPING) then
        self.body:applyForce(0, -30)
    end

    if self.sm:after(self.JUMPING, 0.4) then
        self.sm:setNext(self.FALLING)
    end

    if self.sm:changed(self.JUMPING, self.FALLING) then
        self.body:applyLinearImpulse(0, 8)

        print("FALL!")
    end

    if self.sm:changed(self.FALLING, self.STANDING) then
        print("LAND!")
    end

    if love.keyboard.isDown("left") then
        self.desiredVx = -self.V
    elseif love.keyboard.isDown("right") then
        self.desiredVx = self.V
    else
        self.desiredVx = 0
    end

    self:controll()
end

function Player:controll()
    local vx, _ = self.body:getLinearVelocity()

    if vx < self.desiredVx then
        self.body:applyForce(self.ACCEL, 0)
    elseif vx > self.desiredVx then
        self.body:applyForce(-self.ACCEL, 0)
    end
end

function Player:keypressed(key, scancode, isrepeat)
    if self.sm:is(self.STANDING) and key == "up" then
        self.sm:setNext(self.JUMPING)
    end
end

function Player:keyreleased(key, scancode)
    if key == "up" and self.sm:is(self.JUMPING) then
        self.sm:setNext(self.FALLING)
    end
end

function Player:beginContact(f1, f2, c)
    if f1 == self.fixtures.jumpSensor then
        self.grounded = true
    end
end

function Player:endContact(f1, f2, c)
    if f1 == self.fixtures.jumpSensor then
        self.grounded = false
    end
end

return Player
local class = require "class"
local StateMachine = require "state_machine"
local anim8 = require "lib/anim8"

Player = class()

Player.R = 8
Player.V = 75 
Player.F = 10
Player.I = 5

Player.ACCEL = 50

Player.STANDING = "standing"
Player.JUMPING = "jumping"
Player.FALLING = "falling"

Player.CHARACTER = 3

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
    self.facingRight = true
    self.moving = false

    self.spriteSheet = love.graphics.newImage("characters.png", nil)
    self.spriteGrid = anim8.newGrid(32, 32, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    self.animations = {}
    self.animations.idle = anim8.newAnimation(self.spriteGrid(1, Player.CHARACTER), 0.1)
    self.animations.walking = anim8.newAnimation(self.spriteGrid("1-4", Player.CHARACTER), 0.1)
    self.animations.jumping = anim8.newAnimation(self.spriteGrid(6, Player.CHARACTER), 0.1)
    self.animations.falling = anim8.newAnimation(self.spriteGrid(7, Player.CHARACTER), 0.1)
    self.animations.landing = anim8.newAnimation(self.spriteGrid(8, Player.CHARACTER), 0.1)
    self.animation = self.animations.idle
end

function Player:draw()
    -- DebugDrawBody(self.body)
    local x, y = self.body:getPosition()

    self.animation:draw(self.spriteSheet, x-16, y-25)
end

function Player:update(dt)
    self.sm:update(dt)
    self.animation:update(dt)

    if love.keyboard.isDown("left") then
        self.facingRight = false
        self.moving = true
        self.desiredVx = -self.V
    elseif love.keyboard.isDown("right") then
        self.facingRight = true
        self.moving = true
        self.desiredVx = self.V
    else
        self.moving = false
        self.desiredVx = 0
    end


    if self.sm:is(self.STANDING) then
        if love.keyboard.isDown("up") then
            self.sm:setNext(self.JUMPING)
        elseif not self.grounded then
            self.sm:setNext(self.FALLING)
        end

        if self.sm:from(self.FALLING) and self.sm:before(0.2) then
            self.animation = self.animations.landing
        elseif self.moving then
            self.animation = self.animations.walking
        else
            self.animation = self.animations.idle
        end

    elseif self.sm:is(self.FALLING) then
        self.animation = self.animations.falling

        if self.grounded then
            self.sm:setNext(self.STANDING)
        end

        if self.sm:from(self.JUMPING) and self.sm:enter() then
            self.body:applyLinearImpulse(0, 8) 
        end

    elseif self.sm:is(self.JUMPING) then
        self.body:applyForce(0, -30)
        self.animation = self.animations.jumping

        if self.sm:from(self.STANDING) then
            local vx, _ = self.body:getLinearVelocity()
            self.body:setLinearVelocity(vx, 0)
            self.body:applyLinearImpulse(0, -20)
        end

        if self.sm:after(0.4) then
            self.sm:setNext(self.FALLING)
        end
    end

    self.animation:flipH(not self.facingRight)

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
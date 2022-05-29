local sti = require "lib/sti"

local Camera = require "camera"
local Player = require "player"

local camera, level1, world, player
local ground = {}

local start

function DebugDrawBody(body)
    for _, fixture in ipairs(body:getFixtures()) do
        local shape = fixture:getShape()
        if shape:getType() == "circle" then
            local cx, cy = body:getWorldPoints(shape:getPoint())
            local r = shape:getRadius()
            love.graphics.circle("line", cx, cy, r)
        elseif shape:getType() == "polygon" then
            love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
        end
    end
end

local function onWorldCallback(name)
    return function (f1, f2, ...)      
        local b1 = f1:getBody()
        local b2 = f2:getBody()

        local d1 = b1:getUserData()
        local d2 = b2:getUserData()

        if type(d1) == "table" and d1[name] then
            d1[name](d1, f1, f2, ...)
        end

        if type(d2) == "table" and d2[name] then
            d2[name](d2, f2, f1, ...)
        end
    end
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    world = love.physics.newWorld(0, 100)
    world:setCallbacks(
        onWorldCallback("beginContact"),
        onWorldCallback("endContact"),
        onWorldCallback("preSolve"),
        onWorldCallback("postSolve")
    )

    love.window.setMode(800, 600, { resizable = true })
    level1 = sti("level1.lua")

    start = level1.layers.Info.objects[1]

    for _, collider in ipairs(level1.layers.Collision.objects) do
        local body = love.physics.newBody(world, collider.x+collider.width/2, collider.y+collider.height/2, "static")
        local shape = love.physics.newRectangleShape(collider.width, collider.height)
        love.physics.newFixture(body, shape)
        ground[#ground+1] = body
    end

    camera = Camera(0, 0, 240, 240)

    player = Player(world, start.x, start.y)
end


function love.update(dt)
    world:update(dt)
    player:update(dt)

    camera:moveTo(player.body:getPosition())
end

function love.draw()

    love.graphics.clear(0.247, 0.494, 0.878)

    camera:push()
        love.graphics.print("Hello, LuVE!", 10, 10)


        player:draw()
        level1:drawLayer(level1.layers.Terrain)

        for _, g in ipairs(ground) do
            DebugDrawBody(g)
        end
    camera:pop()
end

function love.keypressed(key, scancode, isrepeat)
    player:keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    player:keyreleased(key, scancode)
end


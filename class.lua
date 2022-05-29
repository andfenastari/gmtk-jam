local M = {}

function M:__call(...)
    local instance = {}
    setmetatable(instance, self)
    instance.class = self
    instance:init(...)

    return instance
end

local function class()
    local klass = {}
    klass.__index = klass

    setmetatable(klass, M)

    return klass
end

return class
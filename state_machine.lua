local class = require "class"

local StateMachine = class()

function StateMachine:init(state)
    self.currentState = state
    self.previousState = nil
    self.nextState = nil
    self.entered = true
    self.duration = 0
end

function StateMachine:setNext(state)
    if self.nextState ~= state then
        self.nextState = state
    end
end

function StateMachine:update(dt)
    if self.nextState then
        self.previousState = self.currentState
        self.currentState = self.nextState
        self.nextState = nil
        self.entered = true
        self.duration = dt
    else
        self.duration = self.duration + dt
        self.entered = false
    end
end

function StateMachine:is(state)
    return self.currentState == state
end

function StateMachine:enter(state)
    return self.currentState == state and self.entered
end

function StateMachine:exit(state)
    return self.previousState == state and self.entered
end

function StateMachine:changed(from, to)
    return self.previousState == from and self.currentState == to and self.entered
end

function StateMachine:before(state, duration)
    return self.currentState == state and self.duration < duration
end

function StateMachine:after(state, duration)
    return self.currentState == state and self.duration > duration
end

function StateMachine:changedBefore(from, to, duration)
    return self.previousState == from and self.currentState == to and self.duration < duration
end

return StateMachine
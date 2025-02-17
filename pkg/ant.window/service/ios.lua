local ltask = require "ltask"
local exclusive = require "ltask.exclusive"
local window = require "window"

local message = {}
local scheduling = exclusive.scheduling()
local SCHEDULE_SUCCESS <const> = 3
local CALL = false
local function update()
    ltask.wakeup "update"
    repeat
        scheduling()
    until ltask.schedule_message() ~= SCHEDULE_SUCCESS
    while CALL do
        exclusive.sleep(1)
        repeat
            scheduling()
        until ltask.schedule_message() ~= SCHEDULE_SUCCESS
    end
end
window.init(message, update)
ltask.fork(function ()
    local ServiceWindow = ltask.queryservice "ant.window|window"
    while true do
        if #message > 0 then
            local mq = {}
            for i = 1, #message do
                mq[i] = message[i]
                message[i] = nil
            end
            CALL = true
            ltask.call(ServiceWindow, "msg", mq)
            CALL = false
        end
        ltask.wait "update"
    end
end)
ltask.fork(function()
    window.mainloop()
    update()
end)

local S = {}

function S.maxfps(fps)
    window.maxfps(fps)
end

return S

-- Copyright (c) 2022, rjt
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

--     * Redistributions of source code must retain the above copyright
--     notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--     notice, this list of conditions and the following disclaimer in the
--     documentation and/or other materials provided with the distribution.
--     * Neither the name of GoodMorning nor the
--     names of its contributors may be used to endorse or promote products
--     derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = "Good Morning"
_addon.author = "rjt"
_addon.version = "1.0"
_addon.commands = { "morning", "goodmorning" }

config = require('config')
defaults = {
    timeout_hr = 6, -- how long before we consider doing timeout actions
    action_delay = 5, -- time between actions

    detect_mouse = false,
    detect_click = true,
    detect_keyboard = true,

    wakeup_actions = T {
        -- "input /servmes",
        "input /lsmes",
        "input /ls2mes"
    }
}

settings = config.load(defaults)

message_stream = function(s) end

idle_time = os.time() -- (settings.timeout_hr * 60 * 60)


function check_idle()
    local time = os.time()

    if (time - idle_time) >= (settings.timeout_hr * 60 * 60) then
        do_wakeup_actions()
    end

    idle_time = time
end

function do_wakeup_actions()
    local actions = settings.wakeup_actions

    local delay = settings.action_delay

    for k, v in ipairs(actions) do
        coroutine.sleep(delay)
        windower.send_command(v)
    end
end

keyboard_evt = nil
mouse_evt = nil
mouse_data = T {
    x = 0,
    y = 0
}

function register_events()
    if settings.detect_keyboard then keyboard_evt = windower.register_event('keyboard', check_idle) end
    if settings.detect_mouse or settings.detect_click then mouse_evt = windower.register_event('mouse',
            function(action, x, y, delta, blocked)
                if settings.detect_click then
                    if action ~= 0 then
                        check_idle()
                    end
                end
                if settings.detect_mouse then
                    if mouse_data.x ~= x or mouse_data.y ~= y then
                        mouse_data.x = x
                        mouse_data.y = y
                        check_idle()
                    end
                end
            end)
    end
end

function unregister_events()
    windower.unregister_event(keyboard_evt, mouse_evt)
end

windower.register_event('addon command', function(...)
    local args = T { ... }
    local command = args[1] and args[1]:lower()
    local cmd_args = args:slice(2)

    local function help_msg()

    end

    local function error_msg(s)

    end

    if not command then
        help_msg()
    elseif command == 'set' then
        if cmd_args[1]:lower() == 'timeout' and cmd_args[2] and tonumber(cmd_args[2]) then
            settings.timeout_hr = tonumber(cmd_args[2])
        elseif cmd_args[1]:lower() == 'delay' and cmd_args[2] and tonumber(cmd_args[2]) then
            settings.action_delay = tonumber(cmd_args[2])
        end
        config.save(settings)
    elseif command == 'add' or command == 'a' or command == '+' then
        if cmd_args[1] then settings.wakeup_actions.insert(cmd_args[1]) else error_msg("Invalid command: ") end
        config.save(settings)
    elseif command == 'del' or command == 'd' or command == '-' then

        config.save(settings)
    elseif command == 'list' then
        windower.add_to_chat(144, 'Wakeup actions: ')
        for k, v in ipairs(settings.wakeup_actions) do
            windower.add_to_chat(144, '  [' .. k .. '] ' .. v)
        end
    end



    -- local command = args[1] and args[1]:lower()

end)

windower.register_event('load', register_events)
windower.register_event('unload', unregister_events)

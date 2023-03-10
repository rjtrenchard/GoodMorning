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

require('csv_simple')
require('tables')
config = require('config')
defaults = {
    timeout_hr = 6, -- how long before we consider doing timeout actions
    action_delay = 5, -- time between actions

    detect_mouse = false,
    detect_click = true,
    detect_keyboard = true,

    actions = "input /lsmes,input /ls2mes"
}

settings = config.load(defaults)
print_target = function(s) windower.add_to_chat(144, s) end

wakeup_actions = csv_to_table(settings.actions)

keyboard_evt = nil
mouse_evt = nil
mouse_data = T {
    x = 0,
    y = 0
}

idle_time = os.time()

-- checks idle time, and updates idle timer
function check_idle()
    local time = os.time()

    if (time - idle_time) >= (settings.timeout_hr * 60 * 60) then
        print_target("You were idle for " .. string.format("%d", (os.time() - idle_time) / 60) .. " minutes.")
        idle_time = time
        do_wakeup_actions()
    end
    idle_time = time
end

-- performs all wakeup actions
function do_wakeup_actions()
    local actions = wakeup_actions

    local delay = settings.action_delay

    for k, v in ipairs(actions) do
        windower.send_command(v)
        coroutine.sleep(delay)
    end
end

function register_events()
    if settings.detect_keyboard then keyboard_evt = windower.register_event('keyboard', check_idle) end
    if settings.detect_mouse or settings.detect_click then
        mouse_evt = windower.register_event('mouse',
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
        print_target('Good Morning!')
        print_target('version ' .. _addon.version)
        print_target('set [timeout,delay] [value] -- sets the duration of timeout or action delay.')
        print_target('toggle [keyboard,click,mouse] -- toggles detection of input')
        print_target('add ["command"] adds a command to execution list')
        print_target('del [index] removes a command at index from execution list')
        print_target('list -- lists functionality of the addon')
    end

    local function error_msg(s)
        print_target(s)
    end

    if not command or command == 'help' then
        help_msg()
        return

    elseif command == 'set' then
        if cmd_args[1]:lower() == 'timeout' and cmd_args[2] and tonumber(cmd_args[2]) then
            settings.timeout_hr = tonumber(cmd_args[2])
        elseif cmd_args[1]:lower() == 'delay' and cmd_args[2] and tonumber(cmd_args[2]) then
            settings.action_delay = tonumber(cmd_args[2])
        end
        config.save(settings)

    elseif command == 'toggle' then
        if cmd_args[1] then
            if cmd_args[1]:lower() == 'keyboard' then
                settings.detect_keyboard = (not settings.detect_keyboard)
            elseif cmd_args[1]:lower() == 'click' then
                settings.detect_click = (not settings.detect_click)
            elseif cmd_args[1]:lower() == 'mouse' then
                settings.detect_mouse = (not settings.detect_mouse)
            else
                error_msg('Error: nothing to toggle')
                return
            end
            config.save(settings)
        end

    elseif command == 'add' or command == 'a' or command == '+' then
        if cmd_args[1] then
            wakeup_actions[#wakeup_actions + 1] = cmd_args[1]
            windower.send_command('morning list')
        else
            error_msg('Error: nothing to add')
        end

        settings.actions = table_to_csv(wakeup_actions)

        config.save(settings)

    elseif command == 'del' or command == 'd' or command == '-' then
        if cmd_args[1] and tonumber(cmd_args[1]) then
            wakeup_actions:remove(cmd_args[1])
            windower.send_command('morning list')
        else
            error_msg("Error: nothing to remove")
        end
        for k, v in ipairs(wakeup_actions) do
            print(k, v)
        end
        settings.actions = table_to_csv(wakeup_actions)
        config.save(settings)

    elseif command == 'list' then
        print_target('Idle timeout: ' .. settings.timeout_hr .. ' hours')
        print_target('Delay: ' .. settings.action_delay .. ' seconds')
        local s = ""
        if settings.detect_keyboard then s = s .. "keyboard " end
        if settings.detect_click then s = s .. "click " end
        if settings.detect_mouse then s = s .. "mouse" end
        print_target('Detecting: ' .. s)
        print_target('Wakeup actions: ')
        for k, v in ipairs(wakeup_actions) do
            print_target('  [' .. k .. '] ' .. v)
        end

    elseif command == 'test' then
        idle_time = os.time() - (settings.timeout_hr * 60 * 60 + 1)
    else
        windower.send_command('morning help')
    end

end)

windower.register_event('load', register_events)
windower.register_event('unload', unregister_events)

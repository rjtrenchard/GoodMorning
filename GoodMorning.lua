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
    timeout_hr = 6,
    action_delay = 2,

    detect_mouse = false,
    detect_click = true,
    detect_keyboard = true,

    wakeup_actions = {
        -- "input /servmes",
        "input /lsmes",
        "input /ls2mes"
    }
}



settings = config.load(defaults)

idle_time = os.time()
seconds_elapsed_target = 0

function update_timeout()
    seconds_elapsed_target = settings.timeout_hr * 60 * 60
end

function check_idle()
    local time = os.time()

    if time > seconds_elapsed_target then
        do_wakeup_actions()
    end

    idle_time = time
end

function do_wakeup_actions()
    local actions = settings.wakeup_actions

    local delay = settings.action_delay

    for k, v in ipairs(actions) do
        print('test')
        coroutine.sleep(delay)
    end

end

keyboard_evt = windower.register_event('keyboard', function(dik, pressed, flags, blocked)
    -- check_idle()
    do_wakeup_actions()
end)

-- windower.register_event('', function(s)

-- end)

windower.register_event('load', function(...)
    seconds_elapsed_target = update_timeout()
end)

windower.register_event('time change', function(old, new)

end)

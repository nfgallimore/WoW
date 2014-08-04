-- Copyright Zarillion FOREVER

MacroPoster = CreateFrame('Frame');

local ADDON_NAME = '|cff3b66dfMacroPoster|r';
local OnLoad, OnEvent, OnUpdate;

if not MacroPosterDB then
    MacroPosterDB = {};
end

--[[ SlashCmdList.MACROPOSTER
Slash command handler for interfacing with this addon. With no arguments,
this command will print a help message to the user describing the available
commands and their functions.

msg                 The message after the command
editbox             The origin of the command
--]]
SLASH_MACROPOSTER1 = '/mp';
SLASH_MACROPOSTER2 = '/macroposter';
function SlashCmdList.MACROPOSTER(msg, editbox)
    if (msg == 'on') then
        MacroPosterDB['enabled'] = true;
        MacroPoster:Print('enabled');
    elseif (msg == 'off') then
        MacroPosterDB['enabled'] = false;
        MacroPoster:Print('disabled');
    elseif (string.match(msg, '^delay %d+$')) then
        delay = tonumber(string.match(msg, '%d+'));
        if (delay < 1 or delay > 15) then
            MacroPoster:Print('delay must be between 1min and 15min');
        else
            MacroPosterDB['delay'] = delay;
            MacroPoster:Print('delay set to', delay, 'minutes');
        end
    elseif (msg == 'delay') then
        MacroPoster:Print('current delay:', MacroPosterDB['delay'], 'minutes');
    elseif (msg == 'count') then
        print_count = MacroPosterDB['print_count'];
        MacroPoster:Print('macro printed', print_count, 'time(s)');
    elseif (msg == 'timer') then
        MacroPoster:PrintMacroTimer();
    else
        MacroPoster:Print('Arguments to /mp:\
on - turns MacroPoster on\
off - turns MacroPoster off\
delay <minutes> - set the delay between messages (in minutes)\
delay - view the current delay\
count - displays total number of prints\
timer - displays remaining seconds until next print');
    end
end

--[[ OnEvent
OnEvent handler which starts different addon functions based on events that
happen in the game.

event               String - The name of the event that was fired
arg1, arg2, ...     Additional arguments passed by the event
--]]
function OnEvent(self, event, ...)
    if (event == 'VARIABLES_LOADED') then
        -- Initialize the database
        if (MacroPosterDB['enabled'] == nil) then
            MacroPosterDB['enabled'] = true;
        end

        if (MacroPosterDB['delay'] == nil) then
            MacroPosterDB['delay'] = 5;
        end

        if (MacroPosterDB['print_count'] == nil) then
            MacroPosterDB['print_count'] = 0;
        end

        if (MacroPosterDB['last_print'] == nil) then
            MacroPosterDB['last_print'] = time() - MacroPosterDB['delay'] * 60 + 10;
        end

        -- Let the user know that MacroPoster has been loaded.
        MacroPoster:Print('loaded successfully.');
        self:SetScript('OnUpdate', OnUpdate);
    end
end

--[[ OnUpdate
OnUpdate handler which will post the macro message at regular intervals
based on the number of minutes specified in MacroPosterDB['delay'].

elapsed             Float - Elapsed time since last call
--]]
function OnUpdate(self, elapsed)
    if (not MacroPosterDB['enabled']) then
        return;
    end

    if (not MacroPoster:TradeChatAvailable()) then
        return;
    end

    last_print = MacroPosterDB['last_print'];
    print_count = MacroPosterDB['print_count'];
    if (time() - last_print > MacroPosterDB['delay'] * 60) then
        MacroPoster:PrintMacro('MacroPoster');
        MacroPosterDB['last_print'] = time();
        MacroPosterDB['print_count'] = print_count + 1;
    end
end

--[[ OnLoad
OnLoad handler which registers in game events, message filters, and in-game
commands which start, end, and manage contests.
--]]
function OnLoad(self)
    self:RegisterEvent('VARIABLES_LOADED');
    self:SetScript('OnEvent', OnEvent);
end

--[[ TradeChatAvailable
Return true if the trade channel is currently available for messaging, false
otherwise.
--]]
function MacroPoster:TradeChatAvailable()
    id1, name1, id2, name2 = GetChannelList();
    return id2 == 2;
end

--[[ MacroPoster:Print
Prepends the addon name to the given message and then outputs it to the user's
system frame.

msg                 Addon message to be printed
--]]
function MacroPoster:Print(...)
    msg = '';
    for i = 1,select('#', ...) do
        v = select(i, ...);
        if (v == nil) then
            v = '(nil)';
        elseif (v == '') then
            v = '(empty)';
        else
            v = tostring(v);
        end
        msg = msg .. v .. ' ';
    end
    color = NORMAL_FONT_COLOR;
    prefix = ADDON_NAME..': %s';
    DEFAULT_CHAT_FRAME:AddMessage(prefix:format(msg), color.r, color.g, color.b);
end

--[[ MacroPoster:PrintMacro
Reads the text of the given macro and sends it to the trade channel.

macro_name          The name of the macro to print
--]]
function MacroPoster:PrintMacro(macro_name)
    macro_text = GetMacroBody(GetMacroIndexByName(macro_name));
    if (macro_text) then
        SendChatMessage(macro_text, 'CHANNEL', nil, '2');
        SendChatMessage(macro_text, 'CHANNEL', nil, '2');
        SendChatMessage(macro_text, 'CHANNEL', nil, '1');
        SendChatMessage(macro_text, 'CHANNEL', nil, '1');
    else
        MacroPoster:Print('warning: no macro named "MacroPoster"');
        MacroPoster:Print('Create the macro or use "/mp off" to disable the timer');
    end
end

--[[ MacroPoster:PrintMacroTimer
Prints the number of seconds remaining until the macro will next be printed
in trade. If the addon is currently disabled, the user will be notified.
--]]
function MacroPoster:PrintMacroTimer()
    if (MacroPosterDB['enabled']) then
        elapsed = time() - MacroPosterDB['last_print'];
        time_left = math.floor(MacroPosterDB['delay'] * 60 - elapsed);
        if (time_left > 0) then
            MacroPoster:Print('next macro prints in', time_left, 'second(s)');
        else
            MacroPoster:Print('next macro will print when you enter trade chat');
        end
    else
        MacroPoster:Print('addon is disabled');
    end
end

OnLoad(MacroPoster);


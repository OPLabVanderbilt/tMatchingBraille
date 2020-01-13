function offset = singleExposure(duration, offsetLimit, window, slack)
%{
Return the offset time after running a single exposure item given a
specific duration, offsetLimit on the target window with a specific slack.
Includes a preparation screen, a short hold, as well as feedback if
participant was too slow to return to spacebar. 
%}

% Restrict keys
RestrictKeysForKbCheck(KbName('space'))

% Participant preparation screen
DrawFormattedText(window, ['Hold down the spacebar and wait for the ' ...
    'Ready!\nWhen you are ready, release and reach for the target ' ...
    'object.\nYou must quickly press the spacebar when the sound plays ' ...
    'and the screen turns black!'], 'center', 'center');
Screen('Flip', window);
KbWait([], 2);

% Brief pause when holding
timer = 0;
while timer < 0.5
    % HOLD!
    DrawFormattedText(window, 'Hold!', 'center', 'center', 0);
    Screen('Flip', window);
    
    if ~KbCheck([])
        % Redraw preparation screen for letting go
        DrawFormattedText(window, ['Hold down the spacebar and wait ' ...
            'for the Ready!\nWhen you release, reach for the target ' ...
            'object.\nYou must quickly press the spacebar when the ' ...
            'sound plays and the screen turns black!'], 'center', ...
            'center', 0);
        Screen('Flip', window);
        KbWait([], 2);
        
        % Reset time 
        timer = 0;
    else
        % Increment timer and pause
        timer = timer + 0.25;
        pause(0.25);
    end
end
    
% Wait for release to start timer
DrawFormattedText(window, 'Ready!', 'center', 'center', 0);
Screen('Flip', window);
time = KbWait([], 1);
DrawFormattedText(window, 'Go!', 'center', 'center', 0);
Screen('Flip', window);

% Return to spacebar
Screen('FillRect', window, [0 0 0]);
DrawFormattedText(window, 'Hit spacebar!', 'center', 'center', 1);
time = Screen('Flip', window, time + (duration / 1000) - slack);
Beeper(400, 0.4, 0.25);

% Wait for response and record offset time
[secs, ~] = KbWait([], 2);
offset = round(1000 * (secs - time));

% Check if offset is over limit
if offset > offsetLimit
    % Display warning screen
    Screen('FillRect', window, [1 0 0]);
    DrawFormattedText(window, 'Hit spacebar faster next time!', ...
        'center', 'center', 0);
    Screen('Flip', window); 
    pause(1.5);
end

% Reset screen
Screen('FillRect', window, [1 1 1]);
Screen('Flip', window);

% Reset KbCheck restrictions
RestrictKeysForKbCheck([]);

end
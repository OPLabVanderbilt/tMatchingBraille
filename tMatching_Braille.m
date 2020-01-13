%{
Same-Different Matching task using pregenerated trials with Braille.
Originally for OT_Beta
Jan12, 2020 - Jason Chow
%}
function tMatching_Braille(sbjID, experimenter, handedness, dataDir)
try
%% Clean up workspace and screen
commandwindow;

Screen('Preference', 'SkipSyncTests', 1);

%% Experiment parameters
windowGap = 100; % Gap between each window
exposureTime = 4000; % Exposure time for each object
testTime = 8000; % Time limit on response
intertrialInterval = 1000; % Minimum gap between trials
interitemInterval = 1000; % Minimum gap between objects within a trial
feedbackTime = 1500; % Time for feedback screens

trialFile = 'tMatchingBrailleTrials.csv';

% Keys for same
sameKeys = {'w', 'e', 'r', 's', 'd', 'f', 'z', 'x', 'c'}; 
% Keys for different
diffKeys = {'i', 'o', 'p', 'k', 'l', ';:', 'm', ',<', '.>'}; 

%% Initialize epxeriment
% Standalone startup if needed
if ~exist('sbjID', 'var') && ~exist('experimenter', 'var') && ...
        ~exist('handedness', 'var')
    inputInfo = inputdlg({'Subject ID', 'Experimenter', 'L.Q.'});
    sbjID = str2double(inputInfo{1});
    experimenter = inputInfo{2};
    handedness = str2double(inputInfo{3});
end

% Check which data directory save to
if ~exist('dataDir', 'var')
    dataDir = 'data';
end
    
% Get inputs from experimenter and create file name
timestamp = char(datetime('now', 'Format', 'MMM-dd-y--HH-mm-ss'));
fileName = strcat(dataDir, '/', sprintf('%03d', sbjID), ...
    '_tMatchingBraille_', timestamp, '.csv');

% Determine main screen dependent on handedness 
if handedness >= 0
    % Right handed
    screenNumber = min(Screen('Screens'));
    altNumber = max(Screen('Screens'));
elseif handedness < 0
    % Left handed
    screenNumber = max(Screen('Screens'));
    altNumber = min(Screen('Screens'));   
end

% Create files
dataFile = fopen(fileName, 'w');
fprintf(dataFile, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n', ...
    'Trial', 'Block', 'Item1', 'Item2', 'CorrResponse', 'Response', ...
    'Corr', 'RT', 'Item1Offset', 'SubjectID', 'LQ', 'Experimenter', ...
    'DateTime');
fclose(dataFile);
dataFormat = '%d,%d,%s,%s,%s,%s,%d,%d,%d,%d,%d,%s,%s\n';

% Read trials file
trials = readtable(trialFile);

% Default setup for psychtoolbox
PsychDefaultSetup(2);

% Silence anymore inputs into matlab
ListenChar(2);
HideCursor();

% Get black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open a window for participant
[window, ~] = PsychImaging('OpenWindow', screenNumber, white);

% Set priority high
prior = Priority(MaxPriority(window));

% Get flip information
flipInt = Screen('GetFlipInterval', window);
slack = flipInt / 2;

% Open a window for experimenter
[expWindow, ~ ] = PsychImaging('OpenWindow', altNumber, white);

%% Instructions
% Preparation screen for experimenter
DrawFormattedText(expWindow, ['Trial practice: participant is reading ' ...
    'instructions.\n\nItem 1: P1\nItem 2: P2'], 'center', 'center', ...
    black);
Screen('Flip', expWindow);

% Prepare beeper
Beeper(400, 0.4, 0.25);

% Restrict to space for instructions
RestrictKeysForKbCheck(KbName('space'));

% Instruction screen for participant
DrawFormattedText(window, ['On this task, you will be asked if two ' ...
    'flat objects are the same.\n\nA pair of objects will be ' ...
    'presented to you individually.\nYou will not have a lot of time ' ...
    'to touch the objects.\nDuring the second object, you have to ' ...
    'decide if the objects are the same or different.\nIf they are ' ...
    'the same, press any of the green keys.\nIf they are different, ' ...
    'press any of the red keys.\n\nPress space to continue.'], ...
    'center', 'center', black);
Screen('Flip', window);
KbWait([], 3);

% Second instruction page
DrawFormattedText(window, ['Throughout this experiment, you should ' ...
    'only use your dominant hand for touching, exploring, and ' ...
    'responding.\nDo not lift or move the items.\nDo not look around ' ...
    'the curtain.\nThere is a time limit for the responses.\nRespond ' ...
    'as quickly as possible without sacrificing accuracy\n\nWe will ' ...
    'start with practice trials.\n\nPress space to continue.'], ...
    'center', 'center', black);
Screen('Flip', window);
KbWait([], 3);

%% Practice trial
trialPract = true;

% Free KB Restrictions
RestrictKeysForKbCheck([]);
% Keep running practice trial until complete
while trialPract
    % Tentatively expect this is the only practice loop needed
    trialPract = false;
    
    % Participant setup wait
    DrawFormattedText(window, ['The experimenter is preparing for the ' ...
        'practice trial.'], 'center', 'center', black);
    Screen('Flip', window);
    
    %% Item 1
    % Experimenter setup
    DrawFormattedText(expWindow, ['Trial practice: participant is ' ...
        'waiting on P1.1\n\nNeed to repeat? ' num2str(trialPract)], ...
        'center', 'center', black);
    Screen('Flip', expWindow);
    GetClicks;
    
    % Experimenter view 
    DrawFormattedText(expWindow, ['Trial practice: participant is ' ...
        'on P1.1\n\nNeed to repeat? ' num2str(trialPract)], 'center', ...
        'center', black);
    Screen('Flip', expWindow);
    
    % Single Exposure
    offset = singleExposure(exposureTime, offsetLimit, window, slack);
    
    % Repeat practice if offset is too long
    if offset > offsetLimit
        trialPract = true;
    end
    
    % Pause between items
    pause(interitemInterval / 1000);
    
    % Waiting for experimenter
    DrawFormattedText(window, ['Experimenter is preparing for the ' ...
        'next part'], 'center', 'center', black);
    Screen('Flip', window);
    
    %% Test phase
    % Experimenter setup
    DrawFormattedText(expWindow, ['Trial practice: participant is ' ...
        'waiting on P1.2\n\nNeed to repeat? ' num2str(trialPract)], ...
        'center', 'center', black);
    Screen('Flip', expWindow);
    GetClicks;
    
    % Blank
    Screen('Flip', expWindow);
    pause(windowGap/1000);
    
    % Experimenter view 
        DrawFormattedText(expWindow, ['Trial practice: participant is ' ...
        'on P1.2\n\nNeed to repeat? ' num2str(trialPract)], 'center', ...
        'center', black);
    Screen('Flip', expWindow);
    
    % Participant preparation screen
    RestrictKeysForKbCheck(KbName('space'));
    DrawFormattedText(window, ['Hold down the spacebar and wait for ' ...
        'the Ready!\nWhen you are ready, release and reach for the ' ...
        'item.\nYou will be presented an item, respond if it ' ...
        'is the same or different than the first.'], 'center', 'center');
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
            DrawFormattedText(window, ['Hold down the spacebar and ' ...
                'wait for the Ready!\nWhen you are ready, release and ' ...
                'reach for the item.\nYou will be presented an item, ' ...
                'respond if it is the same or different than the ' ...
                'first.'], 'center', 'center');
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
    DrawFormattedText(window, 'Ready!', 'center', 'center', black);
    Screen('Flip', window);
    KbWait([], 1);
    DrawFormattedText(window, 'Same or different', 'center', ...
        'center', black);
    time = Screen('Flip', window);
    
    % Unrestrict keys
    RestrictKeysForKbCheck([]);
    
    % Response loop
    keepGoing = true;
    RT = -1;
    response = -1;
    while keepGoing && (GetSecs - time < (testTime/1000))
        % Check keys
        [touch, secs, keyCode] = KbCheck([]);
        
        % There is a key
        if touch
            % Check for same keys
            sameInput = any(arrayfun(@(x) any(x == KbName(sameKeys)), ...
                find(keyCode)));
            % Check for diff keys
            diffInput = any(arrayfun(@(x) any(x == KbName(diffKeys)), ...
                find(keyCode)));
            
            if sameInput && diffInput % Both same and diff keys were pushed
                % Play invalid tone
                Beeper(200, 0.4, 0.1);
            elseif sameInput % Just same keys were pushed
                response = 'same';
                RT = round(1000 * (secs - time));
                keepGoing = false;
            elseif diffInput % Just diff keys were pushed
                response = 'diff';
                RT = round(1000 * (secs - time));
                keepGoing = false;
            else % No valid key was pushed
                % Play invalid tone
                Beeper(200, 0.4, 0.1);
            end
        end
    
        % Pause polling 
        pause(0.0005);
    end
    
    if RT == -1 % timed out
        Screen('FillRect', window, [1 0 0], [0 0 screenX screenY]);
        DrawFormattedText(window, 'Response too slow!', 'center', ...
            'center', black);
        Screen('Flip', window);
        pause(feedbackTime / 1000);
        
        % Reset screen
        Screen('FillRect', window, [1 1 1], [0 0 screenX screenY]);
        
        % Force another practice trial
        trialPract = true;
    else % Some valid response
        % Check if response was wrong
        if strcmp(response, 'same')
            % Feedback
            DrawFormattedText(window, 'That is the incorrect answer.', ...
                'center', 'center', black);
            Screen('Flip', window);
            pause(feedbackTime / 1000);

            % Force another practice trial
            trialPract = true;
        else
            DrawFormattedText(window, 'That is correct!', 'center', ...
                'center', black);
            Screen('Flip', window);
            pause(feedbackTime / 1000);
        end
    end
    
    % Display need to rerun practice if necessary
    if trialPract
        DrawFormattedText(window, 'We will run another practice trial', ...
            'center', 'center', black);
        Screen('Flip', window);
        pause(feedbackTime / 1000);
    else
        DrawFormattedText(window, 'Now onto real trials', 'center', ...
            'center', black);
        Screen('Flip', window);
        pause(feedbackTime / 1000);
    end
end

%% Experiment loop
[trialCount, ~] = size(trials);
block = 1;
trial = 0;
for i = 1:trialCount
    % Check if block break
    if strcmp(trials.Item1(i), '') % It's a break
        RestrictKeysForKbCheck([]);
        DrawFormattedText(window, ['This is a break! Press any button ' ...
            'to continue!'], 'center', 'center', black);
        Screen('Flip', window);
        KbWait([], 3);
        
        % Increment block counter
        block = block + 1;
    else % It's a real trial
        % Increment trial
        trial = trial + 1;
        
        %% Experimenter preparation screen
        % Present waiting screen for participant
        DrawFormattedText(window, ['Please wait as the experimenter ' ...
            'is preparing for the next trial.'], 'center', 'center', ...
            black);
        Screen('Flip', window);
        
        %% Item 1
        % Experimenter screen update
        DrawFormattedText(expWindow, ['Trial ' num2str(trial) ': ' ...
            'participant is waiting for item 1\n\nItem 1: ' ...
            trials.Item1(i) '\nItem 2: ' trials.Item2(i)], 'center', ...
            'center', black);
        Screen('Flip', expWindow);
        GetClicks;
        
        % Blank
        Screen('Flip', expWindow);
        pause(windowGap / 1000);
    
        DrawFormattedText(expWindow, ['Trial ' num2str(trial) ': ' ...
            'participant is on item 1\n\nItem 1: ' trials.Item1(i) ...
            '\nItem 2: ' trials.Item2(i)], 'center', 'center', black);
        Screen('Flip', expWindow);
        
        % Single Exposure
        item1Offset = singleExposure(exposureTime, offsetLimit, window, ...
            slack);
        
        % Interitem interval
        pause(interitemInterval / 1000);
        
        % Wait for experimenter
        DrawFormattedText(window, ['Experimenter is preparing for the ' ...
            'next part.'], 'center', 'center', black);
        Screen('Flip', window);
        
        %% Test phase
        % Preparation screen
        DrawFormattedText(expWindow, ['Trial ' num2str(trial) ': ' ...
            'participant is waiting for item 2\n\nItem 1: ' ...
            trials.Item1(i) '\nItem 2: ' trials.Item2(i)], 'center', ...
            'center', black);
        Screen('Flip', expWindow);
        GetClicks;
        
        % Blank
        Screen('Flip', expWindow);
        pause(windowGap / 1000); 
        
        DrawFormattedText(expWindow, ['Trial ' num2str(trial) ': ' ...
            'participant is on item 2\n\nItem 1: ' trials.Item1(i) ...
            '\nItem 2: ' trials.Item2(i)], 'center', 'center', black);
        Screen('Flip', expWindow);
        
        % Participant preparation screen
        RestrictKeysForKbCheck(KbName('space'));
        DrawFormattedText(window, ['Hold down the spacebar and wait ' ...
            'for the Ready!\nWhen you are ready, release and reach ' ...
            'for the item.\nYou will be presented an item, respond if ' ...
            'it is the same or different than the first.'], 'center', ...
            'center');
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
                DrawFormattedText(window, ['Hold down the spacebar ' ...
                    'and wait for the Ready!\nWhen you are ready, ' ...
                    'release and reach for the item.\nYou will be ' ...
                    'presented an item, respond if it is the same or ' ...
                    'different than the first.'], 'center', 'center');
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
        
        % Show prepreparation window for experimenter
        if i == trialCount
            % Experiment is over
            DrawFormattedText(expWindow, 'The experiment is over.', ...
                'center', 'center', black);
            Screen('Flip', expWindow);
        elseif strcmp(trials.Item1(i + 1), '')
            % Next trial is a break
            DrawFormattedText(expWindow, 'The next trial is a break.', ...
                'center', 'center', black);
            Screen('Flip', expWindow);
        else
            % Flash blank
            Screen('Flip', expWindow);
            pause(0.25);
            
            % Prepare for next trial
            DrawFormattedText(expWindow, ['The next trial is trial ' ...
                num2str(trial + 1) '\n\nItem 1: ' trials.Item1(i + 1) ...
                '\nItem 2: ' trials.Item2(i + 1)], 'center', 'center', ...
                black);
            Screen('Flip', expWindow);
        end
        
        % Wait for release to start timer
        DrawFormattedText(window, 'Ready!', 'center', 'center', black);
        Screen('Flip', window);
        time = KbWait([], 1);
        DrawFormattedText(window, 'Same or Different', 'center', ...
            'center', black);
        Screen('Flip', window);

        % Unrestrict keys
        RestrictKeysForKbCheck([]);

        % Response loop
        keepGoing = true;
        RT = -1;
        response = 'invalid';
        while keepGoing && (GetSecs - time < (testTime/1000))
            % Check keys
            [touch, secs, keyCode] = KbCheck([]);

            % There is a key
            if touch
                % Check for same keys
                sameInput = any(arrayfun(@(x) any(x == KbName(sameKeys)), ...
                    find(keyCode)));
                % Check for diff keys
                diffInput = any(arrayfun(@(x) any(x == KbName(diffKeys)), ...
                    find(keyCode)));

                if sameInput && diffInput % Both same and diff keys were pushed
                    % Play invalid tone
                    Beeper(200, 0.4, 0.1);
                elseif sameInput % Just same keys were pushed
                    response = 'same';
                    RT = round(1000 * (secs - time));
                    keepGoing = false;
                elseif diffInput % Just diff keys were pushed
                    response = 'diff';
                    RT = round(1000 * (secs - time));
                    keepGoing = false;
                else % No valid key was pushed
                    % Play invalid tone
                    Beeper(200, 0.4, 0.1);
                end
            end

            % Pause polling 
            pause(0.0005);
        end
        
        % Check if there is a response
        if strcmp(response, 'invalid')
            DrawFormattedText(window, 'Too slow to hit valid keys!', ...
                'center', 'center', black);
            Screen('Flip', window);
            pause(feedbackTime / 1000);
        end
        
        % Check correct
        correct = sum(strcmp(trials.Correct(i), response));
        
        %% Save data
        dataFile = fopen(fileName, 'a');
        % dataFormat = '%d,%d,%s,%s,%s,%s,%d,%d,%d,%d,%d,%s,%s\n';
        fprintf(dataFile, dataFormat, trial, block, trials.Item1(i), ...
            trials.Item2(i), trials.Correct(i), response, correct, RT, ...
            item1Offset, sbjID, handedness, experimenter, char(datetime));
        fclose(dataFile);
        
        %% Reset for next trial
        Screen('Flip', window);
        Screen('Flip', expWindow);
        pause(intertrialInterval / 1000);
    end
end

% Task completion screen
RestrictKeysForKbCheck(KbName('space'));

Screen('Flip', window);
center_text(w, 'You have finished this task!', 0);
center_text(w, 'Press the spacebar', 0, 50);
Screen('Flip', w);

KbWait([], 3);

% Experiment cleanup
sca;
ListenChar();
ShowCursor();
RestrictKeysForKbCheck([]);
if exist('prior', 'var')
    Priority(prior);
end
catch
% Save error
error = lasterror; %#ok<LERR>
save(['err_', char(datetime('now', 'Format', 'MMM-dd-y--HH-mm-ss'))]); 

% Experiment cleanup
sca;
ListenChar();
ShowCursor();
RestrictKeysForKbCheck([]);
if exist('prior', 'var')
    Priority(prior);
end

% Panic!
rethrow(error);    
end
end
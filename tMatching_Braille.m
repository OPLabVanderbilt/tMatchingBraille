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
windowGap = 250; % Gap between each window
exposureTime = 4000; % Exposure time for each object
testTime = 8000; % Time limit on response
intertrialInterval = 1000; % Minimum gap between trials

trialName = 'tMatchingBrailleTrials.csv';

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
trials = readtable('tMatchingBrailleTrials.csv');

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
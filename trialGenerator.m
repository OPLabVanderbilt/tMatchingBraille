clear all; %#ok<CLALL>

rng(2020);

% Note the use of double quotes to create a string class (not character)
easyTrials = [
    "a", "b";
    "b", "c";
    "m", "v";
    "l", "x";
    "p", "u";
    "k", "x";
    "q", "v";
    "d", "i";
    "j", "p";
    "c", "m";
    "a", "k";
];

medTrials = [
    "f", "h"; 
    "g", "h";
    "b", "k";
    "f", "m";
    "j", "u";
    "x", "y"; 
    "i", "k";
    "b", "l";
    "h", "u";
    "g", "z";
    "u", "v";
    "u", "x"; 
    "h", "r";
    "e", "k";
    "n", "o";
    "i", "s";
];

hardTrials = [
    "e", "i"; 
    "d", "f";
    "g", "n";
    "h", "j";
    "f", "s";
    "n", "p";
    "p", "r";
    "s", "t";
    "o", "s";
    "w", "z";
    "q", "r";
    "g", "q";
    "r", "w";
    "q", "y";
    "j", "t";
    "d", "n";
    "o", "z";
    "w", "t";
];

% Trial statistics
diffTrials = [easyTrials; medTrials; hardTrials];
trialCount = size(diffTrials, 1) * 2;

% Check for repeated trials
diffTrials = sort(diffTrials, 2);
[~, sortIdx] = sort(diffTrials(:, 1));
diffTrials = diffTrials(sortIdx, :);

[~, uniqueIdx] = unique(horzcat([diffTrials{:, 1}]', [diffTrials{:, 2}]'), ...
    'rows', 'stable');

if length(uniqueIdx) ~= size(diffTrials, 1)
    dup = diffTrials(find(~diag(uniqueIdx == 1:size(diffTrials, 1)), 1), :);
    warning('Duplicate found: %s, %s', dup)
end
    
% Generate table for letter usage
letterCounts = table(unique(diffTrials), ...
    zeros(length(unique(diffTrials)), 1), ...
    'VariableNames', {'Letters', 'Count'});

for i = 1:height(letterCounts)
    letterCounts.Count(i) = sum(sum(count(diffTrials, ...
        letterCounts.Letters(i))));
end

% Shuffle withing difficulty then get all diffTrials again
diffTrials = [easyTrials(randperm(length(easyTrials)), :); ...
    medTrials(randperm(length(medTrials)), :); ...
    hardTrials(randperm(length(hardTrials)), :)];

% Add difficulty information
diffDiff = [repmat("easy", size(easyTrials, 1), 1); ...
    repmat("medium", size(medTrials, 1), 1); ...
    repmat("hard", size(hardTrials, 1), 1)];
diffTrials = [diffTrials, diffDiff];

% Generate shuffled trial order with same trials
sameDiff = [repmat("same", size(diffTrials, 1), 1); ...
    repmat("diff", size(diffTrials, 1), 1)];
sameDiff = sameDiff(randperm(length(sameDiff)));

% Make a table for final trial setup
allTrials = table(repmat("", trialCount, 1), ...
    repmat("", trialCount, 1), ...
    repmat("", trialCount, 1), ...
    sameDiff, ...
    'VariableNames', {'Item1', 'Item2', 'Difficulty', 'Correct'});

diffIdx = 0;
for i = 1:trialCount
    if strcmp(allTrials.Correct(i), "same") % Generate a same trial
        % Select a letter at random that still is underused
        letterCount = 12;
        while letterCount > 10
            randIdx = randsample(height(letterCounts), 1);
            letterCount = letterCounts.Count(randIdx);
        end
        
        % Add to trials
        allTrials.Item1(i) = letterCounts.Letters(randIdx);
        allTrials.Item2(i) = letterCounts.Letters(randIdx);
        allTrials.Difficulty(i) = "same";
        allTrials.Correct(i) = "same";
        
        % Increment letter counts
        letterCounts.Count(randIdx) = letterCounts.Count(randIdx) + 2;
        
    else % Get a different trial
        diffIdx = diffIdx + 1;
        
        % Randomize presentation order
        order = randsample(2, 2);
        
        % Add to trials
        allTrials.Item1(i) = diffTrials(diffIdx, order(1));
        allTrials.Item2(i) = diffTrials(diffIdx, order(2));
        allTrials.Difficulty(i) = diffTrials(diffIdx, 3);
        allTrials.Correct(i) = "diff";
    end
end

writetable(allTrials, 'tMatchingBrailleTrials.csv');
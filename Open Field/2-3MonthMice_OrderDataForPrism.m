Contributors: Ryan Yeung

clear
clc

%% Generates a table of the data in the order that matches the Prism file
% Access variable "completedTable" for the ordered data.
% When using on files containing multiple values in the form of a vector, 
% ensure all files contain the same number of values or contains no value.

completedTable = zeros(0,0);

% Edit the variables 'date' and 'trial' to access specific days and trials.
% The format should be '*DayX_' and 'rotarodY*' where X is the day number
% and Y is the trial number.
% To access all data from all days/trials, use date = '*' and trial = '*'
date = '*Day3_';
trial = 'rotarod2*';

files = dir(strcat(date,'146m6_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'145m1_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'145m2_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'145m6_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'145m67_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'146m1July_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'146m3July_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'146m3Aug_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'146m5Aug_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'139m1_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'139m2_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'146m5June_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'145m3_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'145m7_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'146m2July_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'146m1Aug_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'146m2Aug_',trial));
completedTable = addValues(files,completedTable);

files = dir(strcat(date,'146m12July_',trial));
completedTable = addValues(files,completedTable);

%%
% Takes a file of type dir and an array and horizontally concatenates the 
% data from the file with the array and returns the new array
%
% @param files: the files from which to extract data
% @param completedTable: the array to which the new data is concatenated
% @return a new array with the data from files horizontally concatenanted 
% to completedTable

function table = addValues(files, completedTable)
    fileNames = strings([1,length(files)]);
    if isempty(fileNames)
        table = completedTable;
    else
        for i=1:length(files)
            fileNames(i) = files(i).name;
            values(:,i) = load(files(i).name);
        end
        tempTable = vertcat(fileNames,values);
        table = horzcat(completedTable,tempTable);
    end
end


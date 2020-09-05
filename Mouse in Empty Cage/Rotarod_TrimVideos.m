% Contributors: Ryan Yeung

%% Import data from TDT files
% Ensure you are IN the folder for the trial for this part
data = TDTbin2mat(uigetdir);

%% **Check for files called "Updated Notes" or "Updated PrtA" and open those files if they are present!
prompt = 'Are there any Updated Notes or Updated PrtA/PrtB .mat files in the folder? Y/N [Y]: ';
str = input(prompt,'s');
if str == 'Y'
    disp('Remember to load the Updated file');
end

%% Notes
% Define time points to divide video: 
% "Before video" is 270s (4.5 minutes) long, ending 10s before mouse is picked up
% "After video" is 270s (4.5 minutes) long, starting 10s after mouse is put
% down

% Beforevideo would trim the video at Pickup-280 : Pickup-10
% Aftervideo would trim the video at Putdown+10 : Putdown+280
% Script should save the new trimmed videos with the name of file + Before or + After
% To make it easier for DLC later, you could have the video files saved
% into a new folder for Before & After videos.

%% Trim rotarod open field video
% Video is recorded Fs (20) frames per second. Extract pickup, putdown,
% rotarod start, and rotarod end time and convert to frames
Fs = 20;
PickupTime = data.epocs.Note.onset(1,1);
PutdownTime = data.epocs.Note.onset(2,1); 

PickupFrame = round(PickupTime*Fs);
PutdownFrame = round(PutdownTime*Fs);

% Generate video reader system object and video writer system object
%[file,path] = getFilePath(data,'Cam1');
[file,path] = uigetfile('*.avi');
videoFReader = vision.VideoFileReader(fullfile(path,file));
videoFWriterBefore = vision.VideoFileWriter(append('C:\Users\Ryan\Documents\Employment\Raymond Lab WorkLearn\Data\Rotarod analysis\Trimmed videos\',file(1:end-4),'Before.mp4'),'FileFormat','MPEG4','FrameRate',Fs,'Quality',25);
videoFWriterAfter = vision.VideoFileWriter(append('C:\Users\Ryan\Documents\Employment\Raymond Lab WorkLearn\Data\Rotarod analysis\Trimmed videos\',file(1:end-4),'After.mp4'),'FileFormat','MPEG4','FrameRate',Fs,'Quality',25);
%%
% Trim and generate the 'before' and 'after' videos
tic
frame = 1;
while ~isDone(videoFReader)
    videoFrame = videoFReader();
    if frame >= PickupFrame-(280*Fs) && frame <= PickupFrame-(10*Fs)
        videoFWriterBefore(videoFrame);
    elseif frame >= PutdownFrame+(10*Fs) && frame <= PutdownFrame+(280*Fs)
        videoFWriterAfter(videoFrame);
    end
    frame = frame + 1;
end

% Close input and output files
release(videoFReader);
release(videoFWriterBefore);
release(videoFWriterAfter);
toc

%% Trim rotarod video
% Video is recorded Fs (20) frames per second. Extract rotarod start and 
% rotarod end time and convert to frames
Fs = 20;
if isfield(data.epocs,'PrtA')
    RotarodStartTime = data.epocs.PrtA.onset(1,1);
    RotarodEndTime = data.epocs.PrtA.onset(2,1);
else
    RotarodStartTime = data.epocs.PrtB.onset(1,1);
    RotarodEndTime = data.epocs.PrtB.onset(2,1);
end

RotarodStartFrame = round(RotarodStartTime*Fs);
RotarodEndFrame = round(RotarodEndTime*Fs);

% Generate video reader system object and video writer system object
% [file,path] = uigetfile('*.avi');
filePath = getFilePath(data,'Cam2');
videoFReader = vision.VideoFileReader(fullfile(path,file));
videoFWriterRotarod = vision.VideoFileWriter(append('C:\Users\Ryan\Documents\Employment\Raymond Lab WorkLearn\Data\Rotarod analysis\Trimmed videos\On Rotarod\',file(1:end-4),'onRotarod.mp4'),'FileFormat','MPEG4','FrameRate',Fs,'Quality',25);

%%
% Trim and generate the rotarod video
tic
frame = 1;
while ~isDone(videoFReader)
    videoFrame = videoFReader();
    if frame >= RotarodStartFrame && frame <= RotarodEndFrame
        videoFWriterRotarod(videoFrame);
    end
    frame = frame + 1;
end

% Close input and output files
release(videoFReader);
release(videoFWriterRotarod);
toc

%% Save variables into current folder (for current trial)

Timestamps = [PickupTime RotarodStartTime RotarodEndTime PutdownTime];
save(Timestamps); 

%% Function for searching for cropped video
% getFilePath returns a vector of character arrays where 'file' is the file 
% name and path is the preceding path of the file for the cropped video
% corresponding to the structure 'data'. The full file path can be obtained
% with fullfile(path,file).
% Variable 'cam' specifies whether you want the open field video 'Cam1' or
% rotarod video 'Cam2'

function [file,path] = getFilePath(data,cam)
    structureDate = data.info.date;
    
    if strcmp(structureDate(6:8),'Jun')
        date = append('19','06',structureDate(10:11),'_');
    elseif strcmp(structureDate(6:8),'Jul')
        date = append('19','07',structureDate(10:11),'_');
    elseif strcmp(structureDate(6:8),'Aug')
        date = append('19','08',structureDate(10:11),'_');
    else
        disp('Review function filePath; video is not from july or august')
        return
    end
    
    experiment = append(data.info.Experiment,'-');
    blockName = append(data.info.blockname,'_',cam,'.avi');
    
    if strcmp(blockName(6:10),'146m1') || strcmp(blockName(6:10),'146m2') || strcmp(blockName(6:10),'146m3') || strcmp(blockName(6:10),'146m5')
        blockName = insertAfter(blockName,10,structureDate(6:8));
    end
    
    % Change variable 'path' based on the path in which you stored your
    % cropped videos (include '\' at the end)
    path = 'C:\Users\Ryan\Documents\Employment\Raymond Lab WorkLearn\Data\Rotarod analysis\Rotarod Open Field\Day2_146m2_rotarod3\';
    file = append(experiment,date,blockName);
end

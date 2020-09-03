clc
clear all
close all

%% Get file and plot mouse position over time using Body position
% 10 minutes total
% If file is shorter than that, to end of video
% Change body part variables to the x and y you are interested in

filename = uigetfile('.csv');
data = csvread(filename,3,0);
graphtitle = filename(13:52);
%%

%Position of Body
Bodyx = data(:,5);
Bodyy = data(:,6);
for i=1:length(data(:,7))
    if data(i,7) <0.8
        Bodyx(i,1) = NaN;
        Bodyy(i,1) = NaN;
    end
end

Bodyx = repnan(Bodyx,'linear');
Bodyy = repnan(Bodyy,'linear');

Time = data(:,1)/20;

% Plot and save TailBase positions
% Change path for saveas to your computer's path

%figure; plot(Snoutx, Snouty);
%Check the snout tracking to ensure it's usable for calculating the size of
%the cage later on

figure; plot(Bodyx, Bodyy);
hold on
axis([0 450 0 450]);
title(graphtitle,'Interpreter','none')
hold off
saveas(gcf,['C:\Users\Ryan\Documents\Employment\Raymond Lab WorkLearn\Data\Rotarod analysis\Rotarod Open Field\Before data\Position Graphs\',graphtitle,'.jpg']);

%% Calculate total distance travelled

% Calculate travel distance between each frame by pixels
xdiff = diff(Bodyx);
ydiff = diff(Bodyy);
totaldiff = sqrt(xdiff.^2 + ydiff.^2);

% Calculate total travel distance by pixels
totaldistance = nansum(totaldiff);
disp 'total distance in pixels is'
disp(totaldistance);
save(['C:\Users\Ryan\Documents\Employment\Raymond Lab WorkLearn\Data\Rotarod analysis\Rotarod Open Field\Before data\Total distance pixels\', graphtitle],'totaldistance', '-ascii');


%% Use total diff outliers to clean up position data (skip if plot looks good)
% %Replace NaN with average of surrounding data points
% %This is useful if there are points outside of the open field
% %that will affect the x and y ranges, but if you are happy with
% %the labelling you could skip this

% Identify and fill outliers in Bodyx and Bodyy
outliers(2:(length(Time))) = isoutlier(totaldiff,'mean');
outliers = outliers';

for i=1:length(Time)
    if outliers(i,1)
        Bodyx(i,1) = NaN;
        Bodyy(i,1) = NaN;
    end
end
Bodyx = repnan(Bodyx,'linear');
Bodyy = repnan(Bodyy,'linear');

% Identify and fill outliers in totaldiff
oldtotaldiff = totaldiff;
totaldiff = filloutliers(totaldiff,'linear','mean');
totaldiff = repnan(totaldiff,'linear');
totaldistance = nansum(totaldiff);

% Plot and save new position data
mouseplot = figure; plot(Bodyx, Bodyy);
hold on
axis([0 480 0 480]);
title(graphtitle,'Interpreter','none')
hold off
saveas(gcf,['C:\Users\Ryan\Documents\Employment\Raymond Lab WorkLearn\Data\Rotarod analysis\Rotarod Open Field\Before data\Position Graphs\',graphtitle,'.jpg']);

% Re-calculate total distance travelled after filling outliers using bodyx
% and bodyy. 
% Outliers are filled based on linear interpolation of the x and y 
% coordinates individually. If total distance is calculated from
% totaldiff, the outliers are filled based on linear interpolation of
% the distance travelled between two frames.
% I concluded using totaldiff is more accurate so this part has been noted
% out.
% xdiffnew = diff(Bodyx);
% ydiffnew = diff(Bodyy);
% totaldiffnew = sqrt(xdiffnew.^2 + ydiffnew.^2);
% totaldistancenew = nansum(totaldiffnew);

disp 'New total distance in pixels is'
disp(totaldistance);
save(['C:\Users\Ryan\Documents\Employment\Raymond Lab WorkLearn\Data\Rotarod analysis\Rotarod Open Field\Before data\Total distance pixels\', graphtitle],'totaldistance', '-ascii');


%% Calculate ranges by converting pixels to cm

%xcm= 17/xrange;
%ycm = 28/yrange;
%totalrange = sqrt(xrange^2+yrange^2);
%cmconversion = sqrt(17^2+28^2)/totalrange;

% Use conversion factor for day calculated in excel
date = filename(13:18);

if input('Do you want to manually input dimensions?(y/n) ','s') == 'y'
    pixelWidth = input('Width: ');
    pixelHeight = input('Height: ');
elseif strcmp(date,'190622')
    pixelWidth = input('Width: ');
    pixelHeight = input('Height: ');
elseif strcmp(date,'190623')
    pixelWidth = mean([253 257 252]);
    pixelHeight = mean([409 412]);
elseif strcmp(date,'190624')
    pixelWidth = 248;
    pixelHeight = 394;
elseif strcmp(date,'190623')
    pixelWidth = mean([253 257 252]);
    pixelHeight = mean([409 412]);
elseif strcmp(date,'190627')
    %pixelWidth = 263;248;260;
    %pixelHeight = 408;391;
    pixelWidth = input('Width: ');
    pixelHeight = input('Height: ');
elseif strcmp(date,'190628')
    pixelWidth = 244;
    pixelHeight = 391;
elseif strcmp(date,'190629')
    pixelWidth = mean([226 225]);
    pixelHeight = mean([363 364]);
elseif strcmp(date,'190630')
    pixelWidth = 227;
    pixelHeight = 360;
elseif strcmp(date,'190702')
    pixelWidth = mean([240 242 240]);
    pixelHeight = mean([379 385 382]);
elseif strcmp(date,'190703')
    pixelWidth = mean([235 236]);
    pixelHeight = mean([380 382]);
elseif strcmp(date,'190704')
    pixelWidth = 241;
    pixelHeight = 387;
elseif strcmp(date,'190705')
    pixelWidth = 234;
    pixelHeight = 378;
elseif strcmp(date,'190821')
    pixelWidth = 233;
    pixelHeight = 374;
elseif strcmp(date,'190822')
    pixelWidth = mean([232 234]);
    pixelHeight = mean([374 379]);
elseif strcmp(date,'190823')
    %pixelWidth = 246;251;
    %pixelHeight = 398;405;
    pixelWidth = 251;
    pixelHeight = 405;
elseif strcmp(date,'190824')
    pixelWidth = 245;
    pixelHeight = 401;
else
    disp('Date not valid');
end

cmconversion = sqrt(27^2+17^2)/sqrt(pixelWidth^2 + pixelHeight^2);

% Convert distance travelled in pixels to cm
totaldiffcm = abs(totaldiff*cmconversion);
totaldistancecm = nansum(totaldiffcm);

disp 'total distance in cm is';
disp(totaldistancecm);

save(['C:\Users\Ryan\Documents\Employment\Raymond Lab WorkLearn\Data\Rotarod analysis\Rotarod Open Field\Before data\Total diffs\', graphtitle],'totaldiffcm', '-ascii');
save(['C:\Users\Ryan\Documents\Employment\Raymond Lab WorkLearn\Data\Rotarod analysis\Rotarod Open Field\Before data\Total distance\', graphtitle],'totaldistancecm', '-ascii');

%% Calculate center time
% IMPORTANT: ONLY Use this if the mouse goes to each edge at least once, otherwise
% calculations will be off

xcm= 17/pixelWidth;
ycm = 27/pixelHeight;

Bodyxcm = Bodyx*xcm;
Bodyycm = Bodyy*ycm;
 
xcentermin = (min(Bodyxcm)+4);
xcentermax = (max(Bodyxcm)-4);
ycentermin = (min(Bodyycm)+4);
ycentermax = (max(Bodyycm)-4);
 
Bodyxcm(Bodyxcm < xcentermin) = NaN;
Bodyxcm(Bodyxcm > xcentermax) = NaN;
Bodyycm(Bodyycm < ycentermin) = NaN;
Bodyycm(Bodyycm > ycentermax) = NaN;
Bodyxycm = [Bodyxcm, Bodyycm];
 
Centertime = (Bodyxycm(:,1) + Bodyxycm(:,2));
Centertime = (Centertime > 0);
Centertimesum = (sum(Centertime)/(length(Time))*100);

save(['C:\Users\Ryan\Documents\Employment\Raymond Lab WorkLearn\Data\Rotarod analysis\Rotarod Open Field\Before data\Center time\', graphtitle],'Centertimesum', '-ascii');

disp('Center time is');
disp(Centertimesum);


%% Calculate time spent in each of 4 quadrants
% Quadrants increment clockwise starting with the bottom left quadrant (Quad1) 
% Based on Body position, make sure mouse went to all edges if running this
% part

xrange = max(Bodyx) - min(Bodyx);
yrange = max(Bodyy) - min(Bodyy);

xmid = min(Bodyx) + xrange/2;
ymid = min(Bodyy) + yrange/2;

Quad1 = 0;
Quad2 = 0;
Quad3 = 0;
Quad4 = 0;

for i = 1 : length(Bodyx)
    if (Bodyx(i) < xmid) && (Bodyy(i) <= ymid)
        Quad1 = Quad1 + 1;
    elseif (Bodyx(i) <= xmid) && (Bodyy(i) > ymid)
        Quad2 = Quad2 + 1;
    elseif (Bodyx(i) > xmid) && (Bodyy(i) >= ymid)
        Quad3 = Quad3 + 1;
    else
        Quad4 = Quad4 + 1;
    end
end

timeQuad1 = Quad1/20;
timeQuad2 = Quad2/20;
timeQuad3 = Quad3/20;
timeQuad4 = Quad4/20;

timeByQuad = [timeQuad1, timeQuad2, timeQuad3, timeQuad4];
sumOfTime = sum(timeByQuad);

fracInQuad1 = (timeQuad1 / sumOfTime) * 100;
fracInQuad2 = (timeQuad2 / sumOfTime) * 100;
fracInQuad3 = (timeQuad3 / sumOfTime) * 100;
fracInQuad4 = (timeQuad4 / sumOfTime) * 100;

timeByQuadFrac = [fracInQuad1, fracInQuad2, fracInQuad3, fracInQuad4];

if sumOfTime - length(Bodyx)/20 > 0.1
    disp("WARNING: Times don't add to 4.5 minutes; Values not saved");
else
    save(['C:\Users\Ryan\Documents\Employment\Raymond Lab WorkLearn\Data\Rotarod analysis\Rotarod Open Field\Before data\Time by quadrants\', graphtitle],'timeByQuad', '-ascii');
    save(['C:\Users\Ryan\Documents\Employment\Raymond Lab WorkLearn\Data\Rotarod analysis\Rotarod Open Field\Before data\Fraction of time by quadrants\', graphtitle],'timeByQuadFrac', '-ascii');
    disp('Time by quadrants is');
    disp(timeByQuadFrac);
end

%% Calculate total distance per 30 seconds

pixelDistanceOne = nansum(totaldiff(1:599));
pixelDistanceTwo = nansum(totaldiff(600:1199));
pixelDistanceThree = nansum(totaldiff(1200:1799));
pixelDistanceFour = nansum(totaldiff(1800:2399));
pixelDistanceFive = nansum(totaldiff(2400:2999));
pixelDistanceSix = nansum(totaldiff(3000:3599));
pixelDistanceSeven = nansum(totaldiff(3600:4199));
pixelDistanceEight = nansum(totaldiff(4200:4799));
pixelDistanceNine = nansum(totaldiff(4800:end));

cmDistanceOne = abs(pixelDistanceOne * cmconversion);
cmDistanceTwo = abs(pixelDistanceTwo * cmconversion);
cmDistanceThree = abs(pixelDistanceThree * cmconversion);
cmDistanceFour = abs(pixelDistanceFour * cmconversion);
cmDistanceFive = abs(pixelDistanceFive * cmconversion);
cmDistanceSix = abs(pixelDistanceSix * cmconversion);
cmDistanceSeven = abs(pixelDistanceSeven * cmconversion);
cmDistanceEight = abs(pixelDistanceEight * cmconversion);
cmDistanceNine = abs(pixelDistanceNine * cmconversion);

distanceByMinutes = [cmDistanceOne, cmDistanceTwo, cmDistanceThree, cmDistanceFour, cmDistanceFive, cmDistanceSix, cmDistanceSeven, cmDistanceEight, cmDistanceNine];
totalDistance = sum(distanceByMinutes);

if(abs(totalDistance - totaldistancecm) > 0.01)
    disp("WARNING: Distances don't match; Values not saved");
else
    save(['C:\Users\Ryan\Documents\Employment\Raymond Lab WorkLearn\Data\Rotarod analysis\Rotarod Open Field\Before data\Total Distance per minute\', graphtitle],'distanceByMinutes', '-ascii');
    disp('Total distance by 30 seconds is');
    disp(distanceByMinutes);
end

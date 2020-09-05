% Contributors: Ellen Koch, Ryan Yeung

clc
clear all
close all

%% Get file and plot mouse position over time using TailBase position
% 10 minutes total
% If file is shorter than that, to end of video
% Change TailBasex/TailBasey to the x and y you are interested in

file = uigetfile('.csv');
data = readmatrix(file);
graphtitle = file(20:45);

%Position of snout
Snoutx = data(:,2);
Snouty = data(:,3);
for i=1:length(data(:,4));
    if data(i,4) <0.8;
        Snoutx(i,1) = NaN;
        Snouty(i,1) = NaN;
    end
end
 
Snoutx = repnan(Snoutx,'linear');
Snouty = repnan(Snouty,'linear');

%Position of fiber/head
Fiberx = data(:,5);
Fibery = data(:,6);
for i=1:length(data(:,7));
    if data(i,7) <0.8;
        Fiberx(i,1) = NaN;
        Fibery(i,1) = NaN;
    end
end
 
Fiberx = repnan(Fiberx,'linear');
Fibery = repnan(Fibery,'linear');


%Position of Tail Base
TailBasex = data(:,26);
TailBasey = data(:,27);
for i=1:length(data(:,28));
    if data(i,28) <0.8;
        TailBasex(i,1) = NaN;
        TailBasey(i,1) = NaN;
    end
end

TailBasex = repnan(TailBasex,'linear');
TailBasey = repnan(TailBasey,'linear');

Time = data(:,1)/20;
if length(Time) >= 12000
    Time = Time(1:12000);
    Fiberx = Fiberx(1:12000);
    Fibery = Fibery(1:12000);
    Snoutx = Snoutx(1:12000);
    Snouty = Snouty(1:12000);
    TailBasex = TailBasex(1:12000);
    TailBasey = TailBasey(1:12000);
else 
    Time = Time(1:end);
    Fiberx = Fiberx(1:end);
    Fibery = Fibery(1:end);
    Snoutx = Snoutx(1:end);
    Snouty = Snouty(1:end);
    TailBasex = TailBasex(1:end);
    TailBasey = TailBasey(1:end);
end

% Plot and save TailBase positions
% Change path for saveas to your computer's path
figure; plot(TailBasex, TailBasey);
hold on
title(graphtitle,'Interpreter','none')
hold off
saveas(gcf,['C:\Users\ellen\OneDrive\Documents\PhD\Data\Open Field\Position Graphs\',graphtitle,'.jpg']);

%Check other plots too
figure; plot(Fiberx, Fibery);
figure; plot(Snoutx, Snouty);

%Calculate body position (average of fiber and tailbase)
Bodyx = (TailBasex + Fiberx)/2;
Bodyy = (TailBasey + Fibery)/2;
figure; plot(Bodyx, Bodyy);

%% Calculate total distance travelled
% Fill outliers and NaN with average of surrounding points

xdiff = diff(TailBasex);
ydiff = diff(TailBasey);
totaldiff = sqrt(xdiff.^2 + ydiff.^2);
outliers = isoutlier(totaldiff,'mean');
totaldiff = filloutliers(totaldiff,'linear');
totaldiff = repnan(totaldiff,'linear');
totaldistance = nansum(totaldiff);
totaldistancepartial = nansum(totaldiff(end-11400:end));
disp 'total distance in pixels is'
disp(totaldistance);
%save(['C:\Users\ellen\OneDrive\Documents\PhD\Data\Open Field\Total distance pixels\', graphtitle],'totaldistance', '-ascii');

if length(Time) < 12000
    disp 'note: time is less than 10 mins'
    disp(length(Time));
end
disp 'total distance for 9.5 min is';
disp(totaldistancepartial);

%% Use total diff outliers to clean up position data 
% Replace NaN with average of surrounding data points

outliers2(2:(length(Time))) = outliers;
outliers2 = outliers2';
for i=1:length(Time);
    if outliers2(i,1) == 1
        TailBasex(i,1) = NaN;
        TailBasey(i,1) = NaN;
        Bodyx(i,1) = NaN;
        Bodyy(i,1) = NaN;
        Fiberx(i,1) = NaN;
        Fibery(i,1) = NaN;
        Snoutx(i,1) = NaN;
        Snouty(i,1) = NaN;
    end
end
TailBasex = repnan(TailBasex,'linear');
TailBasey = repnan(TailBasey,'linear');
Bodyx = repnan(Bodyx,'linear');
Bodyy = repnan(Bodyy,'linear');
Fiberx = repnan(Fiberx,'linear');
Fibery = repnan(Fibery,'linear');
Snoutx = repnan(Snoutx, 'linear');
Snouty = repnan(Snouty,'linear');

figure; plot(TailBasex, TailBasey);
hold on
title(graphtitle,'Interpreter','none')
hold off
saveas(gcf,['C:\Users\ellen\OneDrive\Documents\PhD\Data\Open Field\Position Graphs\',graphtitle,'.emf']);

%Check others
figure;plot(Fiberx, Fibery);
figure;plot(Bodyx, Bodyy);
figure;plot(Snoutx,Snouty);

%% Calculate ranges, convert ranges to inches then to cm
% Calculate total distance travelled
xrange = max(Snoutx) - min(Snoutx);
yrange = max(Snouty) - min(Snouty);
totalrange = sqrt(xrange.^2 + yrange.^2);
xinches = 19/xrange;
yinches = 15/yrange;

totalinches = 24.2074/totalrange;

xdiffinches = xdiff*xinches;
ydiffinches = ydiff*xinches;
totaldiffinches = abs(totaldiff*totalinches);
totaldistanceinches = sum(totaldiffinches);
totaldiffcm = totaldiffinches*2.54;
totaldistancecm = totaldistanceinches*2.54;
disp 'total distance in cm is';
disp(totaldistancecm);

totaldistancecmpartial = totaldiffinches(end-11400:end)*2.54;
totaldistancecmpartial = nansum(totaldistancecmpartial);
if length(Time) < 12000;
    disp 'note: total time in seconds is'
    disp(length(Time)/20);
end
disp 'total distance for 9.5 min is';
disp(totaldistancecmpartial);

%save(['C:\Users\ellen\OneDrive\Documents\PhD\Data\Open Field\Total diff cm\', graphtitle],'totaldiffcm', '-ascii');
save(['C:\Users\ellen\OneDrive\Documents\PhD\Data\Open Field\Total distance cm\', graphtitle],'totaldistancecm', '-ascii');
save(['C:\Users\ellen\OneDrive\Documents\PhD\Data\Open Field\Total distance cm partial\', graphtitle],'totaldistancecm', '-ascii');
%% Calculate center time
% Convert pixels to inches

Snoutxinches = Snoutx*xinches;
Snoutyinches = Snouty*yinches;
Bodyxinches = Bodyx*xinches;
Bodyyinches = Bodyy*yinches;
 
xcentermin = (min(Snoutxinches)+3);
xcentermax = (max(Snoutxinches)-3);
ycentermin = (min(Snoutyinches)+3);
ycentermax = (max(Snoutyinches)-3);
 
Bodyxinches(Bodyxinches < xcentermin) = NaN;
Bodyxinches(Bodyxinches > xcentermax) = NaN;
Bodyyinches(Bodyyinches < ycentermin) = NaN;
Bodyyinches(Bodyyinches > ycentermax) = NaN;
Bodyxyinches = [Bodyxinches, Bodyyinches];
 
Centertime = (Bodyxyinches(:,1) + Bodyxyinches(:,2));
Centertime = (Centertime > 0);
Centertimesum = (sum(Centertime)/(length(Time))*100);

save(['C:\Users\ellen\OneDrive\Documents\PhD\Data\Open Field\Center time\', graphtitle],'Centertimesum', '-ascii');

disp('Center time is');
disp(Centertimesum);

%% Calculate time spent in each of 4 quadrants
% Quadrants increment clockwise starting with the bottom left quadrant (Quad1) 

xmid = min(Snoutx) + xrange/2;
ymid = min(Snouty) + yrange/2;

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
    disp("WARNING: Times don't add to 10 minutes; Values not saved");
else
    save(['C:\Users\ellen\OneDrive\Documents\PhD\Data\Open Field\Time by quadrants\', graphtitle],'timeByQuad', '-ascii');
    save(['C:\Users\ellen\OneDrive\Documents\PhD\Data\Open Field\Fraction of time by quadrants\', graphtitle],'timeByQuadFrac', '-ascii');
end

%% Calculate total distance per minute

pixelDistanceOne = nansum(totaldiff(1:1199));
pixelDistanceTwo = nansum(totaldiff(1200:2399));
pixelDistanceThree = nansum(totaldiff(2400:3599));
pixelDistanceFour = nansum(totaldiff(3600:4799));
pixelDistanceFive = nansum(totaldiff(4800:5999));
pixelDistanceSix = nansum(totaldiff(6000:7199));
pixelDistanceSeven = nansum(totaldiff(7200:8399));
pixelDistanceEight = nansum(totaldiff(8400:9599));
pixelDistanceNine = nansum(totaldiff(9600:10799));
pixelDistanceTen = nansum(totaldiff(10800:end));

cmDistanceOne = abs(pixelDistanceOne * totalinches) * 2.54;
cmDistanceTwo = abs(pixelDistanceTwo * totalinches) * 2.54;
cmDistanceThree = abs(pixelDistanceThree * totalinches) * 2.54;
cmDistanceFour = abs(pixelDistanceFour * totalinches) * 2.54;
cmDistanceFive = abs(pixelDistanceFive * totalinches) * 2.54;
cmDistanceSix = abs(pixelDistanceSix * totalinches) * 2.54;
cmDistanceSeven = abs(pixelDistanceSeven * totalinches) * 2.54;
cmDistanceEight = abs(pixelDistanceEight * totalinches) * 2.54;
cmDistanceNine = abs(pixelDistanceNine * totalinches) * 2.54;
cmDistanceTen = abs(pixelDistanceTen * totalinches) * 2.54;

distanceByMinutes = [cmDistanceOne, cmDistanceTwo, cmDistanceThree, cmDistanceFour, cmDistanceFive, cmDistanceSix, cmDistanceSeven, cmDistanceEight, cmDistanceNine, cmDistanceTen];
totalDistance = sum(distanceByMinutes);

if(abs(totalDistance - totaldistancecm) > 0.01)
    disp("WARNING: Distances don't match; Values not saved");
else
    save(['C:\Users\ellen\OneDrive\Documents\PhD\Data\Open Field\Total Distance per minute\', graphtitle],'distanceByMinutes', '-ascii');
end

%% Calculate mouse movement and speed
% Removes impossible speeds by filling outliers
% Based on 20 Hz frame rate

%xspeed = abs(xdiffinches/0.05);
%yspeed = abs(ydiffinches/0.05);
totalspeed = abs(totaldiffcm/0.05);

averagespeed = mean(totalspeed);
disp('average speed is');
disp(averagespeed);

Timenew = Time(2:end);
speedfigure = figure; plot(Timenew,totalspeed);
daspect([1 0.1 1])
saveas(gcf,['C:\Users\ellen\OneDrive\Documents\PhD\Data\Open Field\Speed plots\',graphtitle,'.emf']);
%timemoving = (totalspeed >= 3);

save(['C:\Users\ellen\OneDrive\Documents\PhD\Data\Open Field\Speed over time\', graphtitle],'totalspeed', '-ascii');
save(['C:\Users\ellen\OneDrive\Documents\PhD\Data\Open Field\Average speed\', graphtitle],'averagespeed', '-ascii');


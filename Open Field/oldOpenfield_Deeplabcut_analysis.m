% Contributors: Ellen Koch, Ryan Yeung

clc
clear all
close all

%% Get file and plot mouse position over time using Fiber position
% First 10 sec to 10:10 
% If file is shorter than that, first 10 sec to end
% Change Fiberx/Fibery to the x and y you are interested in

file = uigetfile('.csv');
data = readmatrix(file);
graphtitle = file(20:40);

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

Time = data(:,1)/20;
if length(Time) >= 12200
    Time_10 = Time(200:12200);
    Fiberx = Fiberx(200:12200);
    Fibery = Fibery(200:12200);
else 
    Time_10 = Time(200:end);
    Fiberx = Fiberx(200:end);
    Fibery = Fibery(200:end);
end
figure; plot(Fiberx, Fibery);
hold on
title(graphtitle,'Interpreter','none')
hold off

%figure; plot (Time_10, Fiberx);
%figure; plot (Time_10, Fibery);

%% Calculate total distance travelled
% Fill outliers and NaN with average of surrounding points

xdiff = diff(Fiberx);
ydiff = diff(Fibery);
totaldiff = sqrt(xdiff.^2 + ydiff.^2);
outliers = isoutlier(totaldiff,'mean');
totaldiff = filloutliers(totaldiff,'linear');
totaldiff = repnan(totaldiff,'linear');
totaldistance = nansum(totaldiff);
% In case video is less than 10 min, calc total distance per minute and use
% to calculate distance for 10 mins
totaldistancepermin = totaldistance/(length(Time_10))*1200;

%% Use total diff outliers to clean up position data 
% Replace NaN with average of surrounding data points
% This is useful if there are points outside of the open field
% that will affect the x and y ranges, but if you are happy with
% the labelling you could skip this

outliers2(2:(length(Time_10))) = outliers;
outliers2 = outliers2';
for i=1:length(Time_10);
    if outliers2(i,1) == 1;
        Fiberx(i,1) = NaN;
        Fibery(i,1) = NaN;
    end
end
Fiberx = repnan(Fiberx,'linear');
Fibery = repnan(Fibery,'linear');

figure; plot(Fiberx, Fibery);
hold on
title(graphtitle,'Interpreter','none')
hold off
%saveas(gcf,['Z:\Raymond Lab\Ellen\Fiber Photometry\Position Graphs\', graphtitle],'openfieldpositions.emf');
%% Calculate ranges, convert ranges to inches
% Calculate total distance travelled
xrange = max(Fiberx) - min(Fiberx);
yrange = max(Fibery) - min(Fibery);
totalrange = sqrt(xrange.^2 + yrange.^2);
xinches = round(19/xrange,3);
yinches = round(15/yrange,3);

totalinches = round(24.2074/totalrange,3);

xdiffinches = xdiff*xinches;
ydiffinches = ydiff*xinches;
totaldiffinches = abs(totaldiff*totalinches);
totaldistanceinches = sum(totaldiffinches);
totaldistanceinchespermin = (totaldistanceinches/(length(Time_10)))*1200;

save(['Z:\Raymond Lab\Ellen\Fiber Photometry\Open Field\Total diffs over time\', graphtitle],'totaldiffinches', '-ascii');
save(['Z:\Raymond Lab\Ellen\Fiber Photometry\Open Field\Total Distance\', graphtitle],'totaldistanceinches', '-ascii');
save(['Z:\Raymond Lab\Ellen\Fiber Photometry\Open Field\Total Distance per minute\', graphtitle],'totaldistanceinchespermin', '-ascii');

%% Calculate center time
% Convert pixels to inches

Fiberxinches = Fiberx*xinches;
Fiberyinches = Fibery*yinches;

xcentermin = (min(Fiberxinches)+3);
xcentermax = (max(Fiberxinches)-3);
ycentermin = (min(Fiberyinches)+3);
ycentermax = (max(Fiberyinches)-3);

Fiberxinches(Fiberxinches < xcentermin) = NaN;
Fiberxinches(Fiberxinches > xcentermax) = NaN;
Fiberyinches(Fiberyinches < ycentermin) = NaN;
Fiberyinches(Fiberyinches > ycentermax) = NaN;
Fiberxyinches = [Fiberxinches, Fiberyinches];

Centertime = (Fiberxyinches(:,1) + Fiberxyinches(:,2));
Centertime = (Centertime > 0);
Centertimesum = (sum(Centertime)/(length(Time_10))*100);

save(['Z:\Raymond Lab\Ellen\Fiber Photometry\Open Field\Center Time\', graphtitle],'Centertimesum', '-ascii');

%% Calculate mouse movement and speed
% Removes impossible speeds by filling outliers
% Based on 20 Hz frame rate

xspeed = abs(xdiffinches/0.05);
yspeed = abs(ydiffinches/0.05);
totalspeed = abs(totaldiffinches/0.05);

averagespeed = mean(totalspeed);

Timenew = Time(2:end);
plot(Timenew,totalspeed)

timemoving = (totalspeed >= 3);

save(['Z:\Raymond Lab\Ellen\Fiber Photometry\Open Field\Speed over time\', graphtitle],'totalspeed', '-ascii');
save(['Z:\Raymond Lab\Ellen\Fiber Photometry\Open Field\Average speed\', graphtitle],'averagespeed', '-ascii');

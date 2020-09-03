close all
clear variables
clc

%% Import data from TDT files
% Update with current folder path
data = TDTbin2mat(uigetdir);

%% Create time vector from data
% Fs = sampling rate
% tssub = take out first 10 seconds of data

ts = (0:(length(data.streams.x65B.data)-1))/data.streams.x65B.fs;
Fs=data.streams.x65B.fs;
tssub=ts(round(10*Fs):end);

%% Extract signal and control data and create plot
% Apply lowpass filter 

sig=data.streams.x65B.data(round(10*Fs):end);
ctr=data.streams.x05V.data(round(10*Fs):end);
sig=double(sig);
ctr=double(ctr);
ctr_filt=lowpassphotometry(ctr,Fs,2);

plot(tssub,sig)
hold on
plot(tssub,ctr_filt)
xlabel('Time(s)','FontSize',14)
ylabel('mV at detector','FontSize',14)
daspect([1 1 1])
hold off


%% Normalize signal to control channel, plot and save figure
% Add notes to plot

[normDat] = deltaFF(sig,ctr_filt);
figure;plot(tssub, sig, tssub, sig_filt+500)
hold on
xlabel('Time(s)','FontSize',14)
ylabel('deltaF/F','FontSize',14)
title(data.info.blockname(1,:),'Interpreter','none')
vline([data.epocs.Note.onset(1,1) data.epocs.Note.onset(2,1) data.epocs.PrtB.onset(1,1) data.epocs.PrtB.onset(2,1)], {'k', 'k', 'g', 'g'});

hold off

%% Converts notes from Time to Data Points (Time in seconds * Fs)
Notepoints = (data.epocs.Note.onset.*Fs);
Notepoints = Notepoints - round(10*Fs);
Rotarodpoints = (data.epocs.PrtB.onset.*Fs);
Rotarodpoints = Rotarodpoints - round(10*Fs); 

%Notesoff = (data.epocs.Note.offset.*Fs);
%Notesoff = Notesoff - 10000;
Pickup = round(Notepoints(1,1));
Start = round(Rotarodpoints(1,1));
Stop = round(Rotarodpoints(2,1));
Down = round(Notepoints(2,1));
%End = round(Notesoff(4,1));

%% Calculate New z score using baseline and create plot
Before = sig((Pickup-round(280*Fs):(Pickup-round(10*Fs))));
Up = sig(Pickup:Start);
Rotarod = sig(Start:Stop);
Putdown = sig(Stop:Down);
After = sig(Down+round(10*Fs):end);

stdev=std(Before);
zscore=normDat/stdev;

figure;plot(tssub, zscore)
hold on
xlabel('Time(s)','FontSize',14)
ylabel('Z Score','FontSize',14)
title(data.info.blockname(1,:),'Interpreter','none')
vline([data.epocs.Note.onset(1,1) data.epocs.Note.onset(2,1) data.epocs.PrtB.onset(1,1) data.epocs.PrtB.onset(2,1)], {'k', 'k', 'g', 'g'});

hold off

%% FFT (frequency profile)
L = length(sig_filt);
Y = fft(sig_filt);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;

figure(3)
plot(f,P1)
xlim([0,2]);
ylim([0,1]);
title('single sided amplitude spectrum')
ylabel('Signal)')
xlabel('Frequency (Hz)')

%% TRY Welch's power analysis and FFT analysis on Raw data, DFF data, and Z Score data and compare


%for len = 500:300:L
    F = (0:20);
   test = pwelch(x,512,128,[],Fs);
 
    pause;
%end

% using 512 point windows, overlapping by 128 points on either side,
%calculate for frequency range F, with sampling frequency Fs

%%

sig_filt = bandpass(sig, [0.5 1], Fs);
figure;plot(tssub, sig, tssub, sig_filt+1)
hold on
xlabel('Time(s)','FontSize',14)
ylabel('deltaF/F','FontSize',14)
title(data.info.blockname(1,:),'Interpreter','none')
vline([data.epocs.Note.onset(1,1) data.epocs.Note.onset(2,1) data.epocs.PrtB.onset(1,1) data.epocs.PrtB.onset(2,1)], {'k', 'k', 'g', 'g'});

% Contributors: Ellen Koch, Ryan Yeung

close all
clear variables
clc

%% Import data from TDT files
% Update with current folder path
data = TDTbin2mat(uigetdir);

%% Create time vector (RAW DATA)
% Fs = sampling rate
% tssub = take out first 10 seconds of data

ts = (0:(length(data.streams.Fi1r.data(1,:))-1))/data.streams.Fi1r.fs;
Fs=data.streams.Fi1r.fs;
tssub=ts(round(10*Fs)+510:end);

%% Extract excitation, isobestic and carrier signals

E1=data.streams.Fi1r.data(1,round(10*Fs)+510:end);
E1=double(E1);

E2=data.streams.Fi1r.data(2,round(10*Fs)+510:end);
E2=double(E2);

F1=data.streams.Fi1r.data(3,round(10*Fs)+510:end);
F1=double(F1);

F2=data.streams.Fi1r.data(4,round(10*Fs)+510:end);
F2=double(F2);

%% Demodulate modulated signal
% Carrier frequencies are 211hz (for isobestic) and 531hz (for excitation)

% Initial phase of signals are pi/2 radians apart
ini_phasea = pi/6;
ini_phaseb = 2*pi/3;

% Design of Butterworth lowpass filter used in the demodulation
order = 2;
Nyq = Fs/2;
N = length(F1);
[num, den] = butter(order,2/Nyq);
    
% Bode plot of filter
freqz(num,den,N,Fs);

%%
% Perform demodulation with the two carrier frequencies
Fc = 531;
z=sqrt((amdemod(F2,Fc,Fs,ini_phasea)).^2+(amdemod(F2,Fc,Fs,ini_phaseb).^2));
Fc = 211;
y=sqrt((amdemod(F1,Fc,Fs,ini_phasea)).^2+(amdemod(F1,Fc,Fs,ini_phaseb).^2));

%% Plot the results on the same axes
plot(tssub(1000:end),zscore(z(1000:end)))
hold on
plot(tssub(1000:end),zscore(y(1000:end)))

%% FFT (frequency profile)

L = length(y);
Y = fft(y);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;

figure(1)
plot(f,P1)

title('single sided amplitude spectrum')
ylabel('Signal')
xlabel('Frequency (Hz)')

%% Filter and plot
sig_filt=lowpassphotometry(z,Fs,20);
ctr_filt1=lowpassphotometry(y,Fs,20);
figure;plot(tssub(2000:end),sig_filt(2000:end))
hold on
plot(tssub(2000:end),ctr_filt1(2000:end))
xlabel('Time(s)','FontSize',14)
ylabel('mV at detector','FontSize',14)
hold off

%% Chronux mtspectrumc
chronux_sig(:,1) = z;
params.Fs = Fs;
[S,f] = mtspectrumc(chronux_sig,params);
plot_vector(S,f)

%% FFT (frequency profile) of filtered data

L = length(sig_filt);
Y = fft(sig_filt);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;

figure(3)
plot(f,P1)
xlim([0,20]);
ylim([0,0.025]);
title('All data: single sided amplitude spectrum')
ylabel('|P1(f)|')
xlabel('Frequency (Hz)')

%% FFT of control dat

L_ctr = length(ctr_filt1);
Y_ctr = fft(ctr_filt1);

P2_ctr = abs(Y_ctr/L_ctr);
P1_ctr = P2_ctr(1:L_ctr/2+1);
P1_ctr(2:end-1) = 2*P1_ctr(2:end-1);

f_ctr = Fs*(0:(L_ctr/2))/L_ctr;

figure;
plot(f_ctr,P1_ctr)
xlim([0,20]);
ylim([0,0.02]);
title('single sided amplitude spectrum')
ylabel('Signal)')
xlabel('Frequency (Hz)')


function mainFatigueProfile()

clear;
close all;
clc;

%%
% script to examine the fatigue relationship for isometric elbow flexion and
% EMG singal. Run from /src directory.
% For 2008AHS, Introduction to Biomechanics, Lab # 5.
% d.saxby@griffith.edu.au

addpath(genpath(pwd));

%% Settings

a = 0;

if a < 1
    disp('---------------------')
    disp('Specifications')
    disp('---------------------')
    fs = input('Enter sampling frequency: ');
    disp(' ');
    dt = 1/fs;
    t = 0:dt:5-dt;
    gain = input('Enter amplifier gain: ');
    disp(' ');
    epochLength = input('Enter the length in seconds of epochs: ');
    disp(' ')
    nEpochs = input(['Enter the number of ', num2str(epochLength), ' second epochs in the trial: ']);
    disp(' ');
    order = input('Enter the order for the band pass filter: ');
    disp(' ');
    lpfcut = input('Enter the low pass cut-off frequency for the band pass filter: ');
    disp(' ');
    hpfcut = input('Enter the high pass cut-off frequency for the band pass filter: ');
    disp(' ');
%     linEnvLPCut = input('Enter the cut-off frequency for the low pass filter used to create the linear envelope: ');
%     disp(' ');
    if lpfcut > hpfcut
        a = 1;
        fcut = 0.8*[hpfcut, lpfcut];
    else
        error('The low pass cut-off frequency must be greater than the high pass cut-off frequency!');
        disp(' ');
        disp(' ');
    end
    targetForce = input('Enter the target force [N]: '); % 75% of max isometric value

else
    fs = 2000;
    dt = 1/fs;
    epochLength = 5; %seconds
    nEpochs = 5; % number of epochs, testData uses 8.
    gain = 2000;
    order = 2;
    lpfcut = 400;
    hpfcut = 20;
    fcut = 0.8*[hpfcut, lpfcut];
    % linEnvLPCut = 6;
    targetForce = 160; % ~70% of max isometric strength in Newtons

end

% presets, comment our if GUI option is prefered, and set variable "a" on
% line 14 to zero.



%% Read in data holding EMG (first column) and force (second column)
% Trial 1
disp(' ');
cd(pwd);
[FileName,PathName] = uigetfile('*.mat','Select trial 1 (lowest force)', '..\');
cd(PathName);
% data = dlmread(FileName, '\t');
load(FileName);

%% Set force variables
force = data(:,3);

%% Detrend gain-scaled data and assign to EMG variable
emg = detrend(data(:,1)/gain, 'constant');
emgBP = matfiltfilt(dt, fcut, order, emg);

%% Loop through epochs and plot changing EMG power spectrum

totalTrialFrames = size(emg,1);
totalTrialTime = floor(totalTrialFrames*dt);

if floor(totalTrialTime/epochLength)<nEpochs
    error(['You have input too many ', num2str(epochLength), ' second epochs for this given trial, lower the number']);
end

nFramesInEpoch = epochLength*fs;
i = 1;

medfreq = zeros(nEpochs,1);
% powermedfreq = zeros(nEpochs,1);
meanForce = zeros(nEpochs,1);

while i < nEpochs % for 1:nEpochs - 1
    
    chunkRange = (i*nFramesInEpoch+1)-nFramesInEpoch:i*nFramesInEpoch;
    x = emgBP(chunkRange);
    
    [pow,freq] = pwelch(x,[],[],512,fs);
    pow = pow(:,1);
    aoc = sum(pow);
    freqindex = 1;
    sumpow = 0;
    while sumpow <= 0.5*aoc;
        sumpow = sumpow + pow(freqindex);
        freqindex = freqindex + 1;
    end

    medfreq(i) = freq(freqindex);
%     powermedfreq(i) = pow(freqindex);
       
    fig(i) = figure('Name', ['Fourier transform of epoch number ' , num2str(i)]);
    
    plot(freq, pow, 'k');
    xlabel('Frequency [Hz]');
    ylabel('Power [mV^2]')
    vline(medfreq(i), 'r-', ['medianFrequency =  ', num2str(medfreq(i)), ' Hz']);
    box off;
    
    % mean force from each epoch used later
    meanForce(i) = mean(force(chunkRange));

    i = i +1;
    
end

% last remaining data
chunkRange = i*nFramesInEpoch+1:totalTrialFrames;
x = emgBP(chunkRange);
[pow,freq] = pwelch(x,[],[],512,fs);
pow = pow(:,1);

aoc = sum(pow);
freqindex = 1;
sumpow = 0;
while sumpow <= 0.5*aoc;
    sumpow = sumpow + pow(freqindex);
    freqindex = freqindex + 1;
end

medfreq(i) = freq(freqindex);
% powermedfreq(i) = pow(freqindex);

fig(i) = figure('Name', ['Fourier transform of epoch number ' , num2str(i)]);

plot(freq, pow, 'k');
xlabel('Frequency [Hz]');
ylabel('Power [mV^2]')
vline(medfreq(i), 'r-', ['medianFrequency =  ', num2str(medfreq(i)), ' Hz']);
box off;
meanForce(i) = mean(force(chunkRange));


%% Plot 
fig(i+1) = figure('Name', 'Mean Force and Median EMG');
title('Mean Force vs Median EMG');
hold on;
plot(1:length(medfreq), medfreq, 'b');
xlabel('Epoch number');
ylabel([{'Median EMG Frequency (Hz)(left axis)' }; {'Mean Force (N)(right axis)'}]);
hold on
plot(1:length(meanForce), meanForce, 'r');
legend('Median Frequency', 'Mean Force')
legend boxoff
% plot(medfreq, meanForce, 'ko')
% ylabel('Mean Force [N]');
% xlabel('Median EMG [Hz]');

% p = polyfit(medfreq, meanForce, 1);
% f = polyval(p, medfreq);
% plot(medfreq, f, '--r');
hline(targetForce, 'g-', ['targetForce =  ', num2str(targetForce), ' N']);

rmpath(pwd);

%% Embedded functions for graphing
function hhh=vline(x,in1,in2)
% function h=vline(x, linetype, label)
% 
% Draws a vertical line on the current axes at the location specified by 'x'.  Optional arguments are
% 'linetype' (default is 'r:') and 'label', which applies a text label to the graph near the line.  The
% label appears in the same color as the line.
%
% The line is held on the current axes, and after plotting the line, the function returns the axes to
% its prior hold state.
%
% The HandleVisibility property of the line object is set to "off", so not only does it not appear on
% legends, but it is not findable by using findobj.  Specifying an output argument causes the function to
% return a handle to the line, so it can be manipulated or deleted.  Also, the HandleVisibility can be 
% overridden by setting the root's ShowHiddenHandles property to on.
%
% h = vline(42,'g','The Answer')
%
% returns a handle to a green vertical line on the current axes at x=42, and creates a text object on
% the current axes, close to the line, which reads "The Answer".
%
% vline also supports vector inputs to draw multiple lines at once.  For example,
%
% vline([4 8 12],{'g','r','b'},{'l1','lab2','LABELC'})
%
% draws three lines with the appropriate labels and colors.
% 
% By Brandon Kuczenski for Kensington Labs.
% brandon_kuczenski@kensingtonlabs.com
% 8 November 2001

if length(x)>1  % vector input
    for I=1:length(x)
        switch nargin
        case 1
            linetype='r:';
            label='';
        case 2
            if ~iscell(in1)
                in1={in1};
            end
            if I>length(in1)
                linetype=in1{end};
            else
                linetype=in1{I};
            end
            label='';
        case 3
            if ~iscell(in1)
                in1={in1};
            end
            if ~iscell(in2)
                in2={in2};
            end
            if I>length(in1)
                linetype=in1{end};
            else
                linetype=in1{I};
            end
            if I>length(in2)
                label=in2{end};
            else
                label=in2{I};
            end
        end
        h(I)=vline(x(I),linetype,label);
    end
else
    switch nargin
    case 1
        linetype='r:';
        label='';
    case 2
        linetype=in1;
        label='';
    case 3
        linetype=in1;
        label=in2;
    end

    
    
    
    g=ishold(gca);
    hold on

    y=get(gca,'ylim');
    h=plot([x x],y,linetype);
    if length(label)
        xx=get(gca,'xlim');
        xrange=xx(2)-xx(1);
        xunit=(x-xx(1))/xrange;
        if xunit<0.8
            text(x+0.01*xrange,y(1)+0.1*(y(2)-y(1)),label,'color',get(h,'color'))
        else
            text(x-.05*xrange,y(1)+0.1*(y(2)-y(1)),label,'color',get(h,'color'))
        end
    end     

    if g==0
    hold off
    end
    set(h,'tag','vline','handlevisibility','off')
end % else

if nargout
    hhh=h;
end

function hhh=hline(y,in1,in2)
% function h=hline(y, linetype, label)
% 
% Draws a horizontal line on the current axes at the location specified by 'y'.  Optional arguments are
% 'linetype' (default is 'r:') and 'label', which applies a text label to the graph near the line.  The
% label appears in the same color as the line.
%
% The line is held on the current axes, and after plotting the line, the function returns the axes to
% its prior hold state.
%
% The HandleVisibility property of the line object is set to "off", so not only does it not appear on
% legends, but it is not findable by using findobj.  Specifying an output argument causes the function to
% return a handle to the line, so it can be manipulated or deleted.  Also, the HandleVisibility can be 
% overridden by setting the root's ShowHiddenHandles property to on.
%
% h = hline(42,'g','The Answer')
%
% returns a handle to a green horizontal line on the current axes at y=42, and creates a text object on
% the current axes, close to the line, which reads "The Answer".
%
% hline also supports vector inputs to draw multiple lines at once.  For example,
%
% hline([4 8 12],{'g','r','b'},{'l1','lab2','LABELC'})
%
% draws three lines with the appropriate labels and colors.
% 
% By Brandon Kuczenski for Kensington Labs.
% brandon_kuczenski@kensingtonlabs.com
% 8 November 2001

if length(y)>1  % vector input
    for I=1:length(y)
        switch nargin
        case 1
            linetype='r:';
            label='';
        case 2
            if ~iscell(in1)
                in1={in1};
            end
            if I>length(in1)
                linetype=in1{end};
            else
                linetype=in1{I};
            end
            label='';
        case 3
            if ~iscell(in1)
                in1={in1};
            end
            if ~iscell(in2)
                in2={in2};
            end
            if I>length(in1)
                linetype=in1{end};
            else
                linetype=in1{I};
            end
            if I>length(in2)
                label=in2{end};
            else
                label=in2{I};
            end
        end
        h(I)=hline(y(I),linetype,label);
    end
else
    switch nargin
    case 1
        linetype='r:';
        label='';
    case 2
        linetype=in1;
        label='';
    case 3
        linetype=in1;
        label=in2;
    end

    
    
    
    g=ishold(gca);
    hold on

    x=get(gca,'xlim');
    h=plot(x,[y y],linetype);
    if ~isempty(label)
        yy=get(gca,'ylim');
        yrange=yy(2)-yy(1);
        yunit=(y-yy(1))/yrange;
        if yunit<0.2
            text(x(1)+0.02*(x(2)-x(1)),y+0.02*yrange,label,'color',get(h,'color'))
        else
            text(x(1)+0.02*(x(2)-x(1)),y-0.02*yrange,label,'color',get(h,'color'))
        end
    end

    if g==0
    hold off
    end
    set(h,'tag','hline','handlevisibility','off') % this last part is so that it doesn't show up on legends
end % else

if nargout
    hhh=h;
end

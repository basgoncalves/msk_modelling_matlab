function compare_filters()

close all
clc
signal = load('example_signal.mat');
raw_signal = signal.signal;

fR = 1000;
bandwidth_values = [30,400];
cuttoff_low = 9;


[high, demeaned, rectif, low] = filter_butter(raw_signal,fR,bandwidth_values,cuttoff_low);

[new_signal, difference_old_new] = signal_slope_clearer(raw_signal,'zero_th',0);
[high_new, demeaned_new, rectif_new, low_new] = filter_butter(new_signal,fR,bandwidth_values,cuttoff_low);

%%
n_subplots = 6;
[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(n_subplots);

axes(ha(1))
plot(raw_signal);
hold on
x = plot(low);
set(x, 'linewidth', 2);
title('Raw vs Processed')

axes(ha(2))
hold on
plot(raw_signal)
plot(low_new)
title('Raw vs Processed - new method')

axes(ha(n_subplots-3))
plot(high);
title(['band pass filtered = [' num2str(bandwidth_values) ']'])

axes(ha(n_subplots-2))
plot(demeaned);
title('demeaned')

axes(ha(n_subplots-1))
plot(rectif);
title('rectified')

axes(ha(n_subplots))
hold on
plot(low);
plot(low_new)
title(['low pass = [' num2str(cuttoff_low) ']'])
legend({'normal', 'paul method'})

tight_subplot_ticks(ha,LastRow,0)
mmfn_inspect
%% compare multiple values for the new method

thresholds = [0:10];
threshold_types = {'zero_th','diff_th','method','abs_corrector'};

n_types = length(threshold_types);
[ha, pos,FirstCol,LastRow,LastCol] = tight_subplotBG(n_types);

for iType = 1:n_types

    current_type = threshold_types{iType};
    axes(ha(iType))
    hold on
    legend_text = {};
    for iThreshold = 1:length(thresholds)

        current_threshold = thresholds(iThreshold);
        [new_signal, difference_old_new] = signal_slope_clearer(raw_signal,current_type,current_threshold);
        [high_new, demeaned_new, rectif_new, low_new] = filter_butter(new_signal,fR,bandwidth_values,cuttoff_low);
        plot(low_new)
        legend_text{end+1} = ['threshold = ', num2str(current_threshold)];

    end
    mmfn_inspect
    legend(legend_text)
    title(['effect of ' current_type])
end




function [new_signal, difference_old_new] = signal_slope_clearer(raw_signal, varargin)

while (numel(varargin)>0) %changes values from default to specified input values: *'inputname', value*
    switch (varargin{end-1})
        case 'diff_th'
            diff_th = varargin{end};
            varargin(end-1:end) = [];
        case 'zero_th'
            zero_th = varargin{end};
            varargin(end-1:end) = [];
        case 'method'
            method = varargin{end};
            varargin(end-1:end) = [];
        case 'abs_corrector'
            abs_corrector = varargin{end};
            varargin(end-1:end) = [];
        otherwise
            error ("check input arguments");
    end%switch
end%while

%%%%%%defaults
if exist('diff_th') == 0%find a goot rule!
    sigabsvalues = sort(abs(raw_signal));
    sigabsvalues = sigabsvalues(sigabsvalues>4*rms(sigabsvalues(1:1000)));
    diff_th =sigabsvalues(round(length (sigabsvalues)*6/8))*11;
end%if
if exist('zero_th') == 0 %find a goot rule!
    diffabsvalues = sort(abs(diff(raw_signal)));
    diffabsvalues = diffabsvalues(diffabsvalues>4*rms(diffabsvalues(1:1000)));
    zero_th =diffabsvalues(round(length (diffabsvalues)/2))*15;
end%if
if exist('method') == 0
    method = 0;
end%if
if exist('abs_corrector') == 0
    abs_corrector = 1;
end%if


diff_orig = diff(raw_signal);  %distances between two points
diff_modi = diff_orig;

over = find(diff_orig>diff_th);   %slope between two points is higher than diff_th
under = find(diff_orig<-diff_th); %slope between two points is smaler than diff_th

if sum(over)>0 %there are values over diff_th
    if method == 0 %method 0 puts differences that are higher than diff_th to 0
        diff_modi(over) = 0;
    elseif method == 1 %%method 1 puts differences that are higher than diff_th to the mean between differences before and after the indexes of differences over diff_th
        nr_over = length(over);
        row = 1; col = 1;
        for ov = 1:nr_over %resorts in a overmatrix, so that indexes next to each other are in the same row
            if ov== 1
                ovmat(row,col) = over(ov);
            elseif over(ov) - over(ov-1) == 1
                col = col+1;
                ovmat(row,col) = over(ov);
            else
                col = 1;
                row = row+1;
                ovmat(row,col) = over(ov);
            end%if
        end%for
        nr_rows = rows(ovmat);
        for row = 1:nr_rows %for each row == indexes that are next to each other
            rowstore = nonzeros(ovmat(row,:)); %indexes of over (without zero --> due to matrix length)
            s = rowstore(1); %first idx of row
            e = rowstore(end); %last idx of row
            if s ~= 1 && e ~= length(diff_modi) %if first idx is unequal to 1 and last index is unequal to number of diff_orig
                predat = diff_modi(s-1); %datavalue one prior s-index
                postdat= diff_modi(e+1); %datavalue one after e-index
            elseif s == 1 %if first index is equal to 1 only values post are taken
                predat = diff_modi(e+1);
                postdat= diff_modi(e+1);
            elseif e == length(diff_modi) %only values pre
                predat = diff_modi(s-1);
                postdat= diff_modi(s-1);
            end%if

            m = mean([predat, postdat]);
            diff_modi(rowstore) = m; %sets values to mean between pre and post difference
        end%for
    end%if
end%if

if sum(under)>0 %same as over here for under values
    if method == 0
        diff_modi(under) = 0;
    elseif method == 1
        nr_under = length(under);
        row = 1; col = 1;
        for un = 1:nr_under %resorts in a undermatrix, so that indexes next to each other are in the same row
            if un== 1
                unmat(row,col) = under(un);
            elseif under(un) - under(un-1) == 1
                col = col+1;
                unmat(row,col) = under(un);
            else
                col = 1;
                row = row+1;
                unmat(row,col) = under(un);
            end%if
        end%for
        nr_rows = rows(unmat);
        for row = 1:nr_rows %for each punch of zeros which are next to each other
            rowstore = nonzeros(unmat(row,:)); %indexes of zeros (without zero --> due to matrix length)
            s = rowstore(1); %first idx of row
            e = rowstore(end); %last idx of row
            if s~= 1 && e ~= length(diff_modi) %if first idx is unequal to 1 and last index is unequal to number of diff_orig
                predat = diff_modi(s-1); %datavalue one prior s-index
                postdat= diff_modi(e+1); %datavalue one after e-index
            elseif s == 1
                predat = diff_modi(e+1);
                postdat= diff_modi(e+1);
            elseif e == length(diff_modi)
                predat = diff_modi(s-1);
                postdat= diff_modi(s-1);
            end%if

            m = mean([predat, postdat]);
            diff_modi(rowstore) = m;
        end%for
    end%if
end%if

for in = 1:length (raw_signal) %for each value
    if in == 1 %first value is taken from raw_signal
        new_signal(in) = raw_signal(in);
    elseif in > 3 && in < length(raw_signal) -3 && any(raw_signal(in-3:in+3)>-zero_th) && any(raw_signal(in-3:in+3)<zero_th) %if raw_signal signal is within the range + & - zero_th --> value stays the same
        new_signal(in) = raw_signal(in);
    else %otherwise new_signal = value + modified difference between the two points
        new_signal(in) = new_signal(in-1)+diff_modi(in-1);
    end%if
    if abs_corrector == 1 % if the new absolute value is greater than in raw_signal, than it takes raw_signal instead
        if abs(new_signal(in))>abs(raw_signal(in))
            new_signal(in) = mean([new_signal(in-1), raw_signal(in)]); %find a better solution;
        end%if
    end%if

end%for

difference_old_new = find(raw_signal ~= new_signal);


function [high, demeaned, rectif, low] = filter_butter(raw_signal,fR,bandwidth_values ,cuttoff_low)


high     = filterSignal_butter(raw_signal, 'bandpass', fR,'order', 4, 'cutoff',  bandwidth_values);
demeaned = high - mean(high); % demeaned
rectif = sqrt(demeaned.^2); %rectified
low  = filterSignal_butter(rectif, 'low', fR, 'order', 2, 'cutoff', cuttoff_low); % 4th order low-pass Butterworth filter 6 Hz





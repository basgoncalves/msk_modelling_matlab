function filtered_signal = filterSignal_butter(signal, type, frameRate, varargin)

%filters sgnal with a butterworth filter
%required input arguments: signal (that should be filtered); type (filtertype: low/high/stop/bandpass); frameRate (of the signal)
%optional input arguments: order (filter order); cutoff (cutoff frequenzy; one value for high and low, vector with two values for stop and bandpass)
%for octave: load signal pkg (pkg load signal) for butter and filtfilt functions
order = 4; %default filter order
%default cutoff frequenzies for filter types (please define frequenzies for type 'stop')
switch type
  case 'bandpass'
    cutoff = [10,400];
    order = order/4; % butter function douples filter order for bandpass and stop; filtfilt function doubles filter order
  case 'stop'
    cutoff = [10,400];
    order = order/4; % butter function douples filter order for bandpass and stop; filtfilt function doubles filter order
  case 'low'
    cutoff = 6;
    order = order/2; %filtfilt function doubles filter order
  case 'high'
    cutoff = 20;
    order = order/2; %filtfilt function doubles filter order
  otherwise
  error ("filtertype must be: 'bandpass'/'stop'/'low'/'high'");
end%switch

while (numel(varargin)>0) %changes values from default to specified input values: *'inputname', value*
    switch (varargin{end-1})
      case 'order' %redefines filter order
        order = varargin{end};
        varargin(end-1:end) = [];
        switch type
          case 'bandpass'
            order = order/4; % butter function douples filter order for bandpass and stop; filtfilt function doubles filter order
          case 'stop'
            order = order/4; % butter function douples filter order for bandpass and stop; filtfilt function doubles filter order
          case 'high'
            order = order/2; % filtfilt function doubles filter order
          case 'low'
            order = order/2; % filtfilt function doubles filter order
        end%switch
      case 'cutoff' %redefines cutoff frequenzies
        cutoff = varargin{end};
        varargin(end-1:end) = [];
        switch type
          case 'bandpass'
            if length(cutoff) ~= 2
              error ("for bandpass and stop filter type cutoff frequenzy has to be a vector with two values");
            end%if
          case 'stop'
            if length(cutoff) ~= 2
              error ("for bandpass and stop filter type cutoff frequenzy has to be a vector with two values");
            end%if
          case 'high'
            if length(cutoff) ~= 1
              error ("for high and low filter type cutoff frequenzy has to be a vector with one value");
            end%if
          case 'low'
            if length(cutoff) ~= 1
              error ("for high and low filter type cutoff frequenzy has to be a vector with one value");
            end%if
        end%switch
      otherwise
        error ("check input arguments");
    end%switch
end%while
        

[B, A] = butter(order, cutoff/(frameRate/2), type); %butter filter

filtered_signal = filtfilt(B,A, signal); %runs filter foreward and backward direction

end%function
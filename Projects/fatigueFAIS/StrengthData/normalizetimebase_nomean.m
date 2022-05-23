function  [Cycle,TimeGain]=normalizetimebase_nomean(signal,startind,endind)

% NormalizeTimeBase: calcultes a 0-100% timebase, ensemble-averages cyclic signals
% [Cycle,TimeGain]=normalizetimebase_rosie(signal,startind,endind)
%
% Input : Signal: any one-dimensional array
%         trigind : array of indices, default: [1 length(Signal)]
%                   should increase monotonously

% Process: calculates new points based on a 0-100% time base
%          by spline interpolation for each time interval

% Output:  if length(trigind)=2: Cycle [101 1]
%          if length(trigind)>2: Cycle [101 Ncycles+2]
%             Ncyles=length(trigind)-1,
%             Ncycles+1: mean signal per point, i.e. ensemble averaged
%             Ncycles+2: stand.dev ensemble averaged points
%          TimeGain: (average) amplification/reduction of time-axis (i.e. 100/(samples/cycle))

%       so my output is a matrix with cycles: each column contains data per stride
%         except for last two colums: mean and stdev
%
% WARNING user should be aware of information loss in case of excessive downsampling

% AUTHOR(S) AND VERSION-HISTORY
% Ver 1.2 April 2003 (Jaap Harlaar VUmc Amsterdam) adapted from some version

% nargin = amount of input arguments that are named when calling the
% function
if nargin < 2, startind=1; endind=length(signal); end
if nargin < 1, return, end

% FFE  a check for validity of indices
nansignal(isnan(signal))=0;
nansignal(~isnan(signal))=1;


Cycle=[1:101]'*nan;
Cyclenan=[1:101]'*nan;
CycleLength=-101;
N=length(endind);
if N>1,
    for i=1:N,
        x=[startind(i):endind(i)]-startind(i);
        CycleLength(i)=length(x);
        x=x*100/(endind(i)-startind(i));
        x=x+1;
        try
            Cycle(:,i)=interp1(x',signal(startind(i):endind(i))',[1:101]','pchip');
            Cyclenan(:,i)=interp1(x',nansignal(startind(i):endind(i))',[1:101]','pchip');
            
        catch
            Cyclenan(:,i)=nan;
            Cycle(:,i)=nan;
        end
    end
    Cyclenan(Cyclenan<1)=nan;
    Cycle=Cycle.*Cyclenan;
    
%     tmp=nanmean(Cycle(:,1:N)');
%     Cycle(:,N+1)=tmp';
%     tmp=nanstd(Cycle(:,1:N)');
%     Cycle(:,N+2)=tmp';
    TimeGain=101/mean(CycleLength);
elseif N==1,
    x=[startind(1):endind(1)]-startind(1);
    CycleLength=length(x);
    x=x.*100/(endind(1)-startind(1))+1;
    try
        Cycle(:,1)=interp1(x',signal(startind(1):endind(1))',[1:101]','pchip');
    catch
        Cycle(1:101,1)=nan;
    end
    TimeGain=101/CycleLength;
end


return
% ============================================
% END % ### NormalizeTimeBase
%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Recomend to use after BarBG.m
% Sig columns = number of bars per condition | rows = number of conditions

function addSigToBar (Sig,Marker,heightSig,MarkerSize)

if exist('Sig')&&~isempty(Sig)
    if ~exist('Marker') || isempty(Marker)
        Marker = {'*'};
    end
    if ~exist('heightSig') || isempty(heightSig)
        heightSig = max(ylim);
    end
    
    if ~exist('MarkerSize') || isempty(MarkerSize)
        MarkerSize = 20;
    end
    
    ax = gca; idx =[];
    for i = 1: length(ax.Children)
        if contains(class(ax.Children(i)),'.Bar')
            idx = [idx i];
        end
    end
   
    
    [nrows,ncols] = size(Sig);
    barwidth =  ax.Children(idx(1)).BarWidth;
    for i = 1:ncols
        x = (1:nrows) - barwidth/2 + (2*i-1) * barwidth / (2*nrows);
        for s = 1:length(Sig(:,i))
            if Sig(s,i)==1
                t= text(x(s),heightSig,Marker);
                t.FontSize = MarkerSize;
                t.Color = [0 0 0] ;
            end
        end
    end
end

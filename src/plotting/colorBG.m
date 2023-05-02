% [cMat,LineStyles,Marker] = colorBG (nPallet,nColors)
% Color pallet
%  0 = viridis;
%  1 = prism;
%  2 = parula;
%  3 = flag;
%  4 = hsv;
%  5 = hot;
%  6 = cool;
%  7 = spring;
%  8 = summer;
%  9 = autumn;
%  10 = winter;
%  11 = gray;
%  12 = bone;
%  13 = copper;
%  14 = pink;
%  15 = lines;
%  16 = jet;
%  17 = colorcube;

function [cMat,LineStyles,Marker] = colorBG (nPallet,nColors)

if nColors>163
   error('colorBG function only works for n2 =<63') 
end

if nargin < 1
    cMat = convertRGB([176, 104, 16; ...
        16, 157, 176; ...
        136, 16, 176;176,...
        16, 109;31, 28, 28]);  % color scheme 2 (Bas)
else
   
    switch nPallet
        case 1; cMat = prism;
        case 2;cMat = parula;
        case 3;cMat = flag;
        case 4;cMat = hsv;
        case 5;cMat = hot;
        case 6;cMat = cool;
        case 7;cMat = spring;
        case 8;cMat = summer;
        case 9;cMat = autumn;
        case 10;cMat = winter;
        case 11;cMat = gray;
        case 12;cMat = bone;
        case 13;cMat = copper;
        case 14;cMat = pink;
        case 15;cMat = lines;
        case 16;cMat = jet;
        case 17;cMat = colorcube;

        case 'prism';   cMat = prism;
        case 'parula';  cMat = parula;
        case 'flag';    cMat = flag;
        case 'hsv';     cMat = hsv;
        case 'hot';     cMat = hot;
        case 'cool';    cMat = cool;
        case 'spring';  cMat = spring;
        case 'summer';  cMat = summer;
        case 'autumn';  cMat = autumn;
        case 'winter';  cMat = winter;
        case 'gray';    cMat = gray;
        case 'bone';    cMat = bone;
        case 'copper';  cMat = copper;
        case 'pink';    cMat = pink;
        case 'lines';   cMat = lines;
        case 'jet';     cMat = jet;
        case 'colorcube';cMat = colorcube;
           
        case 0;cMat = (viridis); 
    end
    warning off
    if nargin == 2
        if nColors>163; error('colorBG function only works for n2 =<63'); end
        cMat = cMat(1:length(cMat)/nColors:length(cMat),:);
    else
        cMat = cMat([1:64],:);
    end
        
    warning on
end

S = sum(cMat,2);
Duplicates = [];
commonLS = {'-' '--' ':' '-.'};
commonMK = {'none' '+' 's' 'd' '^' 'v'};
N = length(commonMK);
LineStyles ={};Marker ={};
for k = 1:size(cMat,1)
    idx = find(S==S(k));
     if length(idx)==1
        LineStyles{k,1} = commonLS{1};
        Marker{k,1} = commonMK{1};
    else
    if length(idx)/N~= ceil(length(idx)/N)
        idx(end+1:ceil(length(idx)/N)*N)=NaN;
    end
    idx = reshape(idx,N,[]);
        for col = 1:size(idx,2)
            for row = 1:size(idx,1)
                if ~isnan(idx(row,col))
                    LineStyles{idx(row,col),1} = commonLS{col};
                    Marker{idx(row,col),1} = commonMK{row};
                end
            end
        end
    end
    idx = reshape(idx,[],1);idx(isnan(idx))=[];
    S(idx) = NaN;
    Duplicates(idx,1)=k;
end



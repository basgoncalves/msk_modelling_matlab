function [ cMat, cStruct, cNames, colorCell] = getColorSet( NColors , PaletteSize, skipGray)
%GETCOLORSET : Color Blind Friendly Color Sets
%  Helps you choose a palette of color blind friendly colors
%  The palette choice is such as to attempt best discriminability by a deuteranopus
%  color blind as long as PaletteSize(PaletteSize) <= 14
% 
%  1) assigns colors to [cMat, cStruct]
%  2) sets defaultAxesColorOrder accordingly for use with hold all
%  3) Returns a list [ cNames, colorCel] of NColors, 
%     where PaletteSize colors are repeated to fill up required NColors size
% 
% NColors     : size(cMat,1) = numel(cNames) --> number of curves that will be plotted on top
% PaletteSize : how many different colors are there
% 
% PaletteSize : 1..27
% ----------
% <= 11      Color Blind Safe         % SMALL
%    12..15  Color Blind okeish       % MEDIUM
%    16..19  Color Blind challenging  % LARGE
%    20..26  Color Blind unfriendly   % Too Large
% 
% Four possible color addressing modes :
% ------------------------------------
% (1) automatic
% hold all; plot(..);                       Use defaultAxesColorOrder colors, set by this function
% 
% (2) cell Array
% plot(   ,'color',  colorCell{idx})        Cell Array
% 
% (3) matrix row
% plot(...,'color',  cMat(idx,:))           Matrix Row
% 
% (4) struct name with color name field
% plot(...,'color',  cStruct.SpringGreen)   Color Name
% 
% EXAMPLE, Using Defaults
% =======
%     N = 15; %number of curves
%     [ cMat, cStruct] = getColorSet(); %use best defaults for color blind viewer
%     figure(123); hold all;
%     for idx = 1:N
%         plot([0,1],N+1-[idx,idx], 'linewidth',6)
%     end
% EXAMPLE
% =======
% N = 10;
% [ cMat, cStruct, cNames] = getColorSet(N);
% figure(123); hold on;
% for idx = 1:N
%     plot([0,1],[idx,idx],'color',colorCell{idx}, 'DisplayName',cNames{idx}, 'linewidth',6)
% end
% leg = legend(gca,'-DynamicLegend');
% legend(gca,'show');
% 
% Massimo Ciacci, November 23, 2017

global PaletteSize_INTERNAL

if nargin < 1
    NColors = 10; %minimum set, with black and NO gray (confusing with pink)
end
if nargin < 2
    PaletteSize = 10;
end
if nargin < 3
    skipGray = 0;
end

cMat          = [0,0,0]; %still add black
cStruct.Black = [0,0,0];

NColors = min(100,NColors); %it makes no sense to have > 100 curves anyways

% Clip internal palette to exact #entries needed, wo need to pass it around
PaletteSize_INTERNAL = PaletteSize; %total including black and gray

L1 = 9; 
L2 = 13;
L3 = 17;
L4 = 24;
if ~skipGray
    %add 2, black and gray
    Th1 = L1+2;
    Th2 = L2+2;
    Th3 = L3+2;    
    Th4 = L4+2;
else
    %add 1, black 
    Th1 = L1+1;
    Th2 = L2+1;
    Th3 = L3+1;    
    Th4 = L4+1;    
end 

if PaletteSize <= Th1 % 10 including black
    % 9 colors an easy color map for color blinds like me (deuteranopus),    
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,0  ,255, 'Blue');
    [cMat, cStruct] = addColor(cMat, cStruct, 255,0  ,0  , 'Red');
    [cMat, cStruct] = addColor(cMat, cStruct, 251,141,26 , 'Orange');
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,230,115, 'GreenMedium');    
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,255,255, 'Aqua');    
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,135,255, 'Azure');
    [cMat, cStruct] = addColor(cMat, cStruct, 101,43 ,143, 'Violet');    
    [cMat, cStruct] = addColor(cMat, cStruct, 255,0  ,255, 'Magenta');
    [cMat, cStruct] = addColor(cMat, cStruct, 255,92 ,205, 'Pink');
elseif PaletteSize <= Th2 % 14 including black
    % 13 good colors !, hue-sorted
    [cMat, cStruct] = addColor(cMat, cStruct, 255,0  ,0  , 'Red');
    [cMat, cStruct] = addColor(cMat, cStruct, 251,141,26 , 'Orange');    
    [cMat, cStruct] = addColor(cMat, cStruct, 255,191,0  , 'Amber');
    [cMat, cStruct] = addColor(cMat, cStruct, 255,255,0  , 'YellowHtml');
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,255,127, 'SpringGreen');
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,255,204, 'LightTeal');
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,255,255, 'Aqua');
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,191,255, 'DeepSkyBlue');
    [cMat, cStruct] = addColor(cMat, cStruct, 30 ,144,255, 'DodgerBlue');
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,0  ,255, 'Blue');    
    [cMat, cStruct] = addColor(cMat, cStruct, 101,43 ,143, 'Violet');
    [cMat, cStruct] = addColor(cMat, cStruct, 160,32 ,240, 'Purple');    
    [cMat, cStruct] = addColor(cMat, cStruct, 255,92 ,205, 'Pink');
elseif PaletteSize <= Th3 % 18 including black
    % 17 good colors !, hue-sorted
    [cMat, cStruct] = addColor(cMat, cStruct, 255,0  ,0  , 'Red');
    [cMat, cStruct] = addColor(cMat, cStruct, 251,141,26 , 'Orange');        
    [cMat, cStruct] = addColor(cMat, cStruct, 255,191,0  , 'Amber');
    [cMat, cStruct] = addColor(cMat, cStruct, 255,255,0  , 'YellowHtml');
    [cMat, cStruct] = addColor(cMat, cStruct, 195,255,0  , 'Lime');
    [cMat, cStruct] = addColor(cMat, cStruct, 127,255,0  , 'Chartreuse');
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,255,0  , 'GreenHtml');    
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,255,127, 'SpringGreen');
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,255,204, 'LightTeal');
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,255,255, 'Aqua');
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,191,255, 'DeepSkyBlue');
    [cMat, cStruct] = addColor(cMat, cStruct, 30 ,144,255, 'DodgerBlue');
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,0  ,255, 'Blue');        
    [cMat, cStruct] = addColor(cMat, cStruct, 101,43 ,143, 'Violet');
    [cMat, cStruct] = addColor(cMat, cStruct, 160,32 ,240, 'Purple');    
    [cMat, cStruct] = addColor(cMat, cStruct, 255,0  ,255, 'Magenta');        
    [cMat, cStruct] = addColor(cMat, cStruct, 255,0  ,102, 'Pink');
elseif PaletteSize <= Th4 || 1 % 26 including black
    % 24 good colors !, hue-sorted
    [cMat, cStruct] = addColor(cMat, cStruct, 255,0  ,0  , 'Red');
    [cMat, cStruct] = addColor(cMat, cStruct, 255,76 ,0  , 'Vermillion');        
    [cMat, cStruct] = addColor(cMat, cStruct, 251,141,26 , 'Orange');        
    [cMat, cStruct] = addColor(cMat, cStruct, 255,191,0  , 'Amber');
    
    [cMat, cStruct] = addColor(cMat, cStruct, 255,211,0  , 'YellowPrimary');    
    [cMat, cStruct] = addColor(cMat, cStruct, 255,255,0  , 'YellowHtml');
    
    [cMat, cStruct] = addColor(cMat, cStruct, 195,255,0  , 'Lime');
    [cMat, cStruct] = addColor(cMat, cStruct, 173,255,47 , 'GreenYellow');
    [cMat, cStruct] = addColor(cMat, cStruct, 127,255,0  , 'Chartreuse');
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,255,0  , 'GreenHtml');    
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,255,127, 'SpringGreen');
    
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,255,204, 'LightTeal');
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,255,255, 'Aqua');
    [cMat, cStruct] = addColor(cMat, cStruct, 5  ,233,255, 'ArcticBlue');    
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,191,255, 'DeepSkyBlue');
    
    [cMat, cStruct] = addColor(cMat, cStruct, 30 ,144,255, 'DodgerBlue');
    [cMat, cStruct] = addColor(cMat, cStruct, 51 ,51 ,255, 'RoyalBlue');    
    [cMat, cStruct] = addColor(cMat, cStruct, 0  ,0  ,255, 'Blue');        
%     [cMat, cStruct] = addColor(cMat, cStruct, 69 ,0  ,255, 'UltramarineBlue');
    
    [cMat, cStruct] = addColor(cMat, cStruct, 102,0  ,255, 'ElectricViolet');    
    [cMat, cStruct] = addColor(cMat, cStruct, 101,43 ,143, 'Violet');
    [cMat, cStruct] = addColor(cMat, cStruct, 160,32 ,240, 'Purple');    
    
    [cMat, cStruct] = addColor(cMat, cStruct, 255,0  ,255, 'Magenta');        
    [cMat, cStruct] = addColor(cMat, cStruct, 255,0  ,127, 'Pink');
    [cMat, cStruct] = addColor(cMat, cStruct, 255,0  ,127, 'CrimsonRose');        
end
 
if skipGray == 0
    [cMat, cStruct] = addColor(cMat, cStruct, 128,128,128, 'Grey1');
end

cNames = fieldnames(cStruct);

%% Also set default colors for hold All behavior
set(groot,'defaultAxesColorOrder',cMat);

%% extend Mat for indexing without need of wrap around
N1 = size(cMat,1);
if N1 < NColors    
    cMat   = repmat(cMat,ceil(NColors/N1),1);    
    cMat = cMat(1:NColors,:);
    
    nAddedRows = NColors-N1;
    for ii=1:nAddedRows
        cNames{end+1} = cNames{ii};    
    end
end

colorCell = cell(size(cMat,1),1);
for kk=1:size(cMat,1)
    colorCell{kk} = cMat(kk,:);
end



function [mat, struct] = addColor(mat, struct, R,G,B, Name)
global PaletteSize_INTERNAL

if PaletteSize_INTERNAL > size(mat,1)
    rgbRow = [R/255, G/255, B/255];
    mat = [mat;rgbRow];
    struct.(Name) = rgbRow;
end


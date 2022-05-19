% EXAMPLE:

close all
clear all

% testNr = 1;  %use best defaults for color blind viewer
% testNr = 2; % specify colors using colorCell
% testNr = 3; % specify colors using cMat, Select Palette Size MEDIUM
% testNr = 4; % specify colors using "hold all", Select Palette Size LARGE
testNr = 5; % compare Different Palettes, use hold All


if testNr == 1
    N = 15; %number of curves
    [ cMat, cStruct, cNames] = getColorSet(N); %use best defaults for color blind viewer
    figure(123); hold all;
    for idx = 1:N
        plot([0,1],N+1-[idx,idx], 'linewidth',6, 'DisplayName',cNames{idx})
    end
    leg = legend(gca,'-DynamicLegend');     legend(gca,'show');        
elseif testNr == 2
    N = 15;
    [ cMat, cStruct, cNames, colorCell] = getColorSet(N);
    figure(123); hold on;
    for idx = 1:N
        plot([0,1],N+1-[idx,idx],'color',colorCell{idx}, 'DisplayName',cNames{idx}, 'linewidth',6)
    end
    leg = legend(gca,'-DynamicLegend');     legend(gca,'show');    
    
elseif testNr == 3
    N = 20; %number of curves
    
    % [ cMat, cStruct, cNames]= getColorSet(N,11); %SMALL
     [ cMat, cStruct, cNames] = getColorSet(N,15); %MEDIUM
    % [ cMat, cStruct, cNames] = getColorSet(N,19); %LARGE
    
    figure(123); hold on;
    for idx = 1:N
        plot([0,1],N+1-[idx,idx],'color',cMat(idx,:), 'DisplayName',cNames{idx}, 'linewidth',6)
    end
    leg = legend(gca,'-DynamicLegend');     legend(gca,'show');    

elseif testNr == 4
       
    N = 20; %number of curves
    
    % [ cMat, cStruct, cNames]= getColorSet(N,11); %SMALL
    % [ cMat, cStruct, cNames] = getColorSet(N,15); %MEDIUM
    [ cMat, cStruct, cNames] = getColorSet(N,19); %LARGE
    
    figure(124); hold all;
    for idx = 1:N
        plot([0,1],N+1-[idx,idx], 'DisplayName',cNames{idx}, 'linewidth',6)
    end
    
    leg = legend(gca,'-DynamicLegend');
    legend(gca,'show');
    
else
    N = 28; %number of curves

    lw = 6;

    set(0,'defaultaxesfontsize',10);

    [ ~, cStruct, cNames]= getColorSet(N,11);
    figure(120); hold all;
    for idx = 1:N    
        plot([0,1],N+1-[idx,idx], 'DisplayName',cNames{idx}, 'linewidth',lw)
    end
    set(gcf,'units','normalized','position',[.01 .1 .2 .6])
    leg = legend(gca,'-DynamicLegend'); legend(gca,'show');
    title('SMALL: 9+2 colors: OPT readability')
    set(gca,'xticklabel',[],'yticklabel',[]);

    [ ~, cStruct, cNames]= getColorSet(N,15);
    figure(121); hold all;
    for idx = 1:N    
        plot([0,1],N+1-[idx,idx], 'DisplayName',cNames{idx}, 'linewidth',lw)
    end
    set(gcf,'units','normalized','position',[.21 .1 .2 .6])
    leg = legend(gca,'-DynamicLegend'); legend(gca,'show');
    title('MEDIUM: 13+2 colors')
    set(gca,'xticklabel',[],'yticklabel',[]);

    [ ~, cStruct, cNames]= getColorSet(N,19);
    figure(122); hold all;
    for idx = 1:N    
        plot([0,1],N+1-[idx,idx], 'DisplayName',cNames{idx}, 'linewidth',lw)
    end
    set(gcf,'units','normalized','position',[.41 .1 .2 .6])
    leg = legend(gca,'-DynamicLegend'); legend(gca,'show');
    title('LARGE: 17+2 colors: COLOR BLIND HARD')
    set(gca,'xticklabel',[],'yticklabel',[]);

    [ ~, cStruct, cNames]= getColorSet(N, 50);
    figure(123); hold all;
    for idx = 1:N    
        plot([0,1],N+1-[idx,idx], 'DisplayName',cNames{idx}, 'linewidth',lw)
    end
    set(gcf,'units','normalized','position',[.61 .1 .2 .6])
    leg = legend(gca,'-DynamicLegend'); legend(gca,'show');
    title('too Large: 24+2 colors')
    set(gca,'xticklabel',[],'yticklabel',[]);
end

cStruct
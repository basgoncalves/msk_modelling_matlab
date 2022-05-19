%Basilio Goncalves (2020), Griffith University 
% b.goncalves@griffith.edu.au



function plotVert (x,Style,Colors,Width)

hold on
if ~exist('Style','var') || isempty(Style)
    Style={};
    for ii = 1:length(x); Style{ii} = '--'; end
end

if ~exist('Colors','var')||isempty(Colors)
    Colors={};
    for ii = 1:length(x);  Colors{ii} = 'k'; end
end

if ~exist('Width','var')||isempty(Width)
    Width={};
    for ii = 1:length(x); Width{ii} = 0.5; end
end


for ii = 1:length(x)
    
    
    
    l = plot ([x(ii) x(ii)], [min(ylim) max(ylim)],'k');
    set(l,'LineStyle',Style{ii},'Color',Colors{ii},'LineWidth',Width{ii})
    
    
end
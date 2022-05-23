% Basilio Goncalves 2020 (Griffirth University)
%
% shadePower
% Script to be used for "PlotPowerBursts.m"
%

Angle(:,2) = []; AngVel(:,2) = []; Moment(:,2) = [];Power(:,2) = [];FootContact(:,2) = [];
Power (isnan(Power)) =[]; Moment (isnan(Moment)) =[];  AngVel (isnan(AngVel)) =[];
Power = matfiltfilt(1/fs, fcut, 2, Power);
Moment = matfiltfilt(1/fs, fcut, 2, Moment);
AngVel = matfiltfilt(1/fs, fcut, 2, AngVel);

[pfW,nfW,peW,neW] = SplitJointPower_Belli (Power,Moment,AngVel,fs);

SpacingMarkers = 1:3:length(Power);
p = plot (Power,':','LineWidth', 2, 'Color',LineColor, 'LineStyle',LStyle,...
    'LineWidth',LWidth,'Marker',PlotMarker,'MarkerSize',5,'MarkerIndices',SpacingMarkers,...
    'MarkerFaceColor',LineColor);


hold on
%% negative flexion
y1 = nfW;
[SplitData,IdxBursts] = findBursts (abs(y1),0);
Fld = fields(SplitData);

for ss = 1: length(fields(SplitData))
    
    idx = IdxBursts{ss};
    x=idx;                                      % initialize x row vector
    Top= y1(idx)';                           % create top of shaed area
    Bottom = zeros(1,length(idx));              % create bottom of shaded
    X=[x,fliplr(x)];                            % create continuous x value array for plotting
    Y=[Bottom fliplr(Top)];                     % create y values for out and then back
    f1 = fill(X,Y,'k');
    set(f1,'FaceColor', [0 0 0],'EdgeColor','none')
    alpha 0.5
    
    %   tt = text(median(x),mean(y1),'fW^-','FontName','TimesNewRoman','HorizontalAlignment','center');
end

%% positivie flexion
y1 = pfW;
[SplitData,IdxBursts] = findBursts (abs(y1),0);
Fld = fields(SplitData);

for ss = 1: length(fields(SplitData))
    
    idx = IdxBursts{ss};
    x=idx;                                      % initialize x row vector
    Top= y1(idx)';                           % create top of shaed area
    Bottom = zeros(1,length(idx));              % create bottom of shaded
    X=[x,fliplr(x)];                            % create continuous x value array for plotting
    Y=[Bottom fliplr(Top)];                     % create y values for out and then back
    f1 = fill(X,Y,'k');
    set(f1,'FaceColor', [0 0 0],'EdgeColor','none')
    alpha 0.5
    
    %       tt = text(median(x),mean(y1),'fW^+','FontName','TimesNewRoman','HorizontalAlignment','center');
end

%% positive extensor 
y1 = peW;
[SplitData,IdxBursts] = findBursts (abs(y1),0);
Fld = fields(SplitData);

for ss = 1: length(fields(SplitData))
    
    idx = IdxBursts{ss};
    x=idx;                                      % initialize x row vector
    Top= y1(idx)';                           % create top of shaed area
    Bottom = zeros(1,length(idx));              % create bottom of shaded
    X=[x,fliplr(x)];                            % create continuous x value array for plotting
    Y=[Bottom fliplr(Top)];                     % create y values for out and then back
    f1 = fill(X,Y,'k');
    set(f1,'FaceColor', [0.4 0.4 0.4],'EdgeColor','none')
    alpha 0.5
    %      tt = text(median(x),mean(y1)/2,'eW^+','FontName','TimesNewRoman','HorizontalAlignment','center');
end


%% negative extensor 
y1 = neW;
[SplitData,IdxBursts] = findBursts (abs(y1),0);
Fld = fields(SplitData);

for ss = 1: length(fields(SplitData))
    
    idx = IdxBursts{ss};
    x=idx;                                      % initialize x row vector
    Top= y1(idx)';                           % create top of shaed area
    Bottom = zeros(1,length(idx));              % create bottom of shaded
    X=[x,fliplr(x)];                            % create continuous x value array for plotting
    Y=[Bottom fliplr(Top)];                     % create y values for out and then back
    f1 = fill(X,Y,'k');
    set(f1,'FaceColor', [0.4 0.4 0.4],'EdgeColor','none')
    alpha 0.5
    %       tt = text(median(x),mean(y1),'eW^-','FontName','TimesNewRoman','HorizontalAlignment','center');
    
end
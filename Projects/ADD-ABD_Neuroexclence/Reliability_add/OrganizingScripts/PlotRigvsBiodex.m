% calculate correlation between Rig and Biodex

function PlotRigvsBiodex (Data, description)
[~,Ntrials] = size (Data);
Conditions = 1:2:Ntrials; 
meanData = [];


for Trial = Conditions   
    newData = Data (:,Trial:Trial+1);
    meanData(:,end+1)= (newData (:,2)+ newData(:,1))/2;                   % mean for each row
end

Label = 1;                                                          % variable to increas by one at every loop t
Validity = description;
for Trial = 1:6                                                    % loop through the 6 muscle actions (AD, AB, E...)                   
    %% calculate Bias and Pearson Correlation Coefficient
    SDdif = std(meanData (:,Trial+6)- meanData(:,Trial));                 % Standard deviation for each pair of trials (Test2 - Test1)
    indDif = meanData (:,Trial+6)- meanData(:,Trial);                     % Test 2 - Test 1
    Bias = mean (indDif);                                               % Bias as the mean difference between tests
    LoA = SDdif * 1.96;                                                 % Limit of Agreement
    uLoA = Bias + LoA;
    lLoA = Bias  - LoA;
    BiasText = sprintf ('%.2f ± %.2f',Bias,LoA);
    
    [R,Pr] = corrcoef (meanData (:,Trial+6),meanData(:,Trial));
    
    Validity {2,Trial} = BiasText;
    Validity {3,Trial} = R(1,2);
    %% create scatterplot with trendline
    Figure.figH(Trial)= figure('WindowStyle', 'docked', ...
      'Name', sprintf ('%s',description{Label}), 'NumberTitle', 'off');        % create a docked figure (https://au.mathworks.com/matlabcentral/answers/157355-grouping-figures-separately-into-windows-and-tabs)
    scatter(meanData(:,Trial),meanData (:,Trial+6))   
    coef = polyfit(meanData(:,Trial),meanData (:,Trial+6),1);                     % calculate linear regression coefficients
    h = refline(coef(1), coef(2));  
    %% set graph settings   
    ylabel ('Biodex Torque (N.m)');
    xlabel ('Rig Torque (N.m)');
    
    box off
    title (sprintf ('%s',description{Label}),...
        'Interpreter','none');
    
    legend (sprintf(' y = %.2fx + %.2f',coef(1),coef(2)),sprintf(' R = %.2f',R(1,2)));
    Label=Label+1;
    
    
    
end
save BiodexvsRig

%% Description --  Goncalves, BAM (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
% To be used after using Demuse matlab plugin 
% designed for Ricardo Mesquita (ECU)
% --------------------------------------
%OUTPUT
%   PolynomialData = Double with with the same number of channels as
%   inputData
%
%   .mat = all the data used in the function and all the plots in one
%   figure
%
%   Plots for each plynomial in a folder called "results"
%
%   .xls = excel comaptible file with PolynomialData
%
% --------------------------------------
%UPDATES
                
%% Start Function
function PolynomialData = FrequencySpikes_Demuse(Dirfile,PolDegree)

close all                                           % close all figures
%% select file
if ~exist('Dirfile') || isempty(Dirfile)
[Originalfilename, pathname] = uigetfile('*.mat', 'Select a matfile as a resuk from Demuse software');
Dirfile = [pathname Originalfilename];
else
    [pathname,Originalfilename] = fileparts(Dirfile);
end
cd (pathname);
load (Originalfilename);

% IPTs =        [N*M double] with N motorunits and M frames. Contains the raw EMG
%               data
% MUIDs =       [1*N cell] with the ID (name) of each motor unit
% MUpulses =    [1*N cell] with the ID (name) of each motor unit

tic

% Choose the name of the output results folder
prompt = {'Type the name for the excel file or type nothing if you do not want to save'};
dlgtitle = 'Input';
dims = [1 90];
Originalfilename = erase(Originalfilename,'.mat');
definput = {sprintf('%s-results',Originalfilename)};

filename = definput;
% results folder
ResultsFolder = ([pathname filesep 'results' filesep filename{1}]);
mkdir (ResultsFolder);

%% Instataneous frequency
fs = fsamp; %sampling frequency

% create epochs
epochs = 1: 24*fs:length(IPTs);
epochs(end+1) = length(IPTs);

% ForceChannel
ForceChannel = ref_signal(2,:);
RefChannel =  ref_signal(1,:);
% Flip data verticaly if needed
ForceDataFlipped = 0-ForceChannel;                                       % flip data vertically

if max(ForceDataFlipped) > max (ForceChannel)                                 % if the max value of the flipped data is greater than the max of the initial filtered data
    ForceChannel = ForceDataFlipped;                                          % use the flipped data (because the data was
end

InstantFreqVect=[];
InstantFreqVect_Long = [];
for MU = 1: length (MUPulses)               % loop through the motor units
    
    for Pulse = 2: length(MUPulses{MU})     % loop through the pulses
        Frame1 = (MUPulses{MU}(1,Pulse-1));                                                    % find frame for each spike
        Frame2 = (MUPulses{MU}(1,Pulse));
        InstantFreqVect(Frame1,MU) = ...
            1/((MUPulses{MU}(1,Pulse)- MUPulses{MU}(1,Pulse-1))/fs);                        % find intantaneous frequency
        
        InstantFreqVect_Long (Frame1:Frame2,MU) = ...
            1/((MUPulses{MU}(1,Pulse)- MUPulses{MU}(1,Pulse-1))/fs);
    end
end

% make the frequency variables thesame sise as the original raw EMG
InstantFreqVect(length(IPTs),:)=0;
InstantFreqVect_Long(length(IPTs),:)=0;

% Remove all frequencies <1.7Hz
 remove_freqLessThan1_7_demuse
% Remove all frequencies >67Hz - 17/04/2019
 remove_freqMoreThan67_demuse
 
%% polynomial fit _ between 1.7Hz and 67Hz

if ~exist ('PolDegree')|| isempty(PolDegree) || PolDegree < 1
PolDegree = inputdlg('Choose ploynomial degree (eg. 5)','Input',[1 45],{'5'});  % polynomial degree with user input
PolDegree = str2double(PolDegree{1});
end

    f = waitbar(0,'Please wait...');

for EP = 1:length(epochs)-1   % loop through the epochs
    epochFrames = epochs(EP):epochs(EP+1);
    PolynomialData = InstantFreqVect(epochFrames,MU);
    PolynomialData_after500ms = InstantFreqVect(epochFrames,MU);
        waitbar(EP/length(epochs),f,'Processing your data');
    
    for  MU = 1: length (MUPulses)               % loop through the motor units
        
        Vector = InstantFreqVect (epochFrames,MU);                    % plateus to use on the polynomial function
        
        Spikes = find(Vector); 
        
        %Force Data (used in a script - plot_parameters_Demuse)
        ForceData = ForceChannel(epochFrames);
        RefData = RefChannel(epochFrames);
        if isempty (Spikes)
            PolynomialData(:,MU) = zeros(length(PolynomialData),1);
            PolynomialData_after500ms (:,MU) = zeros(length(PolynomialData),1);
            warning on 
            warning ('No spikes found for Montor Unit number %.f',MU) 
            continue
        else
            x = Spikes;
            y = Vector (Spikes);
            % add the previous frequency to match the number firings (COMMENT IF
            % NEEDED)
            %     x = [Spikes(1); x];
            %     y =[y(1) ;y];
            
        end
        
        %% Check if there is any outliers -    COMMENT IF NOT NEEDED
        %   figure
        %   plot(x,y,'.','MarkerSize',12,'Color', [0.25 0.25 0.25] )
        %       xlim([0 length(Vector)]);
        %     choosePoint = 1;
        %     while choosePoint(1) > 0
        %         choosePoint = ginput(1);                    % choose position of the wrong point
        %         [~,idx] = min(abs(y-choosePoint(2)));    % check the closest point to the determined position
        %         choosePoint(1);
        %         if choosePoint(1)> 0
        %             x(idx) = [];
        %             y(idx)=[];
        %             plot(x,y,'.','MarkerSize',12,'Color', [0.25 0.25 0.25] )
        %               xlim([0 length(Vector)]);
        %         end
        %     end
        %
        %%  Create plynomial
        p = polyfit(x,y,PolDegree);                 % polynomial fucntion (https://au.mathworks.com/help/matlab/ref/polyfit.html#bue6sxq-1-y)
        
        xPol = x(1):1:x(end);
        PoliFunct = polyval(p,xPol)';
        
        % assign each polynomial data final variable between 1.7Hz and 67Hz
        PolynomialData(xPol,MU)= PoliFunct;
        
        % find indexes of polynomial 500ms after the beginning
        After500ms = find(xPol>xPol(1)+fs/2);
        
        x_500ms = xPol(After500ms);
        PoliFit_500ms =  PoliFunct(After500ms);
        
        % assign each polynomial data final variable between 1.7Hz and 67Hz
        % -AFTER 500ms of onset
        PolynomialData_after500ms (x_500ms, MU) = PoliFit_500ms;          
        %% plot data  between 1.7Hz and 67Hz      
        plot_parameters_Demuse   %script for the plotting parameters
%         title (sprintf('Channel %d - 1.7Hz to 64Hz', MU))  

        %% save figure
        mkdir([ResultsFolder filesep sprintf('Epoch_%d',EP) filesep 'PolynomialFigures'])
        cd([ResultsFolder filesep sprintf('Epoch_%d',EP) filesep 'PolynomialFigures'])
        
        if isempty (filename{1})~=1
            saveas(fig, sprintf('PolFit-Channel%d.jpeg',MU))
        end
        close all
        %% plot data  between 1.7Hz and 67Hz - after 500ms of onset
        plot_parameters_Demuse   %script for the plotting parameters
        
        %% save figure
        mkdir([ResultsFolder filesep sprintf('Epoch_%d',EP) filesep 'PolynomialFigures_after500ms'])
        cd([ResultsFolder filesep sprintf('Epoch_%d',EP) filesep 'PolynomialFigures_after500ms'])
        if isempty (filename{1})~=1
            saveas(fig, sprintf('PolFit_after500ms-Channel%d.jpeg',MU))
        end
        close all
    end
    
    PolynomialData(:,end+1) = ForceData;                                       % add the force vector at the end of PolynomialData
    PolynomialData_after500ms (:,end+1) = ForceData;
    PolynomialData(:,end+1) = RefData;                                       % add the force vector at the end of PolynomialData
    PolynomialData_after500ms (:,end+1) = RefData;
    
    clear time y1 y p x SpikesCol InitialSpike FinalSpike Nsamples Vector Vector2
    
    
    %% save data
    
    if ~isempty (filename{1})
        
        mkdir ([ResultsFolder filesep sprintf('Epoch_%d',EP)]);
        cd ([ResultsFolder filesep sprintf('Epoch_%d',EP)]);
        save (filename{1}, 'PolynomialData' , 'PolynomialData_after500ms');                                              % save data with the name given
        
        % save data in excel
        cd (ResultsFolder)
          
        filenameXls = sprintf ('%s.xlsx', filename{1});                     % save .xls = Nth degree plynomial without frequeencies below 1.7Hz and above 67Hz
        xlswrite(filenameXls,PolynomialData,sprintf('Epoch_%d',EP));
        
        filenameXls = sprintf ('%s_NoFirst500ms.xlsx', filename{1});                % save .xls = Nth degree plynomial without frequeencies below 1.7Hz and above 67Hz AND without first 3 firings
        xlswrite(filenameXls,  PolynomialData_after500ms, sprintf('Epoch_%d',EP));

    end
    close all
    
    
end

  waitbar(1,f,'Excel data saved');
%% merry xmas

figure, hold on, N = 6^5; c = 50; k = randi(6,c,1); l = randperm(N,c);
q = @(x) rand(N,1); a = q()*2*pi; z = q(); r = .4*(1-z); t = q();
x = r.*cos(a); y = r.*sin(a); P = {'ro','ys','md','b^','kh','c*'};
scatter3(x.*t,y.*t,z,[],[zeros(N,1) (t.*r).^.6 zeros(N,1)],'*')
plot3(0,0,1.05,'rp','markers',12,'markerf','r')
for i = 1:6
    L = l(k==i);
    plot3(x(L),y(L),z(L),P{i},'markers',8,'linew',2);
end
[X,Y,Z] = cylinder(.025,30);
surf(X,Y,-Z*.1)
view(3, 9), axis equal off
for i = 1:9:c*9, set(gca,'vie',[i, 9]); drawnow, end

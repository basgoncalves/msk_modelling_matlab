% Description --  Goncalves, BAM (2021)
% Created by Basilio Goncalves
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% Designed for Ricardo Mesquita (r.mesquita@ecu.edu.au)
% --------------------------------------
% Script to build polynomial data from a single file
% Instruction: Select .mat file and indicate the polynomial degree
%
% Update 17 Jun 2021 - interpolation volume data and add the RMSemg to csv
% Update 17 Nov 2021 - option to either upsample volume or downsample EMG data

function FiringFrequencyPlot_Breathing(Dirfile,PolDegree,EMGdownsample)

warning off
fp = filesep;
%% select file
if ~exist('Dirfile') || isempty(Dirfile)
    [Originalfilename, pathname] = uigetfile('*.mat', 'Select a .mat file');
    Dirfile = [pathname Originalfilename];
else
    [pathname,Originalfilename] = fileparts(Dirfile);
end

% select degree polynomial
if ~exist ('PolDegree')|| isempty(PolDegree) || PolDegree < 1
    PolDegree = inputdlg('Choose polynomial degree (eg. 5)','Input',[1 45],{'5'});  % polynomial degree with user input
    PolDegree = str2double(PolDegree{1});
end

if ~exist ('EMGdownsample')|| isempty(EMGdownsample)
   EMGdownsample = 0; 
end


% results folder
ResultsFolder = ([pathname fp 'results' fp Originalfilename]);
mkdir ([ResultsFolder fp 'PolynomialFigures']);
mkdir ([ResultsFolder fp 'PolynomialFigures_after500ms']);

cd (pathname);
AllChannels = load (Originalfilename);
channels = fields(AllChannels);
% find volume and RMS emg channels
idx = find(contains(channels,'_Ch7')); VolumeChannel = channels{idx}; channels(idx) = [];
idx = find(contains(channels,'_Ch20')); RMSemgChannel = channels{idx}; channels(idx) = [];

TimeVol = AllChannels.(VolumeChannel).times;
TimeEMG = AllChannels.(RMSemgChannel).times;

[Nrows,ii] = max([length(TimeVol) length(TimeEMG)]);

if EMGdownsample==0
    time = TimeEMG;
    Volume = interp1(TimeVol,AllChannels.(VolumeChannel).values,TimeEMG);             % upsample Volume
    EMGrms = AllChannels.(RMSemgChannel).values;
elseif EMGdownsample==1
    time = TimeVol;
    Volume = AllChannels.(VolumeChannel).values;                                        % down sample EMG
    EMGrms = interp1(TimeEMG,AllChannels.(RMSemgChannel).values,TimeVol);
end

SaveData = time;
SaveData(:,2) = Volume;
SaveData(:,3) = EMGrms;

SaveData_after500ms = time;
SaveData_after500ms(:,2) = Volume;
SaveData_after500ms(:,3) = EMGrms;

for MU = 1:length(channels)
    
    Col = MU+3;
    SaveData(:,Col) = 0;
    SaveData_after500ms(:,Col) = 0;  
    
    TimeSpikes = AllChannels.(channels{MU}).times;
    [~,idxSpikes] = intersect(round(time,3),round(TimeSpikes,3));

    TimeSpikes_after500ms = TimeSpikes(TimeSpikes>TimeSpikes(1)+0.5);
    [~,idxSpikes_after500ms] = intersect(round(time,3),round(TimeSpikes_after500ms,3));
    
    fs = 1/(time(2)-time(1));
    
    % full data polynomial
    P = CalcPoly_Breathing(time,Volume,TimeSpikes,PolDegree,fs);
    initialRow = idxSpikes(1);
    SaveData(initialRow:initialRow+length(P.PolTimes)-1,Col) =  P.Pol;
    title('Full polynomial')
    
    saveas(gcf,[ResultsFolder fp 'PolynomialFigures' fp channels{MU} '.tiff'])
    close(gcf)
    
    % polynomial after first 500 ms
    initialRow = idxSpikes_after500ms(1);
    SaveData_after500ms(initialRow:initialRow+length(P.PolTimes_after500ms)-1,Col) =  P.Pol_after500ms;
    title('Polynomial after initial 500ms')
    saveas(gcf,[ResultsFolder fp 'PolynomialFigures_after500ms' fp channels{MU} '_after500ms.tiff'])
    close(gcf)
end
%% save data
cd (ResultsFolder)
save ([ResultsFolder fp Originalfilename '.mat'], 'SaveData','P');   
Headings = {'Time' 'Volume' 'RMSemg' channels{1:end}};
% save data with the name given
% save data in excel
filenameXls = [ResultsFolder fp Originalfilename '.xlsx'];                          % save .xls = Nth degree plynomial without frequeencies below 1.7Hz and above 67Hz
xlswrite(filenameXls,SaveData,'sheet1','A2');
xlswrite(filenameXls,Headings,'sheet1','A1');

% save data in excel
filenameXls = [ResultsFolder fp Originalfilename '_after500ms.xlsx'];               % save .xls = Nth degree plynomial without frequeencies below 1.7Hz and above 67Hz
xlswrite(filenameXls,SaveData_after500ms,'sheet1','A2');
xlswrite(filenameXls,Headings,'sheet1','A1');



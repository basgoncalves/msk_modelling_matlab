%% Description - Goncalves, BM (2019)
% Gets max EMG for all the channels in all the .c3d files in one folder
%
%
%
% CALLBACK FUNTIONS
%   E:\MATLAB\DataProcessing-master\src\emgProcessing\Functions
%   ImportEMGc3d
%   emgAnalysis
%   emgAnalysis_noplots
%-------------------------------------------------------------------------
%INTPUT
%   logic - 1(Default) = plot graphs; 2 = don't plot 
%-------------------------------------------------------------------------
%OUTPUT
%   EMGdataAll - NxM cell matrix with maximum EMG amplitude for M channels 
%   and N condition
%
%%  % The channels used in the normal EMG data are as follows
% Channel1 = VM
% Channel2 = VL
% Channel3 = RF
% Channel4 = GRA
% Channel5 = TA
% Channel6 = AL
% Channel7 = ST
% Channel8 = BF
% Channel9 = MG
% Channel10 = LG
% Channel11 = TFL
% Channel12 = Gmax
% Channel13 = Gmed
% Channel14 = PIR
% Channel15 = OI
% Channel16 = QF
% Channel17 = Force

%--------------------------------------------------------------------------
%% Start Function
function [EMGdataAll,FFTall] = EMGanalysis_FAI(logic,folderC3D,TrialList,Dir,SubjectInfo)
fp = filesep;
if nargin<1
    logic = 1;
end

% find folder with .c3d files
if nargin<2
folderC3D = uigetdir('','select Folder with c3d files for isometric trials');
end

% get all the c3d files in the path
cd (folderC3D);
AllFiles = dir ('*.c3d');

saveDir = [Dir.Results fp 'HipIsometric' fp 'EMG' fp SubjectInfo.ID];

EMGindivudalChannels = struct;
channels = {'VM','VL','RF','GRA','TA','AL','ST','BF','MG','LG','TFL','Gmax','Gmed','PIR','OI','QF','Force'};

% channels to look for in the c3dfile 
ChannelNames = {'Voltage_1_VM';'Voltage_2_VL';'Voltage_3_RF';'Voltage_4_GRA';'Voltage_5_TA';...
    'Voltage_6_AL';'Voltage_7_ST';'Voltage_8_BF';'Voltage_9_MG';'Voltage_10_LG';...
    'Voltage_11_TFL';'Voltage_12_Gmax';'Voltage_13_Gmed_intra';'Voltage_14_PIR_intra';...
    'Voltage_15_OI_intra';'Voltage_16_QF_intra';'Force_Rig'};
%Convert c3d files
col = 0;
for file =  1:length (AllFiles)
%     fprintf ('%.f \n', file)
    % find folder with .c3d files
    path =   AllFiles(file).folder;
    filename = AllFiles(file).name;
    filename = sprintf('%s\\%s',path,filename);
    
    if ~contains(filename,TrialList)
        continue
    end
        
    cd(path);
    % import EMG from .c3d file
    [filename,EMGdata,Fs,Labels] = ImportEMGc3d(filename,ChannelNames);
    
    [~,Ncol] = size (EMGdata);
    col = col+1;
    for i = 1: Ncol
    EMGindivudalChannels.(channels{i})(1:length(EMGdata(:,i)),col)= EMGdata(:,i);
    end
    EMGindivudalChannels.Labels{col} = filename(1:end-4);
    
end

cd([Dir.Elaborated fp 'StrengthData'])
save RawEMG EMGindivudalChannels

%% Filter EMG
Muscles = fields(EMGindivudalChannels);
Muscles(end-1:end)=[];                                                      % names of the muscles ONLY
Nmuscles = length (Muscles);
Labels = EMGindivudalChannels.Labels;                                       % names of the trials 
ForceRaw = EMGindivudalChannels.Force;

for M = 1:Nmuscles
    tic
    EMGdata = EMGindivudalChannels.(Muscles{M});
            
    % first column = name of the muscles 
    EMGdataAll{M+1,1} = Muscles{M};
    
    %create new dir for each trial
    NewFolder = sprintf ('%s\\%s', saveDir,Muscles{M});
    mkdir (NewFolder);
    cd (NewFolder);
    
    %number of channels
    [~,Ncol] = size (EMGdata);
    for i = 1: Ncol                                                         % i = different trials (columns)  
        % get one EMG channel
        EMG = rmmissing((EMGdata(:,i)));
       
        %filter parameter 
        fcolow = 6;
        if contains(Muscles{M},'Gmed')||contains(Muscles{M},'OI')||...
                contains(Muscles{M},'PIR')||contains(Muscles{M},'QF')
            fcohigh = 50;
        else 
            fcohigh = 20;
        end
        actualFrames = 1: length(EMG);  
                      
        %force data for each trial
       [ForceData,MaxForce,baselineForce,peakForce] = GetMaxForce (ForceRaw(:,i),Fs);
       
       %check force onset (when it raises above 1/3 of its maximum)
       ThresholdForce = max(ForceData)*0.8;
       ForceInterest = double(ForceData>ThresholdForce);
        a=find(ForceInterest); 
        ForceInterest(a(1):a(end))= 1;
               
        if logic == 2
        [filter_EMG1,FFT_EMG] = ...
            emgAnalysis_noplots(EMG, Fs, fcolow, fcohigh);
        
        % First row, column i = Name of the trial
        EMGdataAll{1,i+1} = Labels{i}; 
        FFTall{1,i+1}=Labels{i};
        % Max EMG for each muscle / trial
         a=find(ForceInterest); 
        EMGdataAll{M+1,i+1}= max(movmean(filter_EMG1(a),Fs/10));
                
        elseif logic == 1
              
        % filter, rectify and plot EMG
        [~,~, fig,~, ~,filter_EMG1,FFT_EMG] = ...
            emgAnalysis(EMG, Fs, fcolow, fcohigh, actualFrames);
        

        title (sprintf('%s - %s',Muscles{M},Labels{i}),...
            'Interpret','None');
       
        % plot force data
        yyaxis right
        plot(ForceData,'-.','LineWidth', 1.5); 
        ylabel ('Force (N)');
        
         % First row, column i = Name of the trial
        EMGdataAll{1,i+1} = Labels{i}; 
        FFTall{1,i+1}=Labels{i};
        % Max EMG for each muscle / trial
         a=find(ForceInterest); 
        [EMGdataAll{M+1,i+1},idx]= max(movmean(filter_EMG1(a),Fs/10));
        
        % plot max EMG point
      
        idx = a(1)+idx;
        yyaxis left
        hold on
        plot(idx:idx+Fs/2,filter_EMG1(idx:idx+Fs/2),'r.','MarkerSize', 10);                   
        
        %plot vertical lines
        yValue = yticks;
        plot ([a(1) a(1)],[yValue(1) yValue(end)],':')
        plot ([a(end) a(end)],[yValue(1) yValue(end)],':')
        lgd = legend;
        lgd.String{4}= 'MaxEMG';
        lgd.String{5}= 'Max Window';
        lgd.String{6}= 'Max Window';
        lgd.String{7}= 'Force(N)';
        axis tight
        ylabel ('EMG (mV)');
        trialTime = length(ForceData)/Fs;
        xticks (0:length(ForceData)/5:length(ForceData));
        xticklabels(0:trialTime/(length(xticks)-1):trialTime);
        xtickangle(45)
        xlabel ('Time (s)');
        mmfn
        fullscreenFig(0.9,0.9)
        saveas(gcf, sprintf('%s-%s.tif',Muscles{M},Labels{i}))
        close all
        end
           
              
    end
    
    fprintf('%.f out %.f analysed \n',M,Nmuscles)
    
end
toc
fprintf ('EMG data extracted for all trials \n')



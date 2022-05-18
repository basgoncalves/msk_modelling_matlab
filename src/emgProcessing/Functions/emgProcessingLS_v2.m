function emgProcessingLS_v2(isNotch, sessionData, sessionName, emgMax, motoDir, dynamicFolders)
%   Input if Notch is required (Yes, No), session Data, timePoints from
%   cropping into gait cycles, and sessionName (e.g., fast or slow
%   walking). emgMax specifies the maxEMG file used for normalisation.
%   The Notch filter will only be applied for data collected directly
%   through Nexus. motoDir specified the MotoNMS directory.
%   The sessionData is from the MOtoNMS c3d2mat function

%% EMG scaling code
% Designed to work with Load sharing data set
% Code searchers through user provided EMG mat files, processes the signal
% and searches for its global max.
% Code then stores all max emg values to file using CEINMS standard format.
% Code then asks for trials to scale the EMGs against max, and print to
% CEINMS standard format.

% By David Saxby, October 18th, 2015, d.saxby@griffith.edu.au
% Edited by Gavin Lenton, October 2017

%% EMG processing settings
videoSamplingRate = 100;

% Sampling rate
emgSamplingRate = 1000;
a2v = emgSamplingRate/videoSamplingRate;
emgSamplingTimeStep = 1/emgSamplingRate;
emgNyquistLimit = emgSamplingRate/2;
nominalPassBand = [30, 300];
passBandLowerEdge = nominalPassBand(1)/emgNyquistLimit;
passBandUpperEdge = nominalPassBand(2)/emgNyquistLimit;
normalizedPassBand = [passBandLowerEdge, passBandUpperEdge];
% high- and low-pass cut-off frequencies for band-pass filter
% N.B. In pass-band designs, cutoff frequencies are specified
% as a proportion of the Nyquist limit, i.e. rad/sample, not as a scalar.
passBandFilterOrder = 10; % this is double in matlab's conversion
lowPassCutOff = 6; % low-pass cut-off frequency for linear envelope
filterType = 'damped'; % Critically damped filter
emgPrintTag = '.mot'; % file format for printing EMG files for CEINMS

% Notch filter settings to remove 50 Hz (+harmonics) electromagnetic
% interference in signal. *ONLY APPLY TO DATA COLLECTED THROUGH NEXUS*
% Design
fo = 50; % nominal tone
q = 50; % filter "quality factor". Related to bandwidth of notch filter by q = fo/bw
bw = (fo/emgNyquistLimit)/q;
notchFilterOrder = (emgNyquistLimit/fo)*2; % specifies a filter with n+1 coefficients (numerator and demoninator).
% The filter will have n notches distributed from -1 to 1 normalized
% frequency domain

%% Generate pass band filter coefficents - change passBand for 1000Hz data
%  collection otherwise highPass will be = 1 and error thrown
[b_bp, a_bp] = butter(passBandFilterOrder,normalizedPassBand,'bandpass');

%% Optional, uncomment to inspect the band pass filter design
% plot filter magnitude and phase response
% freqz(b_bp,a_bp)

%% Generate notch filter
notchDesign = fdesign.comb('notch', 'N,BW', notchFilterOrder, bw);
notchFilter = design(notchDesign);

% Alternative filter formulation
% [b_notch, a_notch] = iircomb(emgSamplingRate/fo, bw, 'notch');

%% Optional, uncomment to inspect the notch filter design
% fvtool(notchFilter);

% Alternative notch visualization
% fvtool(b_notch, a_notch);

%% EMG labels in the .mat file - CHANGE IF THESE DON'T MATCH YOUR LABELS
emgLabelsInMatFile = {'TA', 'Channel2',  'MG', 'LG', 'Channel5', 'BF', 'VM', 'VL',...
	'RF', 'Sol', 'MH'};
emgLabelsCEINMS = {'tibant_r', 'Channel2', 'gasmed_r', 'gaslat_r', 'Channel5' 'bicfemlh_r', 'vasmed_r', ...
	'vaslat_r', 'recfem_r', 'sol_r', 'semimem_r'};

%% Gait sub-phases as defined in Sturnieks et al 2011
preContactTime = 0.05; % 50 ms prior to heelstrike

%% Directories and files
motoNmsSrcDir = [motoDir, filesep, 'src'];
dynElabDir = regexprep(sessionData, 'sessionData', 'dynamicElaborations');

originalPath=pwd;
cd(motoNmsSrcDir)
cd('shared')
sharedFunctionsPath=pwd;
addpath(sharedFunctionsPath)
cd(originalPath)

%% Dynamic signal conditioning

% Loop through conditions

for conditions = 1:length(dynamicFolders)
	
	trialElabDir = [dynElabDir, filesep, dynamicFolders{conditions}];
	
	gaitCyclesDir = dir([trialElabDir, filesep, 'EMGs', filesep, 'Raw']);
	isub=[gaitCyclesDir(:).isdir];
	trialNames={gaitCyclesDir(~isub).name}';
	trialFolders={gaitCyclesDir(~isub).folder}';
	
	%% Loop through gait cycles
	
	for cycle = 1:length(trialFolders)
		
		% Load session data analog file
		analogFile = fullfile(trialFolders{cycle}, trialNames{cycle});
		try
			load(analogFile);
		catch me
			error(['Cannot load analog data mat file for ' , trialNames{cycle}, ' ensure this data has been converted from c3d to mat'])
		end
		
		% Initialise
		dynamicTrialScaledEmg = zeros(size(dynamicEMGMatrix));
		
		%      % signal dimensions
		%      lengthOfSignal = size(dynamicEMGMatrix,1);
		
		%      % define frequency domain
		%      f = emgSamplingRate*(0:(lengthOfSignal/2))/lengthOfSignal;
		
		% Condition the dynamic EMG
		for n = 1:length(emgLabelsInMatFile)
			
			% De-trended
			detrendedSignal = detrend(dynamicEMGMatrix(:, n), 'constant');
			
			% Band pass filter
			bandPassOut = filter(b_bp, a_bp, detrendedSignal);
			
			% Apply notch filter
			notchedSignal = filter(notchFilter, bandPassOut);
			
			% -----  UNCOMMENT TO RUN FFT ----- %
			
			%           % Fast fourier transform on the band-passed signal
			%           fastFourierBandPassSignal = fft(bandPassOut);
			%
			%           % FFT on the notched signal as well
			%           fastFourierNotchedSignal = fft(notchedSignal);
			%
			%           % Two sided spectrum of FFT non-notched
			%           P2 = abs(fastFourierBandPassSignal/lengthOfSignal);
			%           P1 = P2(1:round(lengthOfSignal/2)+1);
			%           P1(2:end-1) = 2*P1(2:end-1);
			%
			%           % Two sided spectrum of FFT notched signal
			%           P2n = abs(fastFourierNotchedSignal/lengthOfSignal);
			%           P1n = P2n(1:round(lengthOfSignal/2)+1);
			%           P1n(2:end-1) = 2*P1n(2:end-1);
			%
			%           if ~isequal(length(f), length(P1))
			%                f = emgSamplingRate*(0:((lengthOfSignal+1)/2))/(lengthOfSignal+1);
			%           end
			
			% Full-wave rectify
			if strcmp(isNotch, 'yes') == 1
				fullWaveRectifiedSignal = abs(notchedSignal);
			else
				fullWaveRectifiedSignal = abs(bandPassOut);
			end
			
			% Low-pass filter
			lowPassOut = lpfilter(fullWaveRectifiedSignal, lowPassCutOff, emgSamplingRate, filterType);
			
			% Find max
			dynamicTrialScaledEmg(:, n) = lowPassOut/emgMax(n,1);
			
			
			% Check if the linear envelope has scaled signal > 1
			%           if max(dynamicTrialScaledEmg(:, n))>1
			%                display(['The maximum scaled EMG signal for ' , char(emgLabelsInMatFile{n}), ' during ' , char(analogData), ' is greater than 1'])
			%           end
			%
			% Optional plotting of signal processing steps, uncomment to
			% view
% 			fig(1) = figure('Name', char(emgLabelsInMatFile{n}));
% 			
% 			subplot(3,2,1);
% 			plot(dynamicEMGMatrix(:, n), 'k');
% 			box off
% 			legend('Raw Data');
% 			legend boxoff;
% 			subplot(3,2,2);
% 			plot(detrendedSignal, 'g');
% 			box off
% 			legend('Detrended');
% 			legend boxoff;
% 			subplot(3,2,3);
% 			plot(bandPassOut, 'r');
% 			box off
% 			legend('Band-passed');
% 			legend boxoff;
% 			% 			               subplot(4,2,4);
% 			% 			               plot(f,P1,'y');
% 			% 			               box off
% 			% 			               xlabel('frequency (Hz)');
% 			% 			               ylabel('|P1(f)|');
% 			% 			               legend('Single-sided amplitude spectrum');
% 			% 			               legend boxoff;
% 			% 			               subplot(4,2,5)
% 			% 			               plot(f,P1n,'m');
% 			% 			               box off
% 			% 			               xlabel('frequency (Hz)');
% 			% 			               ylabel('|P1 Notched (f)|');
% 			% 			               legend('Single-sided amplitude spectrum (notched)');
% 			% 			               legend boxoff;
% 			subplot(3,2,4)
% 			plot(fullWaveRectifiedSignal, 'b');
% 			box off
% 			legend('Full-wave Rectified');
% 			legend boxoff;
% 			subplot(3,2,5)
% 			plot(lowPassOut, 'c');
% 			box off
% 			legend('Linear Envelope');
% 			legend boxoff;
% 			subplot(3,2,6)
% 			plot(dynamicTrialScaledEmg(:, n), 'k');
% 			box off
% 			legend('Scaled Linear Envelope');
% 			legend boxoff;
% 			
% 			set(gcf,'color','w');
% 			checkHandle1 = get(gcf,'Renderer');
% 			if strcmp(checkHandle1,'opengl')
% 				set(gcf,'Renderer','painters');
% 			end
% 			
% 			if ~exist([trialElabDir, filesep, 'EMGs'], 'dir')
% 				mkdir(regexprep(gaitCyclesDir{cycle}, 'Raw', 'Envelope'));
% 				mkdir(gaitCyclesDir{cycle});
% 			end
			
% 			savefig(fig(1), [trialElabDir, filesep, 'EMGs', filesep, char(emgLabelsInMatFile{n}), '.fig']);
% 			close all;
			
		end
		
		% Save EMGs to dynamic elaboration folder
		save([regexprep(trialFolders{cycle}, 'Raw', 'Envelope'), filesep, ['emgLinEnvelopes', num2str(cycle), '.mat']],...
			'lowPassOut', 'dynamicTrialScaledEmg');
		
		% Print the scaled EMG envelopes to .mot format for future
		% CEINMS use.
		emgMotDir = [trialElabDir, filesep, 'EMGs', filesep];
		timeGaitCycle = 0 : emgSamplingTimeStep : (length(dynamicEMGMatrix(:,1))-1)*emgSamplingTimeStep;
		printEMGmot_LS(emgMotDir,timeGaitCycle',dynamicTrialScaledEmg, emgLabelsCEINMS, emgPrintTag, cycle);
		
	end
end
clearvars -except motoDir




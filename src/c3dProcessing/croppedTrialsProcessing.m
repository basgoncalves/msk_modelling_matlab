function  croppedTrialsProcessing(pname, fName, motoDir, progDir, legName)
%Evaluates the cropped load sharing trials
%   Input the name of directory containing the c3d files and evaluate
%   the files to generate .mot and .trc files for analysis in OpenSim.

% Re-set folder as that chosen above to include new files
croppedSessionDirs = dir([pname, filesep, '*.c3d']);
isub2=[croppedSessionDirs(:).bytes]';
% Only include files above 500000 bytes as these are walking trials
a = isub2 < 500000;

% Delete files I don't want to analyse
c3dFilesCropped = {croppedSessionDirs(a).name}';
c3dFilesCropped = selectWalkingTrials(c3dFilesCropped, 0);

% Run c3d2mat again on cropped trials
% Navigate to directory where function is
% cd([motoDir, filesep, 'src' filesep, 'C3D2MAT_btk']);

% Run modified c3d2mat
% C3D2MAT_cropped(fName, c3dFilesCropped, pname);

% Figure properties
cmap = colormap(parula(350));
legendLabels={};
t = 1; newFig = 1; legendCounter = 1;
%% Loop through gait cycle trials
for croppedTrialNum = 1:length(c3dFilesCropped)
    
    fileName = c3dFilesCropped{croppedTrialNum,1};
    
    %Load the cropped acquisition
    data1 = btk_loadc3d([pname, filesep, fileName], 5);
    
    % Assign force to feet, stitch forces together, and output .trc
    % and .mot files for further analysis.
    [dataFinal, force_data2] = assignForceOutputTrcMot(data1, fileName, progDir, legName);
    
    % If there is force data then plot it
    if ~isempty(force_data2)
        
        % Add filename to legend list
        fileNameLeg = regexprep(fileName(1:end-4), '_', ' ');
        legendLabels{legendCounter} = fileNameLeg;
        
        subplot(2,1,1)
        
        % Uncomment to check to see if forces assigned correctly
        try
            plotColor = cmap(round(1+3*(t-1)),:);
        catch
            plotColor = cmap(1,:);
        end
        
        % Plot vertical GRF
        plot(1:1:length(force_data2(:,1)), force_data2(:,1:3),'Color', plotColor)
        hold on
        
        xlabel('Time (s)')
        ylabel('Force (N)')
        title('Ground reaction forces')

        
        % Plot COP
        subplot(2,1,2)
        plot(1:1:length(force_data2(:,1)), force_data2(:,[4,6]), 'Color', plotColor)
        hold on
        
        xlabel('Time (s)')
        ylabel('COP (m)')
        title('Centre of pressure')
        legend(legendLabels, 'Location', 'eastoutside')
        legend boxoff
        
        % Save output for future use
        outputDir = [pname, filesep, 'matData'];
        
        if ~isdir(outputDir)
            mkdir(outputDir);
        end
        
        % Save output to mat file
        save([outputDir, filesep, fileName(1:end-4), '.mat'], 'dataFinal');
        
        t = t+1; % Iterate t + 1 to exclude trials that have bad data
        legendCounter = legendCounter+1;
        
        % Very 20th loop we create a new figure
        if (t / newFig) == 20
            hold off
            newFig = newFig + 1;
            figure();
            legendLabels={}; legendCounter = 1;
        end
        
    end
    
    % Close vars to save memory
    clearvars dataFinal force_data2 data1 fileName outputDir
end

end

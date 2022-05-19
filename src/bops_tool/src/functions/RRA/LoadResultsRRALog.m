%% adjust mass function
%
% fileID = dir of the out 
    function [m,residuals,ogResiduals,labels,COMAdjResiduals] = LoadResultsRRALog(OutLodDir)
        % import log data
        if exist(OutLodDir,'file')
            data = importdata (OutLodDir, ' ', 100000);
        else
           data = []; 
        end
        labels = {};
        if length(data)<41
            m = NaN;
            residuals = NaN(6,1);
            ogResiduals = NaN(6,1);
            COMAdjResiduals = NaN(6,1);
            return
        end
        
        [m,ln] = findLine(data,'Total mass change',0);
        if ~isempty(m)
        m = str2double(m{end}{end});
        else
            disp(' ')
            disp(' ')
            disp('Total mass change does not exist in the out.log file')
            disp(' ')
            disp(' ')
            
             m = NaN;
            residuals = NaN(6,1);
            ogResiduals =NaN(6,1);
            COMAdjResiduals = NaN(6,1);
            return
        end
        labels ={'FX' 'FY' 'FZ' 'MX' 'MY' 'MZ'};
        % oriinal residuals
        [r,ln] = findLine(data,'* Average residuals before adjusting torso COM:',[0:2]);
        ogResiduals(1,1) = str2double(r{2}{end-2}((4:end)));    % Fx
        ogResiduals(2,1) = str2double(r{2}{end-1}((4:end)));    % Fy
        ogResiduals(3,1)= str2double(r{2}{end}((4:end)));       % Fz
        
        ogResiduals(4,1) = str2double(r{3}{end-2}((4:end)));    % Mx
        ogResiduals(5,1) = str2double(r{3}{end-1}((4:end)));    % My
        ogResiduals(6,1) = str2double(r{3}{end}((4:end)));      % Mz      
        
        % after adjusted COM and Kinematics residual forces
        [r,ln] = findLine(data,'* After torso COM and Kinematics adjustments:',[0:2]);
        residuals(1,1) = str2double(r{2}{end-2}((4:end)));    % Fx
        residuals(2,1) = str2double(r{2}{end-1}((4:end)));    % Fy
        residuals(3,1)= str2double(r{2}{end}((4:end)));       % Fz
        
        residuals(4,1) = str2double(r{3}{end-2}((4:end)));    % Mx
        residuals(5,1) = str2double(r{3}{end-1}((4:end)));    % My
        residuals(6,1) = str2double(r{3}{end}((4:end)));      % Mz     
        
        % COMAdjResiduals residuals (added in Oct 2021)
        [r,ln] = findLine(data,'* Average residuals after adjusting torso COM:',[0:2]);
        COMAdjResiduals(1,1) = str2double(r{2}{end-2}((4:end)));    % Fx
        COMAdjResiduals(2,1) = str2double(r{2}{end-1}((4:end)));    % Fy
        COMAdjResiduals(3,1)= str2double(r{2}{end}((4:end)));       % Fz
        
        COMAdjResiduals(4,1) = str2double(r{3}{end-2}((4:end)));    % Mx
        COMAdjResiduals(5,1) = str2double(r{3}{end-1}((4:end)));    % My
        COMAdjResiduals(6,1) = str2double(r{3}{end}((4:end)));      % Mz      
        
        
    end
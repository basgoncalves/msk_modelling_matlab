% kinematic analysis 

%create directories and get demographics data
OrganiseFAI

%get dir of MOT file
if exist('DirMOTfile')==0 || ~contains(class(DirMOTfile),'char')
    cd(DirElaborated)
    [MOTfile,MOTfilepath] = uigetfile...
        ('*.mot' , 'select MOT file for individual trial');
    DirMOTfile = [MOTfilepath MOTfile];
end

% load kinematic data
Kinematics = importdata (DirMOTfile);


% select Kinematic data
trialNames = {'time' 'pelvis' 'hip' 'knee' 'ankle'};
[SelectedData,SelectedLabels,IDxData] = findData (Kinematics.data,Kinematics.colheaders,trialNames);



%% Plot figure
% figure
% % plot 
% subplot(211)
% plot (SelectedData(:,2:4)); 
% title('Right Leg'); ylabel('Angle {\theta}');
% set(gca,'xtick',[])
% mmfn                                %make my figure nice script
% legend off
% 
% 
% subplot(212)
% plot (SelectedData(:,5:7)); 
% legend (SelectedLabels(5:7),'Interpreter','none');
% title('Left Leg'); ylabel('Angle {\theta}'); xlabel('time (s)');
% mmfn                                %make my figure nice script
% 
% 
% endout=regexp(erase(MOTfilepath,'\Results\'),filesep,'split');
% suptitle(endout{end});

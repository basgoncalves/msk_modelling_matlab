%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               MOtoNMS                                   %
%                MATLAB MOTION DATA ELABORATION TOOLBOX                   %
%                 FOR NEUROMUSCULOSKELETAL APPLICATIONS                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Static Elaboration Core Program 
%
% The file is part of matlab MOtion data elaboration TOolbox for
% NeuroMusculoSkeletal applications (MOtoNMS). 
% Copyright (C) 2012-2014 Alice Mantoan, Monica Reggiani
%
% MOtoNMS is free software: you can redistribute it and/or modify it under 
% the terms of the GNU General Public License as published by the Free 
% Software Foundation, either version 3 of the License, or (at your option)
% any later version.
%
% Matlab MOtion data elaboration TOolbox for NeuroMusculoSkeletal applications
% is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
% PARTICULAR PURPOSE.  See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along 
% with MOtoNMS.  If not, see <http://www.gnu.org/licenses/>.
%
% Alice Mantoan, Monica Reggiani
% <ali.mantoan@gmail.com>, <monica.reggiani@gmail.com>

%%

function []=runStaticElaboration(ConfigFilePath)

if nargin==0
    error('static.xml file path missing: it must be given as a function input')
end

%addSharedPath()

%% -------------------STATIC ELABORATION SETTING-------------------------%%
%           Folders paths definition and parameters generation            %
%-------------------------------------------------------------------------%

[foldersPaths,parameters]= StaticElaborationSettings(ConfigFilePath);

%Parameters List: Ri-nomination 
if isfield(parameters,'Fcut')
    fcut=parameters.Fcut;
end

if isfield(parameters,'JCcomputation')
    Joints=parameters.JCcomputation.Joint;
end
trcMarkersList=parameters.trcMarkersList;
globalToOpenSimRotations=parameters.globalToOpenSimRotations;

motionDirection=parameters.motionDirection;

%% ------------------------------------------------------------------------
%                            DATA LOADING                                 % 
%               Load markers data from static mat folder                  %
%--------------------------------------------------------------------------

load ([foldersPaths.matData filesep 'Markers.mat']);

LabelCols = find(~contains(Markers.Labels,trcMarkersList));
Markers.Labels(LabelCols)= [];

for i=flip(1:length(LabelCols))
    col=LabelCols(i)*3;
    Markers.RawData(:,col-2:col)= [];
end
protocolMLabels=Markers.Labels;
% look for frist frame with no markers missing
for i = 1:size(Markers.RawData,1)
    if length(find(Markers.RawData(i,:)))== size(Markers.RawData,2)
       idx = i;
       break
    end
end
frame=idx;

%% -----------------------------------------------------------------------%
%                           DATA FILTERING                                %
%-------------------------------------------------------------------------%
%A cell data type is necessary to be able to use DataFiltering.m
markers{1}=Markers.RawData;
% if exist('fcut','var')
%     filtMarkers=DataFiltering(markers,Markers.Rate,fcut);
% else
    filtMarkers=markers;
% end

disp('Markers have been loaded and filtered')


%Markers selection from the list
[markerstrc,trcMarkersList] = selectingMarkers(trcMarkersList,Markers.Labels,filtMarkers{1}(:,1:length(Markers.Labels)*3));
%new markers labels list (for addition of computed jc)
MarkersListjc={trcMarkersList};

%% -----------------------------------------------------------------------%
%                       JOINT CENTERS Computation                         %
%                       and markers list updating                         %
%-------------------------------------------------------------------------%
if (exist('Joints','var'))
f=figure; hold on;

for k=1:length(Joints)
    
    joint=Joints(k).Name;
    method=Joints(k).Method;
    input=Joints(k).Input;
    
    switch joint
        
        case 'Hip'
            
            [LHJC,RHJC,markers_hjc,markerNames_hjc]=HJCcomputation(method,input,protocolMLabels,filtMarkers);
            
            %add computed point to figure for checking (coordinates are in the laboratory global reference system)
            drawPoints(f,LHJC,RHJC, markers_hjc,markerNames_hjc,frame,'*r','HJC')
            
            %Updating markers selection and markers label list with jc
            [markerstrc,MarkersListjc]=updatingMarkersList(LHJC,RHJC,markerstrc,'LHJC','RHJC',MarkersListjc);

            %Saving Points
            save([foldersPaths.elaboration filesep 'RHJC.mat'] ,'RHJC')
            save([foldersPaths.elaboration  filesep 'LHJC.mat'] ,'LHJC')            

            
        case 'Knee'
            
            [LKJC,RKJC,markers_kjc,markerNames_kjc]=KJCcomputation(method,input,protocolMLabels,filtMarkers);
            
            drawPoints(f,LKJC,RKJC, markers_kjc,markerNames_kjc,frame,'*b','KJC')
                    
            [markerstrc,MarkersListjc]=updatingMarkersList(LKJC,RKJC,markerstrc,'LKJC','RKJC',MarkersListjc);

            save([foldersPaths.elaboration  filesep 'RKJC.mat'] ,'RKJC')
            save([foldersPaths.elaboration  filesep 'LKJC.mat'] ,'LKJC')
 
            
        case 'Ankle'
            
            [LAJC,RAJC,markers_ajc,markerNames_ajc]=AJCcomputation(method,input,protocolMLabels,filtMarkers);

            drawPoints(f,LAJC,RAJC, markers_ajc,markerNames_ajc,frame,'*g','AJC')
            
            [markerstrc,MarkersListjc]=updatingMarkersList(LAJC,RAJC,markerstrc,'LAJC','RAJC',MarkersListjc);
            
            save([foldersPaths.elaboration  filesep 'RAJC.mat'] ,'RAJC')
            save([foldersPaths.elaboration  filesep 'LAJC.mat'] ,'LAJC')           

            
        case 'Shoulder'
            
            [LSJC,RSJC,markers_sjc,markerNames_sjc]=SJCcomputation(method,input,protocolMLabels,filtMarkers);

            drawPoints(f,LSJC,RSJC, markers_sjc,markerNames_sjc,frame,'*y','SJC')
            
            [markerstrc,MarkersListjc]=updatingMarkersList(LSJC,RSJC,markerstrc,'LSJC','RSJC',MarkersListjc);
            
            save([foldersPaths.elaboration  filesep 'RSJC.mat'] ,'RSJC')
            save([foldersPaths.elaboration  filesep 'LSJC.mat'] ,'LSJC')        
        
            
        case 'Elbow'
            
            [LEJC,REJC,markers_ejc,markerNames_ejc]=EJCcomputation(method,input,protocolMLabels,filtMarkers);

            drawPoints(f,LEJC,REJC, markers_ejc,markerNames_ejc,frame,'*m','EJC')
            
            [markerstrc,MarkersListjc]=updatingMarkersList(LEJC,REJC,markerstrc,'LEJC','REJC',MarkersListjc);
            
            save([foldersPaths.elaboration  filesep 'REJC.mat'] ,'REJC')
            save([foldersPaths.elaboration  filesep 'LEJC.mat'] ,'LEJC') 
            
            
        case 'Wrist'
            
            [LWJC,RWJC,markers_wjc,markerNames_wjc]=WJCcomputation(method,input,protocolMLabels,filtMarkers);

            drawPoints(f,LWJC,RWJC, markers_wjc,markerNames_wjc,frame,'*c','WJC')
            
            [markerstrc,MarkersListjc]=updatingMarkersList(LWJC,RWJC,markerstrc,'LWJC','RWJC',MarkersListjc);
            
            save([foldersPaths.elaboration  filesep 'RWJC.mat'] ,'RWJC')
            save([foldersPaths.elaboration  filesep 'LWJC.mat'] ,'LWJC')  
        
        case 'MidSIS'
            
            [MidASIS,MidSACR,markers_wjc,markerNames_wjc]=WJCcomputation(method,input,protocolMLabels,filtMarkers);

            figure(f)
            hold on
            plot3(MidASIS(frame,1),MidASIS(frame,2),MidASIS(frame,3),'*c')
            text('Position',[(MidASIS(frame,1)+3) (MidASIS(frame,2)+3) (MidASIS(frame,3)+3)], 'String', 'MidASIS')
            plot3(MidSACR(frame,1),MidSACR(frame,2),MidSACR(frame,3),'*c')
            text('Position',[(MidSACR(frame,1)+3) (MidSACR(frame,2)+3) (MidSACR(frame,3)+3)], 'String', 'MidASIS')
            
            
            [markerstrc,MarkersListjc]=updatingMarkersList(MidASIS,MidSACR,markerstrc,'MidASIS','MidSACR',MarkersListjc);
            
            save([foldersPaths.elaboration  filesep 'MidSACR.mat'] ,'MidSACR')
            save([foldersPaths.elaboration  filesep 'MidASIS.mat'] ,'MidASIS') 
           
            [markerstrc,MarkersListjc]=updatingMarkersList(MidASIS,MidSACR,markerstrc,'MidASIS','MidSACR',MarkersListjc);
            
            save([foldersPaths.elaboration  filesep 'MidSACR.mat'] ,'MidSACR')
            save([foldersPaths.elaboration  filesep 'MidASIS.mat'] ,'MidASIS')  
            
            
            
         case 'MidPelvis'
            updatedMarkers={};
            updatedMarkers{1} =  markerstrc;
            [MidHJC,MidPelvis,markers_wjc,markerNames_wjc]=WJCcomputation(method,input,MarkersListjc{1},updatedMarkers);

            figure(f)
            hold on
            plot3(MidHJC(frame,1),MidHJC(frame,2),MidHJC(frame,3),'*c')
            text('Position',[(MidHJC(frame,1)+3) (MidHJC(frame,2)+3) (MidHJC(frame,3)+3)], 'String', 'MidHJC')
            plot3(MidPelvis(frame,1),MidPelvis(frame,2),MidPelvis(frame,3),'*c')
            text('Position',[(MidPelvis(frame,1)+3) (MidPelvis(frame,2)+3) (MidPelvis(frame,3)+3)], 'String', 'MidPelvis')
            
            
            [markerstrc,MarkersListjc]=updatingMarkersList(MidHJC,MidPelvis,markerstrc,'MidHJC','MidPelvis',MarkersListjc);
            
            save([foldersPaths.elaboration  filesep 'MidPelvis.mat'] ,'MidPelvis')
            save([foldersPaths.elaboration  filesep 'MidHJC.mat'] ,'MidHJC') 
           
            [markerstrc,MarkersListjc]=updatingMarkersList(MidHJC,MidPelvis,markerstrc,'MidHJC','MidPelvis',MarkersListjc);
            
            save([foldersPaths.elaboration  filesep 'MidPelvis.mat'] ,'MidPelvis')
            save([foldersPaths.elaboration  filesep 'MidHJC.mat'] ,'MidHJC')     
            %case ...
        %ADD HERE MORE JOINTS
        %...
            
    end
end

%Figure properties Definition
title('Joint Centers Global Position')
grid on
xlabel('Asse x [mm]')
ylabel('Asse y [mm]')
zlabel('Asse z [mm]')
axis equal
figName='JointCenters_globalPosition.fig';
saveas(gcf,[foldersPaths.elaboration filesep figName]) 
disp([figName ' (based on frame 1 data) has been saved'])

end

%% -----------------------------------------------------------------------%
%                        Write static.trc with jc
%-------------------------------------------------------------------------%
trcFileName  = ['static_input.trc'];
FullFileName = [foldersPaths.elaboration filesep trcFileName];

%Mtime and MarkerListjc must be cell to be able to use createtrc
Mtime={[1/Markers.Rate: 1/Markers.Rate:  size(markerstrc,1)/Markers.Rate]'};

rotatedMarkers=RotateCS(markerstrc,globalToOpenSimRotations);

%accounting for the possibility of different directions of motion
markersMotionDirRotOpenSim=rotatingMotionDirection(motionDirection,rotatedMarkers);

CompleteMarkersData=[Mtime{1}(frame) markersMotionDirRotOpenSim(frame,:)];

writetrc(CompleteMarkersData,MarkersListjc{1}',Markers.Rate,FullFileName)

disp('===============================')
disp('')
disp([trcFileName ' has been created'])
disp('')
disp('===============================')

%% save_to_base() copies all variables in the calling function to the base
% workspace. This makes it possible to examine this function internal
% variables from the Matlab command prompt after the calling function
% terminates. Uncomment the following command if you want to activate it
save_to_base(1)



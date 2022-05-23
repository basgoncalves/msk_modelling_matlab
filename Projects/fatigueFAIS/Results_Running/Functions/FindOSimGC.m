% find open sim gait cycle 

function GC = FindOSimGC (DirIK,CurrentTrial)




    load([DirIK filesep 'GaitCycle-' CurrentTrial]);
 
   IKData = importdata ([DirIK filesep 'Results' filesep CurrentTrial '_IK.mot']);

   [timeData,SelectedLabels,IDxData] = findData (IKData.data,IKData.colheaders,'time');            % callback function
  
   fs = 1/(timeData(2)-timeData(1));
   GaitCycle.FirstFrameOpenSim = round(timeData(1)*fs);
   GaitCycle.FinalFrameOpenSim = round(timeData(end)*fs);
    
    GCOS                % get gait cycles arranged for open sim data
    GC= ToeOff;
    GC(3) = foot_contacts;
    

%    DirID = strrep (DirIK,'inverseKinematics','inverseDynamics');
%    IDData = importdata ([DirID filesep 'results' filesep CurrentTrial '_inverse_dynamics.sto']);
%    [timeData2,SelectedLabels,IDxData] = findData (IDData.data,IDData.colheaders,'time');            % callback function
%    
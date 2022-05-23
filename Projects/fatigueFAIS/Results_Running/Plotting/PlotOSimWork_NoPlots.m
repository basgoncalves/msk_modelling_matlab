% PlotOSimWork_NoPlots
% work loops



DirFigRunBiomech =  ([DirFigure filesep 'RunningBiomechanics' filesep Subject]);
mkdir(DirFigRunBiomech);
AcqXml = xml_read([strrep(DirElaborated,'ElaboratedData' ,'InputData') filesep 'acquisition.xml']);

cd(DirIDResults)
load ([DirIDResults filesep 'IDresults.mat']);
load ([DirIKResults filesep 'IKresults.mat']);
Joints= {'hip','knee','ankle'};
Njoints = length(Joints);
startColor = jet;
LegendNames = {};

count =0;


for ii = 1: Njoints             %loop through joints
    CurrentJointIDData = IDresultsNormalized.(Joints{ii});
    CurrentJointIKData = IKresultsNormalized.(Joints{ii});
    TrialsJoint = fields(CurrentJointIDData);
    Ntrials = length(TrialsJoint);
    
    Nmoments = size(CurrentJointIDData.(TrialsJoint{1}),2);
    for mm = 1:Nmoments         % loop through moments
        count = count +1;
       
        MomentName = erase(sprintf('%s',Labels.(Joints{ii}){mm}),' angle r');
        MomentName = erase(MomentName,' angle l');
        MomentName = strrep(MomentName,'on l','on');
        MomentName = strrep(MomentName,'on r','on');

        HeelStrike=[];
        
        for ss = 1:Ntrials          % loop through trials
            CurrentTrial = TrialsJoint{ss};
            Moment = CurrentJointIDData.(CurrentTrial)(:,mm);
            Angle = CurrentJointIKData.(CurrentTrial)(:,mm);
            FootStrike = GaitCycle.(CurrentTrial);
            NormalizedGC = GaitCycle.(CurrentTrial)-GaitCycle.(CurrentTrial)(1)+1;
            HeelStrike(end+1) = round(GaitCycle.(CurrentTrial)(3)*100/GaitCycle.(CurrentTrial)(2));


            LegendNames{end+1}= CurrentTrial;
            
            
        end
        


    end
     
end




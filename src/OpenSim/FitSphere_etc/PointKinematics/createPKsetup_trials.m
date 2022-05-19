function folderPK = createPKsetup_trials(dirFolders, Subj_Code, model, trial,leg)
% PointKinematics in OpenSim - Analyze Toolbox
% 3 points in pelvis CS - generic Raja model: 
% Amid = [-0.0571, -0.0732, 0.08], 
% Asup = [-0.0527, -0.0541, 0.0971],
% Aant = [-0.0326, -0.0699, 0.0768]
% Amid_surfaceSTL = [-0.0626, -0.0532, 0.0584]


fp = '\';
scaleF = getSF(dirFolders, Subj_Code,'pelvis');
[midSphere_acetabulum, ~, p_cup, p_sup, p_midRim] = getAceSphere_midCup(scaleF, dirFolders);
pnames = {'cSphere','p_cup','p_sup','p_midRim'};
pdat = [midSphere_acetabulum; p_cup; p_sup; p_midRim];
if strcmp(leg,'l')
    pdat = pdat .* repmat([1 1 -1], length(pdat),1);
end
 
folderPK = [dirFolders.MOtoNMS, 'pointKinematics\',dirFolders.idOPENSIM,fp,trial,fp];

%% get start/final time from IK.mot - prob a better ways
motfile = [dirFolders.MOtoNMS,'inverseKinematics\',dirFolders.idOPENSIM,fp,trial,'\ik.mot'];
dat = importdata(motfile);
time_start = dat.data(1,1);
time_end = dat.data(end,1);

%%
dir_xml = [dirFolders.XMLbasis,'pointKin_setup.xml'];

prefXmlRead.Str2Num = 'never';
tree = xml_read(dir_xml, prefXmlRead);

tree.AnalyzeTool.model_file = [dirFolders.OpenSimModel, model];
%    ; 
tree.AnalyzeTool.initial_time = time_start;
tree.AnalyzeTool.final_time = time_end ;
iP2 = 1;
for iP = 1:length(pnames)
    for iFrame = 1:2
        if iFrame == 1
            name = ['fem_',pnames{iP}];
            frame = ['femur_',leg];
        else 
            name = ['pel_',pnames{iP}];
            frame = 'pelvis';
        end
        tree.AnalyzeTool.AnalysisSet.objects.PointKinematics(iP2).on = 'true';
        tree.AnalyzeTool.AnalysisSet.objects.PointKinematics(iP2).start_time = time_start;
        tree.AnalyzeTool.AnalysisSet.objects.PointKinematics(iP2).end_time = time_end;
        tree.AnalyzeTool.AnalysisSet.objects.PointKinematics(iP2).step_interval = 1;
        tree.AnalyzeTool.AnalysisSet.objects.PointKinematics(iP2).in_degrees = 'true';
        tree.AnalyzeTool.AnalysisSet.objects.PointKinematics(iP2).body_name = 'pelvis';
        tree.AnalyzeTool.AnalysisSet.objects.PointKinematics(iP2).relative_to_body_name = frame;
        tree.AnalyzeTool.AnalysisSet.objects.PointKinematics(iP2).point_name = name;
        tree.AnalyzeTool.AnalysisSet.objects.PointKinematics(iP2).point = pdat(iP,:);
        tree.AnalyzeTool.AnalysisSet.objects.PointKinematics(iP2).ATTRIBUTE.name =  'PointKinematics';
        iP2 = iP2 +1;
    end
end

tree.AnalyzeTool.coordinates_file = motfile;

prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
prefXmlWrite.CellItem   = false;
PK_setupfile = [folderPK, 'PK_setup.xml'];
xml_write(PK_setupfile, tree,'OpenSimDocument', prefXmlWrite);


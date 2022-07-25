function [T] =  RRA_analysis_exam(iddir,modelf,selectedmodel,selectedmot,selectedgrf,selectedtask,actuatorf,selectedconstraint,selecteddir,start_time,final_time,selectedoutmodel)

import org.opensim.modeling.*

RRA = setup_ReduceResiduals('ModelFile',selectedmodel,...
    'MOTFile',selectedmot,...
    'GRFFile',selectedgrf,...
    'RRATaskFile',selectedtask,...
    'RRAForceFile',actuatorf,...
    'RRAConstraintsFile',selectedconstraint,...
    'AdjCOMRes','true','OptimMaxIter',20000,'LowPassFilterFreq',6,'DirectoryName',selecteddir,...
    'InitialTime',start_time,'FinalTime',final_time,...
    'OutputModelFile',selectedoutmodel)


rra = RRATool([strtok(modelf,'.') '_Setup_ReduceResiduals.xml']);
rra.run()
copyfile([strtok(modelf,'.') '_Setup_ReduceResiduals.xml'], fullfile([selecteddir,'\', [strtok(modelf,'.') '_Setup_ReduceResiduals.xml']]));
outlog = fileread('out.log');
pattern1 = 'total mass change: ';
pattern2 = 'total mass change: .?[0-9]+[.][0-9]+';
pattern3 = 'Mass Center \(COM\) adjustment:';
pattern4 = 'Mass Center \(COM\) adjustment: .+]';
[sectionEndIdx1,debut1,fin1] = regexpi(outlog, pattern1,'start','end');
[sectionEndIdx2,debut2,fin2] = regexpi(outlog, pattern2,'start','end');
[sectionEndIdx3,debut3,fin3] = regexpi(outlog, pattern3,'start','end');
[sectionEndIdx4,debut4,fin4] = regexpi(outlog, pattern4,'start','end');
massChange = str2double(outlog(debut1(end):debut2(end)));
disp(['sidestepcut, rra , dMass = ', num2str(massChange)])
dCOM = outlog(debut3(end):debut4(end));
disp(['sidestepcut, rra , dCOM = ', dCOM])
copyfile('out.log', fullfile([selecteddir, '\_out.log']));
osimModel_rraMassChanges = Model(selectedoutmodel);
osimModel_rraMassChanges = setMassOfBodiesUsingRRAMassChange(osimModel_rraMassChanges, massChange);
osimModel_rraMassChanges.print([selecteddir,'\Model_adjusted.osim']);
%Calculate errors
pelvis_trans = {'pelvistz', 'pelvistx', 'pelvisty'};
pelvis_rot = {'pelvistilt', 'pelvislist', 'pelvisrotation'};
lumbar = {'lumbarextension', 'lumbarbending', 'lumbarrotation'};
le = {'hipflexionr', 'hipadductionr', 'hiprotationr','hipflexionl', 'hipadductionl', 'hiprotationl'};
le1 = {'kneeangler', 'kneeanglel', 'ankleangler', 'ankleanglel'};
     
	  
% load ik/rra kinematic errors
rra_results_dir = selecteddir;
rra_run_pErr = importPErrStoFile([rra_results_dir,'\', [strtok(modelf,'.') '_Visual3d_SIMM_input_RRA_pErr.sto']]);
% rra_run_pErr_pelvisTrans = double(rra_run_pErr(:,pelvis_trans));
% rra_run_pErr_pelvisRot = double(rra_run_pErr(:,pelvis_rot));
% rra_run_pErr_lumbarRot = double(rra_run_pErr(:,lumbar));
% rra_run_pErr_leRot = double(rra_run_pErr(:,le));
% rra_run_pErr_leRot1 = double(rra_run_pErr(:,le1));
rra_run_pErr_pelvisTrans = double(rra_run_pErr(:,[3,4,2]));
rra_run_pErr_pelvisRot = double(rra_run_pErr(:,[5 6 7]));
rra_run_pErr_lumbarRot = double(rra_run_pErr(:,[18 19 20]));
rra_run_pErr_leRot = double(rra_run_pErr(:,[8 9 10 13 14 15]));
rra_run_pErr_leRot1 = double(rra_run_pErr(:,[11 16 12 17]));
r1=180/pi.*max(abs(rra_run_pErr_pelvisRot));
r2=100.*max(abs(rra_run_pErr_pelvisTrans));
% r2([1 2 3]) = r2([3 1 2]);
r3=180/pi.*max(abs(rra_run_pErr_lumbarRot));
r4=180/pi.*max(abs(rra_run_pErr_leRot));
r5=180/pi.*max(abs(rra_run_pErr_leRot1));
% r5([1 2 3 4]) = r5([3 4 1 2]);
rra_pErr = [r1 r2 r4 r3 r5];

%Compare with id
id_results_dir = iddir;
id_filename = strcat(id_results_dir, '\inverse_dynamics.sto');
rra_filename = strcat([rra_results_dir,'\', [strtok(modelf,'.') '_Visual3d_SIMM_input_RRA_Actuation_force.sto']]);
idJointMoments = importIDJointMoments(id_filename);
rraJointMoments = importRRAJointMoments(rra_filename);
%id
time = idJointMoments(:,1);
percentgaitcycle = 100.*(time-time(1))./(time(end) - time(1));
pelvistilt = idJointMoments(:,2);
pelvislist = idJointMoments(:,3);
pelvisrotation = idJointMoments(:,4);
pelvistx = idJointMoments(:,5);
pelvisty = idJointMoments(:,6);
pelvistz = idJointMoments(:,7);
hipflex = idJointMoments(:,8);
hipabd = idJointMoments(:,9);
hiprot = idJointMoments(:,10);
hipflex_l = idJointMoments(:,11);
hipabd_l = idJointMoments(:,12);
hiprot_l = idJointMoments(:,13);
lumbarext = idJointMoments(:,14);
lumbarbend = idJointMoments(:,15);
lumbarrot = idJointMoments(:,16);
kneeext = idJointMoments(:,17);
kneeext_l = idJointMoments(:,18);
ankleext = idJointMoments(:,19);
ankleext_l = idJointMoments(:,20);
idJointMoments = dataset(time, percentgaitcycle, pelvistilt,pelvislist, pelvisrotation, pelvistx, pelvisty, pelvistz, hipflex, hipabd, hiprot, hipflex_l, hipabd_l, hiprot_l, lumbarext, lumbarbend, lumbarrot, kneeext, kneeext_l, ankleext,  ankleext_l);
[~, uIdx, ~] = unique(idJointMoments.percentgaitcycle);
idJointMoments = idJointMoments(uIdx,:);
idJointMoments_interp = dataset({(0:0.2:100)', 'percentgaitcycle'});
idJointMoments_interp.pelvistilt = interp1(idJointMoments.percentgaitcycle, idJointMoments.pelvistilt, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.pelvislist = interp1(idJointMoments.percentgaitcycle, idJointMoments.pelvislist, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.pelvisrotation = interp1(idJointMoments.percentgaitcycle, idJointMoments.pelvisrotation, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.pelvistx = interp1(idJointMoments.percentgaitcycle, idJointMoments.pelvistx, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.pelvisty = interp1(idJointMoments.percentgaitcycle, idJointMoments.pelvisty, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.pelvistz = interp1(idJointMoments.percentgaitcycle, idJointMoments.pelvistz, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.hipflex = interp1(idJointMoments.percentgaitcycle, idJointMoments.hipflex, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.hipabd = interp1(idJointMoments.percentgaitcycle, idJointMoments.hipabd, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.hiprot = interp1(idJointMoments.percentgaitcycle, idJointMoments.hiprot, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.hipflex_l = interp1(idJointMoments.percentgaitcycle, idJointMoments.hipflex_l, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.hipabd_l = interp1(idJointMoments.percentgaitcycle, idJointMoments.hipabd_l, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.hiprot_l = interp1(idJointMoments.percentgaitcycle, idJointMoments.hiprot_l, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.lumbarext = interp1(idJointMoments.percentgaitcycle, idJointMoments.lumbarext, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.lumbarbend = interp1(idJointMoments.percentgaitcycle, idJointMoments.lumbarbend, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.lumbarrot = interp1(idJointMoments.percentgaitcycle, idJointMoments.lumbarrot, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.kneeext = interp1(idJointMoments.percentgaitcycle, idJointMoments.kneeext, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.kneeext_l = interp1(idJointMoments.percentgaitcycle, idJointMoments.kneeext_l, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.ankleext = interp1(idJointMoments.percentgaitcycle, idJointMoments.ankleext, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');
idJointMoments_interp.ankleext_l = interp1(idJointMoments.percentgaitcycle, idJointMoments.ankleext_l, idJointMoments_interp.percentgaitcycle, 'linear', 'extrap');

%rra
time1 = rraJointMoments(:,1);
percentgaitcycle1 = 100.*(time1-time1(1))./(time1(end) - time1(1));
rpelvistilt = rraJointMoments(:,7);
rpelvislist = rraJointMoments(:,5);
rpelvisrotation = rraJointMoments(:,6);
rpelvistx = rraJointMoments(:,2);
rpelvisty = rraJointMoments(:,3);
rpelvistz = rraJointMoments(:,4);
rhipflex = rraJointMoments(:,8);
rhipabd = rraJointMoments(:,9);
rhiprot = rraJointMoments(:,10);
rhipflex_l = rraJointMoments(:,13);
rhipabd_l = rraJointMoments(:,14);
rhiprot_l = rraJointMoments(:,15);
rlumbarext = rraJointMoments(:,18);
rlumbarbend = rraJointMoments(:,19);
rlumbarrot = rraJointMoments(:,20);
rkneeext = rraJointMoments(:,11);
rkneeext_l = rraJointMoments(:,16);
rankleext = rraJointMoments(:,12);
rankleext_l = rraJointMoments(:,17);
rraJointMoments = dataset(time1, percentgaitcycle1, rpelvistilt, rpelvislist, rpelvisrotation, rpelvistx, rpelvisty, rpelvistz, rhipflex, rhipabd, rhiprot, rhipflex_l, rhipabd_l, rhiprot_l, rlumbarext, rlumbarbend, rlumbarrot, rkneeext, rkneeext_l, rankleext,  rankleext_l);

[~, uIdx, ~] = unique(rraJointMoments.percentgaitcycle1);
rraJointMoments = rraJointMoments(uIdx,:);
rraJointMoments_interp = dataset({(0:0.2:100)', 'percentgaitcycle1'});
rraJointMoments_interp.rpelvistilt = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rpelvistilt, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rpelvislist = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rpelvislist, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rpelvisrotation = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rpelvisrotation, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rpelvistx = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rpelvistx, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rpelvisty = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rpelvisty, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rpelvistz = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rpelvistz, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rhipflex = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rhipflex, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rhipabd = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rhipabd, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rhiprot = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rhiprot, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rhipflex_l = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rhipflex_l, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rhipabd_l = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rhipabd_l, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rhiprot_l = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rhiprot_l, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rlumbarext = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rlumbarext, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rlumbarbend = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rlumbarbend, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rlumbarrot = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rlumbarrot, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rkneeext = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rkneeext, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rkneeext_l = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rkneeext_l, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rankleext = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rankleext, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');
rraJointMoments_interp.rankleext_l = interp1(rraJointMoments.percentgaitcycle1, rraJointMoments.rankleext_l, rraJointMoments_interp.percentgaitcycle1, 'linear', 'extrap');

%Comparison
maxID = max(abs(double(idJointMoments(:,3:21))), [], 1);
diff_id_cmc = double(idJointMoments_interp(:,2:20)) - double(rraJointMoments_interp(:,2:20));
diff_id_cmc_abs = abs(double(idJointMoments_interp(:,2:20))) - abs(double(rraJointMoments_interp(:,2:20)));
rms_rra = rms(double(rraJointMoments_interp(:,2:20)),1);
peak_rra = max(abs(double(rraJointMoments(:,3:21))),[],1);
rms_id_cmc = rms(diff_id_cmc,1);
peak_id_cmc = max(diff_id_cmc_abs,[],1);
rms_id_cmc_norm = rms_id_cmc./maxID;
peak_id_cmc_norm = (peak_id_cmc./maxID);
peak_id_cmc_norm_pct = ((abs(maxID - peak_rra))./maxID).*100; 
total_m_change = ones(1,19)*massChange;
T = array2table([total_m_change;rra_pErr;rms_rra;peak_rra;rms_id_cmc;peak_id_cmc;peak_id_cmc_norm_pct]);
T.Properties.VariableNames={'pelvistilt','pelvislist', 'pelvisrotation', 'pelvistx', 'pelvisty', 'pelvistz', 'hipflex', 'hipabd', 'hiprot', 'hipflex_l', 'hipabd_l', 'hiprot_l', 'lumbarext', 'lumbarbend', 'lumbarrot', 'kneeext', 'kneeext_l', 'ankleext',  'ankleext_l'};
T.Properties.RowNames={'Total Mass Change','RRA errors','RMS RRA','Peak RRA','RMS difference ID vs RRA', 'Peak difference ID vs RRA','Peak Percentage Reduction'};
disp(T) 
    
    function osimModel_rraMassChanges = setMassOfBodiesUsingRRAMassChange(osimModel, massChange)
    currTotalMass = getMassOfModel(osimModel);
    suggestedNewTotalMass = currTotalMass + massChange;
    massScaleFactor = suggestedNewTotalMass/currTotalMass;
    
    allBodies = osimModel.getBodySet();
    for i = 0:allBodies.getSize()-1
        currBodyMass = allBodies.get(i).getMass();
        newBodyMass = currBodyMass*massScaleFactor;
        allBodies.get(i).setMass(newBodyMass);
    end
    osimModel_rraMassChanges = osimModel;
end

function totalMass = getMassOfModel(osimModel)
    totalMass = 0;
    allBodies = osimModel.getBodySet();
    for i=0:allBodies.getSize()-1
        curBody = allBodies.get(i);
        totalMass = totalMass + curBody.getMass();
    end
end

end
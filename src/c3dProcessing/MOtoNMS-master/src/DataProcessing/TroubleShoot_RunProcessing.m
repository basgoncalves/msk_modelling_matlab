
SForces = Forces{1, 13} (:,6);
figure
plot(SForces)
StartForces =find(SForces);

SfiltForces = filtForces{1, 13} (:,6);
figure
plot(SfiltForces)
StartfiltForces =find(SfiltForces);



SfiltForces50 = filtForces50{1, 13} (:,6);
figure
plot(SfiltForces50)
StartfiltForces50 =find(SfiltForces50);

legend('SForceFilt','SForceThr','force filtered at 10Hz','','raw data','force filtered at 50Hz')


%%
Ntrial = 9;
col = 3;
SMOTdataOpenSim = MOTdataOpenSim{1, Ntrial} (:,:);
figure
plot(SMOTdataOpenSim(:,col*3))
StrartMOT = find(MOTdataOpenSim{1, Ntrial}(:,col*3));
hold on

SForces = Forces{1, Ntrial} (:,:);
plot(SForces(:,col))
StartForces =find(SForces);
hold on

SglobalMOTdata = globalMOTdata{1, Ntrial} (:,:);
plot(SglobalMOTdata(:,col*3))
StrartglobalMOTdata = find(globalMOTdata(:,col*3));


SForcesFiltered = ForcesFiltered{1, Ntrial} (:,:);
plot(SForcesFiltered(:,col))
StartForcesFiltereds =find(SForcesFiltered);

SglobalForces = globalForces{1, Ntrial} (:,:);
plot(SglobalForces(:,col))
hold on
plot(SForcesFiltered(:,col))


SMOTrotDataOpenSim = MOTrotDataOpenSim{1, Ntrial} (:,:);
plot(SglobalForces(:,col))
hold on
plot(SForcesFiltered(:,col))


SForcesThr = ForcesThr{1, Ntrial} (:,6);
plot(SForcesThr)
StartForcesThr =find(SForcesThr);
hold on
plot(SForces)

%% use after selectionData
SDataSelected = DataSelected{1, k} (:,6);
figure
plot(SDataSelected)
hold on
plot(filtData{1, k} (:,6))

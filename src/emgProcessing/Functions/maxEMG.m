function MaxTrials = maxEMG (EMGdata,Labels)

% addpath(genpath(cd));                % add current folder and sub folders to path 
%% find groups of same names (eg-> H1,H2,H3)
Groups = 1;
for Trial = 2 : length (EMGdata)
   N =  length(EMGdata{Trial})-1;                            % the full name witout the last character, eg.: HE1 => HE 
   if strncmpi((EMGdata{Trial-1}),(EMGdata{Trial}),N)==0      % comapre the current Trial name with the previous one
   Groups (end+1) = Trial; 
   end
end

MaxTrials = table;
for ii = 2:length(Groups)
    TrialName = EMGdata(Groups(ii-1));                                      % name of the trial without the last character (e.g DF1 = DF)
    ForceAll = [];
    
for Trial = (Groups(ii-1):Groups(ii)-1)                                     % index of each trial with the same name 
    cd (sprintf ('%s\\%s',EMGdata(Trial),EMGdata(Trial).name));
    load ForceData.mat MaxForce;
    ForceAll(Trial) = MaxForce;
end
MaxTrials.(Files(Groups(ii-1)).name (1:end-1))(1,2)= max (ForceAll);
    
end

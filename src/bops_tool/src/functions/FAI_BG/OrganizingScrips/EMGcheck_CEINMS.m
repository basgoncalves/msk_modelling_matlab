

function [quality,Adjusted,Synt] = EMGcheck(DirMocap,Subject,trialList)

fp = filesep;
cd(DirMocap)
demographics = importParticipantData('ParticipantData and Labelling.xlsx', 'Demographics');
SubjectCodes = demographics(:,1);

DirC3D = [DirMocap fp 'InputData' fp Subject fp 'pre'];
DirElaborated = [DirMocap fp 'ElaboratedData' fp Subject fp 'pre'];

load ([DirC3D fp 'BadTrials.mat'])

SubjectRow = find(contains(SubjectCodes,Subject));
quality  = mean(cell2mat(BadTrials),2); % calculate the mean accross trials
[TestedLeg,cl] = findLeg(DirElaborated,'');
s = lower(TestedLeg{1});
cl = lower(cl{1});

% define adjusted muscles or synth MTUs
Synt = ['edl_' s ' ehl_' s ' fdl_' s ' fhl_' s ' glmin1_' s ' glmin2_' s ' glmin3_' s ... 
    ' glmed1_' s ' glmed2_' s ' glmed3_' s ' iliacus_' s ' piri_' s ' psoas_' s ...
    ' perbrev_' s ' perlong_' s ' sart_' s ' vasint_' s...
    ' edl_' cl ' ehl_' cl ' fdl_' cl ' fhl_' cl ' iliacus_' cl ...
    ' psoas_' cl ' perbrev_' cl ' perlong_' cl  ' sart_' cl ...
    ' addbrev_' cl ' addlong_' cl ' addmagDist_' cl ' addmagIsch_' cl ' addmagMid_' cl ...
    ' addmagProx_' cl ' bfsh_' cl ' bflh_' cl ' glmax1_' cl ' glmax2_' cl ' glmax3_' cl ...
    ' glmed1_' cl ' glmed2_' cl ' glmed3_' cl ' glmin1_' cl ' glmin2_' cl ' glmin3_' cl ' gaslat_' cl ...
    ' gasmed_' cl ' grac_' cl ' piri_' cl ' recfem_' cl  ' semiten_' cl ' semimem_' cl ' soleus_' cl ...
    ' tfl_' cl ' tibant_' cl ' vasint_' cl ' vaslat_' cl ' vasmed_' cl]; 

Muscles{1} = [' vasmed_' s ];
Muscles{2} = [' vaslat_' s ];
Muscles{3} = [' recfem_' s ];
Muscles{4} = [' grac_' s ];
Muscles{5} = [' tibant_' s ];
Muscles{6} = [' addbrev_' s ' addlong_' s ' addmagDist_' s ' addmagIsch_' s ' addmagMid_' s ' addmagProx_' s ];
Muscles{7} = [' semiten_' s ' semimem_' s ];
Muscles{8} = [ ' bfsh_' s ' bflh_' s ];
Muscles{9} = [' gasmed_' s ];
Muscles{10} = [' gaslat_' s ];
Muscles{11} = [' tfl_' s ];
Muscles{12} = [' glmax1_' s ' glmax2_' s ' glmax3_' s ];

Adjusted =[];
for k = 1:length(Muscles)
    if quality(k) == 0
        Adjusted = [Adjusted Muscles{k}];
        
    else
        Synt = [Synt Muscles{k}];
    end
    
end

if mean(quality(1:2))==0
     Adjusted = [Adjusted ['vasint_' s]];
else
     Synt = [Synt ['vasint_' s]];
end

if mean(quality(9:10))==0
     Adjusted = [Adjusted ['soleus_' s]];
else
     Synt = [Synt ['soleus_' s]];
end
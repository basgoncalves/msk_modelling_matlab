function [muscleGroups,muscleGroupsNames] = get_muscle_groups

muscleGroups = struct;

muscleGroups.Iliopsoas     = {['iliacus'],['psoas']};
muscleGroups.RecFem        = {['recfem']};
muscleGroups.TFL           = {['tfl']};

muscleGroups.Hamstrings    = {['bflh'],['bfsh'],['semimem'],['semiten']};
muscleGroups.Gmax          = {['glmax1'],['glmax2'],['glmax3']};
muscleGroups.Gmed          = {['glmed1'],['glmed2'],['glmed3']};
muscleGroups.Gmin          = {['glmin1'],['glmin2'],['glmin3']};

muscleGroups.Adductors     = {['addbrev'],['addlong'],['addmagDist'],['addmagIsch'],['addmagMid'],['addmagProx'],['grac']};

muscleGroups.Vasti         = {['vasint'],['vaslat'],['vasmed']};

muscleGroups.Gastroc       = {['gaslat'],['gasmed']};
muscleGroups.Soleus        = {['soleus']};

muscleGroups.Tibilais      = {['tibant']};

muscleGroupsNames  = fields(muscleGroups);
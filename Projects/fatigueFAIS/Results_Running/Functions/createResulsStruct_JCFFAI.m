
function [G,W,ST,E] = createResulsStruct_JCFFAI(OutVar,WorkVar,STVar,ErrVar,TrialList,Ncols,Nrows)


G = struct;% group data
E = struct;% error emg and momments

% muscle/joints'ext biomec... paramters
for TypeVar  = fields(OutVar)'
    for GroupVar = fields(OutVar.(TypeVar{1}))'
        for Var = {OutVar.(TypeVar{1}).(GroupVar{1})}
            for trial = TrialList
                if contains(GroupVar,'Impulse')
                    G.(GroupVar{1}).(Var{1}).(trial{1})= NaN(1,Ncols);
                else
                    G.(GroupVar{1}).(Var{1}).(trial{1})= NaN(Nrows,Ncols);
                end
            end
        end
    end
end

% work paramters
for GroupVar = {OutVar.externalBiomech.IK}
    for Var = WorkVar
        for trial = TrialList
            W.(GroupVar{1}).(Var{1}).(trial{1})= NaN(1,Ncols);
        end
    end
end

% ST paramters
for Var = STVar
    for trial = TrialList
        ST.(Var{1}).(trial{1})= NaN(1,Ncols);
    end
end

% error values paramters
for GroupVar = fields(ErrVar)'
    for trial = TrialList
        E.(GroupVar{1}).(trial{1})= NaN(Ncols,1);
    end
end


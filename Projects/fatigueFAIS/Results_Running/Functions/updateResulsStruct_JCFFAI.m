
function [G,W,ST,E] = updateResulsStruct_JCFFAI(G,W,ST,E,TrialList,OutVar,WorkVar,STVar,ErrVar,Ncols,Nrows,ReRunCols)

% muscle/joints'ext biomec... paramters
if ~isempty(fields(OutVar))
    for TypeVar  = fields(OutVar)'
        for GroupVar = fields(OutVar.(TypeVar{1}))'
            for Var = {OutVar.(TypeVar{1}).(GroupVar{1})}
                for trial = TrialList
                    if contains(GroupVar,'Impulse')
                        G.(GroupVar{1}).(Var{1}).(trial{1})(1,ReRunCols)= NaN;
                    else
                        G.(GroupVar{1}).(Var{1}).(trial{1})(Nrows,ReRunCols)= NaN;
                    end
                end
            end
        end
    end
end

% work paramters
if ~isempty(fields(OutVar)) && isfield(OutVar,'externalBiomech')
    for GroupVar = {OutVar.externalBiomech.IK}
        for Var = WorkVar
            for trial = TrialList
                W.(GroupVar{1}).(Var{1}).(trial{1})= NaN(1,Ncols);
            end
        end
    end
end

% ST paramters
if ~isempty(STVar)
    for Var = STVar
        for trial = TrialList
            ST.(Var{1}).(trial{1})= NaN(1,Ncols);
        end
    end
end

% error values paramters
if ~isempty(fields(ErrVar))
    for GroupVar = fields(ErrVar)'
        for trial = TrialList
            E.(GroupVar{1}).(trial{1})= NaN(Ncols,1);
        end
    end
end



for n = 1:length (Files)
    
    if isfolder([Files(n).folder fp Files(n).name fp])~=1                                    % if it is not a folder
        continue                                                % move to the next loop iteration    
    end
    
    SessionData = [Files(n).folder fp Files(n).name fp 'ElaboratedData\sessionData'];
    Trials = dir(SessionData); 
    for t =1:length(Trials)
        trialName = [Trials(t).folder fp Trials(t).name]; 
       if contains(trialName,'Biodex') &&...
               isfolder(trialName)==1
           
           Tfiles = dir(trialName);
           for i = 1:length(Tfiles)
                delete([Tfiles(i).folder fp Tfiles(i).name])
           end
           rmdir(trialName)
       end 
    end
end
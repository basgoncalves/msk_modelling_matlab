%
% 1) find if all "TrialNames" exist in "Labels"
% 2) if NOT, check "AllNames" and assign the nearest word with the closet
% number of letters
%
% Example:
% Labels = {'Run_baselineB1' 'RunA1' 'RunK1' 'RunL1'};
%
% TrialNames = {'Run_baselineA1' 'RunL1'}; 
% 
% AllNames = {'Run_baselineA1' 'Run_baselineB1' 'RunA1' 'RunB1' 'RunC1' 'RunD1' 'RunE1' 'RunF1' ...
%    'RunG1' 'RunH1' 'RunI1' 'RunJ1' 'RunK1' 'RunL1'};
%
% output = {'Run_baselineB1' 'RunL1'}; 
%% start function
function output = findClosedText (Labels,TrialNames,AllNames)
output={};

% Labels = names of trials for this participant (from LRFAI)
if sum(contains(Labels,TrialNames))~= length(TrialNames)
    Match_Labels = contains(AllNames,Labels);
    Match_TrialNames = contains(AllNames,TrialNames);
    NTrialNames = 0;
    for mm = find(Match_TrialNames)
        NTrialNames = NTrialNames+1;                                        % index of the TrialNames variable
        
         % if the word in TrialNames does not match with Labels
        if Match_Labels(mm)==0                                             
            
            DistanceFromWord = double(Match_Labels);                            % variable to calculate the distance between word to match and others            
            [~,distanceidx] = find(Match_Labels);                   
            DistanceFromWord(distanceidx)= distanceidx;
            DistanceFromWord(DistanceFromWord==0) = max(DistanceFromWord);      % make the "zeros" (i.e. the not matching values) = the max distance
            DistanceFromWord = abs(DistanceFromWord-mm);            
            DistanceFromWord = DistanceFromWord-(min(DistanceFromWord));
            
            [~,Closerdx] = find(DistanceFromWord==0);
            % if there are two names equally distante from the "mm" name
            if length(Closerdx)==2
                L1 = length(AllNames{mm});                                  % length of the word to compare
                L2 = length(AllNames{Closerdx(1)});                         % length of first name
                L3 = length(AllNames{Closerdx(2)});                         % length of second name
                if   abs(L1 - L2) <= abs(L1 - L3)                           % compare length differences to select the best fitting word
                    output(NTrialNames) =  AllNames(Closerdx(1));                % select L2
                else
                    output(NTrialNames) =  AllNames(Closerdx(2));                % select L3
                end
                % if there is only one name near "mm"
            else
                output(NTrialNames) =  AllNames(Closerdx);
            end
         % if the word in TrialNames matches with Labels    
        else 
            output(NTrialNames) =  TrialNames(NTrialNames);
        end
    end
    
else 
    output = TrialNames;
    
end
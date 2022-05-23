

function [quality,Adjusted,Synt] = createExcitationGenerator_FAIS(Dir,CEINMSSettings,SubjectInfo)

fp = filesep;
 
load ([Dir.Elaborated fp 'BadTrials.mat'])

quality  = mean(cell2mat(BadTrials),2); % calculate the mean accross trials
dofList = split(CEINMSSettings.dofList ,' ')';
S = getOSIMVariablesFAI(SubjectInfo.TestedLeg,CEINMSSettings.osimModelFilename,dofList);

exctGern = xml_read(CEINMSSettings.excitationGeneratorFilename);
Adjusted =[]; Synt=[];
for m = 1:length(exctGern.mapping.excitation)
    muscle = exctGern.mapping.excitation(m).ATTRIBUTE.id;
    if ~contains(muscle,S.AllMuscles) 
        continue
    end
    
    if ~isempty(exctGern.mapping.excitation(m).input)
        row = [];
        for k = 1:length(exctGern.mapping.excitation(m).input)
            row = [row find(strcmp(strtrim(allMuscles),exctGern.mapping.excitation(m).input(k).CONTENT))];
        end
        if ~isempty(row) && mean(quality(row)) == 0
            Adjusted = [Adjusted muscle ' '];
        elseif ~isempty(row) && mean(quality(row)) > 0
             Synt = [Synt muscle ' '];
             exctGern.mapping.excitation(m).input = [];
        else
             Synt = [Synt muscle ' '];
        end
    else
         Synt = [Synt muscle ' '];
    end
end


xml_write(CEINMSSettings.excitationGeneratorFilename,exctGern,'excitationGenerator');

disp('Adjusted Muscles')
disp(Adjusted)
disp('Synthesised Muscles')
disp(Synt)
disp(' ')
disp(['EMGS signals not used'; allMuscles(quality>0)])
disp(' ')

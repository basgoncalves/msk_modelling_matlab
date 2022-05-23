
%

function [muscles,inputs]=assignEMGtoMuscle(excitationGeneratorFilename)

fp = filesep;
exctGern = xml_read(excitationGeneratorFilename);

for k = 1:length(exctGern.mapping.excitation)
   muscles{k,1} =  exctGern.mapping.excitation(k).ATTRIBUTE.id;
   if isempty(exctGern.mapping.excitation(k).input)
        inputs{k,1} = {};
   else
        inputs{k,1} = exctGern.mapping.excitation(k).input.CONTENT;
   end
end



function createExcitationGeneratorStaticOpt_FAIS(CEINMSSettings)

fp = filesep;
exctGern = xml_read(CEINMSSettings.excitationGeneratorFilename);
for m = 1:length(exctGern.mapping.excitation)
    if ~isempty(exctGern.mapping.excitation(m).input)
        for i = 1:length(exctGern.mapping.excitation(m).input)
            exctGern.mapping.excitation(m).input(i).ATTRIBUTE.weight= '0';
        end
    end
end

xml_write(CEINMSSettings.excitationGeneratorFilenameStaicOpt,exctGern,'excitationGenerator')

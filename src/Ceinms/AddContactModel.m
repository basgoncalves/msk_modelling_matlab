%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
% add the contact model and OSIM model to the  uncalibrated CEINMS subject
%-------------------------------------------------------------------------
%% EditCalibratedSubject 

function AddContactModel(Dir,Temp,CEINMSSettings)

disp('adding contact model...')

fp = filesep;
XML = xml_read (CEINMSSettings.subjectFilename);
copyfile(Temp.CEINMScontactmodel,CEINMSSettings.contactModel)
XML.contactModelFile = CEINMSSettings.contactModel;
XML.opensimModelFile = Dir.OSIM_LO;

%conver the curve data to strings
for k = 1:length({XML.mtuDefault.curve.xPoints})
    XML.mtuDefault.curve(k).xPoints = num2str(XML.mtuDefault.curve(k).xPoints);
    XML.mtuDefault.curve(k).yPoints = num2str(XML.mtuDefault.curve(k).yPoints);
end
for k = 1:length({XML.mtuSet.mtu.name})
    if isfield(XML.mtuSet.mtu(k),'curve') && ~isempty(XML.mtuSet.mtu(k).curve)
        XML.mtuSet.mtu(k).curve.xPoints = num2str(XML.mtuSet.mtu(k).curve.xPoints);
        XML.mtuSet.mtu(k).curve.yPoints = num2str(XML.mtuSet.mtu(k).curve.yPoints);
    end
end

% save model
prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
prefXmlWrite.CellItem   = false;
xml_write(CEINMSSettings.subjectFilename, XML, 'subject', prefXmlWrite);

disp(['Contact model added to ' CEINMSSettings.subjectFilename])

if exist(CEINMSSettings.outputSubjectFilename)
    XML = xml_read (CEINMSSettings.outputSubjectFilename);
    XML.contactModelFile = CEINMSSettings.contactModel;
    XML.opensimModelFile = Dir.OSIM_LO;
    
    %conver the curve data to strings
    for k = 1:length({XML.mtuDefault.curve.xPoints})
        XML.mtuDefault.curve(k).xPoints = num2str(XML.mtuDefault.curve(k).xPoints);
        XML.mtuDefault.curve(k).yPoints = num2str(XML.mtuDefault.curve(k).yPoints);
    end
    
    for k = 1:length({XML.mtuSet.mtu.name})
        if isfield(XML.mtuSet.mtu(k),'curve') && ~isempty(XML.mtuSet.mtu(k).curve)
            XML.mtuSet.mtu(k).curve.xPoints = num2str(XML.mtuSet.mtu(k).curve.xPoints);
            XML.mtuSet.mtu(k).curve.yPoints = num2str(XML.mtuSet.mtu(k).curve.yPoints);
        end
    end
    
    % save model
    prefXmlWrite.StructItem = false; prefXmlWrite.CellItem = false;  % allow arrays of structs to use 'item' notation
    xml_write(CEINMSSettings.outputSubjectFilename, XML, 'subject', prefXmlWrite);

end

disp(['Contact model added to ' CEINMSSettings.outputSubjectFilename])

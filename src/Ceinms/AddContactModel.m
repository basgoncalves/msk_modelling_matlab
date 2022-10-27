%% Description - Basilio Goncalves (2020)
% https://www.researchgate.net/profile/Basilio_Goncalves
% add the contact model and OSIM model to the  uncalibratedcontactModel_xml CEINMS subject
%-------------------------------------------------------------------------
%% EditCalibratedSubject 

function AddContactModel(osim_model, unclaibrated_model_ceinms, claibrated_model_ceinms, template_contactModel_xml, contactModel_xml)

disp('adding contact model...')

XML = xml_read (unclaibrated_model_ceinms);
copyfile(template_contactModel_xml,contactModel_xml)
XML.contactModelFile = contactModel_xml;
XML.opensimModelFile = osim_model;

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
xml_write(unclaibrated_model_ceinms, XML, 'subject', prefXmlWrite);

disp(['Contact model added to ' unclaibrated_model_ceinms])

if exist(claibrated_model_ceinms)
    XML = xml_read (claibrated_model_ceinms);
    XML.contactModelFile = contactModel_xml;
    XML.opensimModelFile = osim_model;
    
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
    xml_write(claibrated_model_ceinms, XML, 'subject', prefXmlWrite);

end

disp(['Contact model added to ' claibrated_model_ceinms])

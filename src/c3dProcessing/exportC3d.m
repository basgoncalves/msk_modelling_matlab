% The function exportC3d is designed to export various types of data from a C3D file to OpenSim-specific formats.
% It uses the OpenSim libraries (import org.opensim.modeling.*) to handle the data.
% It first processes and writes marker data to a TRC (Track) file, subsequently converting it to a specific orientation and saving it.
% Then, it handles force plate data, converting units from millimeters to meters and saving it as a motion file (MOT file).
% Finally, it attempts to extract and write EMG (Electromyography) data to a motion file using the writeMOT_EMG function. If the C3D file doesn't contain the specific data, it raises appropriate warnings.

function exportC3d(c3dFilePath,EMGLabels,bandPassFilter,lowPassFilter)

[parentFolder,trialName] = fileparts(c3dFilePath);

% create trial folder for converted data
trialFolderConverted = [parentFolder fp trialName];
if ~isfolder(trialFolderConverted); mkdir(trialFolderConverted); end

% copy c3d file
copyfile(c3dFilePath,[trialFolderConverted fp 'c3dfile.c3d']);

% Load OpenSim libs
import org.opensim.modeling.*

% Construct an opensimC3D object with input c3d path
c3d = osimC3D(c3dFilePath,1);

disp(['exporting data to ' trialFolderConverted])

% Write marker data to trc file.
try
    c3d.rotateData('x',-90); % Rotate the data
    c3d.rotateData('y',-90);
    c3d.writeTRC([trialFolderConverted fp 'markers.trc']);
catch
    warning([c3dFilePath ' does not contain markers'])
end

% Write grf to mot file
try
    c3d.convertMillimeters2Meters();                    % Convert COP (mm to m) and Moments (Nmm to Nm)
    c3d.writeMOT([trialFolderConverted fp 'grf.mot']);

    replaceWithNaN([trialFolderConverted fp 'grf.mot']);         % replace %Name with NaN
catch
    warning([c3dFilePath ' does not contain grf'])
end

% write EMG data to mot file
try
    if nargin < 2
        EMGLabels = '';
        bandPassFilter = [50, 450];
        lowPassFilter = 6;
    end

    writeMOT_EMG(c3dFilePath,EMGLabels,bandPassFilter,lowPassFilter)
catch
    warning(([c3dFilePath ' does not contain emg data']))
end

% create xml file for grf
[data,C,tableData] =  readMOTSTOTRCfiles([trialFolderConverted '\'],'grf.mot');
numPlates = c3d.getNumForces;

XML = struct;
XML.ATTRIBUTE.Version = 40000;

XML.ExternalLoads = struct;
XML.ExternalLoads.objects = struct;
XML.ExternalLoads.objects.ExternalForce = struct;

for i = 1:numPlates
    XML.ExternalLoads.objects.ExternalForce(i).COMMENT = '';
    XML.ExternalLoads.objects.ExternalForce(i).applied_to_body = 'calcn_r';
    XML.ExternalLoads.objects.ExternalForce(i).force_expressed_in_body = 'ground';
    XML.ExternalLoads.objects.ExternalForce(i).point_expressed_in_body = 'ground';
    XML.ExternalLoads.objects.ExternalForce(i).force_identifier = ['ground_force_' num2str(i) '_v'];
    XML.ExternalLoads.objects.ExternalForce(i).point_identifier = ['ground_force_' num2str(i) '_p'];
    XML.ExternalLoads.objects.ExternalForce(i).torque_identifier = ['ground_moment_' num2str(i) '_m'];
    XML.ExternalLoads.objects.ExternalForce(i).data_source_name = [];
    XML.ExternalLoads.objects.ExternalForce(i).ATTRIBUTTE = struct;
end



footOnForcePlate = detectFootOnForcePlate(verticalGRF, markerCoordinates, threshold)


xml2 = xml_read('C:\Users\Biomech\ucloud\Shared\Data_CEINMS\setupFiles\grf.xml')

function replaceWithNaN(file_path)

% Read the file content
fid = fopen(file_path, 'r');
content = fread(fid, '*char')';
fclose(fid);

% Replace "#NAME?" with "NaN"
content = strrep(content, '-nan(ind)', 'NaN'); 

% Write the modified content back to the file
fid = fopen(file_path, 'w');
fprintf(fid, '%s', content);
fclose(fid);

disp(['File ''' file_path ''' updated.']);


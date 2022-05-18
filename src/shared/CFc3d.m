% CFc3d
% contact frame c3d


[File,FilePath,FileIndex] = ...
    uigetfile('*.*','Select OpenSim Results');
Dirfile = [FilePath File];
[Folder,TrialName,ext]=fileparts(Dirfile);

cd(Folder)

OSIMdata = btk_loadc3d(Dirfile);
openvar('OSIMdata')
fsRatio = OSIMdata.fp_data.Info(1).frequency / OSIMdata.marker_data.Info.frequency;
IF = OSIMdata.marker_data.First_Frame;

disp (TrialName)
Contact = find(OSIMdata.fp_data.GRF_data(1).F(:,end));
if isempty(Contact) Contact = 'Empty'; end
fprintf ('Contact Plate 1 = %.f \n',Contact(1)/fsRatio+IF)

Contact = find(OSIMdata.fp_data.GRF_data(2).F(:,end));
if isempty(Contact) Contact = 'Empty'; end
fprintf ('Contact Plate 2 = %.f \n',Contact(1)/fsRatio+IF)

Contact = find(OSIMdata.fp_data.GRF_data(3).F(:,end));
if isempty(Contact) Contact = 'Empty'; end
fprintf ('Contact Plate 3 = %.f \n',Contact(1)/fsRatio+IF)

Contact = find(OSIMdata.fp_data.GRF_data(4).F(:,end));
if isempty(Contact) Contact = -IF*fsRatio; end
fprintf ('Contact Plate 4 = %.f \n',Contact(1)/fsRatio+IF)
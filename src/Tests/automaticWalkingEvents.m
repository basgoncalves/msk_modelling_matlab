
function automaticWalkingEvents


bops                    = load_setup_bops;
subject                 = load_subject_settings;
c3dFilePathAndName      = 'C:\Users\Bas\Documents\6-FMH\CP_project\Data\InputData\PC013\session2_barefoot\2015_03_24_PC013_BAREFOOT_GAIT0002_1.c3d';
newAcquisition          = xml_read(subject.directories.acquisitionXML);
rightFootMarkers        = newAcquisition.MarkersProtocol.rightFootMarkers;
leftFootMarkers         = newAcquisition.MarkersProtocol.leftFootMarkers;

[StanceOnFP,event_frames] = findGaitCycle_Events(c3dFilePathAndName,'',rightFootMarkers,leftFootMarkers);


[events,motionDirection] = findHeelStrike_Running_multiple(data, motionDirection
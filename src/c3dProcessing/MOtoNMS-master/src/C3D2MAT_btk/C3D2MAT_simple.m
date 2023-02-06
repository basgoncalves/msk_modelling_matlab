

function C3D2MAT_simple(pathName)

if nargin < 1
    pathName = uigetdir(cd);
end
c3dFiles = dir ([pathName filesep '*.c3d']);
for k=1:length(c3dFiles)


    %correction of the name --> after uniformation it should not be necessary
    trialName = regexprep(regexprep((regexprep(c3dFiles(k).name, ' ' , '')), '-',''), '.c3d', '');
    c3dFilePathAndName = fullfile (pathName, c3dFiles(k).name);
    [Markers, AnalogData, FPdata, Events, ForcePlatformInfo, Rates] = getInfoFromC3D(c3dFilePathAndName);

    trialMatFolder = [pathName filesep trialName filesep];
    if ~exist(trialMatFolder)
        mkdir(trialMatFolder)
    end
    saveMat(Markers,AnalogData,FPdata, Events, trialMatFolder)


end
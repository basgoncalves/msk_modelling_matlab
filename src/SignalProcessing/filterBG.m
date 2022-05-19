
function M = filterBG (EMGdataDir)

load(EMGdataDir);
M = mean(RawEMG);


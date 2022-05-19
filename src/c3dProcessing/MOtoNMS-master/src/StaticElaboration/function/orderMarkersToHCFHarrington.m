
function [markerNames_hjc_out,markers_hjc_out] = orderMarkersToHCFHarrington(markerNames_hjc,markers_hjc)


markerNames_hjc_out = {};
markers_hjc_out     = {};
for i = 1:length(markers_hjc) 
   
   iName =  markerNames_hjc{i};
   iData =  markers_hjc {i};
   if       contains(iName,'LASIS');     idx = 1;
   elseif   contains(iName,'RASIS');     idx = 2;
   elseif   contains(iName,'LPSIS');     idx = 3;
   elseif   contains(iName,'RPSIS');     idx = 4;    
   end
markerNames_hjc_out{idx} = iName;
markers_hjc_out{idx} = iData;

end
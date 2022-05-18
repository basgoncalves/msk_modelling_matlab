% moveup N output directories
function [OutputDirectory,filename] = DirUp(originalDirectory,N)

OutputDirectory = originalDirectory; 
if nargin<2; N=1; end
for ii=1:N; [OutputDirectory,filename]=fileparts(OutputDirectory);end



% Dim: 1= rows; 2 = cols;
function [MeanData,SDdata] = MeanMatrices (Dim,varargin)


nMatrices = nargin-1;   

MeanData = [];
SDdata =[];
if Dim==2; for n = 1:nMatrices; varargin{n}=varargin{n}' ;end; end

for ii = 1:size(varargin{1},1)
    colMerge =[];
    for n = 1:nMatrices
        colMerge(n,:)=varargin{n}(ii,:);
    end
    MeanData(ii,:)= nanmean (colMerge);
    SDdata(ii,:)= nanstd (colMerge,0,2);
end


if Dim==2; MeanData=MeanData';SDdata=SDdata'; end; end

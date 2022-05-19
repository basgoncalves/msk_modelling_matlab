
function selectedAnalysis = selectAnalysis(SelectAll)

bops = load_setup_bops;

if nargin < 1
    SelectAll = 0;
end

allAnalysis = fields(bops.analyses);

if SelectAll == 0
    [indx,~] = listdlg('PromptString','select analyses:','ListString',allAnalysis); 
else
    indx = [];
end
selectedAnalysis = allAnalysis(indx);

for i = 1:length(allAnalysis)
    if ~isempty(intersect(indx,i))
        bops.analyses.(allAnalysis{i}) = true;
    else
        bops.analyses.(allAnalysis{i}) = false;
    end
end

answer = questdlg('do you want to re-run analyeses previoulsy completed?'); 

switch answer
    case 'Yes'; bops.current.rerun = 'true';
    case 'No';  bops.current.rerun = 'false';    
end

xml_write(bops.directories.setupbopsXML,bops,'bops',bops.xmlPref);
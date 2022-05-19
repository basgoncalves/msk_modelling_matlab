%% Description - Basilio Goncalves (2019)
% https://www.researchgate.net/profile/Basilio_Goncalves
%
% After exporting the data from univariate analysis from SPSS to xlsx (multiple analyises
% possible) re arranged the data to a friendly word format
%-------------------------------------------------------------------------
%CALLBACK FUNTIONS
%INPUT
%   chose by the user the xlsx file
%-------------------------------------------------------------------------
%OUTPUT
%   Table with the data for descriptive, estimated and pairwise comparisons
%   txt = text to place in the results section
%--------------------------------------------------------------------------

%% ConvertOutputSPSS
function [Table,txt] = ConvertOutputSPSS

% column 1 = mean
% column 2 = standard deviation
SPSSoutput=[];
PairwiseComparisons = [];
OutputLabels={};
Table={};
[filename,filepath,~] = uigetfile('*.xls');
cd(filepath)
[NUM,TXT,RAW] = xlsread([filepath filename]);

%index of each output
Outputdx = find(strcmp(RAW(:,1),{'Output Created'}));
Outputdx(end+1) = length(RAW);  % add one at the end to use as the end of the last output

%index for estimated marginal means
EstimatedMAriginIdx = find(strcmp(RAW(:,1),'Estimated Marginal Means'));

%index for Pairwise Comparisons
PairwiseIdx = find(strcmp(RAW(:,1),'Pairwise Comparisons'));

%index for estimated marginal means
EstimatesIdx = find(strcmp(RAW(:,1),'Estimates'));

%index for estimated marginal means
UniTestIdx = find(strcmp(RAW(:,1),'Univariate Tests'));

%% loop through all the analysis in the export file from SPSS
Table = struct;
for ii = 1:length(EstimatedMAriginIdx)
    
    StructName = sprintf('Pairwise_%d',ii);
    Table.(StructName) = {};
    Table.(StructName)(1,1:5)= [{'Variable'},{'Descriptive'},{'Estimates'},{'Pairwise difference'},{'P-value'}];
    
    %index end of pairwise comparisons
    PairwiseRows = PairwiseIdx(ii):Outputdx(ii+1);
    EndPairwiseIdx = find(strcmp(RAW(PairwiseRows,1),{'Based on estimated marginal means'}))-2;
    PairwiseRows = PairwiseIdx(ii)+3:PairwiseIdx(ii)+EndPairwiseIdx;            % add 3 to PairwiseIdx to start where the variables start
    
    % find N groups and N per group
    CurrentAnalysisRows = Outputdx(ii):Outputdx(ii+1);
    BetweenSubjectsIdx = find(strcmp(RAW(CurrentAnalysisRows,:),{'Between-Subjects Factors'}))+CurrentAnalysisRows(1)-1;
    DescriptiveIdx = find(strcmp(RAW(CurrentAnalysisRows,:),{'Descriptive Statistics'}))+CurrentAnalysisRows(1)-1;
    TestBTWSubjectsIdx = find(strcmp(RAW(CurrentAnalysisRows,:),{'Tests of Between-Subjects Effects'}))+CurrentAnalysisRows(1)-1;
    
    
    GroupsRows = BetweenSubjectsIdx+2:DescriptiveIdx-2;
    NGroups = length(GroupsRows);
    NperGroup = cell2mat(RAW(GroupsRows,3));
    
    % descriptive rows
    % NGroups + 1 = Number of groups plus the total
    
    Variables = RAW(DescriptiveIdx+2:TestBTWSubjectsIdx-2,1);
    Variables(3:3:end) =[];
    Nvariables = length(Variables) / (NGroups);
    DescriptiveRows = DescriptiveIdx+2:TestBTWSubjectsIdx-2;
    DescriptiveRows (3:3:end) =[];
    
    %% get mean and sd for each variable (FROM DESCRIPTIVES)
    
    MeanCol = find(strcmp(RAW(DescriptiveRows(1)-1,:),{'Mean'}));
    SDCol = find(strcmp(RAW(DescriptiveRows(1)-1,:),{'Std. Deviation'}));
    row = 0;
    for dd = DescriptiveRows
        row = row+1;
        if isnan(Variables{row})
            Group = Group +1;
        else
            Group = 1;
            VarName = Variables{row,1};
        end
        
        % delete asterisks or any other characthers that are not numbers
        MeanData = CleanStr2Num (RAW{dd,MeanCol});
        
        % mean ± SD
        a = sprintf('%.2f±%.2f',MeanData,RAW{dd,SDCol});
        if Group == 1
            TableCol = 2;
            TableRow = size(Table.(StructName),1)+1;
        else
            TableCol = TableCol + Group-1;
            TableRow = TableRow;
            Table.(StructName){1,TableCol} = sprintf('Descriptive_%d',Group);
        end
        
        Table.(StructName){TableRow,TableCol}= a;
        Table.(StructName){TableRow,1} = VarName;
    end
    
    
    %% get estimates for each variable
    
    MeanCol = find(strcmp(RAW(EstimatesIdx(ii)+1,:),{'Mean'}));
    SECol = find(strcmp(RAW(EstimatesIdx(ii)+1,:),{'Std. Error'}));
    LBCol = find(strcmp(RAW(EstimatesIdx(ii)+2,:),{'Lower Bound'}));
    UBCol = find(strcmp(RAW(EstimatesIdx(ii)+2,:),{'Upper Bound'}));
    
    Variables = RAW(PairwiseRows,1);
    
    FirstColEstimates = find(contains(Table.(StructName)(1,:),{'Descriptive'}))+1;
    FirstColEstimates = FirstColEstimates(end);
    TableRow =1;
    for ee = EstimatesIdx(ii)+3 :EstimatesIdx(ii)+EndPairwiseIdx
        row = ee -(EstimatesIdx(ii)+3)+1;
        if isnan(Variables{row})
            Group = Group +1;
        else
            Group = 1;
        end
        
        % delete asterisks or any other characthers that are not numbers
        MeanData = CleanStr2Num (RAW{ee,MeanCol});
        
        % mean ± SD
        a = sprintf('%.2f±%.2f',MeanData,RAW{ee,SECol}*sqrt(NperGroup(Group)));
        
        if Group == 1
            TableCol = FirstColEstimates;
            TableRow = TableRow +1;
            Table.(StructName){1,TableCol} = sprintf('Estimates_1');
        else
            TableCol = TableCol + Group-1;
            Table.(StructName){1,TableCol} = sprintf('Estimates_%d',Group);
        end
        
        Table.(StructName){TableRow,TableCol}= a;
    end
    
    %% get mean differences (from the paiswise section)
    % pairwise section = index of pairwise + 3 rows until  'Based on
    % estimated marginal means'-2
    
    
    % find columns for
    MeanDiffCol = find(strcmp(RAW(PairwiseIdx(ii)+1,:),{'Mean Difference (I-J)'}));
    SECol = find(strcmp(RAW(PairwiseIdx(ii)+1,:),{'Std. Error'}));
    PCol = find(strcmp(RAW(PairwiseIdx(ii)+1,:),{'Sig.a'}));
    if isempty(PCol)
        PCol = find(strcmp(RAW(PairwiseIdx(ii)+1,:),{'Sig.b'}));
    end
    
    LBCol = find(strcmp(RAW(PairwiseIdx(ii)+2,:),{'Lower Bound'}));
    UBCol = find(strcmp(RAW(PairwiseIdx(ii)+2,:),{'Upper Bound'}));
    
    FirstColPairwise = find(contains(Table.(StructName)(1,:),{'Estimates'}))+1;
    FirstColPairwise = FirstColPairwise(end);
    
    TableRow =1;
    for pp = PairwiseRows
        row = pp -(PairwiseIdx(ii)+3)+1;        % add 3 to PairwiseIdx to start where the variables start
        
        if isnan(Variables{row})
            Group = Group +1;
        else
            Group = 1;
        end
        
        % delete asterisks or any other characthers that are not numbers
        MeanData = CleanStr2Num (RAW{pp,MeanDiffCol});
        
        % mean diff (95% CI)
        a = sprintf('%.2f(%.2f,%.2f)',MeanData,RAW{pp,LBCol},RAW{pp,UBCol});
        % p- value
        b = sprintf('%.3f',RAW{pp,PCol});
        
        
        if Group == 1
            continue
        else
            TableCol = FirstColPairwise;
            TableRow = TableRow +1;
            Table.(StructName){1,TableCol} = sprintf('Pairwise');
            
        end
        
        % add data to final table
        Table.(StructName){TableRow,TableCol}= a;
        Table.(StructName){TableRow,TableCol+1}= b;
        
    end
    Table.(StructName){1,TableCol+1} = sprintf('P-value');
    
    %% get partial etasquared (from the univariate test section)
    % pairwise section = index of pairwise + 3 rows until  'Based on
    % estimated marginal means'-2
    
    % find columns for
    PartialEtaCol = find(strcmp(RAW(UniTestIdx(ii)+1,:),{'Partial Eta Squared'}));
    ObservedPowerCol = find(strcmp(RAW(UniTestIdx(ii)+1,:),{'Observed Powera'}));
    
    TableCol = find(contains(Table.(StructName)(1,:),{'P-value'}))+1;
    TableCol = TableCol(end);
    
    %index end of pairwise comparisons
    PartialRows = UniTestIdx(ii):Outputdx(ii+1);
    EndUniTestIdx = find(strcmp(RAW(PartialRows,1),...
        {'The F tests the effect of RunningTrial. This test is based on the linearly independent pairwise comparisons among the estimated marginal means.'}))-1;
    PartialRows = UniTestIdx(ii)+2:UniTestIdx(ii)+EndUniTestIdx-1;            % remove 1 cell to match the out put xlsx
    PartialRows = PartialRows(1:2:end);            % jump every second cell
    
    TableRow =1;
    for pp = PartialRows
        row = pp-(UniTestIdx(ii)+2)+1;        % add
        
        if isnan(Variables{row})
            Group = Group +1;
        else
            Group = 1;
        end
        % delete asterisks or any other characthers that are not numbers
        MeanData = CleanStr2Num (RAW{pp,PartialEtaCol});
        
        % partial eta squared
        a = sprintf('%.3f',MeanData);
        b = sprintf('%.3f',RAW{pp,ObservedPowerCol});
        
        if Group == 1
            TableRow = TableRow +1;
            Table.(StructName){1,TableCol} = sprintf('Partial eta-squared');
            Table.(StructName){1,TableCol+1} = sprintf('ObservedPower');
            % add data to final table
            Table.(StructName){TableRow,TableCol}= a;
            Table.(StructName){TableRow,TableCol+1}= b;
        else
            continue
            
        end
    end
end

%% Convert to text 
SPSStoWordText


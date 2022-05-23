
function [segment_mass,bodyNames,original_mass]=read_rra_mass(file)

% [file, pname] = uigetfile('*.log', 'Select C3D file');

var=importdata(file, '\t');
index = 1;

if sum(contains(var,{'Final Average Residuals'}))>0
            
for i =1:length(var)
    if strfind(var{i},'new mass')
        ind1=find((var{i}==','), 1 );
                
        num(index,:)=str2num(var{i}(ind1+12:end));
        [segment_mass]=num;
        ind2 = split(var{i},'=');
        ind2 = split(ind2{2},',');
        num2(index,:)=str2num(ind2{1});
        [original_mass]=num2;
        body =  split(var{i},':');
        bodyNames(index,:)= strrep(body(1),'* ','');
        index = index+1;
    end
end
else
    error(['wrong out log file for RRA. Check: ' file])
end
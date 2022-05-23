

function write_sto_file_IAA(data, filename,colheaders,CMC_states)
% function to write a sto file based on an struture array where each field
% is an array to be added --> note each array must be the same length

if nargin < 2
    filename = 'output.sto';
end

fname = fieldnames(data);
[~,filestring,ext] = fileparts(filename);

%open the file
fid_1 = fopen(filename,'w');

D = data.time;
hd = ['time' '\t'];
fm = '%6.6f\t';

b = find(~strcmp('time',fname));

% crop colheaders to match CMC_states
if nargin > 2
    for i = flip(1:length(colheaders))
        if ~contains(CMC_states,colheaders{i})
            colheaders(i) = [];
            fname(i) = [];
        end
    end
end

for i = 1:length(fname)-1    
    if isstruct(data.(fname{b(i)}))
        f2names = fieldnames(data.(fname{b(i)}));
        for j = 1:length(f2names)
            D = [D data.(fname{b(i)}).(f2names{j})];
            hd = [hd fname{b(i)} '.' f2names{j} '\t'];
        end
    else
        D = [D data.(fname{b(i)})];
        if (fname{b(i)}(1)=='N') && ~isempty(str2num(fname{b(i)}(2)))
            fname{b(i)}(1) = [];
        end
        hd = [hd fname{b(i)} '\t'];
    end
    fm = [fm '%6.6f\t'];
end

if nargin >= 3
    hd = colheaders{1}; 
    for i = 2:length(colheaders)
        hd =[hd '\t' colheaders{i}];
    end
end

hd = [hd '\n'];
fm = [fm '\n'];

% first write the header data
fprintf(fid_1,'%s\n',filestring);
fprintf(fid_1,'version=1\n');
fprintf(fid_1,'nRows=%d\n', size(D,1)); 
fprintf(fid_1,'nColumns=%d\n', size(D,2)); 
fprintf(fid_1,'inDegrees=yes\n'); 
fprintf(fid_1,'endheader\n'); 
fprintf(fid_1, hd);
% then write the output marker data
fprintf(fid_1,fm,D');

%close the file
fclose(fid_1);
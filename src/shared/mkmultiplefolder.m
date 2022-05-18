% make new folders
%   maindir = folder name to create the folders in
%   prefix = string with the prefix for the folders to create (eg. 's' =
%   's001','s002;...'s00n' / 's0nn')
%   n = number of folders to add

function mkmultiplefolder (maindir,prefix,n)

fp = filesep;
Nmax = numel(num2str(n));

for i = 1:n
    
    Ncurrent =  numel(num2str(i)); % lenbgth of current number
    if Ncurrent < Nmax      % if the length of current is smaller
        
        d = Nmax - Ncurrent; % find differece in length between current and max
        fname = prefix;
        for ii = 1:d         % add zeros to get the same length name
            fname = [fname '0'];
        end
        fname = [fname sprintf('%.f',i)];
        mkdir([maindir fp fname])           % make directory
        
    else
        fname = prefix;
        fname = [fname sprintf('%.f',i)];
        mkdir([maindir fp fname])
    end
    
end

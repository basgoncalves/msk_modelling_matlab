function largestFile = findLargestFile(dirPath) 

% Get a list of all files and directories in the given directory
allFiles = dir(dirPath);

% Initialize the variable to store the largest file
largestFile = [];
largestSize = 0;

% Loop through all the files and directories in the list
for i = 1:length(allFiles)
    currentFile = allFiles(i);
    
    % Skip the current file/directory if it is a special folder (e.g., '.' or '..')
    if strcmp(currentFile.name, '.') || strcmp(currentFile.name, '..')
        continue;
    end
    
    % If the current file is a directory, recursively find the largest file in that directory
    if currentFile.isdir
        currentLargestFile = findLargestFile(fullfile(dirPath, currentFile.name));
        

        try currentLargestFile.bytes; catch; currentLargestFile = currentFile; end

        % If the largest file in the current directory is larger than the current largest file, update the largest file
        if currentLargestFile.bytes > largestSize
            largestFile = currentLargestFile;
            largestSize = largestFile.bytes;
        end
    else
        % If the current file is not a directory, check if it is larger than the current largest file
        if currentFile.bytes > largestSize
            largestFile = currentFile;
            largestSize = currentFile.bytes;
        end
    end
end
end

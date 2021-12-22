classdef IArchive < handle
    % dao.IArchive represents a generic archive object to be implemented
    
    methods (Abstract)
        % Lists all files in the archive
        list = listFiles(this)
        
        % Gets the number of files in the archive
        n = getCount(this)
        
        % Adds or replaces a file in the archive
        putFile(this, filePaths)
        
        % Extracts all the content of the archive
        % outPath = extract(this)
        %   extracts into a temporary folder.
        %   returns the full path of the temporary folder
        % 
        % extract(this, outPath)
        %   extracts into a the specified path.
        %   
        outPath = extractAll(this, outPath)
        
        % Extracts a single file out of the archive
        %
        % outputName = extractFile(this, fileName)
        %   extracts the specified file out of the archive into a
        %   temporary file path.
        %   returns the full path of the extracted temporary file.
        % 
        % outputName = extractFile(this, fileName, outPath)
        %   extracts the specified file out of the archive into a
        %   the desired path.
        %   returns the full path of the extracted file.
        %
        % Input:
        % fileName - The name of the file to extract from the archive
        % outPath  - The path to extract the file to
        %
        % Output:
        % outPath  - The full path to which the file was extracted
        %
        outPath = extractFile(this, name, outPath)
    end
end


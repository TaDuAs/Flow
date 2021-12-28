classdef ZipArchive < dao.IArchive
    % dao.ZipArchive allows access to single files inside a zip archive and
    % manages temporary archive as needed
    % 
    % Class written by TADA, 2021
    % extraction of single file without extraction of the whole archive was 
    % written using Mathworks core code by "tmthydvnprt".
    % This functionality was taken from stack exchange:
    % https://stackoverflow.com/questions/37591790/how-to-extract-a-single-file-from-a-zip-archive-in-matlab
    % with minor changes by TADA
    %
    
    properties (GetAccess=public, SetAccess=private)
        % the full path of the zip archive file
        ArchivePath {gen.valid.mustBeTextualScalar(ArchivePath)} = '';
        
        % full path of the temp dir to unzip the archive into in case the
        % undocumented code fails
        TempDirPath {gen.valid.mustBeTextualScalar(TempDirPath)} = '';
        
        % Flag property
        ArchiveUnzipped (1,1) logical = false;
        
        % Fallback to documented functionality is required
        MustUseDocumentedExtraction (1,1) logical = false;
    end
    
    properties (Dependent)
        UseExtractedArchive (1,1) logical;
    end
    
    methods % dependent props
        function tf = get.UseExtractedArchive(this)
            tf = this.MustUseDocumentedExtraction || this.ArchiveUnzipped;
        end
    end
    
    methods
        function this = ZipArchive(archivepath, tempDirPath)
            this.ArchivePath = archivepath;
            [path, dirName] = fileparts(archivepath);
            
            if nargin >= 2
                path = tempDirPath;
            end
            
            tempDirName = [dirName, '_', gen.guid()];
            this.TempDirPath = fullfile(path, tempDirName);
        end
        
        function delete(this)
            % remove temporary files
            if exist(this.TempDirPath, 'dir')
                rmdir(this.TempDirPath, 's');
            end
        end
        
        function list = listFiles(this)
            % list the file entries in the archive
            
            if this.UseExtractedArchive
                % count file entries in the extracted archive
                list = this.listFilesInArchiveExtractAll();
            else
                % count file entries in the zip archive
                list = this.listFilesInArchiveWithJava();
            end
        end
        
        function n = getCount(this)
            % counts the number of file entries in the archive
            
            if this.UseExtractedArchive
                % count file entries in the extracted archive
                n = this.countFilesInArchiveExtractAll();
            else
                % count file entries in the zip archive
                n = this.countFilesInArchiveWithJava();
            end
        end
        
        function putFile(this, files)
            % adds or replaces a list of files in the zip archive.
            
            % ATM - extraction is mandatory before adding files to the
            % archive, addition of single file to the archive is not yet
            % implemented unfortunately.
            this.MustUseDocumentedExtraction = true;
            
            if this.UseExtractedArchive
                this.extractAllArchiveAndPutFiles(files);
            else
                try
                    % try to compress single file using undocumented
                    % functionality
                    this.compressFilesOneByOne(files);
                catch ex
                    % if the error is a managed error, rethrow
                    if startsWith(ex.identifier, 'Flow:dao:ZipArchive:Managed')
                        ex.rethrow();
                    end

                    % else fallback to documented functionality, unzip 
                    % everything in the archive.

                    % raise warning regarding fallback.
                    this.raiseFallbackToDocumentedBehaviorWarning(ex);

                    % fallback to documented functionality is required in
                    % the next extractions as well
                    this.MustUseDocumentedExtraction = true;
                     
                    % add the file to archive
                    this.putFile(files);
                end
            end
            
        end
        
        function outPath = extractAll(this, outPath)
            % extracts the entire archive and returns the output folder
            % path.
            % 
            % outPath = extract(this)
            %   extracts into a temporary folder which is deleted once the
            %   archive object is deleted.
            %   returns the full path of the temporary folder
            % 
            % extract(this, outPath)
            %   extracts into a the specified path.
            %   
            
            if nargin < 2
                outPath = this.TempDirPath;
                this.ensureArchiveTempExtraction();
            else
                if exist(this.ArchivePath, 'file')
                    unzip(this.ArchivePath, outPath);
                end
            end
        end
        
        function outputName = extractFile(this, fileName, outPath)
            % extracts a sinle file out of a zip archive.
            % 
            % outputName = extractFile(this, fileName)
            %   extracts the specified file out of the archive into a
            %   temporary file path. The temporary files are deleted once
            %   the archive object is destroyed.
            %   returns the full path of the extracted temporary file.
            % 
            % outputName = extractFile(this, fileName, outPath)
            %   extracts the specified file out of the archive into a
            %   the desired path.
            %   returns the full path of the extracted file.
            %
            
            % prepare extraction site
            if nargin < 3
                outPath = this.TempDirPath;
                useOnlyTempFile = true;
            else
                useOnlyTempFile = false;
                gen.valid.mustBeTextualScalar(outPath);
                if iscellstr(outPath) || isstring(outPath)
                    outPath = char(outPath);
                end
                
                % if the outpath was specified as an empty string, use 
                % matlabs current working foledr
                if isempty(outPath)
                    outPath = pwd();
                end
            end
            
            % check if undocumented single file extraction already failed
            if this.UseExtractedArchive
                % if undocumented functionality already failed, skip to
                % fallback functionality and extract the full archive to 
                % retrive the file
                outputName = this.extractWholeArchiveAndReturnFile(fileName, outPath, useOnlyTempFile);
            else
                try
                    % try to extract single file using undocumented
                    % functionality
                    outputName = this.extractSingleFile(fileName, outPath);
                catch ex
                    % if the error is a managed error, rethrow
                    if startsWith(ex.identifier, 'Flow:dao:ZipArchive:Managed')
                        ex.rethrow();
                    end

                    % else fallback to documented functionality, unzip 
                    % everything in the archive.

                    % raise warning regarding fallback.
                    this.raiseFallbackToDocumentedBehaviorWarning(ex);

                    % fallback to documented functionality is required in
                    % the next extractions as well
                    this.MustUseDocumentedExtraction = true;
                     
                    % extract the file
                    outputName = this.extractWholeArchiveAndReturnFile(fileName, outPath, useOnlyTempFile);
                end
            end
        end
    end
    
    methods (Access=private)
        function raiseFallbackToDocumentedBehaviorWarning(this, ex)
            warning('Flow:dao:ZipArchive:FallbackToDocumentedFunctionality',...
                ['Extraction or compression of singe file from zip archive failed. ',...
                 'Falling back to documented unzipping of full archive.', ...
                 newline, newline, getReport(ex, 'extended', 'hyperlinks', 'on')]);
        end
        
        function ensureArchiveTempExtraction(this)
            % only extract once... not every time a file is extracted
            if this.ArchiveUnzipped
                return;
            end
            
            % extract the archive
            this.extractArchiveToTempFolder();
        end
        
        function extractArchiveToTempFolder(this)
            % create the temporary folder
            this.ensureTempDir();
            
            if exist(this.ArchivePath, 'file')
                % unzip the full archive into the temporary folder
                unzip(this.ArchivePath, this.TempDirPath);
            end
            
            % mark archive extracted
            this.ArchiveUnzipped = true;
        end
        
        function ensureTempDir(this)
            % makes sure the temporary folder exists
            if ~exist(this.TempDirPath, 'dir')
                mkdir(this.TempDirPath);
            end
        end
        
        function outputName = extractSingleFile(this, fileName, outPath)
            % extracts a single file from a zip archive
            %
            % Most of the code was taken from Mathworks unzip and 
            % extractArchive functions and recomposed to this function by 
            % tmthydvnprt. Taken from:
            % https://stackoverflow.com/questions/37591790/how-to-extract-a-single-file-from-a-zip-archive-in-matlab
            %
            
            % Obtain the entry's output names
            outputName = fullfile(outPath, fileName);
            zipArchivePath = this.ArchivePath;

            % Create a stream copier to copy files.
            streamCopier = ...
                com.mathworks.mlwidgets.io.InterruptibleStreamCopier.getInterruptibleStreamCopier;

            % Create a Java zipFile object and obtain the entries.
            try
                % Create a Java file of the Zip filename.
                zipJavaFile = java.io.File(zipArchivePath);

                % Create a java ZipFile and validate it.
                zipFile = org.apache.tools.zip.ZipFile(zipJavaFile);

                % Get entry
                entry = zipFile.getEntry(fileName);

            catch exception
                if ~isempty(zipFile)
                    zipFile.close;
                end
                ex = MException('Flow:dao:ZipArchive:Intenrnal:InvalidZipFile', 'Invalid ZIP file %s', zipArchivePath);
                ex = ex.addCause(exception);
                throw(ex);
            end

            % Create the Java File output object using the entry's name.
            file = java.io.File(outputName);

            % If the parent directory of the entry name does not exist, then create it.
            parentDir = char(file.getParent.toString);
            if ~exist(parentDir, 'dir')
                mkdir(parentDir)
            end

            % Create an output stream
            try
                fileOutputStream = java.io.FileOutputStream(file);
            catch exception
                overwriteExistingFile = file.isFile && ~file.canWrite;
                if overwriteExistingFile
                    ex = MException('Flow:dao:ZipArchive:Managed:UnableToOverwrite',...
                        'Unable to overwrite file %s', outputName);
                else
                    ex = MException('Flow:dao:ZipArchive:Managed:UnableToCreate', ...
                        'Unable to create file %s', outputName);
                end
                ex = ex.addCause(exception);
                throw(ex);
            end

            % Create an input stream from the API
            fileInputStream = zipFile.getInputStream(entry);

            % Extract the entry via the output stream.
            streamCopier.copyStream(fileInputStream, fileOutputStream);

            % Close all streams
            fileOutputStream.close();
            fileInputStream.close();
            zipFile.close();
        end
        
        function outputName = extractWholeArchiveAndReturnFile(this, fileName, outPath, useOnlyTempFile)
            % extracts the whole archive using documented functionality
            % into the temporary folder, and returns the path of the
            % extracted file.
            % 
            % if useOnlyTempFile is true, then the temp file from the
            % temporary extracted archive is returned, otherwise, the temp
            % file is copied to the permanent location, and this path is
            % returned. If an output location is specified the extracted
            % file will not be deleted when the archive is deleted.
            %
            
            % make sure the archive was extracted
            this.ensureArchiveTempExtraction();
            
            % the temporary file is in this path
            tempfilePath = fullfile(this.TempDirPath, fileName);
            
            % make sure temp file exists
            if ~exist(tempfilePath, 'file')
                throw(MException('Flow:dao:ZipArchive:Managed:FileMissing',...
                    'The requested file %s was not found in the archive %s', fileName, this.ArchivePath));
            end
            
            if useOnlyTempFile
                % return temporary file path
                outputName = tempfilePath;
            else
                % copy the temp file to desired location and return that
                % path
                outputName = fullfile(outPath, fileName);
                copyfile(tempfilePath, outputName);
            end
        end
        
        function extractAllArchiveAndPutFiles(this, files)
            gen.valid.mustBeTextual(files);
            files = cellstr(files);
            
            % ensure the archive was extracted
            this.ensureArchiveTempExtraction();
            
            % copy all desired files into the temporary archive folder
            for i = 1:numel(files)
                currPath = files{i};
                
                % ignore files that are already in the archive temp folder
                if startsWith(currPath, this.TempDirPath)
                    continue;
                end
                
                % copy file into the archive temp folder
                copyfile(currPath, this.TempDirPath, 'f');
            end
            
            % get the full paths of all subfolders and files in the
            % temporary archive folder
            [~, ~, tempSubdirNames] = gen.dirfolds(this.TempDirPath);
            [~, ~, tempFileNames] = gen.dirfiles(this.TempDirPath);
            
            % compress the contents of the temporary archive folder
            zip(this.ArchivePath, [tempSubdirNames, tempFileNames]);
        end
        
        function n = countFilesInArchiveExtractAll(this)
            % ensure the archive was extracted
            this.ensureArchiveTempExtraction();

            entries = gen.dirfiles(this.TempDirPath, '**');
            n = numel(entries);
        end
        
        function n = countFilesInArchiveWithJava(this)
            zipArchivePath = this.ArchivePath;
            n = 0;
            
            % Create a Java zipFile object and obtain the entries.
            try
                % Create a Java file of the Zip filename.
                zipJavaFile = java.io.File(zipArchivePath);

                % Create a java ZipFile and validate it.
                zipFile = org.apache.tools.zip.ZipFile(zipJavaFile);
                
                % list entries in archive
                entries = zipFile.getEntries();

                % count all entries in the archive which are actual files
                while (entries.hasMoreElements())
                    currEntry = entries.nextElement();
                    if (~currEntry.isDirectory())
                        n = n + 1;
                    end
                end
                
                zipFile.close;
            catch exception
                if ~isempty(zipFile)
                    zipFile.close;
                end
                ex = MException('Flow:dao:ZipArchive:Intenrnal:InvalidZipFile', 'Invalid ZIP file %s', zipArchivePath);
                ex = ex.addCause(exception);
                throw(ex);
            end
        end
        
        function list = listFilesInArchiveExtractAll(this)
            % ensure the archive was extracted
            this.ensureArchiveTempExtraction();

            [~, list] = gen.dirfiles(this.TempDirPath, '**');
        end
        
        function list = listFilesInArchiveWithJava(this)
            zipArchivePath = this.ArchivePath;
            list = cell(1, 20);
            n = 0;
            
            % Create a Java zipFile object and obtain the entries.
            try
                % Create a Java file of the Zip filename.
                zipJavaFile = java.io.File(zipArchivePath);

                % Create a java ZipFile and validate it.
                zipFile = org.apache.tools.zip.ZipFile(zipJavaFile);
                
                % list entries in archive
                entries = zipFile.getEntries();

                % count all entries in the archive which are actual files
                while (entries.hasMoreElements())
                    currEntry = entries.nextElement();
                    if (~currEntry.isDirectory())
                        n = n+1;
                        list{n} = char(currEntry.getName());
                    end
                end
                
                zipFile.close;
            catch exception
                if ~isempty(zipFile)
                    zipFile.close;
                end
                ex = MException('Flow:dao:ZipArchive:Intenrnal:InvalidZipFile', 'Invalid ZIP file %s', zipArchivePath);
                ex = ex.addCause(exception);
                throw(ex);
            end
            
            list = list(1:n);
        end
        
        function compressFilesOneByOne(this, files)
%             % Open output stream.
%             try
%                zipFile = java.io.File(this.ArchivePath);
%                fileOutputStream = java.io.FileOutputStream(zipFile);
%                cln = onCleanup(@fileOutputStream.close);
%                zipOutputStream = org.apache.tools.zip.ZipOutputStream(fileOutputStream);
%                zipOutputStream.setEncoding('UTF-8');
%             catch ex
%                err = MException('Flow:dao:ZipArchive:Managed:OpenWriteError', ...
%                    'Could not open %s for writing.', this.ArchivePath);
%                err.addCause(ex);
%                throw(err);
%             end
%    
%             % create the archive
%             try
%                 archive = createArchive(zipFilename, files, rootDir, ...
%                     @createArchiveEntry, zipOutputStream, mfilename);
%             catch exception
%                fileOutputStream.close;
%                zipFile.delete;
%                throw(exception);
%             end
        end
    end
end


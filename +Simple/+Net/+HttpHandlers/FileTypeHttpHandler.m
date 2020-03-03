classdef (Abstract) FileTypeHttpHandler < Simple.Net.HttpHandlers.HttpHandler
    
    methods
        function ismatch = matches(this, request, app)
            ismatch = any(regexpi(request.Filename, ['(?:[\w\.\-]*\/?)+\.(?:' strjoin(this.supportedFileTypes(), '|') ')']));
        end
        
        function handleRequest(this, request, app)
            file.path = this.getFullFilePath(request, app);
            file.extension = file.path(find(file.path=='.',1,'last')+1:end);
            
            if ~exist(file.path, 'file')
                Simple.Net.HttpServer.RaiseFileNotFoundError(request);
            end
            
            % read file
            fileContent = [];
            modTime = 0;
            if this.shouldReadFile(request, app)
                [fileContent, modTime] = this.readFile(request, app, file.path);
            end
            file.content = fileContent;
            file.lastModified = modTime;
            
            this.doHandleRequest(request, app, file);
        end
        
    end
    
    methods (Abstract, Access=protected)
        ext = supportedFileTypes(this)
        bool = shouldReadFile(this, request, app)
        doHandleRequest(this, request, app, file)
    end
    
    methods (Access=protected)
        
        function bool = shouldReadAsTextFile(this, request, app)
            bool = false;
        end
        
        function filePath = getFullFilePath(this, request, app)
            % handle default file
            filePath = request.Filename;
            if(strcmp(filePath, '/'))
                filePath = config.defaultfile;
            end
            
            % get full file path
            filePath = [this.server.config.rootPath filePath];
        end
        
        function [content, modTime] = readFile(this, request, app, filePath)
            
            % Try to open file
            fid = fopen(filePath);
            if fid == -1
                Simple.Net.HttpServer.RaiseFileNotFoundError(request);
            end

            try
                if nargout >= 2
                    % Check file modification time
                    fileInfo = dir(filePath);
                    modTime = fileInfo.datenum;
                end

                % Read file content
                if this.shouldReadAsTextFile(request, app)
                    content = fread(fid, '*char')';
                else
                    content = fread(fid, inf, 'int8')';
                end
                
                fclose(fid);
            catch ex
                if ~isempty(fid) && fid ~= -1
                    try
                        fclose(fid);
                    catch
                    end
                end

                Simple.Net.HttpServer.RaiseFileNotFoundError(request);
            end
        end
    end
end


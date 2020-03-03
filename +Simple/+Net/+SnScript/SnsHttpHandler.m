classdef SnsHttpHandler < Simple.Net.HttpHandlers.FileTypeHttpHandler
    properties (Access=protected)
       runTerminationScript;
    end
    
    methods
        function this = SnsHttpHandler()
            this@Simple.Net.HttpHandlers.FileTypeHttpHandler();
            this.runTerminationScript = false;
        end
    end
    
    methods(Access=protected)
        
        function bool = shouldReadAsTextFile(this, request, app)
            bool = true;
        end
        
        function ext = supportedFileTypes(this)
            ext = {'sns'};
        end
        
        function bool = shouldReadFile(this, request, app)
            bool = false;
        end
        
        function doHandleRequest(this, request, app, file)
            response = request.Response;
            response.ContentType='text/html';
            
            % Prepare the script file
            functionName = this.doPrepareSnScript(request, app, file);
            
            % evaluate the script - get function handle and save it for
            % later.
            feval(functionName, Simple.Net.SnScript.SnScript(request, app));            
        end
        
        function functionName = doPrepareSnScript(this, request, app, file)
            functionName = regexprep(regexprep(request.Filename, '[\/\\\.\-]', '_'), '(^\_+)|(\_+$)', '');
            slashIndex = regexp(file.path, '[\/\\]');
            mfilePath = [file.path(1:slashIndex(end)) functionName '.m'];
            
            % Inspect both .sns and sns.m files to determine if should
            % re-parse the .sns file
            snsFileInfo = dir(file.path);
            if isempty(snsFileInfo)
                Simple.Net.HttpServer.RaiseFileNotFoundError();
            else
                snsFileModTime = snsFileInfo.datenum;
            end
            
            mFileInfo = dir(mfilePath);
            mFileModTime = 0;
            if ~isempty(mFileInfo)
                mFileModTime = mFileInfo.datenum;
            end
            
            % parse sns file
            if snsFileModTime > mFileModTime
                this.parseSnsFile(request, app, file.path, functionName, mfilePath);
            end
        end
        
        function parseSnsFile(this, request, app, snsFilePath, functionName, mfilePath)
            
            snsFileContent = this.readFile(request, app, snsFilePath);
            
            % Find all embedded scripts
            snsPattern = '<%[?$]?(?<script>((%+[\s\w])*[\?!&`#@\|$\s\w\d\-\=\+\)\(\*\^\$\~\;\:\]\[\{\}\<\>\.\,\\\/]*(\''([^'']*(\''\'')*)*\'')*)*)%>';
            [si, ei] = regexp(snsFileContent, snsPattern);
            
            % count the number of lines in the file.
            nLines = sum(snsFileContent==newline);
            
            % each script block and each html line will be represented by a
            % single cell in the cell array.
            % If a line of html contains a script block it will be split
            % into multiple script blocks in the cell array.
            % Lets look at a block of HTML+SnScript:
            %
            % <div>
            % <h1>Random:</h1>
            % <% sns.include('someOtherPage.html'); %>
            % <span>The quick <% sns.write(choose ramdom color) %> fox jumps over the lazy dog</span>
            % </div>
            %
            % The above block will be split into several script blocks in
            % the cell array as follows:
            % {...
            %   'sns.write(''<div>'');',...
            %   'sns.write(''<h1>Random:</h1>'');',...
            %   'sns.include(''someOtherPage.html'');',...
            %   'sns.write(''<span>The quick '');', ...
            %   'sns.write(choose ramdom color);',...
            %   'sns.write('' fox jumps over the lazy dog</span>'');',...
            %   'sns.write(''</div>'');'
            % }
            % The script block cell array is preallocated to have as many
            % cells as lines in the script file + 2*the number of script
            % blocks+5*opening lines to atone for closing lines which we
            % need to prepare at the end of this function because that
            % termination script depends on the generated script.
            % Its better to have a bit more cells preallocated than to
            % allocate more and more cells.
            functionDeclerationScriptBlock = this.prepareFunctionDecleration(functionName);
            scriptBlocks = cell(1, nLines+2*length(si)+5*length(functionDeclerationScriptBlock));
            scriptBlocks(1:end) = {''};
            scriptBlocks(1:length(functionDeclerationScriptBlock)) = functionDeclerationScriptBlock;
            
            % declare anonymous function
            functionDeclerationScriptBlocks = this.prepareFunctionDecleration(functionName);
            scriptBlocks(1:length(functionDeclerationScriptBlocks)) = functionDeclerationScriptBlocks;
            htmlBlockStartIndex = 1;
            scriptBlockIndex = length(functionDeclerationScriptBlocks);
            for i = 1:length(si)
                % Get preceding html block and add a script for writing each line if html into script blocks
                htmlBlock = snsFileContent(htmlBlockStartIndex:si(i)-1);
                htmlScriptBlocks = generateHtmlRegistrationScript(this, htmlBlock);
                scriptBlocks(scriptBlockIndex+1:scriptBlockIndex+length(htmlScriptBlocks)) = htmlScriptBlocks;
                
                % get current script block (ommit the <% %>)
                scriptBlockIndex = scriptBlockIndex + length(htmlScriptBlocks) + 1;
                if snsFileContent(si(i)+2) == '$'
                    % literal script block - used to transfer script blocks
                    % between sns pages (such as masterpage->content)
                    scriptBlocks{scriptBlockIndex} = ['sns.write(''' snsFileContent(si(i):ei(i)) ''');'];
                elseif snsFileContent(si(i)+2) == '?'
                    % unique script blocks, handle special scripts
                    uniqueScriptBlock = this.handleUniqueScriptBlock(snsFileContent(si(i):ei(i)));
                    scriptBlocks{scriptBlockIndex} = uniqueScriptBlock;
                else
                    scriptBlocks{scriptBlockIndex} = snsFileContent(si(i)+2:ei(i)-2);
                end
                
                % next html block starts here
                htmlBlockStartIndex = ei(i) + 1;
            end
            
            htmlBlock = snsFileContent(htmlBlockStartIndex:end);
            htmlScriptBlocks = generateHtmlRegistrationScript(this, htmlBlock);
            scriptBlocks(scriptBlockIndex+1:scriptBlockIndex+length(htmlScriptBlocks)) = htmlScriptBlocks;
            
            % close function
            functionCloseScriptBlock = this.prepareFunctionClose();
            scriptBlockIndex = scriptBlockIndex + length(htmlScriptBlocks);
            scriptBlocks(scriptBlockIndex+1:scriptBlockIndex+length(functionCloseScriptBlock)) = functionCloseScriptBlock;
            
            % generate the final script
            snScript = strjoin(scriptBlocks, newline);
            
            % write function to .m file
            fid = fopen(mfilePath, 'w');
            fwrite(fid, snScript);
            fclose(fid);
            
            % clear function implementation
            clear(functionName);
        end
        
        function scriptBlock = prepareFunctionClose(this)
            if this.runTerminationScript
                scriptBlock = {'sns.done();' 'end'};
            else
                scriptBlock = {'end'};
            end
        end
        
        function scriptBlock = prepareFunctionDecleration(this, functionName)
            scriptBlock = {['function ' functionName '(sns)' newline 'import Simple.*;' newline 'import Simple.Math.*;' newline ]};
        end
        
        function out = handleUniqueScriptBlock(this, scriptBlock)
            % Master Page decleration tag
            if any(regexp(scriptBlock, '^<%\?\s*MasterPage\s+[\w\.\/\\]+\s*%>$'))
                % this regex extract url
                tokens = regexp(scriptBlock, '^<%\?\s*MasterPage\s+(?<url>\/([\w\-]+\/)*[\w\-\.]+\.snmp)\s*%>$', 'names');
                if ~isempty(tokens) && isfield(tokens, 'url') && ~isempty(tokens.url)
                    out = ['sns = Simple.Net.SnScript.MasterPageSnScript(sns, ''' tokens.url ''');'];
                    this.runTerminationScript = true;
                else
                    ex = MException('SNS:MasterPage:InvalidUrl', 'Specified Url must be of a valid master page file (snmp)');
                    throw(ex);
                end
            % Content Start decleration tag
            elseif any(regexp(scriptBlock, '<%\?\s*Content\s+\w+\s*%>'))
                % this regex extracts the content holders name
                tokens = regexp(scriptBlock, '^<%\?\s*Content\s+(?<tag>\w+)\s*%>$', 'names');
                if ~isempty(tokens) && isfield(tokens, 'tag') && ~isempty(tokens.tag)
                    out = ['sns.startContent(''' tokens.tag ''');'];
                else
                    ex = MException('SNS:MasterPage:Content:TagNameMissing', 'Must specify name of content tag');
                    throw(ex);
                end
            % Content end decleration tag
            elseif any(regexp(scriptBlock, '<%\?\s*\/Content\s*%>'))
                out = 'sns.endContent();';
            else
                out = '';
            end
        end
        
        function htmlScriptBlocks = generateHtmlRegistrationScript(this, htmlBlock)
            % split to lines of html
            htmlBlockLines = regexp(htmlBlock, '(\r?\n)+', 'split');
            htmlScriptBlocks = cell(1,length(htmlBlockLines)); 
            actualScriptBlocksCreated = 0;
            nHtmlBlockLines = length(htmlBlockLines);
            
            for lineIdx = 1:nHtmlBlockLines
                % generate script for writing pending html line to
                % response.
                % escape the tags in char arrays
                currHtmlLine = strrep(htmlBlockLines{lineIdx}, '''', '''''');
                if ~isempty(strtrim(currHtmlLine))
                    actualScriptBlocksCreated = actualScriptBlocksCreated + 1;
                    htmlScriptBlocks{actualScriptBlocksCreated} = ['sns.write([''' currHtmlLine '''' Simple.cond(lineIdx < nHtmlBlockLines, ' newline', '') ']);'];
                end
            end
            
            htmlScriptBlocks = htmlScriptBlocks(1:actualScriptBlocksCreated);
        end
    end
end


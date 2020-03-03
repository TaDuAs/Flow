classdef MasterPageSnScript < Simple.Net.SnScript.SnScript
    %MASTERPAGESNSCRIPT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=private)
        sns;
        contentBlocks;
        masterPageContnetTagIndices;
        masterPageContentBlocks;
        currentContentTag;
    end
    
    methods
        
        function this = MasterPageSnScript(sns, url)
            this@Simple.Net.SnScript.SnScript(sns.request, sns.app);
            this.sns = sns;
            this.contentBlocks = {};
            this.masterPageContnetTagIndices = containers.Map;
            this.masterPageContentBlocks = containers.Map;
            this.currentContentTag = '';
            
            if ~any(regexpi(url, '[\/\\\w\d\.]\.snmp$'))
                ex = MException('SNS:MasterPage:InvalidUrl', 'Specified Url must be of a valid master page file (snmp)');
                throw(ex);
            end
            
            if ~isempty(this.response.Content)
                ex = MException('SNS:MasterPage:Decleration', 'Master page decleration must be located at the top of the page');
                throw(ex);
            end
            
            % get master page function
            mpFunctionName = this.get(url);

            % execute mp function
            feval(mpFunctionName, this);
        end
        
        function contentHolder(this, name)
            if this.masterPageContnetTagIndices.isKey(name)
                ex = MException('SNS:MasterPage:Content:NameExists', 'Content tag name already exists');
                throw(ex);
            end
            index = this.write(['%$ content:' name ' $%']);
            this.masterPageContnetTagIndices(name) = index;
            this.masterPageContentBlocks(name) = {};
        end
        
        function startContent(this, name)
            if ~this.masterPageContentBlocks.isKey(name)
                ex = MException('SNS:MasterPage:Content:NameMismatch', 'Content tag name doesn''t match any content tags');
                throw(ex);
            end
            
            if ~isempty(this.masterPageContentBlocks(name))
                ex = MException('SNS:MasterPage:Content:AlreadyAssigned', 'Trying to fill master page content more than once');
                throw(ex);
            end
            
            this.currentContentTag = name;
            
        end
        
        function endContent(this)
            this.currentContentTag = '';
        end
        
        function index = write(this, data)
            if ~isempty(this.currentContentTag)
                mpContentBlocks = [this.masterPageContentBlocks(this.currentContentTag) {data}];
                this.masterPageContentBlocks(this.currentContentTag) = mpContentBlocks;
                index = length(mpContentBlocks);
            else
                this.contentBlocks = [this.contentBlocks {data}];
                index = length(this.contentBlocks);
            end
        end
        
        function done(this)
            cb = this.contentBlocks;
  
            tags = this.masterPageContnetTagIndices.keys;
            for i = length(tags):-1:1
                currTag = tags{i};
                currTagIndex = this.masterPageContnetTagIndices(currTag);
                
                if this.masterPageContentBlocks.isKey(currTag)
                    cb = [cb(1:currTagIndex-1) this.masterPageContentBlocks(currTag) cb(currTagIndex+1:end)];
                else
                    % Probably need to register this somehow to someone
                    % elese
                end
            end
            
            this.sns.write(cb);
        end
    end
    
end


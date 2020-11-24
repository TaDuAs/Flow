classdef GuiApp < mvvm.App
    properties
        RootPath char;
        ResourcePath char;
        Preferences = struct();
    end
    
    methods
        function this = GuiApp(iocContainer, varargin)
            if nargin < 1 || isempty(iocContainer); iocContainer = IoC.Container.empty(); end
            
            this@mvvm.App(iocContainer, varargin{:});
            
            % update log path relative location
            if any(regexp(this.LogPath, '^[\\\/]'))
                this.LogPath = fullfile(this.RootPath, this.LogPath(2:end));
            end
        end
        
        function clear(this)
            this.savePreferences();
            clear@mvvm.App(this);
        end
    end
    
    methods (Access=protected)
        function initConfig(this)
            initConfig@mvvm.App(this);
            
            this.IocContainer.setSingleton("BindingManager", @mvvm.BindingManager.instance);
            this.IocContainer.setPerSession("ViewManager", @mvvm.view.ViewManager, 'App', '$ViewManager');
            this.IocContainer.set("PreferencesProvider", @mvvm.providers.PreferencesProvider, 'App');
        end
        
        function postConfigSetup(this)
            postConfigSetup@mvvm.App(this);
            
            this.loadPreferences(); 
        end
        
        function loadPreferences(this)
            if this.IocContainer.hasDependency('mxml.XmlSerializer')
                prefSerializer = this.IocContainer.get('mxml.XmlSerializer');
            else
                prefSerializer = mxml.XmlSerializer();
            end
            prefPath = fullfile(this.ResourcePath, 'preferences.xml');
            if exist(prefPath, 'file')
                this.Preferences = prefSerializer.load(prefPath);
            end
        end
        
        function savePreferences(this)
            if this.IocContainer.hasDependency('mxml.XmlSerializer')
                prefSerializer = this.IocContainer.get('mxml.XmlSerializer');
            else
                prefSerializer = mxml.XmlSerializer();
            end
            
            prefPath = fullfile(this.ResourcePath, 'preferences.xml');
            
            try
                prefSerializer.save(this.Preferences, prefPath);
            catch ex
                disp(getReport(ex));
            end
        end
        
        function prepareParser(this, parser)
            prepareParser@mvvm.App(this, parser);
            
            % define parameters
            addParameter(parser, 'RootPath', fileparts(which(class(this))),...
                @(x) assert((ischar(x) && isrow(x)) || isStringScalar(x), 'Root path must be a character vector or a string'));
            
            addParameter(parser, 'ResourcePath', '/',...
                @(x) assert((ischar(x) && isrow(x)) || isStringScalar(x), 'ResourcePath path must be a character vector or a string'));
        end
        
        function extractParserParameters(this, parser)
            extractParserParameters@mvvm.App(this, parser);
            
            % root path, by default the path of the app class
            if ~exist(parser.Results.RootPath, 'dir')
                throw(MException('mvvm:GuiApp:InvalidPath', 'RootPath must be a valid directory in local file system'));
            end
            this.RootPath = regexprep(parser.Results.RootPath, '[\\\/]', filesep());
            
            % resource path, preferably a relative path from root path
            if any(regexp(parser.Results.ResourcePath, '^[\\\/]'))
                resPath = fullfile(this.RootPath, parser.Results.ResourcePath(2:end));
            elseif exist(parser.Results.ResourcePath, 'dir')
                resPath = parser.Results.ResourcePath;
            else
                throw(MException('mvvm:GuiApp:InvalidPath', 'ResourcePath must be a valid directory in local file system. If RootPath starts with \ or /, it is concidered a relative path starting from RootPath'));
            end
            this.ResourcePath = regexprep(resPath, '[\\\/]', filesep());
        end
    end
    
    methods (Access=private)
    end
end


classdef AppManager < handle
    %APPMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Static)
        
        function container = getContainer(this)
            persistent appContianer;
            if isempty(appContianer)
                appContianer = gen.Cache();
            end
            
            container = appContianer;
        end
        
        function set(id, app)
            id = string(id);
            container = appd.AppManager.getContainer();
            
            % check if id already exists
            if container.hasEntry(id) && ~isempty(container.get(id))
                prev = appd.AppManager.get(id);
                
                % if the new app is the old app, don't do anything
                % this should also prevent problems with self app
                % registration and stuff
                if prev == app
                    return;
                end
                
                % terminate previous app
                prev.kill();
            end
            
            % register new app
            container.set(id, appd.ManagedAppContext(app));
            
            % start new app
            app.start();
        end
        
        function app = get(id)
            container = appd.AppManager.getContainer();
            context = container.get(id);
            app = context.App;
        end
        
        function app = load(id, ctor)
            id = string(id);
            container = appd.AppManager.getContainer();
            
            % if id exists
            if container.hasEntry(id) && ~isempty(container.get(id))
                app = appd.AppManager.get(id);
                
                newApp = ctor();
                if ~strcmp(class(app), class(newApp))
                    % if the registered app is not the same as the 
                    % specified ctor, terminate the old and set the new
                    % 
                    % p.s, ctor is any function handle, could even be an
                    % anonymous function so comparing registered app class 
                    % to the ctor name isn't relevant, thats why we must
                    % instantiate.
                    % best practive is to use the actual app class ctor
                    % for loading an app
                    appd.AppManager.removeApp(app, id);
                    appd.AppManager.set(id, newApp);
                    app = newApp;
                elseif app.Status ~= appd.AppStatus.Loaded
                    % if the registered application is already running,
                    % reset it
                    app.restart();
                end
            else
                % if id doesn't exist, create new app and start it
                app = ctor();
                appd.AppManager.set(id, app);
            end
        end
        
        function remove(id)
            id = string(id);
            container = appd.AppManager.getContainer();
            
            % if id exists
            if container.hasEntry(id) && ~isempty(container.get(id))
                app = appd.AppManager.get(id);
                
                % remove the app
                container.removeEntry(id);
                
                % kill the app
                app.kill();
            end
        end
        
        function removeApp(app, id)
            if nargin < 2; id = app.Id; end
            container = appd.AppManager.getContainer();
            
            % if id exists
            if container.hasEntry(id) && ~isempty(container.get(id))
                registered = appd.AppManager.get(id);
                
                % and the registered app is the one we want to remove,
                % remove it
                if registered == app
                    appd.AppManager.remove(id)
                end
            end
        end
        
        function clear()
            % remove and terminate all apps
            for id = appd.AppManager.getContainer.allKeys
                appd.AppManager.remove(id);
            end
        end
        
        function apps = list()
            container = appd.AppManager.getContainer();
            c = [matlab.lang.makeValidName(container.allKeys()); cellfun(@(mac) mac.App, container.allValues(), 'UniformOutput', false)];
            apps = struct(c{:});
        end
    end
end


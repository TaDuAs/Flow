classdef ManagedAppContext < handle
    properties
        App mvvm.IApp = mvvm.App.empty();
        KillAppListener event.listener;
    end
    
    methods
        function this = ManagedAppContext(app)
            this.App = app;
            this.KillAppListener = addlistener(app, 'ObjectBeingDestroyed', @this.onKillApp);
        end
        
        function onKillApp(this, ~, ~)
            mvvm.AppManager.removeApp(this.App);
            delete(this.KillAppListener);
            this.App = mvvm.App.empty();
        end
    end
end


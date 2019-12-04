classdef ManagedAppContext < handle
    properties
        App appd.IApp = appd.App.empty();
        KillAppListener event.listener;
    end
    
    methods
        function this = ManagedAppContext(app)
            this.App = app;
            this.KillAppListener = addlistener(app, 'ObjectBeingDestroyed', @this.onKillApp);
        end
        
        function onKillApp(this, ~, ~)
            appd.AppManager.removeApp(this.App);
            delete(this.KillAppListener);
            this.App = appd.App.empty();
        end
    end
end


classdef MainAppView < mvvm.view.Window & mvvm.SessionOwner
    %MASTERVIEW Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function this = MainAppView(app, varargin)
            % app registration
            this@mvvm.SessionOwner();
            
            % view stuff
            this@mvvm.view.Window('App', app, varargin{:});
        end
        
        function delete(this)
            delete(this.App);
        end
    end
    
    methods (Access=protected)
        function init(this)
            init@mvvm.view.Window(this);
            
            % session registration
            [~, session] = this.App.startSession();
            init@mvvm.SessionOwner(this, session);
        end
    end
end
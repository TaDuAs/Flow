classdef MainSessionView < mvvm.view.View & mvvm.SessionOwner
    methods
        function this = MainSessionView(session, varargin)
            if nargin < 1; session = appd.AppSession.empty(); end
            this@mvvm.SessionOwner(session);
            this@mvvm.view.View(varargin{:}, 'App', session);
        end
    end
    
    methods (Access=protected)
        function init(this)
            init@mvvm.view.View(this);
            init@mvvm.SessionOwner(this);
        end
    end
end


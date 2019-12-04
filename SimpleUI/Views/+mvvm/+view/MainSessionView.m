classdef MainSessionView < mvvm.view.View & mvvm.view.SessionOwner
    methods
        function this = MainSessionView(session, varargin)
            if nargin < 1; session = appd.AppSession.empty(); end
            this@mvvm.view.SessionOwner(session);
            this@mvvm.view.View(varargin{:}, 'App', session);
        end
    end
end


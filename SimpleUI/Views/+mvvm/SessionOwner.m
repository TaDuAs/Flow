classdef SessionOwner < handle
    properties
        SessionKey;
        Session mvvm.AppSession;
    end
    
    methods
        function this = SessionOwner()
        end
        
        function delete(this)
            if ~isempty(this.Session)
                this.Session.clearSessionState();
            end
        end
    end
    
    methods (Access=protected)
        function init(this, session)
            if nargin >= 1 && ~isempty(session)
                this.Session = session;
                this.SessionKey = session.SessionKey;       
            end
        end
    end
end


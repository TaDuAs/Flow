classdef SessionStateModelProvider < mvvm.providers.IModelProvider
    %SESSIONSTATEMODELPROVIDER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        SessionKey;
        Session;
    end
    
    methods
        function this = SessionStateModelProvider(session, sesKey)
            this.Session = session;
            this.SessionKey = sesKey;
        end
        
        function model = getModel(this)
            error('not implemented');
        end
        
        function setModel(this, model)
            error('not implemented');
        end
    end
end


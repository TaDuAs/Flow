classdef SessionStateModelProvider < mvvm.providers.IModelProvider
    %SESSIONSTATEMODELPROVIDER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        App mvvm.App;
        SessionId;
        ModelSessionKey;
    end
    
    methods
        function this = SessionStateModelProvider(app, sessionId, modelSessionKey)
            this.App = app;
            this.SessionId = sessionId;
            this.ModelSessionKey = modelSessionKey;
        end
        
        function model = getModel(this, session)
            if nargin < 1
                session = this.App.getSession(this.SessionId);
            end
            model = session.Context.get(this.ModelSessionKey);
        end
        
        function setModel(this, model)
            session = this.App.getSession(this.SessionId);
            prevModel = this.getModel(session);
            
            % check if model actually changed
            if ~isequal(model, prevModel)
                % set new model in session
                session.set(this.ModelSessionKey, model);
                
                % fire modelChanged event
                this.notify('modelChanged');
            end
        end
    end
end


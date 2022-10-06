classdef SessionManager < handle
    %SESSIONMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=private)
        App mvvm.IApp = mvvm.App.empty();
        SessionDictionary gen.ICache = gen.Cache.empty();
        ExpirationTimespan duration;
    end
    
    methods
        function this = SessionManager(app, expirationTime)
            if nargin < 2; expirationTime = inf; end
            
            this.App = app;
            this.SessionDictionary = gen.Cache();
            this.configureExpirationTime(expirationTime);
        end
        
        function configureExpirationTime(this, timespan)
            if nargin < 1 || isempty(timespan)
                timespan = seconds(inf);
            elseif ~isduration(timespan)
                timespan = seconds(timespan);
            end
            this.ExpirationTimespan = timespan;
        end
        
        function raiseSessionExpiredError(this, key)
            ex = MException('AppSession:Expired', 'Session expired: %s', key);
            throw(ex);
        end
        
        function clearSessionContainer(this)
            if isempty(this) || ~isvalid(this)
                return; 
            end
            
            if ~isempty(this.SessionDictionary)
                % clear all sessions by triggering their session
                % termination sequence
                allSessionKeys = this.SessionDictionary.allKeys();
                for i = 1:numel(allSessionKeys)
                    key = allSessionKeys{i};
                    this.clearSession(key);
                end
                
                % completely clear the session dictionary
                this.SessionDictionary.clearCache();
            end
        end
        
        function session = getSession(this, key)
            if ~this.validateSessionKey(key)
                this.raiseSessionExpiredError(key);
            end
            session = mvvm.AppSession(this.App, this, key);
        end
        
        function [key, session] = startNewSession(this)
            key = gen.guid();
            
            % create new IoC container session and make it return current
            % session
            sessionIoC = this.App.IocContainer.startNewSession(['Session.IoC /' key]);
            sessionIoC.setPerSession('SessionKey', @() key);
            sessionIoC.set('Session', @(app, key) app.getSession(key), 'App', 'SessionKey');
            
            % Create session persistence container
            sessionContext.context = mvvm.AppContext(sessionIoC);
            
            % mark current session timestamp to now
            sessionContext.timestamp = now;
            
            % save session
            this.SessionDictionary.set(key, sessionContext);
            session = this.getSession(key);
        end
        
        function isvalid = validateSessionKey(this, key)
            isvalid = this.SessionDictionary.hasEntry(key);
        end
        
        function clearSession(this, key)
            if ~this.validateSessionKey(key)
                return;
            end
            
            % Trigger session destruction sequence
            % This will in turn also call clear session context
            session = this.getSession(key);
            session.kill();
        end
        
        function clearExpiredSessions(this)
            for key = this.SessionDictionary.allKeys
                session = this.SessionDictionary.get(key);
                if now - session.timestamp > this.ExpirationTimespan
                    this.clearSession(key);
                end
            end
        end
    end
    
    methods (Access={?mvvm.AppSession, ?mvvm.SessionManager, ?mvvm.App})
        function context = getSessionContext(this, key)
            sessionRep = this.SessionDictionary;
            if sessionRep.hasEntry(key)
                session = sessionRep.get(key);
                context = session.context;
                session.timestamp = now;
                sessionRep.set(key, session);
            else
                this.raiseSessionExpiredError(key)
            end
        end
        
    end
    
    methods (Access={?mvvm.AppSession})
        
        function clearSesssionContext(this, key)
            if ~this.validateSessionKey(key)
                return;
            end
            
            % clear the context of a specific session key
            session = this.SessionDictionary.get(key).context;
            session.clearCache();
            this.SessionDictionary.removeEntry(key);
        end
        
    end
end


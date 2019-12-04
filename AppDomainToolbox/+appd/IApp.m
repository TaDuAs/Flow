classdef (Abstract) IApp < handle
    % appd.IApp is the interface for application domain app class
    % implementation
    
    properties (Abstract, GetAccess=public, SetAccess=protected)
        % Application status
        Status appd.AppStatus;
    end
    
    properties (Abstract, GetAccess=public, SetAccess=private, Dependent)
        % Dependency injection container
        IocContainer IoC.IContainer;
        
        % Application context object - for application-wide state management
        Context appd.AppContext;
        
        % Application-wide mediator class
        Messenger appd.MessagingMediator;
    end
    
    methods (Abstract)
        % Gets the "boss" application object - for decorator classes
        app = getApp(this);
        
        % terminates application state and context
        clear(this);
        
        % starts the application
        start(this);
        
        % restarts the application - clear state and context before
        % starting fresh
        restart(this);
        
        % kill the application object - delete it and clear state and
        % context
        kill(this);
        
        % Gets a session object from state
        session = getSession(this, key);
        
        % Stats a new session state & context and returns the session id
        % and session object
        [key, session] = startSession(this);
        
        % Terminates all sessions
        clearAllSessions(this);
        
        % Adds an item to be terminated when the application is terminated
        addKillItem(this, item);
        
        % Registers an MVC controller to application layer
        registerController(this, controller);
        
        % Gets an MVC controller
        controller = getController(this, controllerName);
    end
end
classdef (Abstract) IContainer < IoC.IContainerGetter
    methods (Abstract)
        % Returns a new IoC.IContainer as a dependency injection container
        % for a new session
        ioc = startNewSession(ioc);
        
        % Registers a new service with all required dependencies
        % set(ioc, serviceId, ctor)
        %   Registers a new service where serviceId is the string id of the
        %   service and ctor is a function_handle that constructs that
        %   service.
        % set(___, dependencies)
        %   Registers a new service where the dependencies are a list of
        %   ids of required services from the IoC.IContainer. dependencies
        %   may also include values to be passed to the ctor, optional
        %   name-value pairs passed to the ctor, property names followed by
        %   dependencies for property injections.
        % 
        % example:
        %   set(ioc,...
        %       "dependent",...                                     % The service id
        %       @Dependent,...                                      % The service ctor
        %       "someOtherDependency",...                           % reference dependency, will be generated by the IoC.Container at runtime
        %       1:10,...                                            % a by-value dependency
        %       "$A string to be sent to Dependent ctor",...        % a by-value string dependency
        %       "@OptionalParamName", "someOtherDependency",...      % a name-value ctor dependency with a dependency on a service from IoC.IContainer
        %       "&PropName", "someOtherDependency");                % A property injection into the PropName property
        set(ioc, serviceId, ctor, varargin);
        
        % Registers a service that has a single instance per IoC session
        % Syntax similar to set function
        setPerSession(ioc, serviceId, ctor, varargin);
        
        % Registers a service that has a single instance per application
        % domain. Syntax similar to set function
        setSingleton(ioc, serviceId, ctor, varargin);
    end
end


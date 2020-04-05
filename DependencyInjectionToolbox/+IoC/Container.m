classdef Container < IoC.IContainer
    % IoC.Container is an inversion of control container used to manage
    % dependency injections.
    % IoC.Container supports both mandatory and optional dependencies.
    % optonal dependencies can be managed either as property injections or
    % as name-value pairs passed to the ctor as is customary in many matlab
    % funcitons/classes.
    % 
    % Dependencies are identified using strings (or character vectors)
    % To get a dependency use the get method:
    %   obj = get(ioc, dependencyId)
    %   summary:
    %       gets an instance of the desired dependency. The dependency is
    %       instantiated using the dependencies configured during setup
    %       (use one of the set methods for setup)
    %   parametrs:
    %       dependencyId - the id of the current dependency (string/char)
    %   return value:
    %       obj - the instance of the desired dependency.
    %
    %   obj = get(__, varargin)
    %   parametrs:
    %       varargin - list of name-value pairs to be sent as optional ctor
    %                  injections or property injections
    %                  * optional ctor injection syntax:
    %                  obj = get(__, "@name", value)
    %                  this will generate a ctor injection using the
    %                  name-value properties for classes which support that
    %                  * optional property injection syntax:
    %                  obj = get(__, "propertyName", value)
    %       
    %
    % To setup dependencies use one of the set methods:
    %   set(this, dependencyId, ctorHandle)
    %   summary:
    %       sets a dependency using a funciton handle to the function which
    %       generates an instance of the class
    %   parameters:
    %       dependencyId - the id of the current dependency (string/char)
    %       ctorHandle - function handle to generate dependency instance
    %
    %   set(this, dependencyId, className)
    %   summary:
    %       sets a dependency using a the name of the class to build
    %   parameters:
	%       dependencyId - the id of the current dependency (string/char)
    %       className - the name of the dependency class (string/char)
    %
    %   set(__, varargin)
	%       varargin - ctor injections
    %                  objects, numeric or logical values will be passed to
    %                  the ctor as is.
    %                  strings and char vectors will be concidered as
    %                  dependencies to be created by the IoC.Container
    %                  before injection. to send a string or char vector to
    %                  the ctor, use $ sign at the beginning of the string.
    %
    %
    %   setPerSession(this, dependencyId, ctorHandle)
    %   summary:
    %       sets a dependency which is generated once per IoC.Container
    %       session
    %   parameters:
	%       dependencyId - the id of the current dependency (string/char)
    %       ctorHandle - function handle to generate dependency instance
    %
    %   setPerSession(this, dependencyId, className)
    %   summary:
    %       sets a dependency which is generated once per IoC.Container
    %       session
    %   parameters:
	%       dependencyId - the id of the current dependency (string/char)
    %       className - the name of the dependency class (string/char)
    %   
    %   setPerSession(__, varargin)
    %   summary:
    %       sets a dependency which is generated once per IoC.Container
    %       session with a list of ctor injections
    %   parameters:
	%       varargin - ctor injections
    %                  objects, numeric or logical values will be passed to
    %                  the ctor as is.
    %                  strings and char vectors will be concidered as
    %                  dependencies to be created by the IoC.Container
    %                  before injection. to send a string or char vector to
    %                  the ctor, use $ sign at the beginning of the string.
    %
    %
    %   setSingleton(this, dependencyId, ctorHandle)
    %   summary:
    %       sets a dependency which is generated once per application
    %       domain
    %   parameters:
	%       dependencyId - the id of the current dependency (string/char)
    %       ctorHandle - function handle to generate dependency instance
    %
    %   setSingleton(this, dependencyId, className)
    %   summary:
    %       sets a dependency which is generated once per application
    %       domain
    %   parameters:
	%       dependencyId - the id of the current dependency (string/char)
    %       className - the name of the dependency class (string/char)
    %   
    %   setSingleton(__, varargin)
    %   summary:
    %       sets a dependency which is generated once per application
    %       domain with a list of ctor injections
    %   parameters:
	%       varargin - ctor injections
    %                  objects, numeric or logical values will be passed to
    %                  the ctor as is.
    %                  strings and char vectors will be concidered as
    %                  dependencies to be created by the IoC.Container
    %                  before injection. to send a string or char vector to
    %                  the ctor, use $ sign at the beginning of the string.
    %
    %
    %   type = getType(this, dependencyId)
    %   summary:
    %       determines the actual type of the dependency that is created by
    %       the IoC.Conrainer
    %   parameters:
    %       dependencyId - The id of the dependency
    %
    %
    %   newIocSession = startNewSession(this)
    %   summary:
    %       generates a new IoC.Container session. The new session will
    %       have the same setup as the original.
    %       Any dependencies set using the setPerSession method in the 
    %       original contianer will generate a new instance.
    %       Any dependencies set using the setSingleton method in the 
    %       original contianer will generate the same instance as the
    %       original session.
    %
    %
    % example:
    % The order at which dependencies are declared is meaningless,
    % because they are not created at this moment
    % * Use no prefix to declare a reference to another injection which 
    %   will be generated by the IoC.Container at runtime
    % * Use the "@" prefix to declare a dynamically rewritable name-value
    %   ctor injection.
    % * Use the "$" prefix to declare a by value string/char ctor injection
    % * Use the "&" prefix to declare a property injection
    %   set(ioc,...
    %       "dependent",...                                     % The dependency id
    %       @Dependent,...                                      % The dependency ctor
    %       "someOtherDependency",...                           % reference dependency, will be generated by the IoC.Container at runtime
    %       1:10,...                                            % a by-value dependency
    %       "$A string to be sent to Dependent ctor",...        % a by-value string dependency
    %       "@OptionalParamName", "$Optional param value",...   % a name-value ctor dependency
    %       "&PropName", "someOtherDependency");                % A property injection into the PropName property
    %       
    %   % now declare the other dependency
    %   set(ioc, "someOtherDependency", @OtherDependency); 
    %       
    %   % This will generate an object of the class Dependent
    %   obj = get(ioc, "dependent");
    %       
    %   % Similarly to using the ctor of class "Dependent" as follows:
    %   obj2 = Dependent(OtherDependency(), 1:10,...
    %                    "A string to be sent to dependent ctor", ...
    %                    "OptionalParamName", "Optional param value");
    %   % then using the property PropName to inject yet anther instance of 
    %   % the OtherDependency class
    %   obj2.PropName = OtherDependency();
    %
    %
    %
    % *** Dynamic Injections ***
    % Dynamic injections set up at creation time.
    % Beware of Dynamic Injections!!!
    % This practice is risky and may result in using the IoC.Container
    % as a service locator in stead of proper dependency injection service
    % An excellent article by Mark Seemann called
    %   Service Locator is an Anti-Pattern
    %   https://blog.ploeh.dk/2010/02/03/ServiceLocatorisanAnti-Pattern/
    % explains why the Service Locator pattern should be avoided
    %
    % That said, it is sometimes necessary to use the IoC.Container for
    % dynamically generated objects with dynamically generated dependencies
    % I.E in factories, when loading an object graph from a configurable file, etc.
    % Use the get method with specified name-value dependencies:
    % Example:
    % * In dependency name, use the "@" prefix to dynamically set a
    %   name-value ctor injection
    % * In dependency name, use the "&" prefix, or no prefix to declare a 
    %   property injection
    % * In dependency name, use the "#n" pattern, where n is an integer,
    %   i.e "#2", to overwrite the ctor dependency at the specified inedx 
    %   in the parameters list sent to the ctor
    % ** In the dependency value, use no prefix to declare a reference to  
    %    another dependency which will be generated by the IoC.Container at
    %    runtime
    % ** In the dependency value, Use the "$" prefix to declare a by value
    %    string/char injection
    %   set(ioc, "dependent", @Dependent, "someOtherDependency", 1:10, "$A string to be sent to Dependent ctor", "@OptionalParamName", "$Optional param value");
    %   set(ioc, "someOtherDependency", @OtherDependency); 
    %       
    %   % Rewrite the original name-value ctor dependency named
    %   OptionalParamName with this dynamically generated one
    %   obj = get(ioc, "dependent", "@OptionalParamName", "$Rewritten Value");
    %       
    %   % Similarly to using dependent ctor as follows
    %   obj2 = Dependent(OtherDependency(), 1:10,...
    %                    "A string to be sent to Dependent ctor", ...
    %                    "OptionalParamName", "Rewritten Value");
    %   
    %   % Add a name-value ctor dependency that was not declared during
    %   % IoC.Container setup
    %   obj = get(ioc, "dependent", "@AnotherOptionalParameterName", "$Another optional parameter value");
    %   
    %   % this is similar to that:
    %   obj2 = Dependent(OtherDependency(), 1:10,...
    %                    "A string to be sent to Dependent ctor", ...
    %                    "OptionalParamName", "Optional param value", ...
    %                    "AnotherOptionalParameterName", "Another optional parameter value");
    %
    %   % Use dynamic dependencies to change the value injected to the ctor
    %   % at a specific numeric index using the "#" prefix
    %   obj = get(ioc, "dependent", "#2", 1:100);
    %
    %   % this is similar to that:
    %   % notice how the 1:10 injection is changed to 1:100
    %   obj2 = Dependent(OtherDependency(), 1:100,...
    %                    "A string to be sent to Dependent ctor", ...
    %                    "OptionalParamName", "Optional param value");
    %
    %   % Use dynamic dependencies property injection using the "&" prefix
    %   obj = get(ioc, "dependent", "&PropName", "someOtherDependency");
    %   
    %   % this is similar to that:
    %   obj2 = Dependent(OtherDependency(), 1:10,...
    %                    "A string to be sent to Dependent ctor", ...
    %                    "OptionalParamName", "Optional param value");
    %   obj2.PropName = OtherDependency();
    %
    %
    % Author: TADA 2019
   
    
    
    properties (Access=private)
        Dependencies;
    end
    
    methods
        function this = Container()
            this.Dependencies = containers.Map();
            this.Dependencies('IoC') = IoC.ContainerDependency(this, 'IoC');
        end
        
        function tf = hasDependency(this, serviceId)
            serviceId = this.validateServiceId(serviceId);
            tf = arrayfun(@(sid) this.Dependencies.isKey(sid), serviceId);
        end
        
        function ioc = startNewSession(this)
            ioc = IoC.Container();
            ioc.setDependencies(this.Dependencies.values);
        end

        function serviceType = getType(this, serviceId)
            % validate required service id
            serviceId = this.validateAndEnsureDependencyExists(serviceId);

            serviceType = cell(1, numel(serviceId));
            for i = 1:numel(serviceId)
                currDep = this.Dependencies(serviceId{i});
                serviceType{i} = currDep.getType();
            end

            if numel(serviceId) == 1
                serviceType = serviceType{1};
            end
        end
        
        function service = get(this, serviceId, varargin)
            [validServiceId, sidn] = this.validateAndEnsureDependencyExists(serviceId);
            
            sidIdxEnd = cumsum(sidn);
            sidIdxStart = [1, sidIdxEnd(1:end-1)+1];

            service = cell(1, numel(sidn));
            for i = 1:numel(sidn)
                currInjection = cell(1, sidn(i));
                for j = sidn(i):-1:1
                    currDepIdx = j+sidIdxStart(i)-1;
                    currDep = this.Dependencies(validServiceId{currDepIdx});
                    currInjection{j} = currDep.build(varargin{:});
                end
                service{i} = [currInjection{:}];
                clear currInjection;
            end

            if numel(validServiceId) == 1
                service = service{1};
            end
        end

        function set(this, serviceId, ctor, varargin)
            serviceId = this.validateServiceId(serviceId);

            if ischar(ctor) || isstring(ctor)
                ctor = this.generateClassCtor(ctor);
            end
            this.Dependencies(serviceId) = IoC.Dependency(this, serviceId, ctor, varargin{:});
        end

        function setPerSession(this, serviceId, ctor, varargin)
            serviceId = this.validateServiceId(serviceId);

            if ischar(ctor) || isstring(ctor)
                ctor = this.generateClassCtor(ctor);
            end
            this.Dependencies(serviceId) = IoC.SessionDependency(this, serviceId, ctor, varargin{:});
        end
        
        function setSingleton(this, serviceId, ctor, varargin)
            serviceId = this.validateServiceId(serviceId);

            if ischar(ctor) || isstring(ctor)
                ctor = this.generateClassCtor(ctor);
            end
            this.Dependencies(serviceId) = IoC.SingletonDependency(this, serviceId, ctor, varargin{:});
        end
    end
    
    methods (Access=?IoC.Container)
        function setDependencies(this, dependencies)
            for i = 1:numel(dependencies)
                d = dependencies{i};
                this.Dependencies(d.Id) = d.duplicateFor(this);
            end
        end
    end
    
    methods (Access=private)
        function ctor = generateClassCtor(this, funName)
            function obj = constructor(varargin)
                obj = feval(funName, varargin{:});
            end

            ctor = @constructor;
        end

        function [serviceId, sidNumel] = validateServiceId(this, serviceId) 
            if iscell(serviceId)
                if all(cellfun(@(s) ischar(s) || isStringScalar(s), serviceId))
                    sidNumel = ones(size(serviceId));
                    serviceId = string(serviceId);
                else
                    sidNumel = ones(size(serviceId));
                    c = {};
                    for i = 1:numel(serviceId)
                        [currServiceId, sidNumel(i)] = this.validateServiceId(serviceId{i});
                        c = [c currServiceId];
                    end
                    serviceId = c;
                end
            elseif isa(serviceId, 'IoC.Injectable')
                sidNumel = numel(serviceId);
                serviceId = [serviceId.DependencyName];
            elseif ischar(serviceId)
                sidNumel = 1;
                serviceId = string(serviceId);
            elseif ~isstring(serviceId)
                throw(MException('IoC:Injector:invalidServiceId',...
                    'Service id must be a string or character vector or an IoC.Injectable.'));
            else % serviceId is a string vector
                sidNumel = numel(serviceId);
            end

            if any(startsWith(serviceId, ["$", "#", "@", "&", "%"]))
                throw(MException('IoC:Injector:invalidServiceId',...
                    'Service id must not start with "$", "@", "&", "%" nor "#"'));
            end
        end
        
        function [validServiceId, sidNumel] = validateAndEnsureDependencyExists(this, serviceId)
            [validServiceId, sidNumel] = this.validateServiceId(serviceId);
            
            existingServiceIdsMask = this.hasDependency(validServiceId);
            if ~all(existingServiceIdsMask)
                serviceIdForDisplay = strcat('"', strjoin(validServiceId(~existingServiceIdsMask), '", "'), '"');
                throw(MException('IoC:Injector:InvalidDependency', 'No dependency with id %s is registered to the IoC.Container', serviceIdForDisplay));
            end
        end
    end
end
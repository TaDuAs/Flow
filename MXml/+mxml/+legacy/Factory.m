classdef Factory < handle
    % This class generates instances of classes according to name using
    % user-predefined constructor functions or using the default empty
    % constructor function which send no arguments to the constructor
    % method, and set all public properties of that class to the data as
    % saved in the XML file.
    % Factory class provides access to it's singleton instance via the
    % static instance method
    % ctors can be registerd using the addConstructor method or by calling
    % the static method init and sending a FactoryBuilder class which
    % implements a method with the signature: initFactory(Factory)
    % Ctor functions should have the signature:
    %   function obj = ctor(data), where data is a struct containing all
    %   the properties of the class as saved in the M.XML file
    %
    % ---------------------------------------------------------------------
    % Example:
    % ** The following class SomeClass:
    % classdef SomeClass
    %     properties
    %         a = 1:3;
    %         b = 'Hello world';
    %         c = {'Hello' 'World' '!'};
    %     end
    % end
    %
    % ** Would be exported into this XML:
    % <document type="struct">
    % <data type="SomeClass">
    %   <a type="double">1 2 3</a>
    %   <b type="char">Hello world</b>
    %   <c type="cell" isList="true">
    %       <entry type="char">Hello</entry>
    %       <entry type="char">World</entry>
    %       <entry type="char">!</entry>
    % </data>
    % </document>
    % 
    % ** The data struct which would be sent to the registereed ctor method
    % for the root object of type SomeClass would be:
    %   data.a = [1 2 3];
    %   data.b = 'Hello world';
    %   data.c = {'Hello' 'World' '!'};
    %
    % Author: TADA
    
    properties (Access=private)
        constructors = containers.Map();
    end
    
    methods (Access=private)
        function this = Factory()
        end
    end
    
    methods (Static, Access=private)
        function factory = singletonInstance(shouldReset)
            persistent factoryInstance;
            
            if isempty(factoryInstance)
                factoryInstance = mxml.legacy.Factory();
            elseif nargin >= 1 && shouldReset
                delete(factoryInstance);
                factoryInstance = mxml.legacy.Factory();
            end
            
            factory = factoryInstance;
        end
    end
    
    methods (Static)
        function factory = instance()
            factory = mxml.legacy.Factory.singletonInstance();
        end
        
        function factory = terminate()
            factory = mxml.legacy.Factory.singletonInstance(true);
        end
        
        function init(factoryInitializer)
            factory = mxml.legacy.Factory.instance();
            factoryInitializer.initFactory(factory);
        end
    end
    
    methods
        
        function addConstructor(this, className, ctor)
            this.constructors(className) = ctor;
        end
        
        function instance = construct(this, className, data)
            if nargin < 3; data = []; end
            if this.constructors.isKey(className)
%                 error(['specified class ' className ' has no specified constructor']);
                ctor = this.constructors(className);
                if nargin < 3; data = []; end
                instance = ctor(data);
            else
                ctor = this.generateDefaultCtor(className);
                
                try
                    instance = ctor(data);
                catch ex
                    error(['specified class ' className ' has no empty ctor. Add a custom ctor']);
                end

                this.addConstructor(className, ctor);
            end
        end
        
        function instance = cunstructEmpty(this, className, data)
            if nargin < 3
                
                metaclass = meta.class.fromName(className);
                
                if metaclass.Enumeration
                    data = metaclass.EnumerationMemberList(1).Name;
                else
                    data = struct;
                    for propIdx = 1:length(metaclass.PropertyList)
                       data.(metaclass.PropertyList(propIdx).Name) = [];
                    end
                end
            end
            instance = this.construct(className, data);
            for currField = fieldnames(instance)'
                instance.(currField{1}) = [];
            end
        end
        
        function isIdentified = hasCtor(this, className)
            isIdentified = this.constructors.isKey(className);
        end
        
        function reset(this)
            this.constructors.remove(this.constructors.keys);
        end
        
        function bool = isempty(this)
            bool = this.constructors.isempty();
        end
    end
    
    methods (Access=private)
        
        function ctor = generateDefaultCtor(this, className)
            % Try to dynamically generate a ctor for that class
                
            % validate specified name is a name of a class to avoid
            % any funny buisness like invoking delete(*.*)
            classInfo = meta.class.fromName(className);
            if isempty(classInfo)
                error(['specified class ' className ' is not a valid matlab class']);
            end

            % get ctor handle
            ctorMethod = str2func(className);
            
            if classInfo.Enumeration
                ctor = ctorMethod;
                return;
            end

            % find all public properties
            publicProps = classInfo.PropertyList(strcmp({classInfo.PropertyList.SetAccess}, 'public'));

            % Generate a dynamic ctor method that also sets all public
            % properties
            function classInstance = generateInstanceAndSetProperties(data)
                % invoke ctor
                classInstance = ctorMethod();

                % set all public properties
                for i = 1:length(publicProps)
                    propName = publicProps(i).Name;
                    if isfield(data, propName)
                        classInstance.(propName) = data.(propName);
                    end
                end
            end
            
            ctor = @generateInstanceAndSetProperties;
        end
        
    end
end


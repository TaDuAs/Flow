classdef Factory < mfc.MFactory
    %*** OBSOLETE *** OBSOLETE *** OBSOLETE *** OBSOLETE *** OBSOLETE ***
    %
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
    %*** OBSOLETE *** OBSOLETE *** OBSOLETE *** OBSOLETE *** OBSOLETE ***
    %
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
    %
    %*** OBSOLETE *** OBSOLETE *** OBSOLETE *** OBSOLETE *** OBSOLETE ***
    
    properties (Access=private)
        constructors containers.Map;
    end
    
    methods (Access=private)
        function this = Factory()
            this.constructors = containers.Map();
        end
    end
    
    methods (Static, Access=private)
        function factory = singletonInstance(shouldReset)
            persistent factoryInstance;
            
            if isempty(factoryInstance)
                factoryInstance = MXML.Factory();
            elseif nargin >= 1 && shouldReset
                delete(factoryInstance);
                factoryInstance = MXML.Factory();
            end
            
            factory = factoryInstance;
        end
    end
    
    methods (Static)
        function factory = instance()
            warning('MXML:Factory:Obsolete', 'MXML.Factory is obsolete, it will work, but you should use the non-static mfc.MFactory class instead');
            factory = MXML.Factory.singletonInstance();
        end
        
        function factory = terminate()
            warning('MXML:Factory:Obsolete', 'MXML.Factory is obsolete, it will work, but you should use the non-static mfc.MFactory class instead');
            factory = MXML.Factory.singletonInstance(true);
        end
        
        function init(factoryInitializer)
            warning('MXML:Factory:Obsolete', 'MXML.Factory is obsolete, it will work, but you should use the non-static mfc.MFactory class instead');
            factory = MXML.Factory.instance();
            factoryInitializer.initFactory(factory);
        end
    end
    
    methods
        
        function addConstructor(this, className, ctor)
            this.constructors(className) = ctor;
        end
        
        function instance = construct(this, className, varargin)
            if this.hasCtor(className) && isa(this.constructors(className), 'MXML.LegacyFactoryCtor')
                % backwards compatible ctors
                if nargin < 3
                    data = struct();
                elseif nargin > 3
                    data = cell2struct(varargin(2:2:end), varargin(1:2:end), 2);
                elseif isa(varargin{1}, 'mfc.extract.IJitPropertyExtractor')
                    data = struct();
                    ext = varargin{1};
                    props = ext.allProps();
                    for i = 1:numel(props)
                        propName = props{i};
                        data.(propName) = ext.get(propName);
                    end
                else
                    data = varargin{1};
                end
                
                ctor = this.constructors(className);
                instance = ctor.build(data);
            else
                % regular mfc.MFactory functionality
                instance = construct@mfc.MFactory(this, className, varargin{:});
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
        
        function reset(this)
            this.constructors.remove(this.constructors.keys);
        end
    end
end


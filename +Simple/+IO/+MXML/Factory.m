classdef Factory < MXML.Factory
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
    methods (Static)
        function factory = instance()
            factory = MXML.Factory.instance();
        end
        
        function factory = terminate()
            factory = MXML.Factory.terminate();
        end
        
        function init(factoryInitializer)
            MXML.Factory.init(factoryInitializer);
        end
    end
    
end


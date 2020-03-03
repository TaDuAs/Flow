classdef MockSatelite < handle
    %MOCKSATELITE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess=public, SetAccess=private)
        mock;
        mockedProperties;
        mockedMethods;
    end

    methods
        
    end
    
    methods (Access={?Simple.UnitTests.MockFactory})
        function this = MockSatelite(meta)
            this.mock = Mock(meta);
            
            
        end
        
        
    end
    
    methods (Access=private)
        function generateMockedProperty(this, prop)
            dynProp = addprop(this, prop.Name);
            this.mockedProperties.(prop.Name) = struct('dynProp', dynProp, 'value', []);
            dynProp.GetAccess = prop.GetAccess;
            dynProp.SetAccess = prop.SetAccess;
            dynProp.GetMethod = @() this.mockedProperties.(prop.Name).value;
            % set method will be set to change the property value stored in
            % mocked properties if instructed specifically
        end
        
    end
    
end


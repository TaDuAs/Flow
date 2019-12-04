classdef SimpleModelProviderTests < matlab.unittest.TestCase

    properties
    end
    
    methods (TestMethodSetup)
    end
    
    methods (Test)
        function setModel(testCase)
            mp = mvvm.providers.SimpleModelProvider();
            
            mp.setModel(1:10);
            
            value = mp.getModel();
            
            assert(isequal(value, 1:10), 'Expected model [%d] not equal to actual model [%d]', 1:10, value);
        end
        
        function setModelViaCtor(testCase)
            mp = mvvm.providers.SimpleModelProvider(1:10);
            
            value = mp.getModel();
            
            assert(isequal(value, 1:10), 'Expected model [%d] not equal to actual model [%d]', 1:10, value);
        end
        
        function setModelRaisesEvent(testCase)
            mp = mvvm.providers.SimpleModelProvider(1:10);
            x = 0;
            function callback(src, e)
                x = x+1;
            end
            
            listener = mp.addlistener('modelChanged', @callback);
            
            mp.setModel(1);
            mp.setModel(2);
            
            assert(isequal(x, 2), 'Changed the model twice but the event was raised %d times', x);
            
            delete(listener);
        end
        
        function setModelDoesntRaiseEvent(testCase)
            mp = mvvm.providers.SimpleModelProvider(1:10);
            x = 0;
            function callback(src, e)
                x = x+1;
            end
            
            listener = mp.addlistener('modelChanged', @callback);
            
            mp.setModel(1:10);
            mp.setModel(1:10);
            
            assert(isequal(x, 0), 'Model didn''t change but the event was raised %d times', x);
            
            delete(listener);
        end
    end

end
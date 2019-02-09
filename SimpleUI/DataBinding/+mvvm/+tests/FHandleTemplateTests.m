classdef FHandleTemplateTests < matlab.unittest.TestCase

    properties
    end
    
    methods (TestMethodSetup)
    end
    
    methods(TestMethodTeardown)
    end
    
    methods (Test)
        function callBuilderFunc(testCase)
            x = 0;
            function h = foo(scope, container)
                h = [];
                x = x+1;
            end
            
            temp = mvvm.providers.FHandleTemplate(@foo);
            
            temp.build([], []);
            temp.build([], []);
            
            assert(isequal(2, x));
        end
        
        function returnHandlesStruct(testCase)
            function h = foo(scope, container)
                h.a = 123;
                h.b = 'la la la';
            end
            
            temp = mvvm.providers.FHandleTemplate(@foo);
            
            h = temp.build([], []);
            
            assert(isequal(h.a, 123));
            assert(isequal(h.b, 'la la la'));
        end
        
        function terminateHandlesInStruct(testCase)
            fig = figure(99);
            
            h.lbl = uicontrol(fig, 'style', 'text', 'String', 'Blah blah blaH');
            h.hand = mvvm.tests.HandleModel(1, 2, 3, 4);

            temp = mvvm.providers.FHandleTemplate(@foo);
            
            temp.teardown([], [], h);
            
            lblDestroyedAssertFlag = ~ishandle(h.lbl);
            
            close(fig);
            
            assert(lblDestroyedAssertFlag);
            assert(~isvalid(h.hand));
        end
        
        function dontTouchValueTypesInStruct(testCase)
            h.string = 'abc';
            h.num = 123;

            temp = mvvm.providers.FHandleTemplate(@foo);
            
            temp.teardown([], [], h);
            
            assert(isequal(h.string, 'abc'));
            assert(isequal(h.num, 123));
        end
        
        function dontTouchValueTypesButDestroyHandlesInStruct(testCase)
            fig = figure(99);
            
            h.string = 'abc';
            h.lbl = uicontrol(fig, 'style', 'text', 'String', 'Blah blah blaH');
            h.hand = mvvm.tests.HandleModel(1, 2, 3, 4);
            h.num = 123;

            temp = mvvm.providers.FHandleTemplate(@foo);
            
            temp.teardown([], [], h);
            
            lblDestroyedAssertFlag = ~ishandle(h.lbl);
            
            close(fig);
            
            assert(lblDestroyedAssertFlag);
            assert(~isvalid(h.hand));
            assert(isequal(h.string, 'abc'));
            assert(isequal(h.num, 123));
        end
    end

end


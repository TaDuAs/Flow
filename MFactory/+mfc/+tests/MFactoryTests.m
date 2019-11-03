classdef MFactoryTests < matlab.unittest.TestCase
    methods (Test) % addConstructor
        function addCustomCtorTest(testCase)
            mf = mfc.MFactory();
            obj1 = mfc.tests.HandleModel();
            ctor = mfc.FunctionHandleCtor('blah', @(ext) obj1);
            
            mf.addConstructor('blah', ctor);
            obj2 = mf.construct('blah');
            
            assert(isequal(obj1, obj2));
        end
        
        function addCustomCtorFunctionHandleTest(testCase)
            mf = mfc.MFactory();
            obj1 = mfc.tests.HandleModel();
            
            mf.addConstructor('blah', @(ext) obj1);
            obj2 = mf.construct('blah');
            
            assert(isequal(obj1, obj2));
        end
        
        function addCustomCtorFunctionNameTest(testCase)
            mf = mfc.MFactory();
            
            mf.addConstructor('blah', 'mfc.tests.HandleModel');
            obj = mf.construct('blah');
            
            assert(numel(obj) == 1);
            assert(isa(obj, 'mfc.tests.HandleModel'));
        end
        
        
    end
    
    methods (Test) % construct
        function constructRegisteredCtorNoInput(testCase)
            factory = mfc.MFactory();
            obj1 = mfc.tests.HandleModel('1', 2, 3, 4);
            factory.addConstructor('blah', @(ext) obj1);
            
            obj2 = factory.construct('blah');
            
            assert(isequal(obj1, obj2));
        end
        
        function constructRegisteredCtorExtractorInput(testCase)
            factory = mfc.MFactory();
            obj1 = mfc.tests.HandleModel('1', 2, 3, 4);
            ext = mfc.extract.StructJitExtractor(obj1);
            didInvokeFunction = false;
            
            function obj = assertExtractor(ext1)
                obj = mfc.tests.HandleModel();
                didInvokeFunction = true;
                assert(isequal(ext,ext1));
            end
            
            factory.addConstructor('blah', @assertExtractor);
                    
            obj2 = factory.construct('blah', ext);
            
            assert(didInvokeFunction);
            assert(~isequal(obj1.id, obj2.id));
            assert(~isequal(obj1.child1, obj2.child1));
            assert(~isequal(obj1.child2, obj2.child2));
            assert(~isequal(obj1.list, obj2.list));
        end
    end
end


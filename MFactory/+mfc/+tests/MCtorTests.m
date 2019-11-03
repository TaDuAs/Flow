classdef MCtorTests < matlab.unittest.TestCase
    methods (Test)
        function fromTypeName(testCase)
            ctor = mfc.MCtor('mfc.tests.HandleModel');
            
            obj = ctor.build();
            
            assert(isa(obj, 'mfc.tests.HandleModel'));
            assert(numel(obj) == 1);
        end
        
        function fromFunctionHandle(testCase)
            ctor = mfc.MCtor(@mfc.tests.HandleModel);
            
            obj = ctor.build();
            
            assert(isa(obj, 'mfc.tests.HandleModel'));
            assert(numel(obj) == 1);
        end
        
        function mustBeFunctionHandleOrString(testCase)
            success = true;
            try
                ctor = mfc.MCtor(mfc.tests.HandleModel());
                success = false;
            catch ex
                assert(strcmp(ex.identifier, 'MFactory:MCtor:InvalidCtor'));
                % this is good
            end
            
            assert(success);
        end
        
        function buildWithParams(testCase)
            ctor = mfc.MCtor(@mfc.tests.HandleModel);
            
            obj = ctor.build('blah', 1:10);
            
            assert(isa(obj, 'mfc.tests.HandleModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.id, 'blah'));
            assert(isequal(obj.child1, 1:10));
        end
        
        function getTypeName(testCase)
            ctor = mfc.MCtor(@mfc.tests.HandleModel);
            
            type = ctor.getTypeName();
            
            assert(strcmp(type, 'mfc.tests.HandleModel'));
        end
    end
end


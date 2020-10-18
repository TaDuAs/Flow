classdef setobjTests < matlab.unittest.TestCase & mvvm.providers.IModelIndexer

    properties
        index;
    end
    
    methods 
        function value = getv(this, model)
            value = model(this.index{:});
        end
        function model = setv(this, model, value)
            model(this.index{:}) = value;
        end
    end
    
    methods (TestMethodSetup)
        function createModel(testCase)
%             testCase.model = mvvm.tests.generateTestingModel();
        end
    end
    
    methods (Test)
        function setObjToHandle(testCase)
            model = mvvm.tests.HandleModel();
            
            mvvm.setobj(model, 'id', '123');
            
            assert(strcmp(model.id, '123'));
        end
        
        function setObjHandleTree(testCase)
            model = mvvm.tests.generateTestingModel();
            
            mvvm.setobj(model, 'child1.child1.id', 'id changed :)');
            
            assert(strcmp(model.child1.child1.id, 'id changed :)'));
        end
        
        function setObjHandleMissingPath(testCase)
            model = mvvm.tests.HandleModel();
            
            mvvm.setobj(model, 'child1.child1.id', 'id changed :)');
            
            assert(strcmp(model.child1.child1.id, 'id changed :)'));
            assert(isstruct(model.child1));
            assert(isstruct(model.child1.child1));
        end
        
        function setObjValueType(testCase)
            model = mvvm.tests.ValueModel();
            
            model2 = mvvm.setobj(model, 'id', ':)');
            
            assert(strcmp(model2.id, ':)'));
            assert(~strcmp(model.id, ':)'));
        end
        
        function setObjHandleRootValueTree(testCase)
            model = mvvm.tests.generateTestingModel();
            
            model2 = mvvm.setobj(model, 'child1.id', 'id changed :)');
            
            assert(strcmp(model2.child1.id, 'id changed :)'));
            assert(strcmp(model.child1.id, 'id changed :)'));
        end
        
        function setObjValueRootValueTree(testCase)
            model = mvvm.tests.ValueModel([], mvvm.tests.ValueModel([], mvvm.tests.ValueModel()));
            
            model2 = mvvm.setobj(model, 'child1.child1.id', '123');
            
            assert(strcmp(model2.child1.child1.id, '123'));
            assert(~strcmp(model.child1.child1.id, '123'));
        end
        
        function setObjValueRootHandleTree(testCase)
            model = mvvm.tests.ValueModel([], mvvm.tests.ValueModel([], mvvm.tests.HandleModel()));
            
            model2 = mvvm.setobj(model, 'child1.child1.id', '123');
            
            assert(strcmp(model2.child1.child1.id, '123'));
            assert(strcmp(model.child1.child1.id, '123'));
        end
        
        function setObjValueMissingPath(testCase)
            model = mvvm.tests.ValueModel();
            
            model2 = mvvm.setobj(model, 'child1.child1.id', 'id changed :)');
            
            assert(isempty(model.child1));
            assert(strcmp(model2.child1.child1.id, 'id changed :)'));
            assert(isstruct(model2.child1));
            assert(isstruct(model2.child1.child1));
        end
        
        function setObjIndexerOnValue(testCase)
            model = mvvm.tests.ValueModel([], 1:10);
            testCase.index = {1:2};
            
            model2 = mvvm.setobj(model, 'child1', [20 21], testCase);
            
            assert(isequal(model2.child1, [20 21 3:10]));
            assert(isequal(model.child1, 1:10));
        end
        
        function setObjIndexerOnHandle(testCase)
            model = mvvm.tests.HandleModel([], 1:10);
            testCase.index = {1:2};
            
            model2 = mvvm.setobj(model, 'child1', [20 21], testCase);
            
            assert(isequal(model2.child1, [20 21 3:10]));
            assert(isequal(model.child1, [20 21 3:10]));
        end
    end

end
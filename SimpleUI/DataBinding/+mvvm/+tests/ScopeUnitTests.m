classdef ScopeUnitTests < matlab.unittest.TestCase & mvvm.providers.IModelProvider
    %SCOPEUNITTESTS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        model;
        gui;
    end
    
    methods
        
        function model = getModel(this)
            model = this.model;
        end
        
        function setModel(this, model)
            this.model = model;
            
        end
    end
    
    methods (TestMethodSetup)
        function suppressContainersMapWarning(testCase)
            warning('off','mvvm:Scope:ContainersMapIssue');
        end
        function createModel(testCase)
            testCase.model = mvvm.tests.generateTestingModel();
        end
    end
    
    methods (TestMethodTeardown)
        function reactivateContainersMapWarning(testCase)
            warning('on','mvvm:Scope:ContainersMapIssue');
        end
    end
    
    methods (Test) % matrix scope
        function matrixScope_NumericIndex(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child2.list', 3, '');
            value = magic(10);
            value = value(3,:);
            scope = scopeProvider.getModel();
            
            assert(isequal(value, scope), 'scope doesn''t fit the row at index 3. Expected: [%d]; Actual: [%d]', value, scope);
        end
        
        function matrixScope_SetNumericIndex(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child2.list', 3);
            
            value1 = ones(1,10);
            scopeProvider.setModel(value1);
            scope = scopeProvider.getModel();
            
            assert(isequal(value1, scope), 'scope wasn''t changed successfully. Expected: [%d]; Actual: [%d]', value1, scope);
            assert(isequal(testCase.model.child2.list(3,:), value1), 'model wasn''t set successfully. Expected: [%d]; Actual: [%d]', value1, testCase.model.child2.list(3,:));
        end
        
        function matrixScope_NumericIndex_RowVectorIsMatrixRow(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child2.child2', 1);
            value = 1:100;
            scope = scopeProvider.getModel();
            
            assert(isequal(value, scope), 'Row vector is a 1xm matrix, the scope should be the row itself. Expected: [%d]; Actual: [%d]', value, scope);
        end
        
        function matrixScope_NumericIndex_ColVectorIs1ColumnMatrix(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child2.child1.child1.child2', 5);
            value = 15;
            scope = scopeProvider.getModel();
            
            assert(isequal(value, scope), 'Column vector is a nx1 matrix, the scope should be the element at the scope index. Expected: [%d]; Actual: [%d]', value, scope);
        end
    end
    
    methods (Test) % matrix scope - change events
        
        function matrixScope_OnMatrixChanged(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child2.list', 3);
            
            x = 0;
            y = 0;
            function changeCallback(~,~)
                x = x+1;
            end
            function removeCallback(~,~)
                y = y+1;
            end
            
            changeListener = addlistener(scopeProvider, 'modelChanged', @changeCallback);
            removeListener = addlistener(scopeProvider, 'scopeRemoved', @removeCallback);
            
            testCase.model.child2.list(3,:) = testCase.model.child2.list(4,:);
            testCase.model.child2.list(4,:) = testCase.model.child2.list(5,:);
            testCase.model.child2.list(1,:) = testCase.model.child2.list(6,:);
            
            assert(isequal(x, 3), 'Model was changed 3 times but the modelChanged event was raised %d times', x);
            assert(isequal(y, 0), 'The Model was not removed but the modelRemoved event was raised %d times', y);
            
            delete(changeListener);
            delete(removeListener);
        end
        
        function matrixScope_OnMatrixReset(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child2.list', 3);
            
            x = 0;
            y = 0;
            function changeCallback(~,~)
                x = x+1;
            end
            function removeCallback(~,~)
                y = y+1;
            end
            
            changeListener = addlistener(scopeProvider, 'modelChanged', @changeCallback);
            removeListener = addlistener(scopeProvider, 'scopeRemoved', @removeCallback);
            
            testCase.model.child2.list = magic(15);
            
            assert(isequal(x, 1), 'Model was changed 1 times but the modelChanged event was raised %d times', x);
            assert(isequal(y, 0), 'The Model was not removed but the modelRemoved event was raised %d times', y);
            
            delete(changeListener);
            delete(removeListener);
        end
        
        function matrixScope_OnMatrixCleared(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child2.list', 3);
            
            x = 0;
            y = 0;
            function changeCallback(~,~)
                x = x+1;
            end
            function removeCallback(~,~)
                y = y+1;
            end
            
            changeListener = addlistener(scopeProvider, 'modelChanged', @changeCallback);
            removeListener = addlistener(scopeProvider, 'scopeRemoved', @removeCallback);
            
            testCase.model.child2.list = [];
            
            assert(isequal(x, 0), 'Model was not changed but the modelChanged event was raised %d times', x);
            assert(isequal(y, 1), 'The scope was removed once but the modelRemoved event was raised %d times', y);
            
            delete(changeListener);
            delete(removeListener);
        end
        
        function matrixScope_OnPathChanged(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child2.list', 3);
            
            x = 0;
            y = 0;
            function changeCallback(~,~)
                x = x+1;
            end
            function removeCallback(~,~)
                y = y+1;
            end
            
            changeListener = addlistener(scopeProvider, 'modelChanged', @changeCallback);
            removeListener = addlistener(scopeProvider, 'scopeRemoved', @removeCallback);
            
            testCase.model.child2 = mvvm.tests.HandleModel(-1,[],[],magic(9));
            
            assert(isequal(x, 1), 'Model was changed 1 times but the modelChanged event was raised %d times', x);
            assert(isequal(y, 0), 'The Model was not removed but the modelRemoved event was raised %d times', y);
            
            delete(changeListener);
            delete(removeListener);
        end
        
        function matrixScope_OnPathChangedScopeRemoved(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child2.list', 5);
            
            x = 0;
            y = 0;
            function changeCallback(~,~)
                x = x+1;
            end
            function removeCallback(~,~)
                y = y+1;
            end
            
            changeListener = addlistener(scopeProvider, 'modelChanged', @changeCallback);
            removeListener = addlistener(scopeProvider, 'scopeRemoved', @removeCallback);
            
            testCase.model.child2 = mvvm.tests.HandleModel(-1,[],[],magic(4));
            
            assert(isequal(x, 0), 'Model was not changed but the modelChanged event was raised %d times', x);
            assert(isequal(y, 1), 'The scope was removed once but the modelRemoved event was raised %d times', y);
            
            delete(changeListener);
            delete(removeListener);
        end
    end
    
    methods (Test) % cell array scope
        function cellScope_NumericIndex(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child1.child1.list', 3, 'cells');
            value = 'Brown';
            scope = scopeProvider.getModel();
            
            assert(isequal(value, scope), 'scope doesn''t fit the cell at index 3. Expected: [%s]; Actual: [%s]', value, scope);
        end
        
        function cellScope_SetNumericIndex(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child1.child1.list', 3, 'cells');
            value = 'Red';
            scopeProvider.setModel(value);
            scope = scopeProvider.getModel();
            
            assert(isequal(value, scope), 'scope doesn''t fit the cell at index 3. Expected: [%s]; Actual: [%s]', value, scope);
            assert(isequal(testCase.model.child1.child1.list{3}, scope), 'scope doesn''t fit the cell at index 3. Expected: [%s]; Actual: [%s]', value, scope);
        end
    end
    
    methods (Test) % table scope
        function tableScope_RowIndex(testCase)
            scopeProvider = mvvm.scopes.TableScope(testCase, 'list', 3, 'rows');
            value = testCase.model.list(3,:);
            scope = scopeProvider.getModel();
            
            assert(isequal(value, scope), 'scope doesn''t fit the row at index 3');
        end
        
        function tableScope_SetRowIndex(testCase)
            scopeProvider = mvvm.scopes.TableScope(testCase, 'list', 5, 'rows');
            value = testCase.model.list(5,:);
            
            value1 = value;
            value1{1,'LastName'} = {[value{1,'LastName'}{:} ' ' value{1,'LastName'}{:}]};
            scopeProvider.setModel(value1);
            
            scope = scopeProvider.getModel();
            
            assert(isequal(value1, scope), 'scope doesn''t fit the value that was set');
            assert(isequal(testCase.model.list(5,:), scope), 'scope doesn''t fit the row at index 5');
            assert(~isequal(value.LastName, scope.LastName), 'scope wasn''t updated successfully');
        end
        
        function tableScope_RowNameIndex(testCase)
            scopeProvider = mvvm.scopes.TableScope(testCase, 'list', 'Smith', 'rownames');
            value = testCase.model.list('Smith',:);
            scope = scopeProvider.getModel();
            
            assert(isequal(value, scope), 'scope doesn''t fit the row with name ''Smith''');
        end
        
        function tableScope_SetRowNameIndex(testCase)
            scopeProvider = mvvm.scopes.TableScope(testCase, 'list', 'Smith', 'rownames');
            value = testCase.model.list('Smith',:);
            
            value1 = value;
            value1{1,'LastName'} = {[value{1,'LastName'}{:} ' ' value{1,'LastName'}{:}]};
            scopeProvider.setModel(value1);
            
            scope = scopeProvider.getModel();
            
            assert(isequal(value1, scope), 'scope doesn''t fit the value that was set');
            assert(isequal(testCase.model.list('Smith',:), scope), 'scope doesn''t fit the row with name ''Smith''');
            assert(~isequal(value.LastName, scope.LastName), 'scope wasn''t updated successfully');
        end
        
        function tableScope_ColNameIndex(testCase)
            scopeProvider = mvvm.scopes.FieldScope(testCase, 'list', 'LastName');
            testCase.model.list.Properties.RowNames = {};
            value = testCase.model.list.LastName;
            scope = scopeProvider.getModel();
            
            assert(isequal(value, scope), 'scope doesn''t fit the column with name ''LastName''');
        end
        
        function tableScope_SetColNameIndex(testCase)
            scopeProvider = mvvm.scopes.FieldScope(testCase, 'list', 'LastName');
            testCase.model.list.Properties.RowNames = {};
            value = testCase.model.list.LastName;
            
            value1 = value;
            value1(1:3) = strcat(value(1:3), {' '; ' '; ' '}, value(1:3));
            scopeProvider.setModel(value1);
            
            scope = scopeProvider.getModel();
            
            assert(isequal(value1, scope), 'scope doesn''t fit the value that was set');
            assert(isequal(testCase.model.list.LastName, scope), 'scope doesn''t fit the column with name ''LastName''');
            assert(~isequal(value(1:3), scope(1:3)), 'scope wasn''t updated successfully');
        end
    end
    
    methods (Test) % containers.Map array scope
        function mapScope_GetIndex(testCase)
            testCase.model = struct('list', containers.Map({'a' 'b' 'c'}, {'Adams', 'Bush', 'Carter'}));
            scopeProvider = mvvm.scopes.MapScope(testCase, 'list', 'c');
            value = 'Carter';
            scope = scopeProvider.getModel();
            
            assert(isequal(value, scope), 'scope doesn''t fit the value at index ''c''. Expected: [%s]; Actual: [%s]', value, scope);
        end
        
        function mapScope_SetIndex(testCase)
            testCase.model = struct('list', containers.Map({'a' 'b' 'c'}, {'Adams', 'Bush', 'Carter'}));
            scopeProvider = mvvm.scopes.MapScope(testCase, 'list', 'b');
            value = 'W.Bush';
            scopeProvider.setModel(value);
            scope = scopeProvider.getModel();
            
            assert(isequal(value, scope), 'scope doesn''t fit the value at index ''b''. Expected: [%s]; Actual: [%s]', value, scope);
            assert(isequal(testCase.model.list('b'), scope), 'scope doesn''t fit the value at index ''b''. Expected: [%s]; Actual: [%s]', value, scope);
        end
    end
    
    methods (Test) % lists.ICollection scope
        function ICollectionScope_GetIndex(testCase)
            testCase.model = struct();
            testCase.model.list = mvvm.tests.TestCollection({'Jerusalem', 'Tel Aviv', 'Haifa'});
            
            scopeProvider = mvvm.scopes.CollectionScope(testCase, 'list', 2);
            scope = scopeProvider.getModel();
            
            assert(isequal('Tel Aviv', scope), 'scope doesn''t fit the value at index 2. Expected: ''%s''; Actual: ''%s''', 'Tel Aviv', scope);
        end
        
        function ICollectionScope_SetIndex(testCase)
            testCase.model = struct();
            testCase.model.list = mvvm.tests.TestCollection({'Jerusalem', 'Tel Aviv', 'Haifa'});
            
            scopeProvider = mvvm.scopes.CollectionScope(testCase, 'list', 2);
            
            scopeProvider.setModel('Rehovot');
            
            scope = scopeProvider.getModel();
            
            assert(isequal('Rehovot', scope), 'scope wasn''t set properly. Expected: ''%s''; Actual: ''%s''', 'Rehovot', scope);
            assert(isequal('Rehovot', testCase.model.list.list{2}), 'The model wasn''t set properly. Expected: ''%s''; Actual: ''%s''', 'Rehovot', testCase.model.list.list{2});
        end
    end
    
    methods (Test) % struct array scope
        function structArrayScope_NumericIndex(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child2.child1.list', 1, 'cells');
            value = testCase.model.child2.child1.list(1);
            scope = scopeProvider.getModel();
            
            assert(isequal(value, scope), 'scope doesn''t fit the element at index 1');
        end
        
        function structArrayScope_SetNumericIndex(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child2.child1.list', 3, 'cells');
            value = testCase.model.child2.child1.list(3);
            
            scopeProvider.setModel(struct('name', 'Betty', 'id', 100));
            scope = scopeProvider.getModel();
            
            assert(~isequal(value, scope), 'scope didn''t change after updating');
            assert(isequal(testCase.model.child2.child1.list(3), scope), 'scope doesn''t fit the element at index 3');
        end
    end
    
    methods (Test) % handle array scope
        function handleArrayScope_NumericIndex(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child1.list', 3, 'cells');
            value = testCase.model.child1.list(3);
            scope = scopeProvider.getModel();
            
            assert(eq(value, scope), 'scope doesn''t fit the element at index 3');
        end
        
        function handleArrayScope_SetNumericIndex(testCase)
            scopeProvider = mvvm.scopes.Scope(testCase, 'child1.list', 2, 'cells');
            value = testCase.model.child1.list(2);
            
            scopeProvider.setModel(mvvm.tests.HandleModel(10000));
            scope = scopeProvider.getModel();
            
            assert(~eq(value, scope), 'scope didn''t change after updating');
            assert(eq(testCase.model.child1.list(2), scope), 'scope doesn''t fit the element at index 2');
        end
    end
    
    methods (Test) % update the model
        function modelIsValueType_UpdateModel(testCase)
            mod = struct();
            mod.list = {'The', 'Quick', 'Brown', 'Fox', 'Jumps', 'Over', 'The', 'Lazy', 'Dog'};
            mp = mvvm.providers.SimpleModelProvider(mod);
            
            x = 0;
            function callback(src, args)
                x = x+1;
            end
            
            listener = addlistener(mp, 'modelChanged', @callback);
            scopeProvider = mvvm.scopes.Scope(mp, 'list', 5, 'cells');
            
            scopeProvider.setModel('Leans');
            scopeProvider.setModel('Swims');
            scopeProvider.setModel('Screams');
            
            assert(isequal(3, x), 'scope was changed 3 times but the model was only set %d times', x);
            
            delete(listener);
        end
        
        function listIsContainersMapObject_DontUpdateModel(testCase)
            mod = struct();
            mod.list = containers.Map({'a' 'b' 'c'}, {'Adams', 'Bush', 'Carter'});
            
            mp = mvvm.providers.SimpleModelProvider(mod);
            
            x = 0;
            function callback(src, args)
                x = x+1;
            end
            
            listener = addlistener(mp, 'modelChanged', @callback);
            scopeProvider = mvvm.scopes.MapScope(mp, 'list', 'b');
            
            scopeProvider.setModel('W.Bush');
            scopeProvider.setModel('Buchanan');
            scopeProvider.setModel('Bush');
            
            assert(isequal(0, x), 'The handle model was not supposed to be set, but as set %d times', x);
            
            delete(listener);
        end
        
        function listIsICollectionObject_DontUpdateModel(testCase)
            mod = struct();
            mod.list = mvvm.tests.TestCollection({'Jerusalem', 'Tel Aviv', 'Haifa'});
            
            mp = mvvm.providers.SimpleModelProvider(mod);
            
            x = 0;
            function callback(src, args)
                x = x+1;
            end
            
            listener = addlistener(mp, 'modelChanged', @callback);
            scopeProvider = mvvm.scopes.CollectionScope(mp, 'list', 2);
            
            scopeProvider.setModel('Rehovot');
            scopeProvider.setModel('Ramat Gan');
            scopeProvider.setModel('Nes Ziyona');
            
            assert(isequal(0, x), 'The handle model was not supposed to be set, but as set %d times', x);
            
            delete(listener);
        end
        
        function modelIsHandle_DontUpdateModel(testCase)
            mod = mvvm.tests.HandleModel();
            mod.list = {'The', 'Quick', 'Brown', 'Fox', 'Jumps', 'Over', 'The', 'Lazy', 'Dog'};
            mp = mvvm.providers.SimpleModelProvider(mod);
            
            x = 0;
            function callback(src, args)
                x = x+1;
            end
            
            listener = addlistener(mp, 'modelChanged', @callback);
            scopeProvider = mvvm.scopes.Scope(mp, 'list', 5, 'cells');
            
            scopeProvider.setModel('Leans');
            scopeProvider.setModel('Swims');
            scopeProvider.setModel('Screams');
            
            assert(isequal(0, x), 'The handle model was not supposed to be set, but as set %d times', x);
            
            delete(listener);
        end
    end
end


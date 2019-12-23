classdef DefaultScopeFactoryTests < matlab.unittest.TestCase

    properties
    end
    
    methods (TestMethodSetup)
    end
    
    methods(TestMethodTeardown)
    end
    
    methods (Test)
        function buildScopeForMatrix(testCase)
            dsb = mvvm.scopes.DefaultScopeFactory('rows');
            
            mp = mvvm.providers.SimpleModelProvider();
            scope = dsb.build(mp, '', magic(10), 1);
            
            assert(isequal(class(scope), 'mvvm.scopes.Scope'));
            assert(eq(scope.ModelProvider, mp));
            assert(isequal(scope.Key, 1));
            assert(isequal(scope.ModelPath, {''}));
        end
        
        function buildScopeForStructArray_DefaultIndexing(testCase)
            dsb = mvvm.scopes.DefaultScopeFactory('default');
            
            s.list = struct('a', {1 2 3 4 5});
            mp = mvvm.providers.SimpleModelProvider(s);
            scope = dsb.build(mp, 'list', s.list, 3);
            
            assert(isequal(class(scope), 'mvvm.scopes.Scope'));
            assert(eq(scope.ModelProvider, mp));
            assert(isequal(scope.Key, 3));
            assert(isequal(scope.KeyType, 'cells'));
            assert(isequal(scope.ModelPath, {'list'}));
        end
        
        function buildScopeForObjectArray_DefaultIndexing(testCase)
            dsb = mvvm.scopes.DefaultScopeFactory('default');
            
            s.list = [mvvm.tests.HandleModel() mvvm.tests.HandleModel() mvvm.tests.HandleModel()];
            mp = mvvm.providers.SimpleModelProvider(s);
            scope = dsb.build(mp, 'list', s.list, 2);
            
            assert(isequal(class(scope), 'mvvm.scopes.Scope'));
            assert(eq(scope.ModelProvider, mp));
            assert(isequal(scope.Key, 2));
            assert(isequal(scope.KeyType, 'cells'));
            assert(isequal(scope.ModelPath, {'list'}));
        end
        
        function buildScopeForMap(testCase)
            dsb = mvvm.scopes.DefaultScopeFactory('default');
            
            s = struct('a', containers.Map);
            mp = mvvm.providers.SimpleModelProvider(s);
            scope = dsb.build(mp, 'a', s.a, 'bla');
            
            assert(isa(scope, 'mvvm.scopes.MapScope'));
            assert(eq(scope.ModelProvider, mp));
            assert(isequal(scope.Key, 'bla'));
            assert(isequal(scope.ModelPath, {'a'}));
        end
        
        function buildScopeForTable(testCase)
            dsb = mvvm.scopes.DefaultScopeFactory('rownames');
            
            s.t = readtable('Patients.dat');
            s.t.Properties.RowNames = s.t.LastName;
            mp = mvvm.providers.SimpleModelProvider(s);
            scope = dsb.build(mp, 't', s.t, 'Hayes');
            
            assert(isa(scope, 'mvvm.scopes.TableScope'));
            assert(eq(scope.ModelProvider, mp));
            assert(isequal(scope.Key, 'Hayes'));
            assert(isequal(scope.ModelPath, {'t'}));
        end
        
        function buildScopeForCollection(testCase)
            dsb = mvvm.scopes.DefaultScopeFactory('default');
            
            s.m = lists.Map();
            mp = mvvm.providers.SimpleModelProvider(s);
            scope = dsb.build(mp, 'm', s.m, ':)');
            
            assert(isa(scope, 'mvvm.scopes.CollectionScope'));
            assert(eq(scope.ModelProvider, mp));
            assert(isequal(scope.Key, ':)'));
            assert(isequal(scope.ModelPath, {'m'}));
        end
        
        function buildFieldScope(testCase)
            dsb = mvvm.scopes.DefaultScopeFactory('fieldnames');
            
            s.a = 'ab';
            s.c = 'cd';
            s.e = 'ef';
            mp = mvvm.providers.SimpleModelProvider(s);
            scope = dsb.build(mp, '', s, 'c');
            
            assert(isa(scope, 'mvvm.scopes.FieldScope'));
            assert(eq(scope.ModelProvider, mp));
            assert(isequal(scope.Key, 'c'));
            assert(isequal(scope.ModelPath, {''}));
        end
        
        function invalidKeyTypeError(testCase)
            flag = true;
            try
                mvvm.scopes.DefaultScopeFactory('blah');
                flag = false;
            catch
                % this is good
            end
            
            assert(flag, 'The expected error didn''t occur');
        end
        
        function getRowKeys(testCase)
            dsb = mvvm.scopes.DefaultScopeFactory('rows');
            
            assert(isequal(1:10, dsb.getKeys(ones(10))));
            assert(isequal(1:5, dsb.getKeys(ones(5,1))));
            assert(isequal(1, dsb.getKeys(ones(1,5))));
        end
        
        function getRowKeysTable(testCase)
            dsb = mvvm.scopes.DefaultScopeFactory('rows');
            t = readtable('Patients.dat');
            
            assert(isequal(1:size(t, 1), dsb.getKeys(t)));
        end
        
        function getColKeys(testCase)
            dsb = mvvm.scopes.DefaultScopeFactory('cols');
            
            assert(isequal(1:10, dsb.getKeys(ones(10))));
            assert(isequal(1, dsb.getKeys(ones(5,1))));
            assert(isequal(1:5, dsb.getKeys(ones(1,5))));
        end
        
        function getColKeysTable(testCase)
            dsb = mvvm.scopes.DefaultScopeFactory('cols');
            t = readtable('Patients.dat');
            
            assert(isequal(1:size(t, 2), dsb.getKeys(t)));
        end
        
        function getCellsKeys(testCase)
            dsb = mvvm.scopes.DefaultScopeFactory('cells');
            
            assert(isequal(1:100, dsb.getKeys(ones(10))));
            assert(isequal(1:5, dsb.getKeys(ones(5,1))));
            assert(isequal(1:5, dsb.getKeys(ones(1,5))));
        end
        
        function getCellsKeysTable(testCase)
            dsb = mvvm.scopes.DefaultScopeFactory('cells');
            
            t = readtable('Patients.dat');
            
            flag = true;
            try
                dsb.getKeys(t);
                flag = false;
            catch
                % this is good
            end
            
            assert(flag);
        end
        
        function getCellsKeysMap(testCase)
            dsb = mvvm.scopes.DefaultScopeFactory('cells');
            
            t = readtable('Patients.dat');
            
            flag = true;
            try
                dsb.getKeys(t);
                flag = false;
            catch
                % this is good
            end
            
            assert(flag);
        end
        
    end

end


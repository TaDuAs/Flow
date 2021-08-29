classdef MessageBinderTests < matlab.unittest.TestCase & mvvm.providers.IModelProvider

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
        function createGUI(testCase)
            testCase.gui.fig = figure(99);
            testCase.gui.txt = uicontrol(testCase.gui.fig, 'style', 'text');
        end
        function createModel(testCase)
            testCase.model = mvvm.tests.generateTestingModel();
        end
    end
    
    methods (TestMethodTeardown)
        function terminateGui(testCase)
            close(testCase.gui.fig);
        end
    end
    
    methods (Test)
        function bindAllHandlesPath(testCase)
            mod = [];
            tf = [];
            function callback(newModel, flag)
                mod = newModel;
                tf = flag;
            end
            bnd = mvvm.MessageBinder('child1.child1.child1', @callback, testCase.gui, 'ModelProvider', testCase);
            
            assert(isempty(mod), 'callback shouldn''t have fired');
            
            testCase.model.child1.child1.child1 = ':)';
            
            assert(isequal(':)', mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            delete(bnd);
        end 
        
        function bindHandleValueHandle(testCase)
            mod = [];
            tf = [];
            function callback(newModel, flag)
                mod = newModel;
                tf = flag;
            end
            bnd = mvvm.MessageBinder('child2.child1.child2', @callback, testCase.gui, 'ModelProvider', testCase);
            
            assert(isempty(mod), 'callback shouldn''t have fired');
            assert(isempty(tf), 'callback shouldn''t have fired');
            
            testCase.model.child2.child1.child2 = 'it works';
            
            assert(isequal('it works', mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            delete(bnd);
        end 
        
        function bindHandleValueHandle_changeModel_child2(testCase)
            mod = [];
            tf = [];
            function callback(newModel, flag)
                mod = newModel;
                tf = flag;
            end
            bnd = mvvm.MessageBinder('child2.child1.child2', @callback, testCase.gui, 'ModelProvider', testCase);
            
            assert(isempty(mod), 'callback shouldn''t have fired');
            assert(isempty(tf), 'callback shouldn''t have fired');
            
            testCase.model.child2 = mvvm.tests.HandleModel(3,...
                mvvm.tests.ValueModel(31, [],...
                    'The quick bron fox'));
            
            assert(isequal('The quick bron fox', mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            delete(bnd);
        end 
        
        function bindHandleValueHandle_changeModel_child2_child1(testCase)
            mod = [];
            tf = [];
            function callback(newModel, flag)
                mod = newModel;
                tf = flag;
            end
            bnd = mvvm.MessageBinder('child2.child1.child2', @callback, testCase.gui, 'ModelProvider', testCase);
            
            assert(isempty(mod), 'callback shouldn''t have fired');
            assert(isempty(tf), 'callback shouldn''t have fired');
            
            testCase.model.child2.child1 = mvvm.tests.ValueModel(31, 'Jumps over the lazy dog',...
                    'The quick bron fox');
            
            assert(isequal('The quick bron fox', mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            delete(bnd);
        end 

        function bindHandleValueHandle_changeModel_child2_child1_child2(testCase)
            mod = [];
            tf = [];
            function callback(newModel, flag)
                mod = newModel;
                tf = flag;
            end
            bnd = mvvm.MessageBinder('child2.child1.child2', @callback, testCase.gui, 'ModelProvider', testCase);
            
            assert(isempty(mod), 'callback shouldn''t have fired');
            assert(isempty(tf), 'callback shouldn''t have fired');
            
            testCase.model.child2.child1.child2 = 'Jumps over the lazy dog';
            
            assert(isequal('Jumps over the lazy dog', mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            delete(bnd);
        end 
        
        function bindHandleValueHandle_subsequentModelUpdates_topDown(testCase)
            mod = [];
            tf = [];
            function callback(newModel, flag)
                mod = newModel;
                tf = flag;
            end
            bnd = mvvm.MessageBinder('child2.child1.child2', @callback, testCase.gui, 'ModelProvider', testCase);
            
            assert(isempty(mod), 'callback shouldn''t have fired');
            assert(isempty(tf), 'callback shouldn''t have fired');
            
            testCase.model.child2.child1.child2 = 'Jumps over the lazy dog';
            
            assert(isequal('Jumps over the lazy dog', mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            testCase.model.child2 = mvvm.tests.HandleModel(3,...
                mvvm.tests.ValueModel(31, [],...
                    'The quick bron fox2'));
            
            assert(isequal('The quick bron fox2', mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            delete(bnd);
        end 
        
        function bindHandleValueHandle_subsequentModelUpdates_bottomUp(testCase)
            mod = [];
            tf = [];
            function callback(newModel, flag)
                mod = newModel;
                tf = flag;
            end
            bnd = mvvm.MessageBinder('child2.child1.child2', @callback, testCase.gui, 'ModelProvider', testCase);
            
            testCase.model.child2 = mvvm.tests.HandleModel(3,...
                mvvm.tests.ValueModel(31, [],...
                    'The quick bron fox2'));
            
            assert(isequal('The quick bron fox2', mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            testCase.model.child2.child1.child2 = 'Jumps over the lazy dog';
            
            assert(isequal('Jumps over the lazy dog', mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            delete(bnd);
        end 
        
        
        function bindHandleValueHandle_changeModel_child2Child1Child2_several(testCase)
            mod = [];
            tf = [];
            function callback(newModel, flag)
                mod = newModel;
                tf = flag;
            end
            bnd = mvvm.MessageBinder('child2.child1.child2', @callback, testCase.gui, 'ModelProvider', testCase);
            
            testCase.model.child2.child1.child2 = 'The quick brown fox';
            
            assert(isequal('The quick brown fox', mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            testCase.model.child2.child1.child2 = 'Jumps over the lazy dog';
            
            assert(isequal('Jumps over the lazy dog', mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            testCase.model.child2.child1.child2 = 'Again and again';
            
            assert(isequal('Again and again', mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            delete(bnd);
        end 
        
        function bindHandleValueHandle_deleteStopsObserving(testCase)
            mod = [];
            tf = [];
            function callback(newModel, flag)
                mod = newModel;
                tf = flag;
            end
            bnd = mvvm.MessageBinder('child2.child1.child2', @callback, testCase.gui, 'ModelProvider', testCase);
            
            delete(bnd);
            
            testCase.model.child2.child1.child2 = 'Jumps over the lazy dog';
            
            assert(isempty(mod), 'callback shouldn''t have fired');
            assert(isempty(tf), 'callback shouldn''t have fired');
        end 
        
        function bindToEmptyPropertyThenPopulateIt(testCase)
            mod = [];
            tf = [];
            function callback(newModel, flag)
                mod = newModel;
                tf = flag;
            end
            bm = mvvm.tests.TestBindingManager();
            testCase.model = mvvm.tests.HandleModel(123, mvvm.tests.HandleModel.empty());
            
            % modelPath, control, property, event, modelProvider
            binder = mvvm.MessageBinder('child1.id', @callback, testCase.gui.txt, 'BindingManager', bm, 'ModelProvider', testCase);
                        
            testCase.model.child1 = mvvm.tests.HandleModel('345');
            
            assert(isequal('345', mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            delete(binder);
            delete(bm);
        end
        
        function bindNestedPropPathUnderEmptyPropertyThenPopulateIt(testCase)
            mod = [];
            tf = [];
            function callback(newModel, flag)
                mod = newModel;
                tf = flag;
            end
            bm = mvvm.tests.TestBindingManager();
            testCase.model = mvvm.tests.HandleModel(123, mvvm.tests.HandleModel.empty());
            
            % modelPath, control, property, event, modelProvider
            binder = mvvm.MessageBinder('child1.id', @callback, testCase.gui.txt, 'BindingManager', bm, 'ModelProvider', testCase);
                        
            testCase.model.child1 = mvvm.tests.HandleModel();
            testCase.model.child1.id = 'The dude';
            
            assert(isequal('The dude', mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            delete(binder);
            delete(bm);
        end
        
        function bindAllHandlesPath_NumericIndexer(testCase)
            mod = [];
            tf = [];
            function callback(newModel, flag)
                mod = newModel;
                tf = flag;
            end
            bnd = mvvm.MessageBinder('child1.child1.list', @callback, testCase.gui.txt, 'ModelProvider', testCase, 'Indexer', {[1 2]});
            
            testCase.model.child1.child1.list{1} = ':)';
            
            assert(isequal({':)', 'Quick'}, mod), 'Data binding on model change failed');
            assert(tf, 'model was supposed to be found');
            
            delete(bnd);
        end
        
    end

end
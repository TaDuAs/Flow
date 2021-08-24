classdef GuiOneWayBinderTests < matlab.unittest.TestCase & mvvm.providers.IModelProvider

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
            clf;
            testCase.gui.txt = uicontrol(testCase.gui.fig, 'style', 'edit');
            testCase.gui.lbl = uicontrol(testCase.gui.fig, 'style', 'text', 'position', [100, 5, 100, 30], 'String', 'label1');
        end
        function createModel(testCase)
            testCase.model = mvvm.tests.generateTestingModel();
        end
    end
    
    methods (TestMethodTeardown)
        function closeGUI(testCase)
            close(testCase.gui.fig);
        end
    end
    
    methods (Test)
        function textboxUpdatesModel(testCase)
            % modelPath, control, property, event, modelProvider
            binder = mvvm.GuiOneWayBinder('child1.child1.child2', testCase.gui.txt, 'String', 'Event', 'Action', 'ModelProvider', testCase);
            
            set(testCase.gui.txt, 'String', 'Hatul Shamen');
            notify(testCase.gui.txt, 'Action');
            
            assert(strcmp(testCase.model.child1.child1.child2, 'Hatul Shamen'), 'The model wasn''t updated properly');
            
            delete(binder);
        end
        
        function textboxUpdatesModel_NumericIndexer(testCase)
            % modelPath, control, property, event, modelProvider
            binder = mvvm.GuiOneWayBinder('child1.child1.list', testCase.gui.txt, 'String', 'Event', 'Action', 'ModelProvider', testCase, 'Indexer', {1});
            
            set(testCase.gui.txt, 'String', 'Hatul Shamen');
            notify(testCase.gui.txt, 'Action');
            
            assert(strcmp(testCase.model.child1.child1.list{1}, 'Hatul Shamen'), 'The model wasn''t updated properly');
            assert(isequaln(testCase.model.child1.child1.list, {'Hatul Shamen' 'Quick' 'Brown' 'Fox' 'Jumps' 'Over' 'The' 'Lazy' 'Dog'}), 'The model wasn''t updated properly');
            
            delete(binder);
        end
        
        function textboxUpdatesModel_NumericIndexer2(testCase)
            % modelPath, control, property, event, modelProvider
            binder = mvvm.GuiOneWayBinder('child1.child1.list', testCase.gui.txt, 'String', 'Event', 'Action', 'ModelProvider', testCase, 'Indexer', {9});
            
            set(testCase.gui.txt, 'String', 'Hatul Shamen');
            notify(testCase.gui.txt, 'Action');
            
            assert(strcmp(testCase.model.child1.child1.list{9}, 'Hatul Shamen'), 'The model wasn''t updated properly');
            assert(isequaln(testCase.model.child1.child1.list, {'The' 'Quick' 'Brown' 'Fox' 'Jumps' 'Over' 'The' 'Lazy' 'Hatul Shamen'}), 'The model wasn''t updated properly');
            
            delete(binder);
        end
        
        function textboxUpdatesModel_LogicalIndexer(testCase)
            % modelPath, control, property, event, modelProvider
            binder = mvvm.GuiOneWayBinder('child1.child1.list', testCase.gui.txt, 'String', 'Event', 'Action', 'ModelProvider', testCase, 'Indexer', {[false(1,8) true]});
            
            set(testCase.gui.txt, 'String', 'Hatul Shamen');
            notify(testCase.gui.txt, 'Action');
            
            assert(strcmp(testCase.model.child1.child1.list{9}, 'Hatul Shamen'), 'The model wasn''t updated properly');
            assert(isequaln(testCase.model.child1.child1.list, {'The' 'Quick' 'Brown' 'Fox' 'Jumps' 'Over' 'The' 'Lazy' 'Hatul Shamen'}), 'The model wasn''t updated properly');
            
            delete(binder);
        end
        
        function noEventListenerNoUpdate(testCase)
            % modelPath, control, property, event, modelProvider
            binder = mvvm.GuiOneWayBinder('child1.child1.child2', testCase.gui.txt, 'String', 'ModelProvider', testCase);
            
            set(testCase.gui.txt, 'String', 'Hatul Shamen');
            notify(testCase.gui.txt, 'Action');
            
            assert(~strcmp(testCase.model.child1.child1.child2, 'Hatul Shamen'), 'The model was updated when there was no event updating it');
            
            delete(binder);
        end
        
        function textboxDelayedUpdate(testCase)
            % modelPath, control, property, event, modelProvider
            binder = mvvm.GuiOneWayBinder('child1.child1.child2', testCase.gui.txt, 'String', 'Event', 'Action', 'UpdateDelay', 0.3, 'ModelProvider', testCase);
            
            set(testCase.gui.txt, 'String', 'Hatul Shamen++');
            notify(testCase.gui.txt, 'Action');
            
            assert(~strcmp(testCase.model.child1.child1.child2, 'Hatul Shamen++'), 'The model was updated before timeout');
            
            pauseState = pause('on');
            pause(0.4);
            pause(pauseState);
            
            assert(strcmp(testCase.model.child1.child1.child2, 'Hatul Shamen++'), 'The delay time was passed long ago, still no update');
            
            delete(binder);
        end
        
        function textboxDelayedUpdateKeepDelaying(testCase)
            % modelPath, control, property, event, modelProvider
            binder = mvvm.GuiOneWayBinder('child1.child1.child2', testCase.gui.txt, 'String', 'Event', 'Action', 'UpdateDelay', 0.3, 'ModelProvider', testCase);
            
            set(testCase.gui.txt, 'String', 'Hatul Shamen Yoter');
            
            pauseState = pause('on');
            
            for i = 1:5
                notify(testCase.gui.txt, 'Action');
                pause(0.1);
            end
            
            assert(~strcmp(testCase.model.child1.child1.child2, 'Hatul Shamen Yoter'), 'The events did not reset the model-update-timeout');
            
            pause(0.4);
            pause(pauseState);
            
            assert(strcmp(testCase.model.child1.child1.child2, 'Hatul Shamen Yoter'), 'The delay time was passed long ago, still no update');
            
            delete(binder);
        end
        
        function modelChangesDontUpdateGUI(testCase)
            binder = mvvm.GuiOneWayBinder('child2.child1.child2', testCase.gui.txt, 'String', 'Event', 'Callback', 'ModelProvider', testCase);
            
            assert(...
                ~isequal(testCase.model.child2.child1.child2, testCase.gui.txt.String), ...
                'Initial data binding failed. Model Value: ''%s'', TextBox Value: ''%s''', ...
                testCase.model.child2.child1.child2, ...
                testCase.gui.txt.String);
            
            testCase.model.child2.child1.child2 = 'it works';
            
            assert(...
                ~isequal('it works', testCase.gui.txt.String), ...
                'Data binding on model change failed. Model Value: ''%s'', TextBox Value: ''%s''', ...
                testCase.model.child2.child1.child2, ...
                testCase.gui.txt.String);
            
            delete(binder);
        end 
        
        function oneWayAdaptationBinding(testCase)
            bm = mvvm.tests.TestBindingManager();
            testCase.model = mvvm.tests.HandleModel('123');
            
            % modelPath, control, property, event, modelProvider
            binder = mvvm.GuiOneWayBinder('id', testCase.gui.txt, 'String', @(s) [s ' added text'], 'Event', 'Action', 'BindingManager', bm, 'ModelProvider', testCase);
                        
            testCase.gui.txt.String = '345';
            notify(testCase.gui.txt, 'Action');
            
            assert(...
                isequal('345 added text', testCase.model.id), ...
                'Binder should have created the binding once child1 was set', ...
                testCase.model.id, ...
                testCase.gui.txt.String);
            
            delete(binder);
        end
    end

end
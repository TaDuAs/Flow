classdef AdaptationBinderTests < matlab.unittest.TestCase & mvvm.providers.IModelProvider

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
        function bindToEmptyPropertyThenPopulateIt(testCase)
            bm = mvvm.tests.TestBindingManager();
            testCase.model = mvvm.tests.HandleModel(123, mvvm.tests.HandleModel.empty());
            
            % modelPath, control, property, event, modelProvider
            binder = mvvm.AdaptationBinder('child1.id', testCase.gui.txt, 'String', @(s) [s ' added text'], 'BindingManager', bm, 'ModelProvider', testCase);
                        
            testCase.model.child1 = mvvm.tests.HandleModel('345');
            
            assert(...
                isequal('345 added text', testCase.gui.txt.String), ...
                'Binder should have created the binding once child1 was set', ...
                testCase.model.child1.id, ...
                testCase.gui.txt.String);
        end
    end

end
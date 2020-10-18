classdef RepeaterTests < matlab.unittest.TestCase & mvvm.providers.IModelProvider
    
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
            testCase.gui.container = sui.FlowBox(...
                'Parent', testCase.gui.fig,...
                'Units', 'norm', ...
                'BasePosition', [0 0.15 1 0.5], ...
                'BackgroundColor', 'White', ...
                'Spacing', 5, ...
                'Padding', 15);
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
        function initialBinding(testCase)
            rep = mvvm.Repeater('child1.child1.list', testCase.gui.container, mvvm.tests.LabelsTestTemplate(),...
                'ModelProvider', testCase,...
                'IndexingMethod', 'cells');
            
            assert(numel(testCase.gui.container.Contents) == numel(testCase.model.child1.child1.list));
            for i = 1:numel(testCase.model.child1.child1.list)
                assert(strcmp(testCase.gui.container.Contents(i).String, testCase.model.child1.child1.list{i}));
            end
            
            delete(rep);
        end
        
        function ListValueChanged(testCase)
            rep = mvvm.Repeater('child1.child1.list', testCase.gui.container, mvvm.tests.LabelsTestTemplate(),...
                'ModelProvider', testCase,...
                'IndexingMethod', 'cells');
            
            testCase.model.child1.child1.list{1} = 'Changed';
            assert(strcmp(testCase.gui.container.Contents(1).String, 'Changed'));
            
            delete(rep);
        end
        
        function ListValueRemoved(testCase)
            rep = mvvm.Repeater('child1.child1.list', testCase.gui.container, mvvm.tests.LabelsTestTemplate(),...
                'ModelProvider', testCase,...
                'IndexingMethod', 'cells');
            
            testCase.model.child1.child1.list(1) = [];

            
            assert(numel(testCase.gui.container.Contents) == numel(testCase.model.child1.child1.list));
            for i = 1:numel(testCase.model.child1.child1.list)
                assert(strcmp(testCase.gui.container.Contents(i).String, testCase.model.child1.child1.list{i}));
            end
            
            delete(rep);
        end
        
        function ListValueAdded(testCase)
            rep = mvvm.Repeater('child1.child1.list', testCase.gui.container, mvvm.tests.LabelsTestTemplate(),...
                'ModelProvider', testCase,...
                'IndexingMethod', 'cells');
            
            testCase.model.child1.child1.list{numel(testCase.model.child1.child1.list) + 1} = 'Aha!';
            
            assert(numel(testCase.gui.container.Contents) == numel(testCase.model.child1.child1.list));
            for i = 1:numel(testCase.model.child1.child1.list)
                assert(strcmp(testCase.gui.container.Contents(i).String, testCase.model.child1.child1.list{i}));
            end
            
            delete(rep);
        end
        
        function ScopedBindingsWork(testCase)
            rep = mvvm.Repeater('child1.child1.list', testCase.gui.container, mvvm.tests.TextEditAndLabelTestTemplate(0),...
                'ModelProvider', testCase,...
                'IndexingMethod', 'cells');
            
            txt = testCase.gui.container.Contents(1);
            txt.String = 'Text Changed';
            txt.notify('KeyRelease');
            
            assert(strcmp(testCase.model.child1.child1.list{1}, 'Text Changed'));
            assert(strcmp(testCase.gui.container.Contents(2).String, 'Text Changed'));
            
            delete(rep);
        end
    end
end


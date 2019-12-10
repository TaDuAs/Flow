classdef CommandTests < matlab.unittest.TestCase & mvvm.providers.IModelProvider
    
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
            testCase.gui.btn = uicontrol(testCase.gui.fig, 'style', 'pushbutton', 'position', [100, 5, 100, 30], 'String', 'click me');
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
        function commandParams_1value(testCase)
            cmd = mvvm.Command('doSomething', testCase.gui.btn, 'Action', 'ModelProvider', testCase, 'Params', {1});
            
            assert(isequal(cmd.ConstantParams, {1}));
            assert(isempty(cmd.DynamicParams));
            
            delete(cmd);
        end
        
        function commandParams_2value(testCase)
            cmd = mvvm.Command('doSomething', testCase.gui.btn, 'Action', 'ModelProvider', testCase, 'Params', {1, 1:10});
            
            assert(isequal(cmd.ConstantParams, {1, 1:10}));
            assert(isempty(cmd.DynamicParams));
            
            delete(cmd);
        end
        
        function commandParams_valueHandle(testCase)
            cmd = mvvm.Command('doSomething', testCase.gui.btn, 'Action', 'ModelProvider', testCase, 'Params', {1, testCase.model});
            
            assert(isequal(cmd.ConstantParams, {1, testCase.model}));
            assert(isempty(cmd.DynamicParams));
            
            delete(cmd);
        end
        
        function commandParams_dynamicValue(testCase)
            cmd = mvvm.Command('doSomething', testCase.gui.btn, 'Action', 'ModelProvider', testCase, 'Params', {testCase});
            
            assert(isempty(cmd.ConstantParams));
            assert(isequal(cmd.DynamicParams, {testCase}));
            
            delete(cmd);
        end
        
        function buttonNotifyCommand_NoParameters(testCase)
            cmd = mvvm.Command('doSomething', testCase.gui.btn, 'Action', 'ModelProvider', testCase);
            
            notify(testCase.gui.btn, 'Action');
            
            assert(testCase.model.didSomething.n == 1);
            
            delete(cmd);
        end
        
        function buttonNotifyCommand_Value(testCase)
            cmd = mvvm.Command('doSomething', testCase.gui.btn, 'Action', 'ModelProvider', testCase, 'Params', {1});
            
            notify(testCase.gui.btn, 'Action');
            
            assert(testCase.model.didSomething.n == 2);
            assert(isequal(testCase.model.didSomething.a, 1));
            
            delete(cmd);
        end
        
        function buttonNotifyCommand_SomeValues(testCase)
            cmd = mvvm.Command('doSomething', testCase.gui.btn, 'Action', 'ModelProvider', testCase, 'Params', {1 1:10});
            
            notify(testCase.gui.btn, 'Action');
            
            assert(testCase.model.didSomething.n == 3);
            assert(isequal(testCase.model.didSomething.a, 1));
            assert(isequal(testCase.model.didSomething.b, 1:10));
            
            delete(cmd);
        end
        
        function buttonNotifyCommand_DynamicParams(testCase)
            cmd = mvvm.Command('doSomething', testCase.gui.btn, 'Action', 'ModelProvider', testCase, 'Params', {testCase});
            
            notify(testCase.gui.btn, 'Action');
            
            assert(testCase.model.didSomething.n == 2);
            assert(isequal(testCase.model.didSomething.a, testCase.model));
            
            delete(cmd);
        end
        
        function buttonNotifyCommand_ConstAndDynamicParams(testCase)
            cmd = mvvm.Command('doSomething', testCase.gui.btn, 'Action', 'ModelProvider', testCase, 'Params', {1:10, testCase, 'blah'});
            
            notify(testCase.gui.btn, 'Action');
            
            assert(testCase.model.didSomething.n == 4);
            assert(isequal(testCase.model.didSomething.a, 1:10));
            assert(isequal(testCase.model.didSomething.b, testCase.model));
            assert(isequal(testCase.model.didSomething.c, 'blah'));
            
            delete(cmd);
        end
        
        function buttonNotifyCommand_ConstAndDynamicParams_DifferentOrder(testCase)
            cmd = mvvm.Command('doSomething', testCase.gui.btn, 'Action', 'ModelProvider', testCase, 'Params', {testCase, 1:10, 'blah'});
            
            notify(testCase.gui.btn, 'Action');
            
            assert(testCase.model.didSomething.n == 4);
            assert(isequal(testCase.model.didSomething.a, testCase.model));
            assert(isequal(testCase.model.didSomething.b, 1:10));
            assert(isequal(testCase.model.didSomething.c, 'blah'));
            
            delete(cmd);
        end
        
        function buttonNotifyCommand_ControlAccessParam(testCase)
            controlParam = mvvm.providers.ViewCommandParameter(testCase.gui.btn, 'String');
            cmd = mvvm.Command('doSomething', testCase.gui.btn, 'Action', 'ModelProvider', testCase, 'Params', {controlParam});
            
            notify(testCase.gui.btn, 'Action');
            
            assert(testCase.model.didSomething.n == 2);
            assert(isequal(testCase.model.didSomething.a, testCase.gui.btn.String));
            
            delete(cmd);
        end
    end
end


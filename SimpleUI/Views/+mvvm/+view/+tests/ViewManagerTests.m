classdef ViewManagerTests < matlab.mock.TestCase 
    methods (Test)
        function startView(testCase)
            import matlab.mock.actions.AssignOutputs;
            import matlab.mock.constraints.WasCalled;
            import matlab.mock.actions.ThrowException;
            
            [iocMock, iocBehav] = createMock(testCase, ?IoC.IContainer);
            [appMock, appBehav] = createMock(testCase, ?appd.IApp);
            [viewMock, viewBehav] = createMock(testCase, ?mvvm.view.IView);
            appMock.iocContainer = iocMock;
            
            testCase.assignOutputsWhen(withAnyInputs(iocBehav.getType), "mvvm.view.View");
            testCase.assignOutputsWhen(withAnyInputs(iocBehav.get), viewMock);
            
            vm = mvvm.view.ViewManager(appMock);
            
            vm.start('view');
            
            testCase.verifyThat(withAnyInputs(viewBehav.start()), WasCalled());
        end
        
    end
end


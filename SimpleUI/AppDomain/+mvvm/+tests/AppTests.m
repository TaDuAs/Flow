classdef AppTests < matlab.mock.TestCase
    methods (Test)
        function ctorTest(testCase)
            app = mvvm.App();
            
            assert(~isempty(app.Messenger));
            assert(~isempty(app.IocContainer));
            assert(~isempty(app.Context));
            assert(app.Status == mvvm.AppStatus.NotAvailable);
        end
        
        function ctorWithIoCTest(testCase)
            iocMock = testCase.createMock(?IoC.IContainer);
            
            app = mvvm.App(iocMock);
            
            assert(~isempty(app.Messenger));
            assert(~isempty(app.Context));
            assert(app.IocContainer == iocMock);
            assert(app.Status == mvvm.AppStatus.NotAvailable);
        end
        
        function basicIoCConfiguration(testCase)
            ioc = IoC.Container();
            app = mvvm.App(ioc);
            
            app.start();
            
            assert(app == ioc.get("App"));
            assert(app.Messenger == ioc.get("Messenger"));
        end
        
        function lifecycleStatus(testCase)
            app = mvvm.App();
            
            app.start();
            
            assert(app.Status == mvvm.AppStatus.Loaded);
        end
        
        function killItems(testCase)
            h = containers.Map(); % any handle class
            app = mvvm.App();
            
            app.addKillItem(h);
            app.kill();
            
            assert(~isvalid(h));
        end
        
        function restartAppTerminatesKillItems(testCase)
            h = containers.Map(); % any handle class
            app = mvvm.App();
            
            app.addKillItem(h);
            app.restart();
            
            assert(~isvalid(h));
        end
        
        function restartmvvmoesntAffectIoC(testCase)
            ioc = IoC.Container();
            ioc.set('Blah', @gen.tests.HandleModel);
            app = mvvm.App(ioc);
            
            app.restart();
            
            assert(ioc.hasDependency('Blah'));
        end
        
        function getControllerNoneRegistered(testCase)
            app = mvvm.App();
            
            testCase.verifyError(@() app.getController("blah"), 'App:GetController:NotRegistered');
        end
        
        function getControllerWrongName(testCase)
            ctlMock = testCase.createMock(?mvvm.AppController);
            cb = mvvm.AppControllerBuilder("blah", @() ctlMock);
            
            app = mvvm.App();
            
            app.registerController(cb);
            
            testCase.verifyError(@() app.getController("blah2"), 'App:GetController:NotRegistered');
        end
        
        function getController(testCase)
            ctlMock = testCase.createMock(?mvvm.AppController);
            cb = mvvm.AppControllerBuilder("blah", @() ctlMock);
            
            app = mvvm.App();
            
            app.registerController(cb);
            
            actual = app.getController("blah");
            testCase.verifyEqual(actual, ctlMock);
            testCase.verifyEqual(actual, ctlMock);
        end
        
        function restartAppClearsControllers(testCase)
            ctlMock = testCase.createMock(?mvvm.AppController);
            cb = mvvm.AppControllerBuilder("blah", @() ctlMock);
            
            app = mvvm.App();
            app.registerController(cb);
            
            app.restart();
            
            testCase.verifyError(@() app.getController("blah"), 'App:GetController:NotRegistered');
        end
    end
end


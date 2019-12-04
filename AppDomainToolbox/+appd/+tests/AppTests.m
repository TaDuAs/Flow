classdef AppTests < matlab.mock.TestCase
    methods (Test)
        function ctorTest(testCase)
            app = appd.App();
            
            assert(~isempty(app.Messenger));
            assert(~isempty(app.IocContainer));
            assert(~isempty(app.Context));
            assert(app.Status == appd.AppStatus.NotAvailable);
        end
        
        function ctorWithIoCTest(testCase)
            iocMock = testCase.createMock(?IoC.IContainer);
            
            app = appd.App(iocMock);
            
            assert(~isempty(app.Messenger));
            assert(~isempty(app.Context));
            assert(app.IocContainer == iocMock);
            assert(app.Status == appd.AppStatus.NotAvailable);
        end
        
        function basicIoCConfiguration(testCase)
            ioc = IoC.Container();
            app = appd.App(ioc);
            
            app.start();
            
            assert(app == ioc.get("App"));
            assert(app.Messenger == ioc.get("Messenger"));
        end
        
        function lifecycleStatus(testCase)
            app = appd.App();
            
            app.start();
            
            assert(app.Status == appd.AppStatus.Loaded);
        end
        
        function killItems(testCase)
            h = containers.Map(); % any handle class
            app = appd.App();
            
            app.addKillItem(h);
            app.kill();
            
            assert(~isvalid(h));
        end
        
        function restartAppTerminatesKillItems(testCase)
            h = containers.Map(); % any handle class
            app = appd.App();
            
            app.addKillItem(h);
            app.restart();
            
            assert(~isvalid(h));
        end
        
        function restartAppDoesntAffectIoC(testCase)
            ioc = IoC.Container();
            ioc.set('Blah', @gen.tests.HandleModel);
            app = appd.App(ioc);
            
            app.restart();
            
            assert(ioc.hasDependency('Blah'));
        end
        
        function getControllerNoneRegistered(testCase)
            app = appd.App();
            
            testCase.verifyError(@() app.getController("blah"), 'App:GetController:NotRegistered');
        end
        
        function getControllerWrongName(testCase)
            ctlMock = testCase.createMock(?appd.AppController);
            cb = appd.AppControllerBuilder("blah", @() ctlMock);
            
            app = appd.App();
            
            app.registerController(cb);
            
            testCase.verifyError(@() app.getController("blah2"), 'App:GetController:NotRegistered');
        end
        
        function getController(testCase)
            ctlMock = testCase.createMock(?appd.AppController);
            cb = appd.AppControllerBuilder("blah", @() ctlMock);
            
            app = appd.App();
            
            app.registerController(cb);
            
            actual = app.getController("blah");
            testCase.verifyEqual(actual, ctlMock);
            testCase.verifyEqual(actual, ctlMock);
        end
        
        function restartAppClearsControllers(testCase)
            ctlMock = testCase.createMock(?appd.AppController);
            cb = appd.AppControllerBuilder("blah", @() ctlMock);
            
            app = appd.App();
            app.registerController(cb);
            
            app.restart();
            
            testCase.verifyError(@() app.getController("blah"), 'App:GetController:NotRegistered');
        end
    end
end


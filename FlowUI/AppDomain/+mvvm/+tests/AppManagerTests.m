classdef AppManagerTests < matlab.mock.TestCase
    methods (Test)
        function appRegistration(testCase)
            mvvm.AppManager.clear();
            
            app = mvvm.App([], "Id", "hatul");
            mvvm.AppManager.set("hatul", app);
            
            registered = mvvm.AppManager.get("hatul");
            
            testCase.verifyEqual(registered, app);
            testCase.verifyEqual(app.Status, mvvm.AppStatus.Loaded);
        end
        
        function loadNewApp(testCase)
            mvvm.AppManager.clear();
            
            app = mvvm.AppManager.load("hatul", @mvvm.App);
            
            testCase.verifyClass(app, 'mvvm.App');
            testCase.verifyEqual(app.Id, "mvvm.App"); % app manager doesn't change app id to match the app manager id
            testCase.verifyEqual(app.Status, mvvm.AppStatus.Loaded);
        end
        
        function loadNewAppUsingNestedFunction(testCase)
            mvvm.AppManager.clear();
            
            function app = doLoadApp()
                app = mvvm.App([], "Id", "hatul");
            end
            app = mvvm.AppManager.load("hatul", @doLoadApp);
            
            testCase.verifyClass(app, 'mvvm.App');
            testCase.verifyEqual(app.Id, "hatul");
            testCase.verifyEqual(app.Status, mvvm.AppStatus.Loaded);
        end
        
        function loadExistingApp(testCase)
            mvvm.AppManager.clear();
            
            app1 = mvvm.AppManager.load("hatul", @mvvm.App);
            app2 = mvvm.AppManager.load("hatul", @mvvm.App);
            
            testCase.verifyEqual(app1, app2);
        end
        
        function loadExistingAppUsingNestedFunction(testCase)
            mvvm.AppManager.clear();
            
            function app = doLoadApp()
                app = mvvm.App([], "Id", "hatul");
            end
            app1 = mvvm.AppManager.load("hatul", @doLoadApp);
            app2 = mvvm.AppManager.load("hatul", @doLoadApp);
            
            testCase.verifyEqual(app1, app2);
        end
        
        function loadWithNestedFunctionNotOverridingExistingApp(testCase)
            mvvm.AppManager.clear();
            
            function app = doLoadApp()
                app = mvvm.App();
            end
            app1 = mvvm.AppManager.load("hatul", @mvvm.App);
            app2 = mvvm.AppManager.load("hatul", @doLoadApp);
            
            testCase.verifyEqual(app1, app2);
        end
        
        function loadOverrideExistingApp(testCase)
            mvvm.AppManager.clear();
            
            app1 = mvvm.AppManager.load("hatul", @mvvm.App);
            app2 = mvvm.AppManager.load("hatul", @mvvm.tests.TestApp);
            
            testCase.verifyNotEqual(app1, app2);
            testCase.verifyClass(app2, 'mvvm.tests.TestApp');
        end
        
        function multipleApps(testCase)
            mvvm.AppManager.clear();
            
            hatul = mvvm.App([], "Id", "hatul");
            blah = mvvm.App([], "Id", "blah");
            mvvm.AppManager.set(hatul.Id, hatul);
            mvvm.AppManager.set(blah.Id, blah);
            
            registeredH = mvvm.AppManager.get("hatul");
            registeredB = mvvm.AppManager.get("blah");
            
            testCase.verifyEqual(registeredH, hatul);
            testCase.verifyEqual(registeredB, blah);
            testCase.verifyNotEqual(registeredH, registeredB);
        end
        
        function removeId(testCase)
            mvvm.AppManager.clear();
            
            app = mvvm.App([], "Id", "hatul");
            mvvm.AppManager.set("hatul", app);
            
            mvvm.AppManager.remove("hatul");
            
            pc = mvvm.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
        end
        
        function removeIdDoesntInflictOtherIds(testCase)
            mvvm.AppManager.clear();
            
            hatul = mvvm.App([], "Id", "hatul");
            blah = mvvm.App([], "Id", "blah");
            mvvm.AppManager.set(hatul.Id, hatul);
            mvvm.AppManager.set(blah.Id, blah);
            
            mvvm.AppManager.remove("hatul");
            
            pc = mvvm.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
            testCase.verifyTrue(pc.hasEntry("blah"));
        end
        
        function removeApp(testCase)
            mvvm.AppManager.clear();
            
            app = mvvm.App([], "Id", "hatul");
            mvvm.AppManager.set("hatul", app);
            
            mvvm.AppManager.removeApp(app, "hatul");
            
            pc = mvvm.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
        end
        
        function removemvvmoesntInflictOtherApps(testCase)
            mvvm.AppManager.clear();
            
            hatul = mvvm.App([], "Id", "hatul");
            blah = mvvm.App([], "Id", "blah");
            mvvm.AppManager.set(hatul.Id, hatul);
            mvvm.AppManager.set(blah.Id, blah);
            
            mvvm.AppManager.removeApp(hatul, "hatul");
            
            pc = mvvm.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
            testCase.verifyTrue(pc.hasEntry("blah"));
        end
        
        function removeAppAccordingToAppId(testCase)
            mvvm.AppManager.clear();
            
            app = mvvm.App([], "Id", "hatul");
            mvvm.AppManager.set("hatul", app);
            
            mvvm.AppManager.removeApp(app);
            
            pc = mvvm.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
        end
        
        function appRemovedWhenDeleted(testCase)
            mvvm.AppManager.clear();
            
            hatul = mvvm.App([], "Id", "hatul");
            mvvm.AppManager.set(hatul.Id, hatul);
            
            hatul.kill();
            
            pc = mvvm.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
            testCase.verifyEmpty(pc.allKeys());
        end
        
        function appRemovedWhenDeletedOthersArent(testCase)
            mvvm.AppManager.clear();
            
            hatul = mvvm.App([], "Id", "hatul");
            blah = mvvm.App([], "Id", "blah");
            mvvm.AppManager.set(hatul.Id, hatul);
            mvvm.AppManager.set(blah.Id, blah);
            
            hatul.kill();
            
            pc = mvvm.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
            testCase.verifyTrue(pc.hasEntry("blah"));
        end
        
        function getAppsList(testCase)
            mvvm.AppManager.clear();
            
            hatul = mvvm.App([], "Id", "ha.tul");
            blah = mvvm.App([], "Id", "blah");
            mvvm.AppManager.set(hatul.Id, hatul);
            mvvm.AppManager.set(blah.Id, blah);
            
            apps = mvvm.AppManager.list();
            
            testCase.verifyEqual(hatul, apps.ha_tul);
            testCase.verifyEqual(blah, apps.blah);
        end
        
        function clearAppManager(testCase)
            mvvm.AppManager.clear();
            
            hatul = mvvm.App([], "Id", "hatul");
            blah = mvvm.App([], "Id", "blah");
            mvvm.AppManager.set(hatul.Id, hatul);
            mvvm.AppManager.set(blah.Id, blah);
            
            mvvm.AppManager.clear();
            
            pc = mvvm.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
            testCase.verifyFalse(pc.hasEntry("blah"));
            testCase.verifyEmpty(pc.allKeys());
        end
    end
end


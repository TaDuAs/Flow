classdef AppManagerTests < matlab.mock.TestCase
    methods (Test)
        function appRegistration(testCase)
            appd.AppManager.clear();
            
            app = appd.App([], "Id", "hatul");
            appd.AppManager.set("hatul", app);
            
            registered = appd.AppManager.get("hatul");
            
            testCase.verifyEqual(registered, app);
            testCase.verifyEqual(app.Status, appd.AppStatus.Loaded);
        end
        
        function loadNewApp(testCase)
            appd.AppManager.clear();
            
            app = appd.AppManager.load("hatul", @appd.App);
            
            testCase.verifyClass(app, 'appd.App');
            testCase.verifyEqual(app.Id, "appd.App"); % app manager doesn't change app id to match the app manager id
            testCase.verifyEqual(app.Status, appd.AppStatus.Loaded);
        end
        
        function loadNewAppUsingNestedFunction(testCase)
            appd.AppManager.clear();
            
            function app = doLoadApp()
                app = appd.App([], "Id", "hatul");
            end
            app = appd.AppManager.load("hatul", @doLoadApp);
            
            testCase.verifyClass(app, 'appd.App');
            testCase.verifyEqual(app.Id, "hatul");
            testCase.verifyEqual(app.Status, appd.AppStatus.Loaded);
        end
        
        function loadExistingApp(testCase)
            appd.AppManager.clear();
            
            app1 = appd.AppManager.load("hatul", @appd.App);
            app2 = appd.AppManager.load("hatul", @appd.App);
            
            testCase.verifyEqual(app1, app2);
        end
        
        function loadExistingAppUsingNestedFunction(testCase)
            appd.AppManager.clear();
            
            function app = doLoadApp()
                app = appd.App([], "Id", "hatul");
            end
            app1 = appd.AppManager.load("hatul", @doLoadApp);
            app2 = appd.AppManager.load("hatul", @doLoadApp);
            
            testCase.verifyEqual(app1, app2);
        end
        
        function loadWithNestedFunctionNotOverridingExistingApp(testCase)
            appd.AppManager.clear();
            
            function app = doLoadApp()
                app = appd.App();
            end
            app1 = appd.AppManager.load("hatul", @appd.App);
            app2 = appd.AppManager.load("hatul", @doLoadApp);
            
            testCase.verifyEqual(app1, app2);
        end
        
        function loadOverrideExistingApp(testCase)
            appd.AppManager.clear();
            
            app1 = appd.AppManager.load("hatul", @appd.App);
            app2 = appd.AppManager.load("hatul", @appd.tests.TestApp);
            
            testCase.verifyNotEqual(app1, app2);
            testCase.verifyClass(app2, 'appd.tests.TestApp');
        end
        
        function multipleApps(testCase)
            appd.AppManager.clear();
            
            hatul = appd.App([], "Id", "hatul");
            blah = appd.App([], "Id", "blah");
            appd.AppManager.set(hatul.Id, hatul);
            appd.AppManager.set(blah.Id, blah);
            
            registeredH = appd.AppManager.get("hatul");
            registeredB = appd.AppManager.get("blah");
            
            testCase.verifyEqual(registeredH, hatul);
            testCase.verifyEqual(registeredB, blah);
            testCase.verifyNotEqual(registeredH, registeredB);
        end
        
        function removeId(testCase)
            appd.AppManager.clear();
            
            app = appd.App([], "Id", "hatul");
            appd.AppManager.set("hatul", app);
            
            appd.AppManager.remove("hatul");
            
            pc = appd.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
        end
        
        function removeIdDoesntInflictOtherIds(testCase)
            appd.AppManager.clear();
            
            hatul = appd.App([], "Id", "hatul");
            blah = appd.App([], "Id", "blah");
            appd.AppManager.set(hatul.Id, hatul);
            appd.AppManager.set(blah.Id, blah);
            
            appd.AppManager.remove("hatul");
            
            pc = appd.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
            testCase.verifyTrue(pc.hasEntry("blah"));
        end
        
        function removeApp(testCase)
            appd.AppManager.clear();
            
            app = appd.App([], "Id", "hatul");
            appd.AppManager.set("hatul", app);
            
            appd.AppManager.removeApp(app, "hatul");
            
            pc = appd.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
        end
        
        function removeAppDoesntInflictOtherApps(testCase)
            appd.AppManager.clear();
            
            hatul = appd.App([], "Id", "hatul");
            blah = appd.App([], "Id", "blah");
            appd.AppManager.set(hatul.Id, hatul);
            appd.AppManager.set(blah.Id, blah);
            
            appd.AppManager.removeApp(hatul, "hatul");
            
            pc = appd.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
            testCase.verifyTrue(pc.hasEntry("blah"));
        end
        
        function removeAppAccordingToAppId(testCase)
            appd.AppManager.clear();
            
            app = appd.App([], "Id", "hatul");
            appd.AppManager.set("hatul", app);
            
            appd.AppManager.removeApp(app);
            
            pc = appd.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
        end
        
        function appRemovedWhenDeleted(testCase)
            appd.AppManager.clear();
            
            hatul = appd.App([], "Id", "hatul");
            appd.AppManager.set(hatul.Id, hatul);
            
            hatul.kill();
            
            pc = appd.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
            testCase.verifyEmpty(pc.allKeys());
        end
        
        function appRemovedWhenDeletedOthersArent(testCase)
            appd.AppManager.clear();
            
            hatul = appd.App([], "Id", "hatul");
            blah = appd.App([], "Id", "blah");
            appd.AppManager.set(hatul.Id, hatul);
            appd.AppManager.set(blah.Id, blah);
            
            hatul.kill();
            
            pc = appd.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
            testCase.verifyTrue(pc.hasEntry("blah"));
        end
        
        function getAppsList(testCase)
            appd.AppManager.clear();
            
            hatul = appd.App([], "Id", "ha.tul");
            blah = appd.App([], "Id", "blah");
            appd.AppManager.set(hatul.Id, hatul);
            appd.AppManager.set(blah.Id, blah);
            
            apps = appd.AppManager.list();
            
            testCase.verifyEqual(hatul, apps.ha_tul);
            testCase.verifyEqual(blah, apps.blah);
        end
        
        function clearAppManager(testCase)
            appd.AppManager.clear();
            
            hatul = appd.App([], "Id", "hatul");
            blah = appd.App([], "Id", "blah");
            appd.AppManager.set(hatul.Id, hatul);
            appd.AppManager.set(blah.Id, blah);
            
            appd.AppManager.clear();
            
            pc = appd.AppManager.getContainer();
            
            testCase.verifyFalse(pc.hasEntry("hatul"));
            testCase.verifyFalse(pc.hasEntry("blah"));
            testCase.verifyEmpty(pc.allKeys());
        end
    end
end


classdef SessionTests < matlab.mock.TestCase
    methods (Test)
        function start1Session(testCase)
            app = appd.App();
            
            [sid, session] = app.startSession();
            
            assert(ischar(sid) && isrow(sid));
            assert(isa(session, 'appd.AppSession'));
        end
        
        function start2Sessions(testCase)
            app = appd.App();
            
            sid1 = app.startSession();
            sid2 = app.startSession();
            
            assert(~strcmp(sid1, sid2));
        end
        
        function sessionContextSeparateFromAppContext(testCase)
            app = appd.App();
            
            [sid, session] = app.startSession();
            
            app.Context.set('Blah', 123);
            
            assert(~session.Context.hasEntry('Blah'));
            
            session.Context.set('Blah', "And Now for Something Completely Different");
            
            assert(isequal(session.Context.get('Blah'), "And Now for Something Completely Different"));
            assert(isequal(app.Context.get('Blah'), 123));
        end
        
        function sessionContextPersists(testCase)
            app = appd.App();
            
            [sid, session] = app.startSession();
            
            session.Context.set('Blah', "And Now for Something Completely Different");
            
            delete(session);
            
            session2 = app.getSession(sid);
            
            assert(isequal(session2.Context.get('Blah'), "And Now for Something Completely Different"));
        end
        
        function differentSessionsHaveSeparateContexts(testCase)
            app = appd.App();
            
            [sid1, session1] = app.startSession();
            [sid2, session2] = app.startSession();
            
            session1.Context.set('Blah', "And Now for Something Completely Different");
            
            assert(~session2.Context.hasEntry('Blah'));
            assert(isequal(session1.Context.get('Blah'), "And Now for Something Completely Different"));
            
            session2.Context.set('Blah', 123);

            assert(isequal(session1.Context.get('Blah'), "And Now for Something Completely Different"));
            assert(isequal(session2.Context.get('Blah'), 123));
        end
        
        function clearSession(testCase)
            app = appd.App();
            
            [sid1, session1] = app.startSession();
            
            session1.Context.set('Blah', "And Now for Something Completely Different");
            
            app.clearAllSessions();
            
            testCase.verifyError(@() session1.Context, 'AppSession:Expired');
            testCase.verifyError(@() app.getSession(sid1), 'AppSession:Expired');
        end
        
        function sessionGetApp(testCase)
            app = appd.App();
            
            [sid, session] = app.startSession();
            
            assert(isequal(session.getApp(), app));
        end
        
        function sessionGetController(testCase)
            ctlMock = testCase.createMock(?appd.AppController);
            cb = appd.AppControllerBuilder("blah", @() ctlMock);
            
            app = appd.App();
            
            app.registerController(cb);
            
            [sid, session] = app.startSession();
            actual = session.getController("blah");
            
            testCase.verifyEqual(actual, ctlMock);
            testCase.verifyEqual(actual.App, session);
        end
    end
end


classdef AppDataTests < matlab.unittest.TestCase

    properties
        fig;
    end
    
    methods (TestMethodSetup)
        function createGUI(testCase)
            testCase.fig = figure(99);
        end
    end
    
    methods(TestMethodTeardown)
        function closeFigure(testCase)
            close(testCase.fig)
        end
    end
    
    methods (Test)
        function setGetAppData(testCase)
            setappdata(testCase.fig, 'AppDataTests_Vec', 1:10);
            value = getappdata(testCase.fig, 'AppDataTests_Vec');
            
            assert(isequal(value, 1:10), 'App data doesn''t meet expectation. Expected: %d; Actual: %d', 1:10, value);
        end
        
        function setGetAppData_DifferentKeys(testCase)
            setappdata(testCase.fig, 'AppDataTests_Vec', 1:10);
            setappdata(testCase.fig, 'AppDataTests_Vec2', 1:100);
            
            value = getappdata(testCase.fig, 'AppDataTests_Vec');
            assert(isequal(value, 1:10), 'App data doesn''t meet expectation. Expected: %d; Actual: %d', 1:10, value);
            
            value = getappdata(testCase.fig, 'AppDataTests_Vec2');
            assert(isequal(value, 1:100), 'App data doesn''t meet expectation. Expected: %d; Actual: %d', 1:100, value);
        end
        
        function setGetAppData_DifferentHandles(testCase)
            setappdata(testCase.fig, 'AppDataTests_Vec', 1:10);
            fig2 = figure();
            setappdata(fig2, 'AppDataTests_Vec', 1:100);
            
            value = getappdata(testCase.fig, 'AppDataTests_Vec');
            assert(isequal(value, 1:10), 'App data doesn''t meet expectation. Expected: %d; Actual: %d', 1:10, value);
            
            value = getappdata(fig2, 'AppDataTests_Vec');
            assert(isequal(value, 1:100), 'App data doesn''t meet expectation. Expected: %d; Actual: %d', 1:100, value);
            
            close(fig2);
        end
        
        function justGetAppData(testCase)
            value = getappdata(testCase.fig, 'AppDataTests:nothing');
            
            assert(isempty(value), 'App data doesn''t meet expectation. Expected: []; Actual: %d', value);
        end
        
        function getAppData_NoEventRaised(testCase)
            x = 0;
            function callback(src, e)
                x = x+1;
            end
            listener = watchappdata(@callback);
            getappdata(testCase.fig, 'AppDataTests_nothing');
            getappdata(testCase.fig, 'AppDataTests_nothing');
            getappdata(testCase.fig, 'AppDataTests_nothing');
            
            assert(isequal(x, 0), 'App data changed event was expected 0 times but was raised %d times.', x);
            
            delete(listener);
        end
        
        function setAppData_Event(testCase)
            x = 0;
            function callback(src, e)
                x = x+1;
            end
            
            listener = watchappdata(@callback);
            setappdata(testCase.fig, 'AppDataTests_setAppData_Event', 10);
            setappdata(testCase.fig, 'AppDataTests_setAppData_Event', 10);
            setappdata(testCase.fig, 'AppDataTests_setAppData_Event', 10);
            
            assert(isequal(x, 3), 'App data changed event was expected 3 times but was raised %d times.', x);
            
            delete(listener);
        end
        
        function setAppData_EventArgs_SameKey(testCase)
            eArgs = [];
            function callback(src, e)
                eArgs = e;
            end
            
            listener = watchappdata(@callback);
            setappdata(testCase.fig, 'AppDataTests_setAppData_EventArgs', 10);
            
            assert(isequal(eArgs.name, 'AppDataTests_setAppData_EventArgs'), 'App data changed raised with the wrong key. Expected: ''AppDataTests_setAppData_EventArgs'', Actual: ''%s''', eArgs.name);
            assert(isequal(testCase.fig, eArgs.h), 'App data changed raised with the wrong handle.');
            
            setappdata(testCase.fig, 'AppDataTests_setAppData_EventArgs', 100);
            
            assert(isequal(eArgs.name, 'AppDataTests_setAppData_EventArgs'), 'App data changed raised with the wrong key. Expected: ''AppDataTests_setAppData_EventArgs'', Actual: ''%s''', eArgs.name);
            assert(isequal(testCase.fig, eArgs.h), 'App data changed raised with the wrong handle.');
            
            delete(listener);
        end
        
        function setAppData_EventArgs_DifferentKeys(testCase)
            eArgs = [];
            function callback(src, e)
                eArgs = e;
            end
            
            listener = watchappdata(@callback);
            setappdata(testCase.fig, 'AppDataTests_setAppData_EventArgs1', 10);
            
            assert(isequal(eArgs.name, 'AppDataTests_setAppData_EventArgs1'), 'App data changed raised with the wrong key. Expected: ''AppDataTests_setAppData_EventArgs1'', Actual: ''%s''', eArgs.name);
            assert(isequal(testCase.fig, eArgs.h), 'App data changed raised with the wrong handle.');
            
            setappdata(testCase.fig, 'AppDataTests_setAppData_EventArgs2', 100);
            
            assert(isequal(eArgs.name, 'AppDataTests_setAppData_EventArgs2'), 'App data changed raised with the wrong key. Expected: ''AppDataTests_setAppData_EventArgs2'', Actual: ''%s''', eArgs.name);
            assert(isequal(testCase.fig, eArgs.h), 'App data changed raised with the wrong handle.');
            
            delete(listener);
        end
        
        function setAppData_EventArgs_DifferentHandles(testCase)
            eArgs = [];
            function callback(src, e)
                eArgs = e;
            end
            
            listener = watchappdata(@callback);
            setappdata(testCase.fig, 'AppDataTests_setAppData_EventArgs3', 10);
            
            assert(isequal(eArgs.name, 'AppDataTests_setAppData_EventArgs3'), 'App data changed raised with the wrong key. Expected: ''AppDataTests_setAppData_EventArgs3'', Actual: ''%s''', eArgs.name);
            assert(isequal(testCase.fig, eArgs.h), 'App data changed raised with the wrong handle.');
            
            fig2 = figure();
            setappdata(fig2, 'AppDataTests_setAppData_EventArgs3', 1:10);
            
            assert(isequal(eArgs.name, 'AppDataTests_setAppData_EventArgs3'), 'App data changed raised with the wrong key. Expected: ''AppDataTests_setAppData_EventArgs3'', Actual: ''%s''', eArgs.name);
            assert(isequal(fig2, eArgs.h), 'App data changed raised with the wrong handle.');
            
            delete(listener);
            close(fig2);
        end
    end

end
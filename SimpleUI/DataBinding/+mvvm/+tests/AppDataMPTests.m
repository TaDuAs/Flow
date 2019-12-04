classdef AppDataMPTests < matlab.unittest.TestCase

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
        function setAppDataGetModel(testCase)
            mp = mvvm.providers.AppDataModelProvider(testCase.fig, 'AppDataMPTests');
            setappdata(testCase.fig, 'AppDataMPTests', 1:10);
            
            value = mp.getModel();
            
            assert(isequal(value, 1:10), 'App data stored model different from data set using setappdata. Expected: %d; Actual: %d', 1:10, value);
            delete(mp);
        end
        
        function setModelGetAppData(testCase)
            mp = mvvm.providers.AppDataModelProvider(testCase.fig, 'AppDataMPTests');
            mp.setModel(1);
            
            value = getappdata(testCase.fig, 'AppDataMPTests');
            
            assert(isequal(value, 1), 'App data different from data set using setModel. Expected: %d; Actual: %d', 1, value);
            delete(mp);
        end
        
        function setModelGetModel(testCase)
            mp = mvvm.providers.AppDataModelProvider(testCase.fig, 'AppDataMPTests');
            mp.setModel(1:100);
            
            value = mp.getModel();
            
            assert(isequal(value, 1:100), 'App data stored model different from data set using set model. Expected: %d; Actual: %d', 1:100, value);
            delete(mp);
        end
        
        function setModelRaiseModelChanged(testCase)
            mp = mvvm.providers.AppDataModelProvider(testCase.fig, 'AppDataMPTests');
            x = 0;
            function callback(src, arg)
                x = x + 1;
            end
            listener = mp.addlistener('modelChanged', @callback);
            
            mp.setModel(2);
            mp.setModel(3);
            mp.setModel(3);
            
            assert(isequal(x, 3), 'Modek was changed 3 times but the event was raised %d times.', x);
            
            delete(listener);
            delete(mp);
        end
        
        function setAppDataRaiseModelChanged(testCase)
            mp = mvvm.providers.AppDataModelProvider(testCase.fig, 'AppDataMPTests');
            x = 0;
            function callback(src, arg)
                x = x + 1;
            end
            listener = mp.addlistener('modelChanged', @callback);
            
            setappdata(testCase.fig, 'AppDataMPTests', 2);
            setappdata(testCase.fig, 'AppDataMPTests', 2);
            setappdata(testCase.fig, 'AppDataMPTests', 3);
                     
            assert(isequal(x, 3), 'App data was changed 3 times but the event was raised %d times.', x);
            
            delete(listener);
            delete(mp);
        end
        
        function setAppDataDifferentKeyNoEvent(testCase)
            mp = mvvm.providers.AppDataModelProvider(testCase.fig, 'AppDataMPTests');
            x = 0;
            function callback(src, arg)
                x = x + 1;
            end
            listener = mp.addlistener('modelChanged', @callback);
            
            setappdata(testCase.fig, 'AppDataMPTests_2', 2);
            setappdata(testCase.fig, 'AppDataMPTests_2', 3);
            setappdata(testCase.fig, 'AppDataMPTests_2', 4);
            
            assert(isequal(x, 0), 'The model wasn''t changed but the event was raised %d times.', x);
            
            delete(listener);
            delete(mp);
        end
        
        function setAppDataDifferentHandleNoEvent(testCase)
            mp = mvvm.providers.AppDataModelProvider(testCase.fig, 'AppDataMPTests');
            x = 0;
            function callback(src, arg)
                x = x + 1;
            end
            listener = mp.addlistener('modelChanged', @callback);
            
            fig1 = figure();
            setappdata(fig1, 'AppDataMPTests', 2);
            setappdata(fig1, 'AppDataMPTests', 3);
            setappdata(fig1, 'AppDataMPTests', 4);
            
            assert(isequal(x, 0), 'The model wasn''t changed but the event was raised %d times.', x);
            
            close(fig1);
            delete(listener);
            delete(mp);
        end
    end

end
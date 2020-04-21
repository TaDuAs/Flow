classdef BindingManagerTests < matlab.unittest.TestCase & mvvm.providers.IModelProvider
    
    properties
        model;
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
        function initModel(testCase)
            testCase.model = mvvm.tests.generateTestingModel();
        end
    end
    
    methods (Test) % getModelProvider
        function BindingManager_DefaultModelProvider(testCase)
            bm = mvvm.BindingManager();
            modelProvier = bm.getModelProvider();
            
            assert(isa(modelProvier, 'mvvm.providers.SimpleModelProvider'), 'default model provider is not a mvvm.providers.SimpleModelProvider');
        end
        
        function BindingManager_ChangeDefaultModelProvider(testCase)
            bm = mvvm.BindingManager();
            bm.setDefaultModelProvider(testCase)
            modelProvier = bm.getModelProvider();
            
            assert(eq(modelProvier, testCase), 'default model provider was not changed');
        end
        
        function BindingManager_SetModelProvider(testCase)
            bm = mvvm.BindingManager();
            
            container = figure();
            
            bm.setModelProvider(container, testCase)
            modelProvier = bm.getModelProvider(container);
            
            assert(eq(modelProvier, testCase), 'model provider for a container is wrong');
            
            close(container);
        end
        
        function BindingManager_GetAncestorModelProvider(testCase)
            bm = mvvm.BindingManager();
            
            container = figure();
            container2 = uicontrol(container);
            
            bm.setModelProvider(container, testCase)
            modelProvier = bm.getModelProvider(container2);
            
            assert(eq(modelProvier, testCase), 'model provider for child container is wrong');
            
            close(container);
        end
        
        function BindingManager_GetSelfModelProvider(testCase)
            bm = mvvm.BindingManager();
            
            container = figure();
            container2 = uicontrol(container);
            
            bm.setModelProvider(container, testCase);
            
            mp2 = mvvm.providers.SimpleModelProvider();
            bm.setModelProvider(container2, mp2);
            modelProvier = bm.getModelProvider(container2);
            
            assert(eq(modelProvier, mp2), 'model provider for child container is wrong');
            
            close(container);
        end
        
        function BindingManager_GetComplexUIHierarchyModelProvider(testCase)
            bm = mvvm.BindingManager();
            
            container = figure();
            container2 = uipanel(container);
            container3 = uipanel(container);
            container4 = uicontrol(container3);
            
            bm.setModelProvider(container, testCase);
            
            mp2 = mvvm.providers.SimpleModelProvider();
            bm.setModelProvider(container2, mp2);
            modelProvier = bm.getModelProvider(container4);
            
            assert(eq(modelProvier, testCase), 'model provider for child container is wrong');
            
            close(container);
        end
        
        function BindingManager_GetComplexUIHierarchyModelProvider2(testCase)
            bm = mvvm.BindingManager();
            
            container = figure();
            container2 = uipanel(container);
            container3 = uipanel(container);
            container4 = uicontrol(container3);
            
            bm.setDefaultModelProvider(testCase);
            
            mp2 = mvvm.providers.SimpleModelProvider();
            bm.setModelProvider(container2, mp2);
            modelProvier = bm.getModelProvider(container4);
            
            assert(eq(modelProvier, testCase), 'model provider for child container is wrong');
            
            close(container);
        end
        
        function BindingManager_ChangeModelProvider(testCase)
            bm = mvvm.BindingManager();
            
            container = figure();
            
            bm.setModelProvider(container, testCase)
            modelProvier = bm.getModelProvider(container);
            
            assert(eq(modelProvier, testCase), 'model provider for a container after setting for the first time is wrong');
            
            mp2 = mvvm.providers.SimpleModelProvider();
            bm.setModelProvider(container, mp2)
            modelProvier = bm.getModelProvider(container);
            
            assert(eq(modelProvier, mp2), 'model provider for a container after changing is wrong');
            
            close(container);
        end
        
        function BindingManager_SetDifferentModelProvider(testCase)
            bm = mvvm.BindingManager();
            
            container1 = figure();
            container2 = figure();
            mp2 = mvvm.providers.SimpleModelProvider();
            
            bm.setModelProvider(container1, testCase);
            bm.setModelProvider(container2, mp2);
            
            modelProvier = bm.getModelProvider(container1);
            
            assert(eq(modelProvier, testCase), 'model provider for a container after setting for the first time is wrong');
            
            modelProvier = bm.getModelProvider(container2);
            
            assert(eq(modelProvier, mp2), 'model provider for a container after changing is wrong');
            
            close(container1);
            close(container2);
        end
        
        function BindingManager_RemoveProviderWhenCotainerIsTerminated(testCase)
            bm = mvvm.BindingManager();
            
            container = figure();
            
            bm.setModelProvider(container, testCase);
            
            modelProvier = bm.getModelProvider(container);
            
            assert(eq(modelProvier, testCase), 'model provider for a container after setting for the first time is wrong');
            
            close(container);
            container = [];
            
            modelProvier = bm.getModelProvider(container);
            
            assert(~eq(modelProvier, testCase), 'when closing the figure, model provider should be removed');
            assert(isa(modelProvier, 'mvvm.providers.SimpleModelProvider'), 'model provider for a container after closing figure should be the default');
        end
        
        function BindingManager_RemoveProviderWhenProviderIsTerminated(testCase)
            bm = mvvm.BindingManager();
            
            container = figure();
            
            mp = mvvm.providers.SimpleModelProvider();
            bm.setModelProvider(container, mp);
            
            modelProvier = bm.getModelProvider(container);
            
            assert(eq(modelProvier, mp), 'model provider for a container after setting for the first time is wrong');
            
            delete(mp);
            
            modelProvier = bm.getModelProvider(container);
            
            assert(~eq(modelProvier, mp), 'when deleting the provider, it should be removed');
            
            close(container);
        end
        
        function BindingManager_DontRemoveReplacedProviderWhenTerminated(testCase)
            bm = mvvm.BindingManager();
            
            container = figure();
            
            mp = mvvm.providers.SimpleModelProvider();
            bm.setModelProvider(container, mp);
            bm.setModelProvider(container, testCase);
            
            delete(mp);
            
            modelProvier = bm.getModelProvider(container);
            
            assert(eq(modelProvier, testCase), 'when deleting the initial provider, it shouldn''t remove the new provider');
            
            close(container);
        end
        
        function BindingManager_RemoveModelProvider(testCase)
            bm = mvvm.BindingManager();
            
            container1 = figure();
            container2 = figure();
            
            mp = mvvm.providers.SimpleModelProvider();
            bm.setModelProvider(container1, mp);
            bm.setModelProvider(container2, testCase);
            
            bm.removeModelProvider(container1);
            
            modelProvier = bm.getModelProvider(container1);
            
            assert(~isempty(modelProvier), 'when no model provider is registered for a given gui component, should return the default model provider');
            assert(any(~eq(modelProvier, testCase)) && all(~eq(modelProvier, testCase)), 'model provider for a container1 was not removed properly');
            
            modelProvier = bm.getModelProvider(container2);
            
            assert(eq(modelProvier, testCase), 'model provider for a container2 was not supposed to be removed');
            
            close(container2);
            close(container1);
        end
    end
end


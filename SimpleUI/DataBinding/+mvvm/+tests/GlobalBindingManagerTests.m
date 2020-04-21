classdef GlobalBindingManagerTests < matlab.unittest.TestCase & mvvm.providers.IModelProvider
    
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
    
    methods (Test) % Static Instance
        function BindingManagerSingleton(testCase)
            ref1 = mvvm.GlobalBindingManager.instance();
            ref2 = mvvm.GlobalBindingManager.instance();
            
            assert(eq(ref1, ref2), 'mvvm.GlobalBindingManager instance not a singleton');
        end
        
        function BindingManagerForceInstance(testCase)
            ref1 = mvvm.GlobalBindingManager.instance();
            ref2 = mvvm.GlobalBindingManager.forceNewInstance();
            
            assert(~eq(ref1, ref2), 'mvvm.GlobalBindingManager forceNewInstance doesn''t create new instance');
        end
    end
    
    methods (Test) % getModProv
        function BindingManager_DefaultModelProvider(testCase)
            mvvm.GlobalBindingManager.forceNewInstance();
            modelProvier = mvvm.GlobalBindingManager.getModProv();
            
            assert(isa(modelProvier, 'mvvm.providers.SimpleModelProvider'), 'default model provider is not a mvvm.providers.SimpleModelProvider');
        end
        
        function BindingManager_ChangeDefaultModelProvider(testCase)
            mvvm.GlobalBindingManager.forceNewInstance();
            mvvm.GlobalBindingManager.setDefaultModProv(testCase)
            modelProvier = mvvm.GlobalBindingManager.getModProv();
            
            assert(eq(modelProvier, testCase), 'default model provider was not changed');
        end
        
        function BindingManager_SetModelProvider(testCase)
            mvvm.GlobalBindingManager.forceNewInstance();
            
            container = figure();
            
            mvvm.GlobalBindingManager.setModProv(container, testCase)
            modelProvier = mvvm.GlobalBindingManager.getModProv(container);
            
            assert(eq(modelProvier, testCase), 'model provider for a container is wrong');
            
            close(container);
        end
        
        function BindingManager_GetAncestorModelProvider(testCase)
            mvvm.GlobalBindingManager.forceNewInstance();
            
            container = figure();
            container2 = uicontrol(container);
            
            mvvm.GlobalBindingManager.setModProv(container, testCase)
            modelProvier = mvvm.GlobalBindingManager.getModProv(container2);
            
            assert(eq(modelProvier, testCase), 'model provider for child container is wrong');
            
            close(container);
        end
        
        function BindingManager_GetSelfModelProvider(testCase)
            mvvm.GlobalBindingManager.forceNewInstance();
            
            container = figure();
            container2 = uicontrol(container);
            
            mvvm.GlobalBindingManager.setModProv(container, testCase);
            
            mp2 = mvvm.providers.SimpleModelProvider();
            mvvm.GlobalBindingManager.setModProv(container2, mp2);
            modelProvier = mvvm.GlobalBindingManager.getModProv(container2);
            
            assert(eq(modelProvier, mp2), 'model provider for child container is wrong');
            
            close(container);
        end
        
        function BindingManager_GetComplexUIHierarchyModelProvider(testCase)
            mvvm.GlobalBindingManager.forceNewInstance();
            
            container = figure();
            container2 = uipanel(container);
            container3 = uipanel(container);
            container4 = uicontrol(container3);
            
            mvvm.GlobalBindingManager.setModProv(container, testCase);
            
            mp2 = mvvm.providers.SimpleModelProvider();
            mvvm.GlobalBindingManager.setModProv(container2, mp2);
            modelProvier = mvvm.GlobalBindingManager.getModProv(container4);
            
            assert(eq(modelProvier, testCase), 'model provider for child container is wrong');
            
            close(container);
        end
        
        function BindingManager_GetComplexUIHierarchyModelProvider2(testCase)
            mvvm.GlobalBindingManager.forceNewInstance();
            
            container = figure();
            container2 = uipanel(container);
            container3 = uipanel(container);
            container4 = uicontrol(container3);
            
            mvvm.GlobalBindingManager.setDefaultModProv(testCase);
            
            mp2 = mvvm.providers.SimpleModelProvider();
            mvvm.GlobalBindingManager.setModProv(container2, mp2);
            modelProvier = mvvm.GlobalBindingManager.getModProv(container4);
            
            assert(eq(modelProvier, testCase), 'model provider for child container is wrong');
            
            close(container);
        end
        
        function BindingManager_ChangeModelProvider(testCase)
            mvvm.GlobalBindingManager.forceNewInstance();
            
            container = figure();
            
            mvvm.GlobalBindingManager.setModProv(container, testCase)
            modelProvier = mvvm.GlobalBindingManager.getModProv(container);
            
            assert(eq(modelProvier, testCase), 'model provider for a container after setting for the first time is wrong');
            
            mp2 = mvvm.providers.SimpleModelProvider();
            mvvm.GlobalBindingManager.setModProv(container, mp2)
            modelProvier = mvvm.GlobalBindingManager.getModProv(container);
            
            assert(eq(modelProvier, mp2), 'model provider for a container after changing is wrong');
            
            close(container);
        end
        
        function BindingManager_SetDifferentModelProvider(testCase)
            mvvm.GlobalBindingManager.forceNewInstance();
            
            container1 = figure();
            container2 = figure();
            mp2 = mvvm.providers.SimpleModelProvider();
            
            mvvm.GlobalBindingManager.setModProv(container1, testCase);
            mvvm.GlobalBindingManager.setModProv(container2, mp2);
            
            modelProvier = mvvm.GlobalBindingManager.getModProv(container1);
            
            assert(eq(modelProvier, testCase), 'model provider for a container after setting for the first time is wrong');
            
            modelProvier = mvvm.GlobalBindingManager.getModProv(container2);
            
            assert(eq(modelProvier, mp2), 'model provider for a container after changing is wrong');
            
            close(container1);
            close(container2);
        end
        
        function BindingManager_RemoveProviderWhenCotainerIsTerminated(testCase)
            mvvm.GlobalBindingManager.forceNewInstance();
            
            container = figure();
            
            mvvm.GlobalBindingManager.setModProv(container, testCase);
            
            modelProvier = mvvm.GlobalBindingManager.getModProv(container);
            
            assert(eq(modelProvier, testCase), 'model provider for a container after setting for the first time is wrong');
            
            close(container);
            container = [];
            
            modelProvier = mvvm.GlobalBindingManager.getModProv(container);
            
            assert(~eq(modelProvier, testCase), 'when closing the figure, model provider should be removed');
            assert(isa(modelProvier, 'mvvm.providers.SimpleModelProvider'), 'model provider for a container after closing figure should be the default');
        end
        
        function BindingManager_RemoveProviderWhenProviderIsTerminated(testCase)
            mvvm.GlobalBindingManager.forceNewInstance();
            
            container = figure();
            
            mp = mvvm.providers.SimpleModelProvider();
            mvvm.GlobalBindingManager.setModProv(container, mp);
            
            modelProvier = mvvm.GlobalBindingManager.getModProv(container);
            
            assert(eq(modelProvier, mp), 'model provider for a container after setting for the first time is wrong');
            
            delete(mp);
            
            modelProvier = mvvm.GlobalBindingManager.getModProv(container);
            
            assert(~eq(modelProvier, mp), 'when deleting the provider, it should be removed');
            
            close(container);
        end
        
        function BindingManager_DontRemoveReplacedProviderWhenTerminated(testCase)
            mvvm.GlobalBindingManager.forceNewInstance();
            
            container = figure();
            
            mp = mvvm.providers.SimpleModelProvider();
            mvvm.GlobalBindingManager.setModProv(container, mp);
            mvvm.GlobalBindingManager.setModProv(container, testCase);
            
            delete(mp);
            
            modelProvier = mvvm.GlobalBindingManager.getModProv(container);
            
            assert(eq(modelProvier, testCase), 'when deleting the initial provider, it shouldn''t remove the new provider');
            
            close(container);
        end
        
        function BindingManager_RemoveModelProvider(testCase)
            mvvm.GlobalBindingManager.forceNewInstance();
            
            container1 = figure();
            container2 = figure();
            
            mp = mvvm.providers.SimpleModelProvider();
            mvvm.GlobalBindingManager.setModProv(container1, mp);
            mvvm.GlobalBindingManager.setModProv(container2, testCase);
            
            mvvm.GlobalBindingManager.removeModProv(container1);
            
            modelProvier = mvvm.GlobalBindingManager.getModProv(container1);
            
            assert(~isempty(modelProvier), 'when no model provider is registered for a given gui component, should return the default model provider');
            assert(any(~eq(modelProvier, testCase)) && all(~eq(modelProvier, testCase)), 'model provider for a container1 was not removed properly');
            
            modelProvier = mvvm.GlobalBindingManager.getModProv(container2);
            
            assert(eq(modelProvier, testCase), 'model provider for a container2 was not supposed to be removed');
            
            close(container2);
            close(container1);
        end
    end
end


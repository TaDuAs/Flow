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
    
    methods (Test) % Singleton
        function BindingManagerSingleton(testCase)
            ref1 = mvvm.BindingManager.instance();
            ref2 = mvvm.BindingManager.instance();
            
            assert(eq(ref1, ref2), 'mvvm.BindingManager instance not a singleton');
        end
        
        function BindingManagerForceInstance(testCase)
            ref1 = mvvm.BindingManager.instance();
            ref2 = mvvm.BindingManager.forceNewInstance();
            
            assert(~eq(ref1, ref2), 'mvvm.BindingManager forceNewInstance doesn''t create new instance');
        end
    end
    
    methods (Test) % getModProv
        function BindingManager_DefaultModelProvider(testCase)
            mvvm.BindingManager.forceNewInstance();
            modelProvier = mvvm.BindingManager.getModProv();
            
            assert(isa(modelProvier, 'mvvm.providers.SimpleModelProvider'), 'default model provider is not a mvvm.providers.SimpleModelProvider');
        end
        
        function BindingManager_ChangeDefaultModelProvider(testCase)
            mvvm.BindingManager.forceNewInstance();
            mvvm.BindingManager.setDefaultModProv(testCase)
            modelProvier = mvvm.BindingManager.getModProv();
            
            assert(eq(modelProvier, testCase), 'default model provider was not changed');
        end
        
        function BindingManager_SetModelProvider(testCase)
            mvvm.BindingManager.forceNewInstance();
            
            container = figure();
            
            mvvm.BindingManager.setModProv(container, testCase)
            modelProvier = mvvm.BindingManager.getModProv(container);
            
            assert(eq(modelProvier, testCase), 'model provider for a container is wrong');
            
            close(container);
        end
        
        function BindingManager_ChangeModelProvider(testCase)
            mvvm.BindingManager.forceNewInstance();
            
            container = figure();
            
            mvvm.BindingManager.setModProv(container, testCase)
            modelProvier = mvvm.BindingManager.getModProv(container);
            
            assert(eq(modelProvier, testCase), 'model provider for a container after setting for the first time is wrong');
            
            mp2 = mvvm.providers.SimpleModelProvider();
            mvvm.BindingManager.setModProv(container, mp2)
            modelProvier = mvvm.BindingManager.getModProv(container);
            
            assert(eq(modelProvier, mp2), 'model provider for a container after changing is wrong');
            
            close(container);
        end
        
        function BindingManager_SetDifferentModelProvider(testCase)
            mvvm.BindingManager.forceNewInstance();
            
            container1 = figure();
            container2 = figure();
            mp2 = mvvm.providers.SimpleModelProvider();
            
            mvvm.BindingManager.setModProv(container1, testCase);
            mvvm.BindingManager.setModProv(container2, mp2);
            
            modelProvier = mvvm.BindingManager.getModProv(container1);
            
            assert(eq(modelProvier, testCase), 'model provider for a container after setting for the first time is wrong');
            
            modelProvier = mvvm.BindingManager.getModProv(container2);
            
            assert(eq(modelProvier, mp2), 'model provider for a container after changing is wrong');
            
            close(container1);
            close(container2);
        end
        
        function BindingManager_RemoveProviderWhenCotainerIsTerminated(testCase)
            mvvm.BindingManager.forceNewInstance();
            
            container = figure();
            
            mvvm.BindingManager.setModProv(container, testCase);
            
            modelProvier = mvvm.BindingManager.getModProv(container);
            
            assert(eq(modelProvier, testCase), 'model provider for a container after setting for the first time is wrong');
            
            close(container);
            container = [];
            
            modelProvier = mvvm.BindingManager.getModProv(container);
            
            assert(~eq(modelProvier, testCase), 'when closing the figure, model provider should be removed');
            assert(isa(modelProvier, 'mvvm.providers.SimpleModelProvider'), 'model provider for a container after closing figure should be the default');
        end
        
        function BindingManager_RemoveProviderWhenProviderIsTerminated(testCase)
            mvvm.BindingManager.forceNewInstance();
            
            container = figure();
            
            mp = mvvm.providers.SimpleModelProvider();
            mvvm.BindingManager.setModProv(container, mp);
            
            modelProvier = mvvm.BindingManager.getModProv(container);
            
            assert(eq(modelProvier, mp), 'model provider for a container after setting for the first time is wrong');
            
            delete(mp);
            
            modelProvier = mvvm.BindingManager.getModProv(container);
            
            assert(~eq(modelProvier, mp), 'when deleting the provider, it should be removed');
            
            close(container);
        end
        
        function BindingManager_DontRemoveReplacedProviderWhenTerminated(testCase)
            mvvm.BindingManager.forceNewInstance();
            
            container = figure();
            
            mp = mvvm.providers.SimpleModelProvider();
            mvvm.BindingManager.setModProv(container, mp);
            mvvm.BindingManager.setModProv(container, testCase);
            
            delete(mp);
            
            modelProvier = mvvm.BindingManager.getModProv(container);
            
            assert(eq(modelProvier, testCase), 'when deleting the initial provider, it shouldn''t remove the new provider');
            
            close(container);
        end
        
        function BindingManager_RemoveModelProvider(testCase)
            mvvm.BindingManager.forceNewInstance();
            
            container1 = figure();
            container2 = figure();
            
            mp = mvvm.providers.SimpleModelProvider();
            mvvm.BindingManager.setModProv(container1, mp);
            mvvm.BindingManager.setModProv(container2, testCase);
            
            mvvm.BindingManager.removeModProv(container1);
            
            modelProvier = mvvm.BindingManager.getModProv(container1);
            
            assert(~eq(modelProvier, testCase), 'model provider for a container1 was not removed properly');
            
            modelProvier = mvvm.BindingManager.getModProv(container2);
            
            assert(eq(modelProvier, testCase), 'model provider for a container2 was not supposed to be removed');
            
            close(container2);
            close(container1);
        end
    end
end


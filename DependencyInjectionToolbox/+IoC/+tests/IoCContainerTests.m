classdef IoCContainerTests < matlab.unittest.TestCase 

    methods (TestMethodSetup)
        function initModel(testCase)
        end
    end
    
    methods (Test)
        function getType(testCase)
            inj = IoC.Container();
            inj.set('handle', @IoC.tests.HandleModel);
            type = inj.getType('handle');
            
            assert(strcmp(type, 'IoC.tests.HandleModel'));
        end
        
        function stringCtor(testCase)
            inj = IoC.Container();
            inj.set("handle", "IoC.tests.HandleModel");
            obj = inj.get("handle");
            
            assert(isa(obj, 'IoC.tests.HandleModel'));
        end
        
        function stringCtorWithArgs(testCase)
            inj = IoC.Container();
            inj.set("handle", "IoC.tests.HandleModel");
            inj.set("handle1", "IoC.tests.HandleModel", "$123", "handle", "handle", 1:10);
            obj = inj.get("handle1");
            
            assert(isa(obj, 'IoC.tests.HandleModel'));
            assert(strcmp(obj.id, "123"));
            assert(isa(obj.child1, 'IoC.tests.HandleModel'));
            assert(isa(obj.child2, 'IoC.tests.HandleModel'));
            assert(isequal(obj.list, 1:10));
        end
        
        function simpleDependencyDefault(testCase)
            inj = IoC.Container();
            inj.set('handle', @IoC.tests.HandleModel);
            obj = inj.get('handle');
            
            assert(isa(obj, 'IoC.tests.HandleModel'));
        end
        
        function simpleDependencyWithConstArgs(testCase)
            inj = IoC.Container();
            inj.set('handle', @IoC.tests.HandleModel, "$id", 1:10, struct(), []);
            obj = inj.get('handle');
            
            assert(isa(obj, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.id, 'id'));
            assert(isequaln(obj.child1, 1:10));
            assert(isequaln(obj.child2, struct()));
            assert(isequaln(obj.list, []));
        end
        
        function simpleDependencyWithOneDependentArgs(testCase)
            inj = IoC.Container();
            inj.set("handle", @IoC.tests.HandleModel, "$id");
            inj.set("dependentHandle", @IoC.tests.HandleModel, "$idd", "handle");
            obj = inj.get("dependentHandle");
            
            assert(isa(obj, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.id, 'idd'));
            assert(isa(obj.child1, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.child1.id, 'id'));
        end
        
        function simpleDependencyWithSeveralDependentArgs(testCase)
            inj = IoC.Container();
            inj.set("handle", @IoC.tests.HandleModel, "$id");
            inj.set("value", @IoC.tests.ValueModel, "$value");
            inj.set("dependentHandle", @IoC.tests.HandleModel, "$idd", "handle", "value");
            obj = inj.get("dependentHandle");
            
            assert(isa(obj, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.id, 'idd'));
            assert(isa(obj.child1, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.child1.id, 'id'));
            assert(isa(obj.child2, 'IoC.tests.ValueModel'));
            assert(isequaln(obj.child2.id, 'value'));
        end
        
        function simpleDependencyIndependentArgs(testCase)
            inj = IoC.Container();
            inj.set("handle", @IoC.tests.HandleModel, "$id", [], [], []);
            inj.set("dependentHandle", @IoC.tests.HandleModel, "$idd", "handle");
            obj = inj.get("handle");
            
            assert(isa(obj, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.id, 'id'));
            assert(isequaln(obj.child1, []));
            assert(isequaln(obj.child2, []));
            assert(isequaln(obj.list, []));
        end
        
        function complexObjectGraph(testCase)
            inj = IoC.Container();
            inj.set("handle1", @IoC.tests.HandleModel, "$h1", [], [], []);
            inj.set("handle2", @IoC.tests.HandleModel, "$h2", "handle1");
            inj.set("handle3", @IoC.tests.HandleModel, "$h3", "handle2");
            inj.set("handle4", @IoC.tests.HandleModel, "$h4", "handle2");
            inj.set("handle5", @IoC.tests.HandleModel, "$h5", "handle3", "handle4");
            obj = inj.get("handle5");
            
            assert(isa(obj, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.id, 'h5'));
            assert(isa(obj.child1, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.child1.id, 'h3'));
            assert(isa(obj.child1.child1, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.child1.child1.id, 'h2'));
            assert(isa(obj.child1.child1.child1, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.child1.child1.child1.id, 'h1'));
            assert(isa(obj.child2, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.child2.id, 'h4'));
            assert(isa(obj.child2.child1, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.child2.child1.id, 'h2'));
            assert(isa(obj.child2.child1.child1, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.child2.child1.child1.id, 'h1'));
        end
        
        function instancePerInvokation(testCase)
            inj = IoC.Container();
            inj.set('handle', @IoC.tests.HandleModel);
            obj1 = inj.get('handle');
            obj2 = inj.get('handle');
            
            assert(isa(obj1, 'IoC.tests.HandleModel'));
            assert(isa(obj2, 'IoC.tests.HandleModel'));
            assert(~eq(obj1, obj2));
        end
        
        function instancePerSession(testCase)
            inj = IoC.Container();
            inj.setPerSession('handle', @IoC.tests.HandleModel);
            obj1 = inj.get('handle');
            obj2 = inj.get('handle');
            
            assert(isa(obj1, 'IoC.tests.HandleModel'));
            assert(eq(obj1, obj2));
        end
        
        function singletonInstance(testCase)
            inj = IoC.Container();
            inj.setSingleton('handle', @IoC.tests.HandleModel);
            obj1 = inj.get('handle');
            obj2 = inj.get('handle');
            
            assert(isa(obj1, 'IoC.tests.HandleModel'));
            assert(eq(obj1, obj2));
        end
        
        function newSession(testCase)
            inj1 = IoC.Container();
            inj1.set('handle', @IoC.tests.HandleModel, "$id", 1:10, struct(), []);
            
            inj2 = inj1.startNewSession();
            obj = inj2.get('handle');
            
            assert(isa(obj, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.id, 'id'));
            assert(isequaln(obj.child1, 1:10));
            assert(isequaln(obj.child2, struct()));
            assert(isequaln(obj.list, []));
        end
        
        function newSessionNewContainer(testCase)
            inj1 = IoC.Container();
            inj1.set('handle', @IoC.tests.HandleModel, "$id", 1:10, struct(), []);
            
            inj2 = inj1.startNewSession();
            
            assert(isa(inj2, 'IoC.Container'));
            assert(~eq(inj1, inj2));
        end
        
        function newSessionMultipleDependencies(testCase)
            inj1 = IoC.Container();
            inj1.set("handle1", @IoC.tests.HandleModel, "$h1", [], [], []);
            inj1.set("handle2", @IoC.tests.HandleModel, "$h2", "handle1");
            inj1.set("handle3", @IoC.tests.HandleModel, "$h3", "handle2");
            inj1.set("handle4", @IoC.tests.HandleModel, "$h4", "handle2");
            inj1.set("handle5", @IoC.tests.HandleModel, "$h5", "handle3", "handle4");
            
            inj2 = inj1.startNewSession();
            
            obj = inj2.get("handle5");
            
            assert(isa(obj, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.id, 'h5'));
            assert(isa(obj.child1, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.child1.id, 'h3'));
            assert(isa(obj.child1.child1, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.child1.child1.id, 'h2'));
            assert(isa(obj.child1.child1.child1, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.child1.child1.child1.id, 'h1'));
            assert(isa(obj.child2, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.child2.id, 'h4'));
            assert(isa(obj.child2.child1, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.child2.child1.id, 'h2'));
            assert(isa(obj.child2.child1.child1, 'IoC.tests.HandleModel'));
            assert(isequaln(obj.child2.child1.child1.id, 'h1'));
        end
        
        function newSessionNewInstance(testCase)
            inj1 = IoC.Container();
            inj1.set('handle', @IoC.tests.HandleModel, "$id", 1:10, struct(), []);
            inj2 = inj1.startNewSession();
            
            obj1 = inj1.get('handle');
            obj2 = inj2.get('handle');
            
            assert(isa(obj1, 'IoC.tests.HandleModel'));
            assert(isa(obj2, 'IoC.tests.HandleModel'));
            assert(~eq(obj1, obj2));
        end
        
        function newSessionNewPerSessionInstance(testCase)
            inj1 = IoC.Container();
            inj1.setPerSession('handle', @IoC.tests.HandleModel, "$id", 1:10, struct(), []);
            obj1 = inj1.get('handle');
            
            inj2 = inj1.startNewSession();
            
            obj2 = inj2.get('handle');
            
            assert(isa(obj1, 'IoC.tests.HandleModel'));
            assert(isa(obj2, 'IoC.tests.HandleModel'));
            assert(~eq(obj1, obj2));
        end
        
        function newSessionNewPerSessionInstanceLazyLoad(testCase)
            inj1 = IoC.Container();
            inj1.setPerSession('handle', @IoC.tests.HandleModel, "$id", 1:10, struct(), []);
            inj2 = inj1.startNewSession();
            
            obj1 = inj1.get('handle');
            obj2 = inj2.get('handle');
            
            assert(isa(obj1, 'IoC.tests.HandleModel'));
            assert(isa(obj2, 'IoC.tests.HandleModel'));
            assert(~eq(obj1, obj2));
        end
        
        function newSessionSingletonInstance(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('handle', @IoC.tests.HandleModel, "$id", 1:10, struct(), []);
            obj1 = inj1.get('handle');
            
            inj2 = inj1.startNewSession();
            
            obj2 = inj2.get('handle');
            
            assert(isa(obj1, 'IoC.tests.HandleModel'));
            assert(isa(obj2, 'IoC.tests.HandleModel'));
            assert(eq(obj1, obj2));
        end
        
        function newSessionSingletonInstanceLazyLoad(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('handle', @IoC.tests.HandleModel, "$id", 1:10, struct(), []);
            inj2 = inj1.startNewSession();
            
            obj1 = inj1.get('handle');
            obj2 = inj2.get('handle');
            
            assert(isa(obj1, 'IoC.tests.HandleModel'));
            assert(isa(obj2, 'IoC.tests.HandleModel'));
            assert(eq(obj1, obj2));
        end
        
        function nameValueCtorInjection(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('getset', @IoC.tests.GetSetModel, "@prop1", 1:10, "@prop2", "$my_id");
            
            obj1 = inj1.get('getset');
            
            assert(isa(obj1, 'IoC.tests.GetSetModel'));
            assert(isequal(obj1.prop1, 1:10));
            assert(isequal(obj1.prop2, "my_id"));
            assert(isequal(obj1.prop3, []));
        end
        
        function propInjection(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('getset', @IoC.tests.GetSetModel, "&prop1", 1:10, "&prop2", "$my_id");
            
            obj1 = inj1.get('getset');
            
            assert(isa(obj1, 'IoC.tests.GetSetModel'));
            assert(isequal(obj1.prop1, 1:10));
            assert(isequal(obj1.prop2, "my_id"));
            assert(isequal(obj1.prop3, []));
        end
        
        function nameValueCtorInjectionNoCtorAvailable(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('getset', @IoC.tests.NoGetSetModel, "@prop1", 1:10, "@prop2", "$my_id");
            
            success = true;
            try
                obj1 = inj1.get('getset');
                success = false;
            catch
                % this is good
            end
            
            assert(success);
        end
        
        function propInjectionNoCtorAvailable(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('getset', @IoC.tests.NoGetSetModel, "&prop1", 1:10, "&prop2", "$my_id");
            
            obj1 = inj1.get('getset');
            
            assert(isa(obj1, 'IoC.tests.NoGetSetModel'));
            assert(isequal(obj1.prop1, 1:10));
            assert(isequal(obj1.prop2, "my_id"));
            assert(isequal(obj1.prop3, []));
        end
        
        function dynamicPropInjectionNoCtorInjection(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('getset', @IoC.tests.GetSetModel);
            
            obj1 = inj1.get('getset', "&prop1", 1:3, "&prop2", "$changed");
            
            assert(isa(obj1, 'IoC.tests.GetSetModel'));
            assert(isequal(obj1.prop1, 1:3));
            assert(isequal(obj1.prop2, "changed"));
        end
        
        function dynamicPropInjectionNoPrefix(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('getset', @IoC.tests.GetSetModel);
            
            obj1 = inj1.get('getset', "prop1", 1:3, "prop2", "$changed");
            
            assert(isa(obj1, 'IoC.tests.GetSetModel'));
            assert(isequal(obj1.prop1, 1:3));
            assert(isequal(obj1.prop2, "changed"));
        end
        
        function dynamicPropInjectionOverrideCtorInjection(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('getset', @IoC.tests.GetSetModel, "&prop1", 1:10, "&prop2", "$my_id");
            
            obj1 = inj1.get('getset', "&prop1", 1:3, "&prop2", "$changed");
            
            assert(isa(obj1, 'IoC.tests.GetSetModel'));
            assert(isequal(obj1.prop1, 1:3));
            assert(isequal(obj1.prop2, "changed"));
        end
        
        function dynamicNameValueInjectionNoCtorInjection(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('getset', @IoC.tests.GetSetModel, "&prop1", 1:10);
            
            obj1 = inj1.get('getset', "@prop2", "$my_id");
            
            assert(isa(obj1, 'IoC.tests.GetSetModel'));
            assert(isequal(obj1.prop1, 1:10));
            assert(isequal(obj1.prop2, "my_id"));
        end
        
        function dynamicNameValueInjectionOverrideCtorInjection(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('getset', @IoC.tests.GetSetModel, "@prop1", 1:10, "@prop2", "$my_id");
            
            obj1 = inj1.get('getset', "@prop1", 1:3, "@prop2", "$changed");
            
            assert(isa(obj1, 'IoC.tests.GetSetModel'));
            assert(isequal(obj1.prop1, 1:3));
            assert(isequal(obj1.prop2, "changed"));
        end
        
        function dynamicNameValueInjectionCantOverridePropertyInjection(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('getset', @IoC.tests.GetSetModel, "&prop1", 1:10, "&prop2", "$my_id");
            
            obj1 = inj1.get('getset', "@prop1", 1:3, "@prop2", "$changed");
            
            assert(isa(obj1, 'IoC.tests.GetSetModel'));
            assert(isequal(obj1.prop1, 1:10));
            assert(isequal(obj1.prop2, "my_id"));
        end
        
        function dynamicIndexInjectionOverrideCtorInjection(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('handle', @IoC.tests.HandleModel, '$id', 1:10);
            
            obj1 = inj1.get('handle', "#1", "$newId");
            
            assert(isa(obj1, 'IoC.tests.HandleModel'));
            assert(isequal(obj1.id, "newId"));
            assert(isequal(obj1.child1, 1:10));
        end
        
        function dynamicIndexInjectionAddCtorInjection(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('handle', @IoC.tests.HandleModel, '$id', 1:10);
            
            obj1 = inj1.get('handle', "#3", "$strings strings strings");
            
            assert(isa(obj1, 'IoC.tests.HandleModel'));
            assert(isequal(obj1.id, "id"));
            assert(isequal(obj1.child1, 1:10));
            assert(isequal(obj1.child2, "strings strings strings"));
        end
        
        function dynamicIndexInjectionAddAndOverrideCtorInjection(testCase)
            inj1 = IoC.Container();
            inj1.setSingleton('handle', @IoC.tests.HandleModel, '$id', 1:10);
            
            obj1 = inj1.get('handle', "#3", 1:100, "#1", '$id123');
            
            assert(isa(obj1, 'IoC.tests.HandleModel'));
            assert(isequal(obj1.id, 'id123'));
            assert(isequal(obj1.child1, 1:10));
            assert(isequal(obj1.child2, 1:100));
        end
    end
end
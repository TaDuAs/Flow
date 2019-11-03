classdef ClassAnalyzerCtorTests < matlab.unittest.TestCase
    methods (Test)
        function fromMCtor(testCase)
            mctor = mfc.MCtor(@mfc.tests.HandleModel);
            
            ctor = mfc.ClassAnalyzerCtor(mctor);
            
            ext = mfc.extract.StructJitExtractor(struct());
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.HandleModel'));
            assert(numel(obj) == 1);
        end
        
        function fromTypeName(testCase)
            ctor = mfc.ClassAnalyzerCtor('mfc.tests.HandleModel');
            
            ext = mfc.extract.StructJitExtractor(struct());
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.HandleModel'));
            assert(numel(obj) == 1);
        end
        
        function fromFunctionHandle(testCase)
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.HandleModel);
            
            ext = mfc.extract.StructJitExtractor(struct());
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.HandleModel'));
            assert(numel(obj) == 1);
        end
        
        function getTypeName(testCase)
            mctor = mfc.ClassAnalyzerCtor(@mfc.tests.HandleModel);
            
            ctor = mfc.ClassAnalyzerCtor(mctor);
            
            type = ctor.getTypeName();
            
            assert(strcmp(type, 'mfc.tests.HandleModel'));
        end
        
        function buildWithParams(testCase)
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.HandleModel);
            
            ext = mfc.extract.NameValueJitExtractor({'id', 'blah', 'child1', 1:10});
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.HandleModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.id, 'blah'));
            assert(isequal(obj.child1, 1:10));
        end
        
        function buildWithParams2(testCase)
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.HandleModel);
            
            ext = mfc.extract.NameValueJitExtractor({'id', 'blah', 'list', 1:10});
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.HandleModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.id, 'blah'));
            assert(isequal(obj.list, 1:10));
            assert(isequal(obj.child1, []));
            assert(isequal(obj.child2, []));
        end
        
        function buildWithOptionalParams(testCase)
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.DynamicCtorParamsModel);
            
            ext = mfc.extract.NameValueJitExtractor({'id', 'blah', 'child1', mfc.tests.HandleModel(), 'list', 1:10});
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.DynamicCtorParamsModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.id, 'blah'));
            assert(isequal(obj.list, 1:10));
            assert(isa(obj.child1, 'mfc.tests.HandleModel'));
        end
        
        function buildWithOptionalParams2(testCase)
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.DynamicCtorParamsModel);
            
            ext = mfc.extract.NameValueJitExtractor({'child2', 1:10});
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.DynamicCtorParamsModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.child2, 1:10));
            assert(isequal(obj.id, ''));
            assert(isequal(obj.list, []));
            assert(isequal(obj.child1, []));
        end
        
        function buildWithNoParams(testCase)
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.DynamicCtorParamsModel);
            
            ext = mfc.extract.StructJitExtractor(struct());
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.DynamicCtorParamsModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.id, ''));
            assert(isequal(obj.list, []));
            assert(isequal(obj.child1, []));
            assert(isequal(obj.child2, []));
        end
        
        function buildNonMetaWithNoParams(testCase)
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.NonMetaModel);
            
            ext = mfc.extract.StructJitExtractor(struct());
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.NonMetaModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.id, []));
            assert(isequal(obj.x, []));
            assert(isequal(obj.y, []));
        end
        
        function buildNonMetaWithFromClone(testCase)
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.NonMetaModel);
            
            cloneThis = mfc.tests.NonMetaModel('hatul', 1:10, 11:20);
            ext = mfc.extract.StructJitExtractor(cloneThis);
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.NonMetaModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.id, 'hatul'));
            assert(isequal(obj.x, 1:10));
            assert(isequal(obj.y, 11:20));
        end
        
        function buildNonMetaWithFromFieldStruct(testCase)
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.NonMetaModel);
            
            fields = struct('id', 'hatul', 'y', 11:20);
            ext = mfc.extract.StructJitExtractor(fields);
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.NonMetaModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.id, 'hatul'));
            assert(isequal(obj.x, []));
            assert(isequal(obj.y, 11:20));
        end
        
        function buildNonMetaWithFromExtractor(testCase)
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.NonMetaModel);
            
            fields = struct('id', 'hatul', 'x', 1:10, 'y', 11:20);
            extractor = mfc.extract.StructJitExtractor(fields);
            obj = ctor.build(extractor);
            
            assert(isa(obj, 'mfc.tests.NonMetaModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.id, 'hatul'));
            assert(isequal(obj.x, 1:10));
            assert(isequal(obj.y, 11:20));
        end
        
        function buildNonMetaWithWrongParamsFormat(testCase)
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.NonMetaModel);
            
            ext = mfc.extract.NameValueJitExtractor({'hatul', 1:10});
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.NonMetaModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.id, []));
            assert(isequal(obj.x, []));
            assert(isequal(obj.y, []));
        end
        
        function buildNonMetaWithWrongParamsFormat2(testCase)
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.NonMetaModel);
            
            success=true;
            try
                obj = ctor.build('hatul', 1:10, 1:10);
                success = false;
            catch ex
                % this is good
            end
            
            assert(success);
        end
        
        function buildNonMetaWithParams(testCase)
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.NonMetaModel);
            
            ext = mfc.extract.NameValueJitExtractor({'id', 'hatul', 'x', 1:10, 'y', 11:20});
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.NonMetaModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.id, 'hatul'));
            assert(isequal(obj.x, 1:10));
            assert(isequal(obj.y, 11:20));
        end
        
        function buildNonMetaWithSomeParams(testCase)
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.NonMetaModel);
            
            ext = mfc.extract.NameValueJitExtractor({'id', 'hatul', 'y', 1:10});
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.NonMetaModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.id, 'hatul'));
            assert(isequal(obj.x, []));
            assert(isequal(obj.y, 1:10));
        end
        
        function buildWithDependencyInjection(testCase)
            dep = struct('Blah', "The Quick Brown Fox", 'text', 1:10);
            ioc = mfc.tests.IoCContainerMock(dep);
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.DependencyInjectionModel, ioc);
            
            ext = mfc.extract.StructJitExtractor(struct('text', 'my string'));
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.DependencyInjectionModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.input, {'blah', "The Quick Brown Fox", 'text', 'my string'}));
        end
        
        function buildWithMissingDependencyInjection(testCase)
            dep = struct('Blah2', "The Quick Brown Fox", 'text', 1:10);
            ioc = mfc.tests.IoCContainerMock(dep);
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.DependencyInjectionModel, ioc);
            
            ext = mfc.extract.StructJitExtractor(struct('text', 'my string'));
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.DependencyInjectionModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.input, {'text', 'my string'}));
        end
        
        function buildWithDependencyInjectionMissingProps(testCase)
            dep = struct('Blah', "The Quick Brown Fox", 'text', 1:10);
            ioc = mfc.tests.IoCContainerMock(dep);
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.DependencyInjectionModel, ioc);
            
            ext = mfc.extract.StructJitExtractor(struct());
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.DependencyInjectionModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.input, {'blah', "The Quick Brown Fox"}));
        end
        
        function buildWithDependencyInjectionMissingAll(testCase)
            dep = struct('Blah2', "The Quick Brown Fox", 'text', 1:10);
            ioc = mfc.tests.IoCContainerMock(dep);
            ctor = mfc.ClassAnalyzerCtor(@mfc.tests.DependencyInjectionModel, ioc);
            
            ext = mfc.extract.StructJitExtractor(struct());
            obj = ctor.build(ext);
            
            assert(isa(obj, 'mfc.tests.DependencyInjectionModel'));
            assert(numel(obj) == 1);
            assert(isequal(obj.input, {}));
        end
    end
end


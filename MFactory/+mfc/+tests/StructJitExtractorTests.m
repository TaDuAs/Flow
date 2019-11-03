classdef StructJitExtractorTests < matlab.unittest.TestCase
    methods (Test)
        function structHasField(testCase)
            obj = struct();
            obj.a = 1:10;
            obj.b = 'the fat cat';
            ext = mfc.extract.StructJitExtractor(obj);
            
            tf = ext.hasProp('a') && ext.hasProp('b');
            
            assert(tf);
        end
        
        function structDoesntHaveField(testCase)
            obj = struct();
            obj.a = 1:10;
            obj.b = 'the fat cat';
            ext = mfc.extract.StructJitExtractor(obj);
            
            tf = ext.hasProp('c') || ext.hasProp('x');
            
            assert(~tf);
        end
        
        function objectHasField(testCase)
            obj = mfc.tests.HandleModel();
            ext = mfc.extract.StructJitExtractor(obj);
            
            tf = ext.hasProp('child1') && ext.hasProp('id');
            
            assert(tf);
        end
        
        function objectDoesntHaveField(testCase)
            obj = mfc.tests.HandleModel();
            ext = mfc.extract.StructJitExtractor(obj);
            
            tf = ext.hasProp('c') || ext.hasProp('x');
            
            assert(~tf);
        end
        
        function structGetField(testCase)
            obj = struct();
            obj.a = 1:10;
            obj.b = 'the fat cat';
            ext = mfc.extract.StructJitExtractor(obj);
            
            value = ext.get('a');
            
            assert(isequal(value, 1:10));
        end
        
        function structDoesntGetField(testCase)
            obj = struct();
            obj.a = 1:10;
            obj.b = 'the fat cat';
            ext = mfc.extract.StructJitExtractor(obj);
            
            success = true;
            try
                ext.get('c');
                success = false;
            catch 
                %this is good
            end
            
            assert(success);
        end
        
        function objectGetField(testCase)
            obj = mfc.tests.HandleModel('blah');
            ext = mfc.extract.StructJitExtractor(obj);
            
            value = ext.get('id');
            
            assert(isequal(value, 'blah'));
        end
        
        function objectDoesntGetField(testCase)
            obj = mfc.tests.HandleModel('blah');
            ext = mfc.extract.StructJitExtractor(obj);
            
            success = true;
            try
                ext.get('c');
                success = false;
            catch 
                %this is good
            end
            
            assert(success);
        end
    end
end


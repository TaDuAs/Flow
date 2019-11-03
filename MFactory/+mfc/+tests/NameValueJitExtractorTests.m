classdef NameValueJitExtractorTests < matlab.unittest.TestCase
    methods (Test)
        function hasField(testCase)
            ext = mfc.extract.NameValueJitExtractor({'a', 1:10, 'b', 'the fat cat'});
            
            tf = ext.hasProp('a') && ext.hasProp('b');
            
            assert(tf);
        end
        
        function doesntHaveField(testCase)
            ext = mfc.extract.NameValueJitExtractor({'a', 1:10, 'b', 'the fat cat'});
            
            tf = ext.hasProp('c') || ext.hasProp('x');
            
            assert(~tf);
        end
        
        function getField(testCase)
            ext = mfc.extract.NameValueJitExtractor({'a', 1:10, 'b', 'the fat cat'});
            
            value = ext.get('a');
            
            assert(isequal(value, 1:10));
        end
        
        function doesntGetField(testCase)
            ext = mfc.extract.NameValueJitExtractor({'a', 1:10, 'b', 'the fat cat'});
            
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


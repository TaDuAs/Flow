classdef str2booleanTests < matlab.unittest.TestCase
    methods (Test)
        function numericTrueTest(testCase)
            testCase.verifyEqual(gen.str2boolean('1'), true);
            testCase.verifyEqual(gen.str2boolean('10'), true);
            testCase.verifyEqual(gen.str2boolean('-4'), true);
        end
        
        function numericFalseTest(testCase)
            testCase.verifyEqual(gen.str2boolean('0'), false);
        end
        
        function textTrueTest(testCase)
            testCase.verifyEqual(gen.str2boolean('true'), true);
        end
        
        function textFalseTest(testCase)
            testCase.verifyEqual(gen.str2boolean('false'), false);
        end
        
        function numericVectorSpacesTest(testCase)
            testCase.verifyEqual(gen.str2boolean('1 0 0 1'), logical([1 0 0 1]));
        end
        
        function numericVectorCommasTest(testCase)
            testCase.verifyEqual(gen.str2boolean('1,0,0,1'), logical([1 0 0 1]));
        end
        
        function numericVectorCommasSpacesCombinedTest(testCase)
            testCase.verifyEqual(gen.str2boolean('1 ,0 , 0, 1,1 0'), logical([1 0 0 1 1 0]));
        end
        
        function combinedVectorTest(testCase)
            testCase.verifyEqual(gen.str2boolean('1 ,false , 0, 1,true 0'), logical([1 0 0 1 1 0]));
        end
    end
end


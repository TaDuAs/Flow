classdef isSameSetAsTests < matlab.unittest.TestCase
    methods (Test)
        function strings(testCase)
            testCase.verifyTrue(gen.isSameSetAs({'a'}, {'a'}));
            testCase.verifyTrue(gen.isSameSetAs({'dsa', 'abcd'}, {'dsa', 'abcd'}));
            testCase.verifyTrue(gen.isSameSetAs({'dsa', 'abcd'}, {'abcd', 'dsa'}));
            testCase.verifyTrue(gen.isSameSetAs({'d', 'xyz', 'abc123'}, {'xyz', 'abc123', 'd'}));
            
            testCase.verifyFalse(gen.isSameSetAs({'dsa', 'xyz'}, {'abc', 'dsa'}));
            testCase.verifyFalse(gen.isSameSetAs({'dsa', 'xyz', 'abc'}, {'abc', 'dsa'}));
            testCase.verifyFalse(gen.isSameSetAs({'dsa'}, {'dsa', 'dsa'}));
        end
        
        function numbers(testCase)
            testCase.verifyTrue(gen.isSameSetAs(1, 1));
            testCase.verifyTrue(gen.isSameSetAs([1, 2], [1, 2]));
            testCase.verifyTrue(gen.isSameSetAs([1 2], [2 1]));
            
            testCase.verifyFalse(gen.isSameSetAs([1 2], [1 3]));
            testCase.verifyFalse(gen.isSameSetAs([1 2 3], [1 2]));
            testCase.verifyFalse(gen.isSameSetAs(1, [1 1]));
        end
        
        function numbersCells(testCase)
            testCase.verifyTrue(gen.isSameSetAs({1}, {1}));
            testCase.verifyTrue(gen.isSameSetAs({1, 2}, {1, 2}));
            testCase.verifyTrue(gen.isSameSetAs({1 2}, {2 1}));
            testCase.verifyTrue(gen.isSameSetAs({1 1:10 magic(5)}, {magic(5) 1 1:10}));
            
            testCase.verifyFalse(gen.isSameSetAs({1 2}, {1 3}));
            testCase.verifyFalse(gen.isSameSetAs({1 2 3}, {1 2}));
            testCase.verifyFalse(gen.isSameSetAs({1}, {1 1}));
        end
        
        function numbersArrays(testCase)
            testCase.verifyTrue(gen.isSameSetAs(1, {1}));
            testCase.verifyTrue(gen.isSameSetAs([1 2], {1, 2}));
            testCase.verifyTrue(gen.isSameSetAs([1 2], {2 1}));
            
            testCase.verifyFalse(gen.isSameSetAs([1 2], {1 3}));
            testCase.verifyFalse(gen.isSameSetAs([1 2 3], {1 2}));
            testCase.verifyFalse(gen.isSameSetAs(1, {1 1}));
        end
        
        function numbersAndStrings(testCase)
            testCase.verifyTrue(gen.isSameSetAs({1, 'abc'}, {1, 'abc'}));
            testCase.verifyTrue(gen.isSameSetAs({1, 'abc'}, {'abc', 1}));
            testCase.verifyTrue(gen.isSameSetAs({1, 'abc', 'xy' 2}, {2, 1, 'xy', 'abc'}));
            testCase.verifyTrue(gen.isSameSetAs({1 1:10 magic(5) 'xyz', "ABC"}, {magic(5) 1 1:10, "xyz", "ABC"}));
        end
    end
end


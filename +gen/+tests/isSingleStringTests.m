classdef isSingleStringTests < matlab.unittest.TestCase
    methods (Test)
        function charRow(testCase)
            testCase.verifyEqual(gen.isSingleString('dsa'), true);
        end
        
        function charCol(testCase)
            testCase.verifyEqual(gen.isSingleString(['d';'s';'a']), false);
        end
        
        function charMat(testCase)
            testCase.verifyEqual(gen.isSingleString(['dd';'ss';'aa']), false);
        end
        
        function charScalar(testCase)
            testCase.verifyEqual(gen.isSingleString('a'), true);
        end
        
        function emtyChar(testCase)
            testCase.verifyEqual(gen.isSingleString(''), true);
        end
        
        function charRowCell(testCase)
            testCase.verifyEqual(gen.isSingleString({'dsa'}), true);
        end
        
        function charColCell(testCase)
            testCase.verifyEqual(gen.isSingleString({['d';'s';'a']}), false);
        end
        
        function charMatCell(testCase)
            testCase.verifyEqual(gen.isSingleString({['dd';'ss';'aa']}), false);
        end
        
        function charScalarCell(testCase)
            testCase.verifyEqual(gen.isSingleString({'a'}), true);
        end
        
        function emtyCharCell(testCase)
            testCase.verifyEqual(gen.isSingleString({''}), true);
        end
        
        function emtyCell(testCase)
            testCase.verifyEqual(gen.isSingleString({}), false);
        end
        
        function multiCharCell(testCase)
            testCase.verifyEqual(gen.isSingleString({'dsa', 'dsa'}), false);
        end
        
        function multiEmptyCharCell(testCase)
            testCase.verifyEqual(gen.isSingleString({'', ''}), false);
        end
        
        function stringScalar(testCase)
            testCase.verifyEqual(gen.isSingleString("dsa"), true);
        end
        
        function emptyStringScalar(testCase)
            testCase.verifyEqual(gen.isSingleString(""), true);
        end
        
        function emptyString(testCase)
            testCase.verifyEqual(gen.isSingleString(string.empty()), false);
        end
        
        function stringRow(testCase)
            testCase.verifyEqual(gen.isSingleString(["12" "321"]), false);
        end
        
        function stringCol(testCase)
            testCase.verifyEqual(gen.isSingleString(["12"; "321"]), false);
        end
        
        function stringScalarCell(testCase)
            testCase.verifyEqual(gen.isSingleString({"12"}), true);
        end
        
        function strinRowCell(testCase)
            testCase.verifyEqual(gen.isSingleString({"12" "321"}), false);
        end
        
        function stringColCell(testCase)
            testCase.verifyEqual(gen.isSingleString({"12"; "321"}), false);
        end
        
        function combinedCell(testCase)
            testCase.verifyEqual(gen.isSingleString({"12" '321'}), false);
        end
    end
end


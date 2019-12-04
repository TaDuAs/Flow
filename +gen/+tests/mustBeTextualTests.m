classdef mustBeTextualTests < matlab.unittest.TestCase
    methods (Test)
        function charRow(testCase)
            gen.valid.mustBeTextual('dsa');
        end
        
        function charCol(testCase)
            gen.valid.mustBeTextual(['d';'s';'a']);
        end
        
        function charMat(testCase)
            gen.valid.mustBeTextual(['dd';'ss';'aa']);
        end
        
        function charScalar(testCase)
            gen.valid.mustBeTextual('a');
        end
        
        function emptyChar(testCase)
            gen.valid.mustBeTextual('');
        end
        
        function charRowCell(testCase)
            gen.valid.mustBeTextual({'dsa'});
        end
        
        function charColCell(testCase)
            gen.valid.mustBeTextual({['d';'s';'a']});
        end
        
        function charMatCell(testCase)
            gen.valid.mustBeTextual({['dd';'ss';'aa']});
        end
        
        function charScalarCell(testCase)
            gen.valid.mustBeTextual({'a'});
        end
        
        function emptyCharCell(testCase)
            gen.valid.mustBeTextual({''});
        end
        
        function emptyCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextual({}), 'Validator:mustBeTextual');
        end
        
        function multiCharCell(testCase)
            gen.valid.mustBeTextual({'dsa', 'dsa'});
        end
        
        function multiEmptyCharCell(testCase)
            gen.valid.mustBeTextual({'', ''});
        end
        
        function stringScalar(testCase)
            gen.valid.mustBeTextual("dsa");
        end
        
        function emptyStringScalar(testCase)
            gen.valid.mustBeTextual("");
        end
        
        function emptyString(testCase)
            gen.valid.mustBeTextual(string.empty());
        end
        
        function stringRow(testCase)
            gen.valid.mustBeTextual(["12" "321"]);
        end
        
        function stringCol(testCase)
            gen.valid.mustBeTextual(["12"; "321"]);
        end
        
        function stringScalarCell(testCase)
            gen.valid.mustBeTextual({"12"});
        end
        
        function strinRowCell(testCase)
            gen.valid.mustBeTextual({"12" "321"});
        end
        
        function stringColCell(testCase)
            gen.valid.mustBeTextual({"12"; "321"});
        end
        
        function combinedTextualCell(testCase)
            gen.valid.mustBeTextual({"12" '321'});
        end
        
        function numeric(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextual(1), 'Validator:mustBeTextual');
        end
        
        function object(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextual(testCase), 'Validator:mustBeTextual');
        end
        
        function numericCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextual({1}), 'Validator:mustBeTextual');
        end
        
        function objectCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextual({testCase}), 'Validator:mustBeTextual');
        end
        
        function combinedTextualNonTextualCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextual({"123" testCase 'sad'}), 'Validator:mustBeTextual');
        end
    end
end


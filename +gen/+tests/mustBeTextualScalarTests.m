classdef mustBeTextualScalarTests < matlab.unittest.TestCase
    methods (Test)
        function charRow(testCase)
            gen.valid.mustBeTextualScalar('dsa');
        end
        
        function charCol(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar(['d';'s';'a']), 'Validator:mustBeTextualScalar');
        end
        
        function charMat(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar(['dd';'ss';'aa']), 'Validator:mustBeTextualScalar');
        end
        
        function charScalar(testCase)
            gen.valid.mustBeTextualScalar('a');
        end
        
        function emptyChar(testCase)
            gen.valid.mustBeTextualScalar('');
        end
        
        function charRowCell(testCase)
            gen.valid.mustBeTextualScalar({'dsa'});
        end
        
        function charColCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar({['d';'s';'a']}), 'Validator:mustBeTextualScalar');
        end
        
        function charMatCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar({['dd';'ss';'aa']}), 'Validator:mustBeTextualScalar');
        end
        
        function charScalarCell(testCase)
            gen.valid.mustBeTextualScalar({'a'});
        end
        
        function emptyCharCell(testCase)
            gen.valid.mustBeTextualScalar({''});
        end
        
        function emptyCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar({}), 'Validator:mustBeTextualScalar');
        end
        
        function multiCharCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar({'dsa', 'dsa'}), 'Validator:mustBeTextualScalar');
        end
        
        function multiEmptyCharCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar({'', ''}), 'Validator:mustBeTextualScalar');
        end
        
        function stringScalar(testCase)
            gen.valid.mustBeTextualScalar("dsa");
        end
        
        function emptyStringScalar(testCase)
            gen.valid.mustBeTextualScalar("");
        end
        
        function emptyString(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar(string.empty()), 'Validator:mustBeTextualScalar');
        end
        
        function stringRow(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar(["12" "321"]), 'Validator:mustBeTextualScalar');
        end
        
        function stringCol(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar(["12"; "321"]), 'Validator:mustBeTextualScalar');
        end
        
        function stringScalarCell(testCase)
            gen.valid.mustBeTextualScalar({"12"});
        end
        
        function strinRowCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar({"12" "321"}), 'Validator:mustBeTextualScalar');
        end
        
        function stringColCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar({"12"; "321"}), 'Validator:mustBeTextualScalar');
        end
        
        function combinedTextualCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar({"12" '321'}), 'Validator:mustBeTextualScalar');
        end
        
        function numeric(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar(1), 'Validator:mustBeTextualScalar');
        end
        
        function object(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar(testCase), 'Validator:mustBeTextualScalar');
        end
        
        function numericCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar({1}), 'Validator:mustBeTextualScalar');
        end
        
        function objectCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar({testCase}), 'Validator:mustBeTextualScalar');
        end
        
        function combinedTextualNonTextualCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeTextualScalar({"123" testCase 'sad'}), 'Validator:mustBeTextualScalar');
        end
    end
end


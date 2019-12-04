classdef mustBeNumericOrTextualScalarTests < matlab.unittest.TestCase
    methods (Test)
        function charRow(testCase)
            gen.valid.mustBeNumericOrTextualScalar('dsa');
        end
        
        function charCol(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(['d';'s';'a']), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function charMat(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(['dd';'ss';'aa']), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function charScalar(testCase)
            gen.valid.mustBeNumericOrTextualScalar('a');
        end
        
        function emptyChar(testCase)
            gen.valid.mustBeNumericOrTextualScalar('');
        end
        
        function charRowCell(testCase)
            gen.valid.mustBeNumericOrTextualScalar({'dsa'});
        end
        
        function charColCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar({['d';'s';'a']}), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function charMatCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar({['dd';'ss';'aa']}), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function charScalarCell(testCase)
            gen.valid.mustBeNumericOrTextualScalar({'a'});
        end
        
        function emptyCharCell(testCase)
            gen.valid.mustBeNumericOrTextualScalar({''});
        end
        
        function emptyCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar({}), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function multiCharCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar({'dsa', 'dsa'}), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function multiEmptyCharCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar({'', ''}), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function stringScalar(testCase)
            gen.valid.mustBeNumericOrTextualScalar("dsa");
        end
        
        function emptyStringScalar(testCase)
            gen.valid.mustBeNumericOrTextualScalar("");
        end
        
        function emptyString(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(string.empty()), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function stringRow(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(["12" "321"]), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function stringCol(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(["12"; "321"]), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function stringScalarCell(testCase)
            gen.valid.mustBeNumericOrTextualScalar({"12"});
        end
        
        function strinRowCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar({"12" "321"}), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function stringColCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar({"12"; "321"}), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function combinedTextualCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar({"12" '321'}), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function numeric(testCase)
            gen.valid.mustBeNumericOrTextualScalar(1);
        end
        
        function numericRow(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar([1 2 3]), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function numericCol(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar([1; 2; 3]), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function numericMat(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar([1 2 3; 1 2 3]), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function numericEmpty(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar([]), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function numericTypes(testCase)
            gen.valid.mustBeNumericOrTextualScalar(int8(1));
            gen.valid.mustBeNumericOrTextualScalar(int16(1));
            gen.valid.mustBeNumericOrTextualScalar(int32(1));
            gen.valid.mustBeNumericOrTextualScalar(int64(1));
            gen.valid.mustBeNumericOrTextualScalar(uint8(1));
            gen.valid.mustBeNumericOrTextualScalar(uint16(1));
            gen.valid.mustBeNumericOrTextualScalar(uint32(1));
            gen.valid.mustBeNumericOrTextualScalar(uint64(1));
            gen.valid.mustBeNumericOrTextualScalar(single(1));
        end
        
        function numericTypesVectors(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(int8(1:3)), 'Validator:mustBeNumericOrTextualScalar');
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(int16(1:3)), 'Validator:mustBeNumericOrTextualScalar');
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(int32(1:3)), 'Validator:mustBeNumericOrTextualScalar');
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(int64(1:3)), 'Validator:mustBeNumericOrTextualScalar');
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(uint8(1:3)), 'Validator:mustBeNumericOrTextualScalar');
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(uint16(1:3)), 'Validator:mustBeNumericOrTextualScalar');
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(uint32(1:3)), 'Validator:mustBeNumericOrTextualScalar');
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(uint64(1:3)), 'Validator:mustBeNumericOrTextualScalar');
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(single(1:3)), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function object(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar(testCase), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function numericCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar({1}), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function objectCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar({testCase}), 'Validator:mustBeNumericOrTextualScalar');
        end
        
        function combinedTextualNonTextualCell(testCase)
            testCase.verifyError(@() gen.valid.mustBeNumericOrTextualScalar({"123" testCase 'sad'}), 'Validator:mustBeNumericOrTextualScalar');
        end
    end
end


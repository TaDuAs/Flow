classdef mustBeKeyValuePairsTests < matlab.unittest.TestCase
    methods (Test)
        function testChar(testCase)
            testCase.verifyError(@() gen.valid.mustBeKeyValuePairs({'key'}), '');
        end
        
        function testString(testCase)
            testCase.verifyError(@() gen.valid.mustBeKeyValuePairs({"key"}), '');
        end
        
        function testNumber(testCase)
            testCase.verifyError(@() gen.valid.mustBeKeyValuePairs({123}), '');
        end
        
        function testPair(testCase)
            gen.valid.mustBeKeyValuePairs({'X', 123});
        end
        
        function testPairWithString(testCase)
            gen.valid.mustBeKeyValuePairs({"X", 123});
        end
        
        function testTwoPairs(testCase)
            gen.valid.mustBeKeyValuePairs({"X", 1:3, 'blah', "dsads"});
        end
        
        function testFlippedOrder(testCase)
            testCase.verifyError(@() gen.valid.mustBeKeyValuePairs({1:3, "dsads"}), 'Validator:mustBeTextualScalar');
        end
        
        function testWrongOrder(testCase)
            testCase.verifyError(@() gen.valid.mustBeKeyValuePairs({"X", 'blah', 1:3, "dsads"}), 'Validator:mustBeTextualScalar');
        end
    end
end


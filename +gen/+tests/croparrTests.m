classdef croparrTests < matlab.unittest.TestCase
    methods (Test)
        function cropRange1(testCase)
            x = 1:100;
            
            y = gen.croparr(x, [1, 10]);
            
            testCase.verifyEqual(y, 1:10);
        end
        
        function cropRange2(testCase)
            x = 1:100;
            
            y = gen.croparr(x, [10, 50]);
            
            testCase.verifyEqual(y, 10:50);
        end
        
        function cropRange3(testCase)
            x = 1:100;
            
            y = gen.croparr(x, [60, 100]);
            
            testCase.verifyEqual(y, 60:100);
        end
        
        function cropRange4(testCase)
            x = 1:100;
            
            y = gen.croparr(x, [1, 100]);
            
            testCase.verifyEqual(y, x);
        end
        
        function cropFragmentStart1(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.25, 'start');
            
            testCase.verifyEqual(y, 1:25);
        end
        
        function cropFragmentStart2(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.1, 'start');
            
            testCase.verifyEqual(y, 1:10);
        end
        
        function cropFragmentStart3(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.02, 'start');
            
            testCase.verifyEqual(y, 1:2);
        end
        
        function cropFragmentStart4(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.01, 'start');
            
            testCase.verifyEqual(y, 1);
        end
        
        function cropFragmentStart5(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.0001, 'start');
            
            testCase.verifyEqual(y, 1);
        end
        
        function cropFragmentStart6(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 1, 'start');
            
            testCase.verifyEqual(y, 1:100);
        end
        
        function cropFragmentEnd1(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.25, 'end');
            
            testCase.verifyEqual(y, 76:100);
        end
        
        function cropFragmentEnd2(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.1, 'end');
            
            testCase.verifyEqual(y, 91:100);
        end
        
        function cropFragmentEnd3(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.02, 'end');
            
            testCase.verifyEqual(y, 99:100);
        end
        
        function cropFragmentEnd4(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.01, 'end');
            
            testCase.verifyEqual(y, 100);
        end
        
        function cropFragmentEnd5(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.0001, 'end');
            
            testCase.verifyEqual(y, 100);
        end
        
        function cropFragmentEnd6(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 1, 'end');
            
            testCase.verifyEqual(y, 1:100);
        end
        
        function cropFragmentIdx1(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.1, 1);
            
            testCase.verifyEqual(y, 1:10);
        end
        
        function cropFragmentIdx2(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.1, 10);
            
            testCase.verifyEqual(y, 10:19);
        end
        
        function cropFragmentIdx3(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.01, 10);
            
            testCase.verifyEqual(y, 10);
        end
        
        function cropFragmentIdx4(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.001, 50);
            
            testCase.verifyEqual(y, 50);
        end
        
        function cropFragmentIdx5(testCase)
            x = 1:100;
            
            y = gen.croparr(x, 0.5, 26);
            
            testCase.verifyEqual(y, 26:75);
        end
    end
end


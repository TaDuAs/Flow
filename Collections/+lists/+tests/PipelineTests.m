classdef PipelineTests < matlab.unittest.TestCase
    
    methods (TestMethodSetup)
    end
    
    methods(TestMethodTeardown)
    end
    
    methods (Test)
        function addTaskTest1(testCase)
            pl = lists.Pipeline();
            
            pt = lists.PipelineTask();
            pl.add(pt);
            
            testCase.verifyEqual(pl.length(), 1);
            testCase.verifyFalse(pl.isempty());
            testCase.verifyEqual(pl.size(), [1,1]);
            testCase.verifyEqual(pl.size(1), 1);
            testCase.verifyEqual(pl.size(2), 1);
            testCase.verifyEqual(pl.getv(1), pt);
        end
        
        function addSetvTest1(testCase)
            pl = lists.Pipeline();
            
            pt = lists.PipelineTask();
            pl.setv(1, pt);
            
            testCase.verifyEqual(pl.length(), 1);
            testCase.verifyFalse(pl.isempty());
            testCase.verifyEqual(pl.size(), [1,1]);
            testCase.verifyEqual(pl.size(1), 1);
            testCase.verifyEqual(pl.size(2), 1);
            testCase.verifyEqual(pl.getv(1), pt);
        end
    end
end


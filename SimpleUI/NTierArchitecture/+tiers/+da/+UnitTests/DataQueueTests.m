classdef DataQueueTests < matlab.unittest.TestCase
 
    properties
%         TestFigure
    end
 
%     methods(TestMethodSetup)
%         function createFigure(testCase)
%             testCase.TestFigure = figure;
%         end
%     end
 
%     methods(TestMethodTeardown)
%         function closeFigure(testCase)
%             close(testCase.TestFigure)
%         end
%     end
 
    methods(Test)
 
        function x(testCase)
            import Simple.DataAccess.*;
            import matlab.unittest.constraints.IsEmpty;
            
            [stub,behav] = createMock(testCase.forInteractiveUse,?DataAccessor);
 
            dq = DataQueue(stub, {'a', 'b', 'c'});
            
            testCase.verifyThat(dq, IsEmpty, ...
                'Default current object should be empty')
        end
 
    end
 
end
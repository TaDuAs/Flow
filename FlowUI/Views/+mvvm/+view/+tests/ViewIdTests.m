classdef ViewIdTests < matlab.mock.TestCase 
    methods (Test)
        function eqDifferentType(testCase)
            vid1 = mvvm.view.ViewID('view1');
            vid2 = mvvm.view.ViewID('view2');
            
            assert(vid1 ~= vid2);
            assert(~(vid1 == vid2));
        end
        
        function eqDifferentTypeId(testCase)
            vid1 = mvvm.view.ViewID('view1', 123);
            vid2 = mvvm.view.ViewID('view2', 10);
            
            assert(vid1 ~= vid2);
            assert(~(vid1 == vid2));
        end
        
        function eqSameTypeNoId(testCase)
            vid1 = mvvm.view.ViewID('view2');
            vid2 = mvvm.view.ViewID('view2');
            
            assert(vid1 == vid2);
            assert(~(vid1 ~= vid2));
        end
        
        function eqSameTypeDifferentId(testCase)
            vid1 = mvvm.view.ViewID('view2', 123);
            vid2 = mvvm.view.ViewID('view2', 10);
            
            assert(vid1 ~= vid2);
            assert(~(vid1 == vid2));
        end
        
        function eqSameTypeYesNoId(testCase)
            vid1 = mvvm.view.ViewID('view2');
            vid2 = mvvm.view.ViewID('view2', 10);
            
            assert(vid1 ~= vid2);
            assert(~(vid1 == vid2));
        end
        
        function eqDifferentTypeYesNoId(testCase)
            vid1 = mvvm.view.ViewID('view1');
            vid2 = mvvm.view.ViewID('view2', 10);
            
            assert(vid1 ~= vid2);
            assert(~(vid1 == vid2));
        end
        
        function eqSameTypeDifferentStringId(testCase)
            vid1 = mvvm.view.ViewID('view1', 'xyz');
            vid2 = mvvm.view.ViewID('view2', 'abc');
            
            assert(vid1 ~= vid2);
            assert(~(vid1 == vid2));
        end
        
        function eqSameTypeYesNoStringId(testCase)
            vid1 = mvvm.view.ViewID('view1');
            vid2 = mvvm.view.ViewID('view2', 'abc');
            
            assert(vid1 ~= vid2);
            assert(~(vid1 == vid2));
        end
        
        function eqSameTypeSameStringId(testCase)
            vid1 = mvvm.view.ViewID('view1', 'abc');
            vid2 = mvvm.view.ViewID('view2', 'abc');
            
            assert(vid1 ~= vid2);
            assert(~(vid1 == vid2));
        end
    end
end


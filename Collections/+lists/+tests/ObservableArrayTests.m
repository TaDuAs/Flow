classdef ObservableArrayTests < matlab.unittest.TestCase
    
    methods (TestMethodSetup)
    end
    
    methods(TestMethodTeardown)
    end
    
    methods (Test) % indexing
        function indexingSubsRefTest1(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A);
            
            testCase.verifyEqual(arr(1), A(1));
            testCase.verifyEqual(arr(1,1), A(1,1));
            testCase.verifyEqual(arr(2,4), A(2,4));
            testCase.verifyEqual(arr(:,1), A(:,1));
            testCase.verifyEqual(arr(1,:), A(1,:));
            testCase.verifyEqual(arr(:,:), A);
            testCase.verifyEqual(arr(1:2,3:4), A(1:2,3:4));
            testCase.verifyEqual(arr(1,1:end), A(1,1:5));
            testCase.verifyEqual(arr(1:end,2), A(1:5,2));
            testCase.verifyEqual(arr(1:end-1,4), A(1:4,4));
            testCase.verifyEqual(arr(1:end-5), A(1:20));
            testCase.verifyEqual(arr(A > 10), A(A > 10));
            testCase.verifyEqual(arr([true true false false true], 2:3), A([1,2,5], 2:3));
            testCase.verifyEqual(arr(3:end, [false false false true false]), A(3:5, 4));
        end
        
        function indexingSubsAsgnTest1(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A);
            
            arr(1) = 0;
            A(1) = 0;
            testCase.verifyEqual(arr.Array, A);
            
            arr(1,1) = 2;
            A(1,1) = 2;
            testCase.verifyEqual(arr.Array, A);
            
            arr(2,4) = nan();
            A(2,4) = nan();
            testCase.verifyEqual(arr.Array, A);
            
            arr(:,1) = (1:5)';
            A(:,1) = (1:5)';
            testCase.verifyEqual(arr.Array, A);
            
            arr(1,:) = 10:14;
            A(1,:) = 10:14;
            testCase.verifyEqual(arr.Array, A);
            
            arr(:,:) = zeros(5);
            A = zeros(5);
            testCase.verifyEqual(arr.Array, A);
            
            arr(1:2,3:4) = inf;
            A(1:2,3:4) = inf;
            testCase.verifyEqual(arr.Array, A);
            
            arr(1,1:end) = 100;
            A(1,1:end) = 100;
            testCase.verifyEqual(arr.Array, A);
            
            arr(1:end,2) = (21:25)';
            A(1:end,2) = (21:25)';
            testCase.verifyEqual(arr.Array, A);
            
            arr(1:end-1,4) = (21:24)';
            A(1:end-1,4) = (21:24)';
            testCase.verifyEqual(arr.Array, A);
            
            arr(1:end-5) = 1:20;
            A(1:end-5) = 1:20;
            testCase.verifyEqual(arr.Array, A);
            
            arr(A > 10) = 1;
            A(A > 10) = 1;
            testCase.verifyEqual(arr.Array, A);
            
            arr([true true false false true], 2:3) = [1, 2; 3, 4; 5, 6];
            A([true true false false true], 2:3) = [1, 2; 3, 4; 5, 6];
            testCase.verifyEqual(arr.Array, A);
            
            arr(3:end, [false false false true false]) = (3:5)';
            A(3:end, [false false false true false]) = (3:5)';
            testCase.verifyEqual(arr.Array, A);
            
            arr(6, :) = (1:5)';
            A(6, :) = (1:5)';
            testCase.verifyEqual(arr.Array, A);
            testCase.verifyEqual(size(arr.Array, 1), 6);
        end
    end
    
    methods (Test) % concatenation
        function horzcatTest1(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A);
            
            arr2 = [arr, A];
            
            testCase.verifyClass(arr2, 'lists.ObservableArray');
            testCase.verifyEqual(arr2.Array, [A, A]);
            testCase.verifyEqual(arr.Array, A);
        end
        
        function horzcatTest2(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A);
            
            arr2 = horzcat(arr, A);
            
            testCase.verifyClass(arr2, 'lists.ObservableArray');
            testCase.verifyEqual(arr2.Array, [A, A]);
            testCase.verifyEqual(arr.Array, A);
        end
        
        function horzcatTest3(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A);
            
            arr2 = [arr, arr];
            
            testCase.verifyClass(arr2, 'lists.ObservableArray');
            testCase.verifyEqual(arr2.Array, [A, A]);
            testCase.verifyEqual(arr.Array, A);
        end
        
        function horzcatTest4(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A);
            
            arr2 = horzcat(arr, arr);
            
            testCase.verifyClass(arr2, 'lists.ObservableArray');
            testCase.verifyEqual(arr2.Array, [A, A]);
            testCase.verifyEqual(arr.Array, A);
        end
        
        function vertcatTest1(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A);
            
            arr2 = [arr; A];
            
            testCase.verifyClass(arr2, 'lists.ObservableArray');
            testCase.verifyEqual(arr2.Array, [A; A]);
            testCase.verifyEqual(arr.Array, A);
        end
        
        function vertcatTest2(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A);
            
            arr2 = [arr; arr];
            
            testCase.verifyClass(arr2, 'lists.ObservableArray');
            testCase.verifyEqual(arr2.Array, [A; A]);
            testCase.verifyEqual(arr.Array, A);
        end
        
        function vertcatTest3(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A);
            
            arr2 = vertcat(arr, arr);
            
            testCase.verifyClass(arr2, 'lists.ObservableArray');
            testCase.verifyEqual(arr2.Array, [A; A]);
            testCase.verifyEqual(arr.Array, A);
        end
        
        function vertcatTest4(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A);
            
            arr2 = vertcat(arr, A);
            
            testCase.verifyClass(arr2, 'lists.ObservableArray');
            testCase.verifyEqual(arr2.Array, [A; A]);
            testCase.verifyEqual(arr.Array, A);
        end
    end
    
    methods (Test) % getv/setv matrix
        function getvCellsTest1(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A, 'IndexingMethod', 'cells');
            
            testCase.verifyEqual(arr.getv(1), A(1));
            testCase.verifyEqual(arr.getv(6), A(6));
            testCase.verifyEqual(arr.getv(24), A(24));
            testCase.verifyEqual(arr.getv(3:4), A(3:4));
            testCase.verifyEqual(arr.getv([1,3,5]), A([1,3,5]));
            testCase.verifyEqual(arr.getv(1,1), A(1,1));
            testCase.verifyEqual(arr.getv(2,4), A(2,4));
            testCase.verifyEqual(arr.getv(:,1), A(:,1));
            testCase.verifyEqual(arr.getv(1,:), A(1,:));
            testCase.verifyEqual(arr.getv(:,:), A);
            testCase.verifyEqual(arr.getv(1:2,3:4), A(1:2,3:4));
            testCase.verifyEqual(arr.getv(A > 10), A(A > 10));
            testCase.verifyEqual(arr.getv([true true false false true], 2:3), A([1,2,5], 2:3));
        end
        
        function getvRowsTest1(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A, 'IndexingMethod', 'rows');
            
            testCase.verifyEqual(arr.getv(1), A(1, :));
            testCase.verifyEqual(arr.getv(3), A(3, :));
            testCase.verifyEqual(arr.getv(3:4), A(3:4, :));
            testCase.verifyEqual(arr.getv([1,3,5]), A([1,3,5], :));
            testCase.verifyEqual(arr.getv(1,1), A(1,1));
            testCase.verifyEqual(arr.getv(2,4), A(2,4));
            testCase.verifyEqual(arr.getv(:,1), A(:,1));
            testCase.verifyEqual(arr.getv(1,:), A(1,:));
            testCase.verifyEqual(arr.getv(:,:), A);
            testCase.verifyEqual(arr.getv(1:2,3:4), A(1:2,3:4));
            testCase.verifyEqual(arr.getv(A > 10), A(A > 10));
            testCase.verifyEqual(arr.getv([true true false false true], 2:3), A([1,2,5], 2:3));
            testCase.verifyEqual(arr.getv([true true false false true]), A([true true false false true], :));
            testCase.verifyEqual(arr.getv([false false false false true]), A([false false false false true], :));
        end
        
        function getvColsTest1(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A, 'IndexingMethod', 'cols');
            
            testCase.verifyEqual(arr.getv(1), A(:, 1));
            testCase.verifyEqual(arr.getv(3), A(:, 3));
            testCase.verifyEqual(arr.getv(3:4), A(:, 3:4));
            testCase.verifyEqual(arr.getv([1,3,5]), A(:, [1,3,5]));
            testCase.verifyEqual(arr.getv(1,1), A(1,1));
            testCase.verifyEqual(arr.getv(2,4), A(2,4));
            testCase.verifyEqual(arr.getv(:,1), A(:,1));
            testCase.verifyEqual(arr.getv(1,:), A(1,:));
            testCase.verifyEqual(arr.getv(:,:), A);
            testCase.verifyEqual(arr.getv(1:2,3:4), A(1:2,3:4));
            testCase.verifyEqual(arr.getv(A > 10), A(A > 10));
            testCase.verifyEqual(arr.getv([true true false false true], 2:3), A([1,2,5], 2:3));
            testCase.verifyEqual(arr.getv([true true false false true]), A(:, [true true false false true]));
            testCase.verifyEqual(arr.getv([false false false false true]), A(:, [false false false false true]));
        end
        
        function setvCellsTest1(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A, 'IndexingMethod', 'cells');
            
            arr.setv(0, 1);
            A(1) = 0;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(5, 7);
            A(7) = 5;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(24, 24);
            A(24) = 24;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(3:4, 3:4);
            A(3:4) = 3:4;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(2, 1, 1);
            A(1,1) = 2;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(nan(), 2, 4);
            A(2,4) = nan();
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv((1:5)', :, 1);
            A(:,1) = (1:5)';
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(10:14, 1, :);
            A(1,:) = 10:14;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(zeros(5), :, :);
            A = zeros(5);
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(inf, 1:2, 3:4);
            A(1:2,3:4) = inf;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(1, A > 10);
            A(A > 10) = 1;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv([1, 2; 3, 4; 5, 6], [true true false false true], 2:3);
            A([true true false false true], 2:3) = [1, 2; 3, 4; 5, 6];
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv((1:5)', 6, :);
            A(6, :) = (1:5)';
            testCase.verifyEqual(arr.Array, A);
            testCase.verifyEqual(size(arr.Array, 1), 6);
        end
        
        function setvColsTest1(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A, 'IndexingMethod', 'cols');
            
            arr.setv(0, 1);
            A(:, 1) = 0;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(5, 3);
            A(:, 3) = 5;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv([1:5; 2:6]', 3:4);
            A(:, 3:4) = [1:5; 2:6]';
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(2, 1, 1);
            A(1,1) = 2;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(nan(), 2, 4);
            A(2,4) = nan();
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv((1:5)', :, 1);
            A(:,1) = (1:5)';
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(10:14, 1, :);
            A(1,:) = 10:14;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(zeros(5), :, :);
            A = zeros(5);
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(inf, 1:2, 3:4);
            A(1:2,3:4) = inf;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(1, A > 10);
            A(A > 10) = 1;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv([1, 2; 3, 4; 5, 6], [true true false false true], 2:3);
            A([true true false false true], 2:3) = [1, 2; 3, 4; 5, 6];
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv([1:5; 11:15; 21:25]', [true true false false true]);
            A(:, [true true false false true]) = [1:5; 11:15; 21:25]';
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(1, [true false false false false]);
            A(:, [true false false false false]) = 1;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv((1:5)', 6, :);
            A(6, :) = (1:5)';
            testCase.verifyEqual(arr.Array, A);
            testCase.verifyEqual(size(arr.Array, 1), 6);
            
            arr.setv((1:6)', 7);
            A(:, 7) = (1:6)';
            testCase.verifyEqual(arr.Array, A);
            testCase.verifyEqual(size(arr.Array), [6, 7]);
        end
        
        function setvRowsTest1(testCase)
            A = magic(5);
            arr = lists.ObservableArray(A, 'IndexingMethod', 'rows');
            
            arr.setv(0, 1);
            A(1, :) = 0;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(5, 3);
            A(3, :) = 5;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv([1:5; 2:6], 3:4);
            A(3:4, :) = [1:5; 2:6];
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(2, 1, 1);
            A(1,1) = 2;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(nan(), 2, 4);
            A(2,4) = nan();
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv((1:5)', :, 1);
            A(:,1) = (1:5)';
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(10:14, 1, :);
            A(1,:) = 10:14;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(zeros(5), :, :);
            A = zeros(5);
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(inf, 1:2, 3:4);
            A(1:2,3:4) = inf;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(1, A > 10);
            A(A > 10) = 1;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv([1, 2; 3, 4; 5, 6], [true true false false true], 2:3);
            A([true true false false true], 2:3) = [1, 2; 3, 4; 5, 6];
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv([1:5; 11:15; 21:25], [true true false false true]);
            A([true true false false true], :) = [1:5; 11:15; 21:25];
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv(1, [true false false false false]);
            A([true false false false false], :) = 1;
            testCase.verifyEqual(arr.Array, A);
            
            arr.setv((1:5), 6, :);
            A(6, :) = (1:5);
            testCase.verifyEqual(arr.Array, A);
            testCase.verifyEqual(size(arr.Array, 1), 6);
            
            arr.setv((2:6), 7);
            A(7, :) = (2:6);
            testCase.verifyEqual(arr.Array, A);
            testCase.verifyEqual(size(arr.Array, 1), 7);
        end
    end
end


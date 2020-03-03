classdef UnitTesting < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        todoBien;
        batchName;
    end
    
    methods
        function this = UnitTesting(testBatchName)
            this.todoBien = true;
            this.batchName = testBatchName;
            disp(['Starting to run unit tests for ', testBatchName, '... Let''s Do This!']);
        end
        
        function checkExpectation(this, expected, actual, testCase, toString, compare)
            if (nargin >= 6 && ~compare(expected, actual)) || ~Simple.UnitTests.UnitTesting.compare(expected, actual)
                this.todoBien = false;
                if nargin < 5
                    toString = @Simple.UnitTests.UnitTesting.toString;
                end
                str = [testCase, ' Testcase doesn''t match expectation. Expected value: ', toString(expected), ' Actual: ', toString(actual)];
                this.raiseFlag(str);
            end
        end
        
        function checkNonDeterministicExpectation(this, expected, actual, testCase, toString, compare)
            isgood = false;
            for i = 1:length(expected)
                if (nargin >= 6 && compare(expected{i}, actual)) || Simple.UnitTests.UnitTesting.compare(expected{i}, actual)
                    isgood = true;
                    break;
                end
            end
            
            if ~isgood
                this.todoBien = false;
                if nargin < 5
                    toString = @Simple.UnitTests.UnitTesting.toString;
                end
                expectations = '{';
                for i = 1:length(expected)
                    if i > 1
                        expectations = strcat(expectations, ',');
                    end
                    expectations = strcat(expectations, '(', toString(expected{i}), ')');
                end
                expectations = strcat(expectations, '}');
                str = [testCase, ' Testcase doesn''t match expectation. Possible expected values: ', expectations, ' Actual: ', toString(actual)];
                this.raiseFlag(str);
            end
        end
        
        function checkTypeExpectation(this, expected, value, testCase)
            actual = class(value);
            if ~strcmp(expected, actual)
                this.todoBien = false;
                str = [testCase, ' Testcase doesn''t match expectation. Expected type: ', expected, ' Actual: ', actual];
                this.raiseFlag(str);
            end
        end
        
        function checkNaNExpectation(this, actual, testCase, toString)
            if ~isnan(actual)
                this.todoBien = false;
                if nargin < 4
                    toString = @Simple.UnitTests.UnitTesting.toString;
                end
                str = [testCase, ' Testcase doesn''t match expectation. Expected NaN, Actual: ', toString(actual)];
                this.raiseFlag(str);
            end
        end
        
        function checkEmptyExpectation(this, actual, testCase, toString)
            if ~isempty(actual)
                this.todoBien = false;
                if nargin < 4
                    toString = @Simple.UnitTests.UnitTesting.toString;
                end
                str = [testCase, ' Testcase doesn''t match expectation. Expected empty, Actual: ', toString(actual)];
                this.raiseFlag(str);
            end
        end
        
        function raiseExpectedExceptionFlag(this, testCase, type, msg)
            str = 'An exception';
            if exist('type', 'var')
                str = [str ' of type ' type];
            end
            if exist('msg', 'var')
                str = [str ' with the message ' msg];
            end
            str = [str ' was not thrown as expected. ' testCase];
            this.raiseFlag(str);
            this.todoBien = false;
        end
        
        function this = raiseFlag(this, msg)
            this.displayMsg('Error', [msg '\n']);
        end
        
        function evaluateAllExpectations(this)
            if this.todoBien
                this.displayMsg('Comment', 'Good Job! all unit tests passed!\n');
            else
                this.displayMsg('Error', 'SOB!\n');
            end
        end
    end

    methods (Access=private)
        function displayMsg(this, type, msg)
            if exist('cprintf', 'file')
                cprintf(type, msg);
            else
                fprintf(msg);
            end
        end
    end
    
    methods (Static)
        
        function ret = compare(a, b)
            if isobject(a) && ismethod(a, 'equals')
                ret = a.equals(b);
            elseif isobject(a) && ismethod(a, 'eq')
                ret = a.eq(b);
            elseif isobject(b) && ismethod(b, 'equals')
                ret = b.equals(a);
            elseif isobject(b) && ismethod(b, 'eq')
                ret = b.eq(a);
            else
                ret = isequaln(a,b);
            end
        end
        
        function str = toString(a)
            if isnumeric(a) || islogical(a)
                str = num2str(a);
                if ismatrix(a) && size(str,1) > 1
                    tempStr = sprintf('\n');
                    for i=1:size(a,1)
                        tempStr = [tempStr str(i,:) sprintf('\n')];
                    end
                    str = tempStr;
                end
            elseif iscellstr(a)
                str = ['{' strjoin(a, ', ') '}'];
            elseif ischar(a)
                str = a;
            else
                error('Doh!');
            end
        end
    end
    
end


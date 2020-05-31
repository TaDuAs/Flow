classdef JsonSerializationTests < matlab.mock.TestCase
    %JSONSERIALIZATIONTESTS Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Test) % primitive values & enums
        function serializeNumber(testCase)
            ser = mxml.JsonSerializer();
            
            json = ser.serialize(123);
            
            root = jsondecode(json);
            
            testCase.verifyEqual(root, 123);
        end
        
        function serializeNumberRow(testCase)
%             ser = mxml.JsonSerializer();
%             
%             json = ser.serialize(1:5);
%             
%             root = jsondecode(json);
%             
%             testCase.verifyEqual(root, 1:5);
            testCase.verifyFail('Json Serialization does not maintain row vectors size at the moment');
        end
        
        function serializeNumberCol(testCase)
            ser = mxml.JsonSerializer();
            
            json = ser.serialize((1:5)');
            
            root = jsondecode(json);
            
            testCase.verifyEqual(root, (1:5)');
        end
        
        function serializeNumberMatrix(testCase)
            ser = mxml.JsonSerializer();
            
            json = ser.serialize([1:3; 4:6; 7:9]);
            
            root = jsondecode(json);
            
            testCase.verifyEqual(root, [1:3; 4:6; 7:9]);
        end
        
        function serializeIntDefaultBehav(testCase)
            ser = mxml.JsonSerializer();
            
            json = ser.serialize(int32(123));
            
            root = jsondecode(json);
            
            testCase.verifyEqual(root, 123);
        end
        
        function serializeIntAddedMaintainability(testCase)
            ser = mxml.JsonSerializer();
            ser.MaintainedTypes = "int32";
            
            json = ser.serialize(int32(123));
            
            root = jsondecode(json);
            
            testCase.verifyEqual(root.value, 123);
            testCase.verifyEqual(root.(mxml.JsonSerializer.TYPE_PROP_NAME), 'int32');
            testCase.verifyEqual(root.(mxml.JsonSerializer.VERSION_PROP_NAME), 3);
        end
        
        function serializeIntMatrixAddedMaintainability(testCase)
            ser = mxml.JsonSerializer();
            ser.MaintainedTypes = "int32";
            
            json = ser.serialize(int32([1:3; 4:6; 7:9]));
            
            root = jsondecode(json);
            
            testCase.verifyEqual(root.value, [1:3; 4:6; 7:9]);
            testCase.verifyEqual(root.(mxml.JsonSerializer.TYPE_PROP_NAME), 'int32');
            testCase.verifyEqual(root.(mxml.JsonSerializer.VERSION_PROP_NAME), 3);
        end
        
%         function dontDeleteThisYet
%             ser = mxml.JsonSerializer();
%             
%             json = ser.serialize(int32(123));
%             
%             root = jsondecode(json);
%             
%             testCase.verifyEqual(root.value, 123);
%             testCase.verifyEqual(root.(mxml.JsonSerializer.TYPE_PROP_NAME), 'double');
%             testCase.verifyEqual(root.(mxml.JsonSerializer.VERSION_PROP_NAME), '3');
%         end
    end
end


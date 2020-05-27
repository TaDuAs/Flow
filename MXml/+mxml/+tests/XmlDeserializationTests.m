classdef XmlDeserializationTests < matlab.mock.TestCase
    methods (Test)
        function deserializeTest(testCase)
            % prep dom
            [~, xml] = mxml.tests.genDOM();
            
            % mock extractor and builder
            [extractorMock, extractorBehav] = testCase.createMock(?mfc.extract.IJitPropertyExtractor);
            [builderMock, builderBehav] = testCase.createMock(?mxml.IFieldExtractorBuilder);
            testCase.assignOutputsWhen(withAnyInputs(builderBehav.build), extractorMock);
            
            % generate the object
            objMock = mxml.tests.HandleModel();
            
            % mock the factory
            [factoryMock, factoryBehav] = testCase.createMock(?mfc.IFactory);
            testCase.assignOutputsWhen(factoryBehav.construct('mxml.tests.HandleModel', extractorBehav), objMock);
            
            % define serializer
            ser = mxml.XmlSerializer('Factory', factoryMock);
            ser.ExtractorBuilder = builderMock;
            
            % perform deserialization - only the top level will be
            % deserialized. Drilling down the DOM is activated by the
            % factory-extractor-serializer combination
            obj = ser.deserialize(xml);
            
            % ASSERT
            assert(eq(obj, objMock));
        end
        
        function deserializeIntegratedTest(testCase)
            % prep dom
            [~, xml] = mxml.tests.genDOM();
            
            % define serializer
            ser = mxml.XmlSerializer();
            
            % perform deserialization - only the top level will be
            % deserialized. Drilling down the DOM is activated by the
            % factory-extractor-serializer combination
            obj = ser.deserialize(xml);
            
            % ASSERT
            testCase.verifyClass(obj, 'mxml.tests.HandleModel');
            testCase.verifyEqual(obj.id, 'myId');
            testCase.verifyEqual(obj.child1, 123);
            
            % obj.child2
            testCase.verifyClass(obj.child2, 'mxml.tests.HandleModel');
            testCase.verifyEqual(obj.child2.id, '123');
            testCase.verifyEqual(obj.child2.child1, 'my son');
            testCase.verifyClass(obj.child2.child2, 'string');
            testCase.verifyEqual(obj.child2.child2, "The quick brown fox");
            testCase.verifyClass(obj.child2.list, 'int32');
            testCase.verifyEqual(obj.child2.list, int32([1 2 3 4 5]));
            
            % obj.list
            testCase.verifyClass(obj.list, 'mxml.tests.HandleModel');
            testCase.verifyNumElements(obj.list, 2);
            
            % obj.list(1)
            testCase.verifyClass(obj.list(1), 'mxml.tests.HandleModel');
            testCase.verifyEqual(obj.list(1).id, 1);
            testCase.verifyClass(obj.list(1).child1, 'string');
            testCase.verifyEqual(obj.list(1).child1, "The quick brown fox");
            testCase.verifyEqual(obj.list(1).list, uint16([1 2 3 4 5]));
            
            % obj.list(2)
            testCase.verifyClass(obj.list(2), 'mxml.tests.HandleModel');
            testCase.verifyEqual(obj.list(2).id, 2);
            testCase.verifyClass(obj.list(2).child1, 'string');
            testCase.verifyEqual(obj.list(2).child1, "Jumps over the lazy dog");
            testCase.verifyClass(obj.list(2).child2, 'lists.Dictionary');
            testCase.verifyEqual(obj.list(2).child2.getv('string'), "Something");
            testCase.verifyEqual(obj.list(2).child2.getv('number'), 1:4);
            handleInDictionary = obj.list(2).child2.getv('handle');
            testCase.verifyClass(handleInDictionary, 'mxml.tests.HandleModel');
            testCase.verifyEqual(handleInDictionary.id, 'dictionaryHandle');
            testCase.verifyEqual(obj.list(2).child2.getv('enum'), mxml.tests.MyEnum.Giraffe);
            testCase.verifyEqual(obj.list(2).list, single([1:5; 6:10]));
        end
    end
end


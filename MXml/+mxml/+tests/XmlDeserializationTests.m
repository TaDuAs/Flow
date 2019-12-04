classdef XmlDeserializationTests < matlab.mock.TestCase
    methods (Test)
        function deserializeTest(testCase)
%             testCase = matlab.mock.TestCase.forInteractiveUse;
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
    end
end


classdef XmlFieldExtractorTests < matlab.mock.TestCase
    methods (Test)
        function extractChild1(testCase)
%             testCase = matlab.mock.TestCase.forInteractiveUse;
            % prep dom
            root = mxml.tests.genDOM();
            
            % mock stuff
            [interpreterMock, interpreterBehav] = testCase.createMock(?mxml.IXmlInterpreter);
            testCase.assignOutputsWhen(interpreterBehav.interpretElement(root.children.child1.node, 3), 123);
            
            extractor = mxml.XmlFieldExtractor(interpreterMock, root.node, 3, '_type');
            
            value = extractor.get('child1');
            
            assert(value == 123);
        end
        
        function extractChildObj(testCase)
            % prep dom
            root = mxml.tests.genDOM();
            
            % mock stuff
            [interpreterMock, interpreterBehav] = testCase.createMock(?mxml.IXmlInterpreter);
            testCase.assignOutputsWhen(interpreterBehav.interpretElement(root.children.child2.node, 3), mxml.tests.HandleModel());
            
            extractor = mxml.XmlFieldExtractor(interpreterMock, root.node, 3, ["_type", "_version", "_isList"]);
            
            value = extractor.get('child2');
            
            assert(isa(value, 'mxml.tests.HandleModel'));
        end
        
        function extractAttrProp(testCase)
            root = mxml.tests.genDOM();
            
            % mock stuff
            [interpreterMock, interpreterBehav] = testCase.createMock(?mxml.IXmlInterpreter);
            testCase.assignOutputsWhen(interpreterBehav.interpretAttribute(java.lang.String('myId'), 3), 'the cat in the hat');
            
            extractor = mxml.XmlFieldExtractor(interpreterMock, root.node, 3, {'_type', '_version', '_isList'});
            
            value = extractor.get('id');
            
            assert(strcmp(value, 'the cat in the hat'));
        end
        
        function extractAttrProp_Compatible(testCase)
            root = mxml.tests.genCompatibilityDOM();
            
            % mock stuff
            [interpreterMock, interpreterBehav] = testCase.createMock(?mxml.IXmlInterpreter);
            testCase.assignOutputsWhen(interpreterBehav.interpretAttribute(java.lang.String(root.attr.type.value), 3), 'the cat in the hat');
            
            extractor = mxml.XmlFieldExtractor(interpreterMock, root.node, 3, {'_type', '_version', '_isList'});
            
            value = extractor.get('type');
            
            assert(strcmp(value, 'the cat in the hat'));
        end
        
        function extractMissingProp(testCase)
            root = mxml.tests.genDOM();
            
            % mock stuff
            [interpreterMock, interpreterBehav] = testCase.createMock(?mxml.IXmlInterpreter);
            testCase.assignOutputsWhen(interpreterBehav.interpretAttribute(java.lang.String(root.attr.id.value), 3), 'the cat in the hat');
            
            extractor = mxml.XmlFieldExtractor(interpreterMock, root.node, 3, {'_type', '_version', '_isList'});
            
            flag = true;
            try
                value = extractor.get('blahblahblah');
                flag = false;
            catch ex
                % this is good
            end
            
            assert(flag);
        end
        
        function cantGetMetaDataAttr(testCase)
            root = mxml.tests.genDOM();
            
            % mock stuff
            [interpreterMock, interpreterBehav] = testCase.createMock(?mxml.IXmlInterpreter);
            testCase.assignOutputsWhen(interpreterBehav.interpretAttribute(java.lang.String(root.attr.id.value), 3), 'the cat in the hat');
            
            extractor = mxml.XmlFieldExtractor(interpreterMock, root.node, 3, {'_type', '_version', '_isList'});
            
            flag = true;
            try
                value = extractor.get('_type');
                flag = false;
            catch ex
                % this is good
            end
            
            assert(flag);
        end
        
        function cantGetMetaDataAttr_Compatible(testCase)
            root = mxml.tests.genCompatibilityDOM();
            
            % mock stuff
            [interpreterMock, interpreterBehav] = testCase.createMock(?mxml.IXmlInterpreter);
            testCase.assignOutputsWhen(interpreterBehav.interpretAttribute(java.lang.String(root.attr.type.value), 3), 'the cat in the hat');
            
            extractor = mxml.XmlFieldExtractor(interpreterMock, root.node, 3, {'type', 'isList'});
            
            flag = true;
            try
                value = extractor.get('type');
                flag = false;
            catch ex
                % this is good
            end
            
            assert(flag);
        end
        
        function hasNodeProp(testCase)
            root = mxml.tests.genDOM();
            
            % mock stuff
            [interpreterMock, interpreterBehav] = testCase.createMock(?mxml.IXmlInterpreter);
            
            extractor = mxml.XmlFieldExtractor(interpreterMock, root.node, 3, {'_type', '_version', '_isList'});
            
            assert(extractor.hasProp('child1'));
        end
        
        function hasAttrProp(testCase)
            root = mxml.tests.genDOM();
            
            % mock stuff
            [interpreterMock, interpreterBehav] = testCase.createMock(?mxml.IXmlInterpreter);
            
            extractor = mxml.XmlFieldExtractor(interpreterMock, root.node, 3, {'_type', '_version', '_isList'});
            
            assert(extractor.hasProp('id'));
        end
        
        function doesntHaveProp(testCase)
            root = mxml.tests.genDOM();
            
            % mock stuff
            [interpreterMock, interpreterBehav] = testCase.createMock(?mxml.IXmlInterpreter);
            
            extractor = mxml.XmlFieldExtractor(interpreterMock, root.node, 3, {'_type', '_version', '_isList'});
            
            assert(~extractor.hasProp('blahblahblah'));
        end
        
        function ignoreMetaDataAttrs(testCase)
            root = mxml.tests.genDOM();
            
            % mock stuff
            [interpreterMock, interpreterBehav] = testCase.createMock(?mxml.IXmlInterpreter);
            
            extractor = mxml.XmlFieldExtractor(interpreterMock, root.node, 3, {'_type', '_version', '_isList'});
            
            assert(~extractor.hasProp('_type'));
        end
        
        function hasAttrProp_Compatible(testCase)
            root = mxml.tests.genCompatibilityDOM();
            
            % mock stuff
            [interpreterMock, interpreterBehav] = testCase.createMock(?mxml.IXmlInterpreter);
            
            extractor = mxml.XmlFieldExtractor(interpreterMock, root.node, 3, {'_type', '_version', '_isList'});
            
            assert(extractor.hasProp('type'));
        end
        
        function doesntHaveAttrProp_Compatible(testCase)
            root = mxml.tests.genCompatibilityDOM();
            
            % mock stuff
            [interpreterMock, interpreterBehav] = testCase.createMock(?mxml.IXmlInterpreter);
            
            extractor = mxml.XmlFieldExtractor(interpreterMock, root.node, 3, {'type', 'isList'});
            
            assert(~extractor.hasProp('type'));
        end
        
    end
end


classdef XmlSerializationTests < matlab.mock.TestCase
    %XMLSERIALIZATIONTESTS Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Test) % primitive values & enums
        function serializeNumber(testCase)
            ser = mxml.XmlSerializer();
            
            xml = ser.serialize(123);
            
            root = mxml.tests.genDOM(xml);
            
            assert(strcmp(root.value, '123'));
            assert(strcmp(root.attr.a_version.value, '3'));
            assert(strcmp(root.attr.a_type.value, 'double'));
            assert(isempty(fieldnames(root.children)));
        end
        
        function serializeVector(testCase)
            ser = mxml.XmlSerializer();
            
            xml = ser.serialize(1:10);
            
            root = mxml.tests.genDOM(xml);
            
            assert(strcmp(root.value, '1 2 3 4 5 6 7 8 9 10'));
            assert(strcmp(root.attr.a_version.value, '3'));
            assert(strcmp(root.attr.a_type.value, 'double'));
            assert(isempty(fieldnames(root.children)));
        end
        
        function serializeMatrix(testCase)
            ser = mxml.XmlSerializer();
            
            xml = ser.serialize([1:3; 4:6; 7:9]);
            
            root = mxml.tests.genDOM(xml);
            
            assert(strcmp(root.value, '1 2 3;4 5 6;7 8 9'));
            assert(strcmp(root.attr.a_version.value, '3'));
            assert(strcmp(root.attr.a_type.value, 'double'));
            assert(isempty(fieldnames(root.children)));
        end
        
        function maintainNumericTypes(testCase)
            ser = mxml.XmlSerializer();
            
            xml = ser.serialize(double(123));
            doAssert(xml, 'double');
            
            xml = ser.serialize(single(123));
            doAssert(xml, 'single');
            
            xml = ser.serialize(int8(123));
            doAssert(xml, 'int8');
            
            xml = ser.serialize(uint8(123));
            doAssert(xml, 'uint8');
            
            xml = ser.serialize(int16(123));
            doAssert(xml, 'int16');
            
            xml = ser.serialize(uint16(123));
            doAssert(xml, 'uint16');
            
            xml = ser.serialize(int32(123));
            doAssert(xml, 'int32');
            
            xml = ser.serialize(uint32(123));
            doAssert(xml, 'uint32');
            
            xml = ser.serialize(int64(123));
            doAssert(xml, 'int64');
            
            xml = ser.serialize(uint64(123));
            doAssert(xml, 'uint64');
            
            function doAssert(xml, type)
                root = mxml.tests.genDOM(xml);

                assert(strcmp(root.value, '123'));
                assert(strcmp(root.attr.a_version.value, '3'));
                assert(strcmp(root.attr.a_type.value, type));
                assert(isempty(fieldnames(root.children)));
            end
        end
        
        function serializeLogical(testCase)
            ser = mxml.XmlSerializer();
            
            xml = ser.serialize(true);
            doAssert(xml, '1');
            
            xml = ser.serialize(false);
            doAssert(xml, '0');
            
            function doAssert(xml, value)
                root = mxml.tests.genDOM(xml);

                assert(strcmp(root.value, value));
                assert(strcmp(root.attr.a_version.value, '3'));
                assert(strcmp(root.attr.a_type.value, 'logical'));
                assert(isempty(fieldnames(root.children)));
            end
        end
        
        function serializeLogicalVector(testCase)
            ser = mxml.XmlSerializer();
            
            xml = ser.serialize([true false true true]);
            
            root = mxml.tests.genDOM(xml);
            
            assert(strcmp(root.value, '1 0 1 1'));
            assert(strcmp(root.attr.a_version.value, '3'));
            assert(strcmp(root.attr.a_type.value, 'logical'));
            assert(isempty(fieldnames(root.children)));
        end
        
        function serializeLogicalMatrix(testCase)
            ser = mxml.XmlSerializer();
            
            xml = ser.serialize([true false true; false true false; false false false]);
            
            root = mxml.tests.genDOM(xml);
            
            assert(strcmp(root.value, '1 0 1;0 1 0;0 0 0'));
            assert(strcmp(root.attr.a_version.value, '3'));
            assert(strcmp(root.attr.a_type.value, 'logical'));
            assert(isempty(fieldnames(root.children)));
        end
        
        function serializeChar(testCase)
            ser = mxml.XmlSerializer();
            
            xml = ser.serialize('The Cat in the Hat');
            
            root = mxml.tests.genDOM(xml);
            
            assert(strcmp(root.value, 'The Cat in the Hat'));
            assert(strcmp(root.attr.a_version.value, '3'));
            assert(strcmp(root.attr.a_type.value, 'char'));
            assert(isempty(fieldnames(root.children)));
        end
        
        function serializeCharMat(testCase)
            ser = mxml.XmlSerializer();
            
            xml = ser.serialize(['The Cat'; 'in  the'; '   Hat.']);
            
            root = mxml.tests.genDOM(xml);
            
            assert(strcmp(root.attr.a_version.value, '3'));
            assert(strcmp(root.attr.a_type.value, 'char'));
            assert(strcmp(root.attr.a_isList.value, 'true'));
            assert(numel(root.list) == 3);
            assert(strcmp(root.list{1}.attr.a_type.value, 'char'));
            assert(strcmp(root.list{1}.name, 'entry'));
            assert(strcmp(root.list{1}.value, 'The Cat'));
            assert(strcmp(root.list{2}.attr.a_type.value, 'char'));
            assert(strcmp(root.list{2}.name, 'entry'));
            assert(strcmp(root.list{2}.value, 'in  the'));
            assert(strcmp(root.list{3}.attr.a_type.value, 'char'));
            assert(strcmp(root.list{3}.name, 'entry'));
            assert(strcmp(root.list{3}.value, '   Hat.'));
        end
        
        function serializeString(testCase)
            ser = mxml.XmlSerializer();
            
            xml = ser.serialize("The Cat in the Hat");
            
            root = mxml.tests.genDOM(xml);
            
            assert(strcmp(root.value, 'The Cat in the Hat'));
            assert(strcmp(root.attr.a_version.value, '3'));
            assert(strcmp(root.attr.a_type.value, 'string'));
            assert(isempty(fieldnames(root.children)));
        end
        
        function serializeStringArray(testCase)
            ser = mxml.XmlSerializer();
            
            xml = ser.serialize(["The Cat", "in the", "Hat"]);
            
            root = mxml.tests.genDOM(xml);
            
            assert(strcmp(root.attr.a_version.value, '3'));
            assert(strcmp(root.attr.a_type.value, 'string'));
            assert(strcmp(root.attr.a_isList.value, 'true'));
            assert(numel(root.list) == 3);
            assert(strcmp(root.list{1}.attr.a_type.value, 'string'));
            assert(strcmp(root.list{1}.name, 'entry'));
            assert(strcmp(root.list{1}.value, 'The Cat'));
            assert(strcmp(root.list{2}.attr.a_type.value, 'string'));
            assert(strcmp(root.list{2}.name, 'entry'));
            assert(strcmp(root.list{2}.value, 'in the'));
            assert(strcmp(root.list{3}.attr.a_type.value, 'string'));
            assert(strcmp(root.list{3}.name, 'entry'));
            assert(strcmp(root.list{3}.value, 'Hat'));
        end
        
        function serializeEnum(testCase)
            ser = mxml.XmlSerializer();
            
            xml = ser.serialize(mxml.tests.MyEnum.Cat);
            
            root = mxml.tests.genDOM(xml);
            
            assert(strcmp(root.value, 'Cat'));
            assert(strcmp(root.attr.a_version.value, '3'));
            assert(strcmp(root.attr.a_type.value, 'mxml.tests.MyEnum'));
            assert(isempty(fieldnames(root.children)));
        end
        
        function serializeEnumVector(testCase)
            
            assert(false, 'Enum vector serialization not implemented yet');
            
            ser = mxml.XmlSerializer();
            
            xml = ser.serialize([mxml.tests.MyEnum.Cat, mxml.tests.MyEnum.Cat, mxml.tests.MyEnum.Giraffe]);
            
            root = mxml.tests.genDOM(xml);
            
            assert(strcmp(root.attr.a_version.value, '3'));
            assert(strcmp(root.attr.a_type.value, 'mxml.tests.MyEnum'));
            assert(strcmp(root.attr.a_isList.value, 'true'));
            assert(numel(root.list) == 3);
            assert(strcmp(root.list{1}.attr.a_type.value, 'mxml.tests.MyEnum'));
            assert(strcmp(root.list{1}.name, 'entry'));
            assert(strcmp(root.list{1}.value, 'Cat'));
            assert(strcmp(root.list{2}.attr.a_type.value, 'mxml.tests.MyEnum'));
            assert(strcmp(root.list{2}.name, 'entry'));
            assert(strcmp(root.list{2}.value, 'Cat'));
            assert(strcmp(root.list{3}.attr.a_type.value, 'mxml.tests.MyEnum'));
            assert(strcmp(root.list{3}.name, 'entry'));
            assert(strcmp(root.list{3}.value, 'Giraffe'));
        end
        
        function serializeDuration(testCase)
            assert(false, 'duration serialization is not supported yet');
        end
    end
    
    methods (Test) % struct
        function serializeSimpleStruct(testCase)
            ser = mxml.XmlSerializer();
            
            s.x = 1:10;
            s.txt = 'Your text goes here';
            s.enum = mxml.tests.MyEnum.Dog;
            
            xml = ser.serialize(s);
            
            root = mxml.tests.genDOM(xml);
            
            assert(strcmp(root.attr.a_version.value, '3'));
            assert(strcmp(root.attr.a_type.value, 'struct'));
            assert(strcmp(root.attr.txt.value, 'Your text goes here'));
            assert(strcmp(root.children.x.attr.a_type.value, 'double'));
            assert(strcmp(root.children.x.value, '1 2 3 4 5 6 7 8 9 10'));
            assert(strcmp(root.children.enum.attr.a_type.value, 'mxml.tests.MyEnum'));
            assert(strcmp(root.children.enum.value, 'Dog'));
        end
        
        function serializeComplexStruct(testCase)
            ser = mxml.XmlSerializer();
            
            s.x = 1:10;
            s.txt = 'Your text goes here';
            s.enum = mxml.tests.MyEnum.Dog;
            s.child.a = "abc";
            s.child.b = [1;3;5];
            
            xml = ser.serialize(s);
            
            root = mxml.tests.genDOM(xml);
            
            assert(strcmp(root.attr.a_version.value, '3'));
            assert(strcmp(root.attr.a_type.value, 'struct'));
            assert(strcmp(root.attr.txt.value, 'Your text goes here'));
            assert(strcmp(root.children.x.attr.a_type.value, 'double'));
            assert(strcmp(root.children.x.value, '1 2 3 4 5 6 7 8 9 10'));
            assert(strcmp(root.children.enum.attr.a_type.value, 'mxml.tests.MyEnum'));
            assert(strcmp(root.children.enum.value, 'Dog'));
            
            assert(strcmp(root.children.child.attr.a_type.value, 'struct'));
            assert(strcmp(root.children.child.attr.a.value, 'abc'));
            assert(strcmp(root.children.child.children.b.attr.a_type.value, 'double'));
            assert(strcmp(root.children.child.children.b.value, '1;3;5'));
        end
    end
end


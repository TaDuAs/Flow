classdef EnumCtorTests < matlab.unittest.TestCase
    methods (Test)
        function fromName(testCase)
            ctor = mfc.EnumCtor('mfc.tests.MyEnum');
            
            enum = ctor.build('One');
            
            assert(isequal(enum, mfc.tests.MyEnum.One));
        end
        
        function fromFunctionHandle(testCase)
            ctor = mfc.EnumCtor(@mfc.tests.MyEnum);
            
            enum = ctor.build('One');
            
            assert(isequal(enum, mfc.tests.MyEnum.One));
        end
        
        function fromIMCtor(testCase)
            ctor = mfc.EnumCtor(mfc.MCtor('mfc.tests.MyEnum'));
            
            enum = ctor.build('One');
            
            assert(isequal(enum, mfc.tests.MyEnum.One));
        end
        
        function buildFromEnumName(testCase)
            ctor = mfc.EnumCtor(@mfc.tests.MyEnum);
            
            enum = ctor.build('Two');
            
            assert(isequal(enum, mfc.tests.MyEnum.Two));
        end
        
        function buildFromNumber(testCase)
            ctor = mfc.EnumCtor(@mfc.tests.MyEnum);
            
            enum = ctor.build(3);
            
            assert(isequal(enum, mfc.tests.MyEnum.Three));
        end
        
        function buildFromNumberString(testCase)
            ctor = mfc.EnumCtor(@mfc.tests.MyEnum);
            
            enum = ctor.build('3');
            
            assert(isequal(enum, mfc.tests.MyEnum.Three));
        end
    end
end


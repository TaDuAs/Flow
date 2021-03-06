classdef MapTests < matlab.unittest.TestCase

    properties
    end
    
    methods (TestMethodSetup)
    end
    
    methods(TestMethodTeardown)
    end
    
    methods (Test)
        function emptyCtorTest(testCase)
            map = lists.Map();
            
            assert(isequal(0, map.Count));
            assert(isequal('char', map.KeyType));
            assert(isequal('any', map.ValueType));
        end
        
        function KeyValueCtorTest(testCase)
            map = lists.Map({'abc', 'kmn', 'xyz'}, [1 2 3]);
            
            assert(isequal(3, map.Count));
            assert(isequal('char', map.KeyType));
            assert(isequal('double', map.ValueType));
            assert(isequal(1, map('abc')));
            assert(isequal(2, map('kmn')));
            assert(isequal(3, map('xyz')));
        end
        
        function TypesCtorTest(testCase)
            map = lists.Map('KeyType', 'int32', 'ValueType', 'char');
            
            assert(isequal(0, map.Count));
            assert(isequal('int32', map.KeyType));
            assert(isequal('char', map.ValueType));
        end
        
        function InvalidKeyTypesError(testCase)
            map = lists.Map('KeyType', 'int32', 'ValueType', 'char');
            
            x = false;
            
            try
                map('sda') = 'abcd';
                x = true; % an error was supposed to occur
            catch e
                % this is good
            end
            
            assert(~x);
        end
        
        function InvalidValueTypesError(testCase)
            map = lists.Map('KeyType', 'int32', 'ValueType', 'char');
            
            x = false;
            
            try
                map(int32(1)) = 1:19;
                x = true; % an error was supposed to occur
            catch e
                % this is good
            end
            
            assert(~x);
        end
        
        function ValidTypes(testCase)
            map = lists.Map('KeyType', 'int32', 'ValueType', 'char');
            
            map(int32(1)) = 'abc';
            
            assert(isequal(map.Count, 1));
            assert(isequal(map(int32(1)), 'abc'));
        end
        
        function GetValue(testCase)
            map = lists.Map();
            
            map('abc') = 'abc';
            
            assert(isequal(map.Count, 1));
            assert(isequal(map.getv('abc'), 'abc'));
        end
        
        function SetValue(testCase)
            map = lists.Map();
            
            map.setv('abc', 'abc');
            
            assert(isequal(map.Count, 1));
            assert(isequal(map('abc'), 'abc'));
        end
        
        function SizeTest(testCase)
            map = lists.Map();
            
            assert(isequal(map.size(), [0, 1]));
            assert(isequal(map.size(1), 0));
            assert(isequal(map.size(2), 1));
            assert(isequal(map.size(3), 1));
            
            map.setv('abc', 'abc');
            map.setv('abc2', 'abc');
            map.setv('abc3', 'abc');
            
            assert(isequal(map.size(), [3, 1]));
            assert(isequal(map.size(1), 3));
            assert(isequal(map.size(2), 1));
            assert(isequal(map.size(3), 1));
        end
        
        function LengthTest(testCase)
            map = lists.Map();
            
            assert(isequal(map.length(), 0));
            
            map.setv('abc', 'abc');
            map.setv('abc2', 'abc');
            map.setv('abc3', 'abc');
            
            assert(isequal(map.length(), 3));
        end
        
        function IsKeyTest(testCase)
            map = lists.Map();
            
            assert(~map.isKey('abc'));
            assert(~map.containsIndex('abc'));
            
            map.setv('abc', 'abc');
            
            assert(map.isKey('abc'));
            assert(~map.isKey('abc1'));
            assert(map.containsIndex('abc'));
            assert(~map.containsIndex('abc1'));
        end
        
        function KeysTest(testCase)
            map = lists.Map();
            
            assert(isempty(map.keys()));
            
            map.setv('xyz', 'abc');
            map.setv('xyz1', 'abc1');
            map.setv('xyz2', 'abc2');
            
            assert(isequal(map.keys(), {'xyz' 'xyz1' 'xyz2'}));
        end
        
        function ValuesTest(testCase)
            map = lists.Map();
            
            assert(isempty(map.values()));
            
            map.setv('xyz', 'abc');
            map.setv('xyz1', 'abc1');
            map.setv('xyz2', 'abc2');
            
            assert(isequal(map.values(), {'abc' 'abc1' 'abc2'}));
            assert(isequal(map.values({'xyz' 'xyz1'}), {'abc', 'abc1'}));
        end
        
        function removeTest(testCase)
            map = lists.Map();
            
            map.setv('abc', 'xyz');
            map.setv('abc1', 'xyz1');
            map.setv('abc2', 'xyz2');
            
            assert(map.isKey('abc'));
            assert(map.isKey('abc1'));
            assert(map.isKey('abc2'));
            
            map.remove('abc');
            
            assert(~map.isKey('abc'));
            assert(map.isKey('abc1'));
            assert(map.isKey('abc2'));
            
            map.remove({'abc1' 'abc2'});
            
            assert(~map.isKey('abc'));
            assert(~map.isKey('abc1'));
            assert(~map.isKey('abc2'));
        end
        
        function removeAtTest(testCase)
            map = lists.Map();
            
            map.setv('abc', 'xyz');
            map.setv('abc1', 'xyz1');
            map.setv('abc2', 'xyz2');
            
            assert(map.isKey('abc'));
            assert(map.isKey('abc1'));
            assert(map.isKey('abc2'));
            
            map.removeAt('abc');
            
            assert(~map.isKey('abc'));
            assert(map.isKey('abc1'));
            assert(map.isKey('abc2'));
            
            map.removeAt({'abc1' 'abc2'});
            
            assert(~map.isKey('abc'));
            assert(~map.isKey('abc1'));
            assert(~map.isKey('abc2'));
        end
        
        function changeEvent(testCase)
            map = lists.Map({'abc', 'xyz'}, [1 2]);
            x.change = 0;
            x.remove = 0;
            x.add = 0;
            function callback(~, args)
                x.(args.Action) = x.(args.Action) + 1;
            end
            
            listener = map.addlistener('collectionChanged', @callback);
            
            map.setv('abc', 1);
            map('abc') = 2;
            map.setv('abc', 3);
            
            assert(isequal(x.change, 3));
            assert(isequal(x.add, 0));
            assert(isequal(x.remove, 0));
            
            delete(listener);
        end
        
        function removeEvent(testCase)
            map = lists.Map({'abc', 'xyz'}, [1 2]);
            x.change = 0;
            x.remove = 0;
            x.add = 0;
            function callback(~, args)
                x.(args.Action) = x.(args.Action) + 1;
            end
            
            listener = map.addlistener('collectionChanged', @callback);
            
            map.remove('abc');
            map.removeAt('xyz');
            
            assert(isequal(x.change, 0));
            assert(isequal(x.add, 0));
            assert(isequal(x.remove, 2));
            
            delete(listener);
        end
        
        function addEvent(testCase)
            map = lists.Map({'abc', 'xyz'}, [1 2]);
            x.change = 0;
            x.remove = 0;
            x.add = 0;
            function callback(~, args)
                x.(args.Action) = x.(args.Action) + 1;
            end
            
            listener = map.addlistener('collectionChanged', @callback);
            
            map.setv('abc1', 20);
            map('xyz1') = 10;
            
            assert(isequal(x.change, 0));
            assert(isequal(x.add, 2));
            assert(isequal(x.remove, 0));
            
            delete(listener);
        end
        
        function isaTest(testCase)
            map = lists.Map();
            
            assert(isa(map, 'lists.Map'));
            assert(isa(map, 'containers.Map'));
            assert(isa(map, 'lists.ICollection'));
            assert(isa(map, 'handle'));
            assert(~isa(map, 'mvvm.Binder'));
        end
    end

end
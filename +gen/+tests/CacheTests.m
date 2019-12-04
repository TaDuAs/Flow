classdef CacheTests < matlab.mock.TestCase
    methods (Test)
        function hasNoEntry(testCase)
            cache = gen.Cache();
            
            testCase.verifyFalse(cache.hasEntry('blah'));
        end
        
        function getNoEntry(testCase)
            cache = gen.Cache();
            
            testCase.verifyEmpty(cache.get('blah'));
        end
        
        function removeNoEntry(testCase)
            cache = gen.Cache();
            
            cache.removeEntry('blah');
            
            % throws no error
        end
        
        function emptyAllKeys(testCase)
            cache = gen.Cache();
            
            testCase.verifyEmpty(cache.allKeys());
        end
        
        function emptyAllValues(testCase)
            cache = gen.Cache();
            
            testCase.verifyEmpty(cache.allValues());
        end
        
        function retriveValue(testCase)
            cache = gen.Cache();
            
            cache.set('item', 123);
            
            testCase.verifyEqual(cache.get('item'), 123);
        end
        
        function retriveValueChanged(testCase)
            cache = gen.Cache();
            
            cache.set('item', 123);
            cache.set('item', 321);
            
            testCase.verifyEqual(cache.get('item'), 321);
        end
        
        function retriveValueUnchanged(testCase)
            cache = gen.Cache();
            
            cache.set('item', 123);
            cache.set('item2', 321);
            
            testCase.verifyEqual(cache.get('item'), 123);
        end
        
        function retriveValueRemoved(testCase)
            cache = gen.Cache();
            
            cache.set('item', 123);
            cache.removeEntry('item');
            
            testCase.verifyEmpty(cache.get('item'));
        end
        
        function retriveValueRemovedOther(testCase)
            cache = gen.Cache();
            
            cache.set('item', 123);
            cache.set('item2', 321);
            cache.removeEntry('item');
            
            testCase.verifyEmpty(cache.get('item'));
            testCase.verifyEqual(cache.get('item2'), 321);
        end
        
        function retriveValueClearedCache(testCase)
            cache = gen.Cache();
            
            cache.set('item', 123);
            cache.set('item2', 321);
            cache.clearCache();
            
            testCase.verifyEmpty(cache.get('item'));
            testCase.verifyEmpty(cache.get('item2'));
        end
        
        function hasStoredEntry(testCase)
            cache = gen.Cache();
            
            cache.set('item', 123);
            
            testCase.verifyTrue(cache.hasEntry('item'));
        end
        
        function hasChangedEntry(testCase)
            cache = gen.Cache();
            
            cache.set('item', 123);
            cache.set('item', 321);
            
            testCase.verifyTrue(cache.hasEntry('item'));
        end
        
        function hasEntryWhichIsEmpty(testCase)
            cache = gen.Cache();
            
            cache.set('item', []);
            
            testCase.verifyTrue(cache.hasEntry('item'));
        end
        
        function hasClearedEntry(testCase)
            cache = gen.Cache();
            
            cache.set('item', 123);
            cache.clearCache();
            
            testCase.verifyFalse(cache.hasEntry('item'));
        end
        
        function hasRemovedEntry(testCase)
            cache = gen.Cache();
            
            cache.set('item', 123);
            cache.removeEntry('item');
            
            testCase.verifyFalse(cache.hasEntry('item'));
        end
        
        function getAllKeysMultipleEntries(testCase)
            cache = gen.Cache();
            
            cache.set('item1', 123);
            cache.set('item2', 1:10);
            cache.set('item3', magic(5));
            
            testCase.verifyThat(cache.allKeys(), matlab.unittest.constraints.IsSameSetAs({'item1', 'item2', 'item3'}));
        end
        
        function getAllValuessMultipleEntries(testCase)
            cache = gen.Cache();
            
            cache.set('item1', 123);
            cache.set('item2', 1:10);
            cache.set('item3', magic(5));
            
            testCase.verifyTrue(gen.isSameSetAs(cache.allValues(), {123, 1:10, magic(5)}));
        end
        
        function getAllKeysRemovedEntries(testCase)
            cache = gen.Cache();
            
            cache.set('item1', 123);
            cache.set('item2', 1:10);
            cache.set('item3', magic(5));
            cache.set('item4', 1:3);
            
            cache.removeEntry('item1');
            cache.removeEntry('item2');
            
            testCase.verifyThat(cache.allKeys(), matlab.unittest.constraints.IsSameSetAs({'item3', 'item4'}));
        end
        
        function getAllValuessRemovedEntries(testCase)
            cache = gen.Cache();
            
            cache.set('item1', 123);
            cache.set('item2', 1:10);
            cache.set('item3', magic(5));
            cache.set('item4', 1:3);
            
            cache.removeEntry('item1');
            cache.removeEntry('item2');
            
            testCase.verifyTrue(gen.isSameSetAs(cache.allValues(), {1:3, magic(5)}));
        end
        
        function getAllKeysClearedCache(testCase)
            cache = gen.Cache();
            
            cache.set('item1', 123);
            cache.set('item2', 1:10);
            cache.set('item3', magic(5));
            cache.set('item4', 1:3);
            
            cache.clearCache();
            
            testCase.verifyEmpty(cache.allKeys());
        end
        
        function getAllValuessClearedCache(testCase)
            cache = gen.Cache();
            
            cache.set('item1', 123);
            cache.set('item2', 1:10);
            cache.set('item3', magic(5));
            cache.set('item4', 1:3);
            
            cache.clearCache();
            
            testCase.verifyEmpty(cache.allValues());
        end
    end
end


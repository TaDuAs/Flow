classdef Map < handle & lists.IObservable
    % Wrapper for containers.Map class, which implements the
    % lists.ICollection interface.
    % Implements complete containers.Map API and lists.ICollection API
    % 
    % identifies as containers.Map with isa(map, 'containers.Map')
    %
    % Author: TADA
    
    properties (GetAccess=private, SetAccess=private)
        map;
    end
    
    properties (Dependent, GetAccess=public)
        Count;
        KeyType;
        ValueType;
    end
    
    methods
        function value = get.Count(this)
            m = this.map;
            value = m.Count;
        end
        function value = get.KeyType(this)
            m = this.map;
            value = m.KeyType;
        end
        function value = get.ValueType(this)
            m = this.map;
            value = m.ValueType;
        end
    end
    
    methods
        
        function this = Map(varargin)
            this.map = containers.Map(varargin{:});
        end
        
        function out = subsref(A, S)
            switch(S(1).type)
                case '()'
                    out = subsref(A.('map'), S);
                otherwise
                    out = builtin('subsref', A, S);
            end
        end
        
        function A = subsasgn(A, S, B)
            args = event.EventData();
            
            if numel(S) > 1
                throw(MException('lists:Map:AssignmentChaining', 'lists.Map doesn''t support assignment chaining operations'));
            end
            
            if strcmp(S.type, '()')
                if numel(S.subs) ~= 1
                    throw(MException('lists:Map:InvalidSubs', 'lists.Map supports Only one-dimensional indexing'));
                end

                A.setv(B, S.subs{1});
            elseif strcmp(S.type, '.')
                A = builtin('subsasgn', A, S, B);
            else
                throw(MException('lists:Map:InvalidAssignment', 'lists.Map only supports ''()'' indexing assignment'))
            end
        end
        
        function this = remove(this, i)
            this.map.remove(i);
            
            % notify collection changed
            this.raiseCollectionChangedEvent('remove', i);
        end
        
        function this = removeAt(this, i)
            this.remove(i);
        end
        
        function this = setv(this, value, key)
            m = this.map;

            if m.isKey(key)
                action = 'change';
            else
                action = 'add';
            end

            % assign data
            m(key) = value;
            
            % notify collection changed
            this.raiseCollectionChangedEvent(action, key);
        end
        
        function value = getv(this, i)
            value = this.map(i);
        end
        
        function setVector(this, values, keys)
            this.remove(this.keys);
            for i = 1:numel(keys)
                if iscell(keys); currKey = keys{i}; else currKey = keys(i); end
                if iscell(keys); currVal = values{i}; else currVal = values(i); end
                
                this.add(currKey, currVal)
            end
        end
        
        function add(this, value, key)
            this.setv(value, key);
        end

        function s = size(this, dim)
            if nargin < 2
                s = size(this.map);
            else 
                s = size(this.map, dim);
            end
        end
        
        function b = isempty(this)
            b = this.Count == 0;
        end
        
        function n = length(this)
            n = this.Count;
        end
        
        function b = containsIndex(this, i)
            b = this.map.isKey(i);
        end

        function b = isKey(this, i)
            b = this.map.isKey(i);
        end
        
        function valueSet = values(this, keySet)
            if nargin < 2
                valueSet = this.map.values();
            else
                valueSet = this.map.values(keySet);
            end
        end
        
        function keySet = keys(this)
            keySet = this.map.keys();
        end
        
        function b = isa(this, type)
            if strcmp(type, 'containers.Map')
                b = true;
            else
                b = builtin('isa', this, type);
            end
        end
    end
    
    methods (Access=private)
        function raiseCollectionChangedEvent(this, action, key)
            if ischar(key)
                idx = {key};
            else
                idx = key;
            end
            args = lists.CollectionChangedEventData(action, idx);

            % raise event
            notify(this, 'collectionChanged', args);
        end
    end
end


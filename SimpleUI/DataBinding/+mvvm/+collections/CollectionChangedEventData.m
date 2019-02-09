classdef CollectionChangedEventData < event.EventData
% Event data for mvvm.collections.ICollection collectionChanged event.
% Properties:
%   Action: Either 'add' (newly added items), 'remove' (removed items) or
%           'change' (altered items)
%   Subs:   Expected to be a cell array of subscripts for the changed items
%   i:      Is expected to be a vector of linear indexes for the changed items
    
    properties
        Action;
        Subs;
        i;
    end
    
    methods
        function set.Action(this, value)
            assert(ischar(value) && any(strcmpi(value, {'add', 'remove', 'change'})),...
                'Action must be either ''add'', ''remove'' or ''change''');
            this.Action = lower(value);
        end
        
        function this = CollectionChangedEventData(action, i, subs)
            this.Action = action;
            this.i = i;
            if nargin >= 3
                this.Subs = subs;
            else
                this.Subs = i;
            end
        end
    end
end


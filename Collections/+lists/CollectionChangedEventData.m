classdef CollectionChangedEventData < event.EventData
% Event data for lists.IObservable collectionChanged event.
% Properties:
%   Action: Either 'add' (newly added items), 'remove' (removed items) or
%           'change' (altered items)
%   Subs:   Expected to be a cell array of subscripts for the changed items
%   i:      Is expected to be a vector of linear indexes for the changed items
    
    properties
        Action char {mustBeMember(Action, {'add', 'remove', 'change', 'index_update'})} = 'change';
        Subs;
        i;
    end
    
    methods
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


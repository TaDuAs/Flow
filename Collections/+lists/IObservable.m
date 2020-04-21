classdef (Abstract) IObservable < lists.ICollection
    % This abstract class can be derived to allow for data binding of list classes.
    %
    % See also: lists.ISequentialKeys, mvvm.scopes.CollectionScope
    % 
    % Author: TADA
    
    methods (Abstract)
        tf = containsIndex(this, i);
        keySet = keys(this);
    end
    
    events
        collectionChanged;
    end
end


classdef IItemFetcher < handle
    %IITEMFETCHER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Abstract)
        % Loads a single data item.
        % Implement in derived class to get the data item from whichever
        % source is used (file system, web service, database, whatever
        % floats your boat....)
        % key represents a unique identifier of the required data item in
        % the context it is held in.
        item = load(this, key);
    end
end


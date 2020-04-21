classdef (Abstract) ISequentialKeys < handle
    % lists.ISequentialKeys is a flag interface.
    % Basically, this is a contract signed by deriving classes to a
    % sequential numeric index (1..N) as their main key set
    % 
    % mvvm scopes rely on this identification to manage the observed keys
    % of scoped entities within the collection
    % see also mvvm.scopes.CollectionScope
end
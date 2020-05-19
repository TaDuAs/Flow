function [values, obj] = listOfValidTextValues(varargin)
% Prepare a list of valid values and a key-value struct of these values

    % validate input is a list of key-value paris
    gen.valid.mustBeKeyValuePairs(varargin);
    
    % concatenate all values into a cell array of character vectors
    rawValues = cellfun(@cellstr, varargin(2:2:end), 'UniformOutput', false);
    values = [rawValues{:}];
    
    % add all key-value pair to the key-value struct
    if nargout >= 2
        % prepare list of keys as cell arrays of character vectors
        keys = cellfun(@cellstr, varargin(1:2:end));
        
        % prepare the list of key-value pairs for struct function
        % the cell arrays need to be wrapped with another cell array to
        % prevent a struct array
        structParams = [keys; cellfun(@(c) {c}, rawValues, 'UniformOutput', false)];
        
        % build key-value struct
        obj = struct(structParams{:});
    end
end
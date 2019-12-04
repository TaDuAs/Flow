function mustBeTextual(A)
    if ~isstring(A) && ~ischar(A) && ~(iscell(A) && ~isempty(A) && all(cellfun(@(s) isstring(s) || ischar(s), A)))
        throw(MException('Validator:mustBeTextual', 'Must be a textual value (char, string, cell array of character vectors)'));
    end
end


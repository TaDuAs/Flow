function mustBeTextualScalar(A)
    if ~gen.isSingleString(A)
        throw(MException('Validator:mustBeTextualScalar', 'Must be a single textual value (char row vector, string scalar, single element cellstr)'));
    end
end


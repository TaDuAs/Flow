function mustBeNumericOrTextualScalar(A)
    if ~gen.isSingleString(A) && ~(isnumeric(A) && isscalar(A))
        throw(MException('Validator:mustBeNumericOrTextualScalar', 'Must be a numeric scalar or a single textual value (char row vector, string scalar, single element cellstr)'));
    end
end


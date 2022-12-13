function mustBeTextualScalarOrEmpty(A)
    if ~isempty(A)
        gen.valid.mustBeTextualScalar(A);
    end
end


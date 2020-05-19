function mustBeFinitePositiveRealScalar(x)
    assert(isscalar(x), 'Must be scalar');
    mustBeNumeric(x);
    mustBePositive(x);
    mustBeReal(x);
    mustBeFinite(x);
end


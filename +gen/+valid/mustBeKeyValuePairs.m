function mustBeKeyValuePairs(args)
    assert(iscell(args), 'Arguments must be passed as a cell array');
    assert(mod(numel(args), 2) == 0, 'Number of inputs invalid. Inputs must be passed in as pairs.');
    
    for i = 1:2:numel(args)
        currKey = args{i};
        gen.valid.mustBeTextualScalar(currKey);
        assert(~isempty(currKey));
    end
end


function l = sp3ChainLength(bondLengths)
% Calculates the actual length of a chain of sp3 atoms
            Simple.obsoleteWarning('Simple.Scientific');
    factor = cos(degtorad(35.25));
    l = sum(bondLengths*factor);
end
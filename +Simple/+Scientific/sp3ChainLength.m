function l = sp3ChainLength(bondLengths)
% Calculates the actual length of a chain of sp3 atoms
    factor = cos(degtorad(35.25));
    l = sum(bondLengths*factor);
end
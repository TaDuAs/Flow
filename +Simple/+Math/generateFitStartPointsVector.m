function coeffVector = generateFitStartPointsVector(fitFunction, values)
    import Simple.*;
    coeffNamesArray = coeffnames(fittype(fitFunction));
    coeffVector = ones(1, length(coeffNamesArray));
    for i = 1:length(coeffNamesArray)
        coeffVector(i) = getobj(values, coeffNamesArray{i}, 1);
    end
end
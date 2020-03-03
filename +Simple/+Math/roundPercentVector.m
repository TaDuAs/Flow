function rounded = roundPercentVector(values)

    perc = values/sum(values)*100;
    rounded = round(perc);
    sr = sum(rounded);
    
    while sr ~= 100
        rmp = rounded - perc;
        if sr < 100
            [m, i] = min(rmp);
            addThatMuch = 1;
        else % sr > 100
            [m, i] = max(rmp);
            addThatMuch = -1;
        end
        
        if isempty(i)
            rounded(1) = rounded(1) + addThatMuch;
        else
            rounded(i(1)) = rounded(i(1)) + addThatMuch;
        end
        
        sr = sum(rounded);
    end

end


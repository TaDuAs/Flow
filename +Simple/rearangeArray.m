function rearranged = rearangeArray(arr, mode)
% rearranges an array
% arr - the array to rearrange
% mode - 'conv' = converging: from the edges to the center:
%               [1 2 3 4 5 6 7 8 9 10]
%               = [1 10 2 9 3 8 4 7 5 6]
%      - 'alt' = alternating: from left to right once from the left then
%      form the middle (left mid left mid...)
%               [1 2 3 4 5 6 7 8 9 10]
%               = [1 6 2 7 3 8 4 9 5 10]
%      - 'rand' = random order
    import Simple.*;

    if nargin < 2
        mode = 'alt';
    end
    n = length(arr);
    isEven = n/2 == floor(n/2);
    switch mode
        case 'alt'
            order = [1:ceil(n/2), cond(isEven, 1:n/2, 1:floor(n/2))];
        case 'conv'
            order = [1:ceil(n/2), cond(isEven, n/2:-1:1, floor(n/2):-1:1)];
        case 'rand'
            order = rand(1,n);
        otherwise
            error('Invalid order mode');
    end
    areaIndex = [1:n; order];
    areaIndex = sortrows(areaIndex', 2)';
    rearranged = areaIndex(1,:);
end


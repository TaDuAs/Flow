function value = cond(condition, ifTrue, ifFalse)
% ternary operator implementation
    if condition
        if isa(ifTrue,'function_handle')
            value = ifTrue();
        else
            value = ifTrue;
        end
    else
        if isa(ifFalse,'function_handle')
            value = ifFalse();
        else
            value = ifFalse;
        end
    end
end


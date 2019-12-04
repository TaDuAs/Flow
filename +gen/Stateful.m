classdef Stateful < handle
    properties (GetAccess=public, SetAccess=protected)
        IsDirty;
    end
    
    methods
        function A = subsasgn(A, S, B)
            if strcmp(S(1).type, '.')
                
            else
                A = builtin('subsasgn', A, S, B);
            end
        end
    end
end


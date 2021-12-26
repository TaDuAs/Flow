function mustBeNotNull(obj)
% mustBeNotNull verifies that the object is a valid instance, and not an
% empty or deleted object.
% This validation function is for use with lists.ICollections which
% override the builtin size methods. In many cases it is fine to use an
% empty lists.ICollection (I.E. colleciton with no values) but it must be 
% instantiated.

    if ishandle(obj)
        assert(isvalid(obj), 'Must be valid object');
    end
    nel = builtin('numel', obj);
    assert(nel > 0, 'Must not be an empty object');
end


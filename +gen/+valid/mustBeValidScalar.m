function mustBeValidScalar(obj)
% mustBeSingleValue verifies that the object is a valid scalar instance, 
% and not an empty, vector/matrix, or deleted object.
% This validation function is for use with lists.ICollections which
% override the builtin size methods. In many cases it is fine to use an
% empty lists.ICollection (I.E. colleciton with no values) but it must be 
% instantiated.
    gen.valid.mustBeNotNull(obj);
    nel = builtin('numel', obj);
    assert(nel == 1, 'Must be single element');
end


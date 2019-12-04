classdef IModelIndexer < handle
    methods
        value = getv(this, model);
        model = setv(this, model, value);
    end
end


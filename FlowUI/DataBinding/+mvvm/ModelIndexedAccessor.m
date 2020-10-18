classdef ModelIndexedAccessor < mvvm.SimpleModelObserver
    %MODELINDEXER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Index;
    end
    
    methods
        function this = ModelIndexedAccessor(modelPath, modelProvider)
            this@mvvm.SimpleModelObserver(modelPath, modelProvider);
        end
    end
    
    methods (Access=protected)
        function doHandleModelUpdate(this, src, args, setPathIndex, raisedListenerIndex)
            model = mvvm.getobj(src, this.ModelPath(setPathIndex:numel(this.ModelPath)));
            
            % produce indexing struct for subsref
            if istable(model) || iscell(model)
                subsType = '{}';
            else
                subsType = '()';
            end
            subIdx = substruct(subsType, this.Index);
            
            % extract stuff from index
            finalItem = subsref(model, subIdx);
            
            % raise event with extracted object
            this.raiseModelChangedEvent(finalItem, {});
        end
    end
end


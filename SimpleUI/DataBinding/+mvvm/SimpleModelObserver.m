classdef SimpleModelObserver < mvvm.ModelPathObserver
    %SIMPLEMODELOBSERVER Summary of this class goes here
    %   Detailed explanation goes here
    
    events
        ModelChanged;
    end
    
    methods
        function this = SimpleModelObserver(modelPath, modelProvider)
            this@mvvm.ModelPathObserver();
            this.init(modelPath, modelProvider);
        end
    end
    
    methods (Access=protected)
        function doHandleModelUpdate(this, src, args, setPathIndex, raisedListenerIndex)
            this.raiseModelChangedEvent(src, setPathIndex);
        end
        
        function raiseModelChangedEvent(this, src, setPathIndex)
            notify(this, 'ModelChanged', mvvm.ModelChangeEventData(src, this.ModelPath(setPathIndex:end)));
        end
    end
end


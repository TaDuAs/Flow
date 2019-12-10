classdef BoundModelIndexer < mvvm.providers.IModelIndexer
    
    properties
        ModelProvider mvvm.providers.IModelProvider;
        ModelPath;
    end
    
    methods
        function this = BoundModelIndexer(modelPath, modelProvider)
            if isa(modelProvider, 'mvvm.providers.IModelProvider')
                this.ModelProvider = modelProvider;
            else
                throw(MException('mvvm:providers:BoundModelIndexer:InvalidModelProvider', 'ModelProvider must implement the mvvm.providers.IModelProvider abstract class'));
            end
            
            if iscellstr(modelPath)
                this.ModelPath = modelPath;
            elseif ischar(modelPath)
                this.ModelPath = strsplit(modelPath, '.');
            else
                throw(MException('mvvm:providers:BoundModelIndexer:InvalidModelPath', 'Model Path must be either a a character vector or a cell array of character vectors'));
            end
        end
        
        function value = getv(this, model)
            index = this.getIndex(model);
            value = model(index{:});
        end
        
        function model = setv(this, model, value)
            index = this.getIndex(model);
            model(index{:}) = value;
        end
        
        function index = getIndex(this, model)
            index = mvvm.getobj(this.ModelProvider.getModel(), this.ModelPath, {false(size(model))});
            
            if ~iscell(index)
                index = {index};
            end
        end
    end
end


classdef AdaptationBinder < mvvm.Binder
    % mvvm.AdaptationBinder is a type of mvvm.Binder which performs some
    % adaptation on the data when transfering between the mdoel and gui.
    % 
    % one particular example of an adaptation is to enable/disable or
    % show/hide a control for some values of the model, such as a property
    % whos value is an enum and you want to enable the control for some
    % values and disable it for all the others
    % In that example the adapter can be a simple function like that:
    %   function enabled = adapt(value)
    %       % this is an adaptation to enable the degree numeric input only
    %       % for Savitzky–Golay smoothing
    %       enabled = strcmp(value, 'sgolay');
    %   end
    %
    % See also: mvvm.Binder, mvvm.Repeater, mvvm.IDataAdapter, mvvm.FunctionHandleDataAdapter
    %
    % Author: TADA
    
    properties (Access=protected)
        Adapter
    end
    
    methods
        function this = AdaptationBinder(modelPath, control, property, adapter, varargin)
            this@mvvm.Binder(modelPath, control, property, adapter, varargin{:});
        end
        
    end
    
    methods (Access=protected)
        
        function extractParserParameters(this, parser, control)
            extractParserParameters@mvvm.Binder(this, parser, control);
            
            if isa(parser.Results.Adapter, 'function_handle')
                this.Adapter = mvvm.FunctionHandleDataAdapter(parser.Results.Adapter);
            else
                this.Adapter = parser.Results.Adapter;
            end
        end
        
        function prepareParser(this, parser)
            addRequired(parser, 'Adapter',...
                @(x) assert(isa(x, 'mvvm.IDataAdapter') || isa(x, 'function_handle'),...
                            'Adapter must be a function handle or a class which implements the mvvm.IDataAdapter abstract class'));
            
            prepareParser@mvvm.Binder(this, parser);
        end
        
        function value = extractValueFromModel(this, scope, path)
            temp = extractValueFromModel@mvvm.Binder(this, scope, path);
            value = this.Adapter.model2gui(temp);
        end
        
        function value = extractValueFromControl(this)
            temp = extractValueFromControl@mvvm.Binder(this);
            value = this.Adapter.gui2model(temp);
        end
    end
end


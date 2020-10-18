classdef ComponentView < mvvm.view.View
    % mvvm.view.ComponentView a GUI component that does not own a figure.
    % mvvm.view.ComponentView is to be placed inside another mvvm.view.View
    
    properties (Access=private)
        ContainerBoxCtor function_handle = @uipanel;
        ContainerBox_ mvvm.view.IContainer = mvvm.view.ContainerControl.empty();
        Parent_ mvvm.view.IContainer = mvvm.view.ContainerControl.empty();
    end
    
    properties (Dependent, GetAccess=public, SetAccess=private)
        ContainerBox mvvm.view.IContainer;
    end
    
    methods % property accessors
        function box = get.ContainerBox(this)
            if ~isempty(this.ContainerBox_)
                box = this.ContainerBox_;
            else
                box = this.Parent;
            end
        end
        
        function set.ContainerBox(this, box)
            this.ContainerBox_ = box;
        end
    end
    
    methods
        function this = ComponentView(parent, varargin)
            this@mvvm.view.View(varargin{:}, 'Parent', parent);
        end
        
        
        function h = getContainerHandle(this)
            h = this.ContainerBox_.getContainerHandle();
        end
        
        function parent = ancestor(this, type)
            if nargin >= 2
                parent = ancestor(getContainerHandle([this.Parent]), type);
            else
                parent = ancestor(getContainerHandle([this.Parent]));
            end
        end
        
        function addChild(this, child)
            this.ContainerBox.addChild(child);
        end
        
        function children = getChildren(this)
            children = this.ContainerBox.getChildren();
        end
        
        function parent = getParent(this)
            parent = this.Parent_;
        end
        
        function setParent(this, parent)
            if ishandle(parent)
                this.Parent_ = mvvm.view.ContainerControl(parent);
            else
                this.Parent_ = parent;
            end
            
            % ensure the wrapping box of this component gets the parent
            % container
            if ~isempty(this.ContainerBox_)
                this.ContainerBox_.setParent(this.Parent_);
            end
        end
    end
    
    methods (Access=protected)
        
        function init(this)
            % base initialize components
            init@mvvm.view.View(this);
            
            % initialize self box
            if ~isempty(this.ContainerBoxCtor)
                this.ContainerBox_ = mvvm.view.ContainerControl(this.ContainerBoxCtor());
                this.ContainerBox_.setParent(this.Parent);
            end
        end
        
        function extractParserParameters(this, parser)
            extractParserParameters@mvvm.view.View(this, parser);
            
            % get container box ctor
            boxType = parser.Results.BoxType;
            if ~isempty(boxType)
                if isa(boxType, 'function_handle')
                    this.ContainerBoxCtor = parser.Results.BoxType;
                else
                    this.ContainerBoxCtor = str2func(parser.Results.BoxType);
                end
            end
            
            if ~isempty(parser.Results.Parent)
                this.setParent(parser.Results.Parent);
            end
        end
        
        function prepareParser(this, parser)
            prepareParser@mvvm.view.View(this, parser);
            
            % define parameters
            addParameter(parser, 'BoxType', '',...
                @(x) assert((ischar(x) && isrow(x)) || isStringScalar(x) || isa(x, 'function_handle'), 'BoxType must be ctor function or a type name'));
            addParameter(parser, 'Parent', mvvm.view.ContainerControl.empty(),...
                @(x) assert(ishandle(x) || isa(x, 'mvvm.view.IContainer'), 'ComponentView parent must be a gui handle or an mvvm.view.IContainer'));
        end
        
    end
end


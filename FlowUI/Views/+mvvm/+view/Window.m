classdef Window < mvvm.view.View
    
    properties
        FigType mvvm.view.FigureType;
    end
    
    methods
        function this = Window(varargin)
            this@mvvm.view.View(varargin{:});
        end
        
        function delete(this)
            set([this.Fig], 'CloseRequestFcn', 'closereq');
            b = ishandle(this.Fig);
            if any(b)
                delete([this(b).Fig]);
            end
        end
        
        function show(this)
            if isa(this.Fig, 'handle') && ishandle(this.Fig) && isvalid(this)
                figure(this.Fig);
            end
        end
        
        function hide(this)
            if isa(this.Fig, 'handle') && ishandle(this.Fig) && isvalid(this)
                this.Fig.WindowState = 'minimized';
            end
        end
        
        function h = getContainerHandle(this)
            h = [this.Fig];
        end
        
        function parent = ancestor(this, type)
            if nargin >= 2
                parent = ancestor([this.Fig], type);
            else
                parent = ancestor([this.Fig]);
            end
        end
        
        function addChild(this, child)
            if isa(child, 'mvvm.view.IContainer')
                h = child.getContainerHandle();
            else
                h = child;
            end
            
            h.Parent = this.Fig;
        end
        
        function children = getChildren(this)
            children = this.Fig.Children;
        end
        
        function parent = getParent(this)
            parent = this.OwnerView;
        end
        
        function setParent(this, parent)
            this.OwnerView = parent;
        end
        
        function h = findobj(this, varargin)
            h = findobj(this.Fig, varargin{:});
        end
    end
    
    methods (Access=protected)
        function init(this)
            init@mvvm.view.View(this);
            
            if ~isempty(this.App)
                this.App.addKillItem(this);
            end
            
            if this.FigType == mvvm.view.FigureType.Classic
                this.Fig = figure();
            else
                this.Fig = uifigure();
            end
            this.Fig.CloseRequestFcn = @this.onCloseRequest;
            this.Fig.UserData = this;
        end
        
        function handleCriticalError(this, err)
            set([this.Fig], 'CloseRequestFcn', 'closereq');
        end
        
        function extractParserParameters(this, parser)
            extractParserParameters@mvvm.view.View(this, parser);
            
            % first of all, get figure type
            this.FigType = parser.Results.FigType;
        end
        
        function prepareParser(this, parser)
            prepareParser@mvvm.view.View(this, parser);
            
            % define parameters
            addParameter(parser, 'FigType', mvvm.view.FigureType.Classic, ...
                @(x) assert(isa(x, 'mvvm.view.FigureType'), 'FigType must be mvvm.view.FigureType'));
        end
    end
end


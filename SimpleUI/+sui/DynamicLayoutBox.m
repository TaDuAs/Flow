classdef (Abstract) DynamicLayoutBox < uix.Box & sui.INotifyRedrawn
    %DynamicLayoutBox  - A box expected to resize to fit it's contents. 
    %                 ** When using derived classes, Set BasePosition 
    %                 ** instead of Position property.
    %
    %  See also: sui.StackBox, sui.FlowBox
    % 
    %  Written by: TADA, Dec. 2018
    
    properties (Access=private)
        basePosition_;
        childResizedListeners;
    end
    
    properties (Access=protected)
        StopRedraw;
    end
    
    properties (GetAccess=public, SetAccess=private)
        BasePosUnits;
    end
    
    properties (Dependent, GetAccess=public, SetAccess=private)
        BaseSize;
    end
    properties (Dependent)
        BasePosition;
    end
    properties
        Direction;
        Align;
        VRowAlign;
    end
    
    methods % Property accessors
        function value = get.BaseSize(this)
            value = this.basePosition_([3 4]);
        end
        
        %
        % Base Position
        %
        function value = get.BasePosition(this)
            value = this.basePosition_;
        end
        function set.BasePosition(this, value)
            this.basePosition_ = value;
            this.BasePosUnits = get(this, 'Units');
            set(this, 'Position', value);
        end
        
        %
        % Direction
        %
        function set.Direction(this, value)
            value = lower(value);
            if strcmp(value, this.Direction); return; end
            
            assert(any(strcmp({'ltr' 'rtl'}, value)),...
                'Specified Direction value "%s" is invalid. Must be either ltr or rtl', value);

            this.Direction = value;
            this.Dirty = true;
        end
        
        %
        % Align
        %
        function set.Align(this, value)
            value = lower(value);
            if strcmp(value, this.Align); return; end
            
            assert(any(strcmp({'right' 'left' 'center'}, value)),...
                'Specified Align value "%s" is invalid. Must be either right, left or center', value);

%             assert(~strcmp('center', value), 'Align center doesn''t work well at the moment');

            this.Align = value;
            this.Dirty = true;
        end
        
        %
        % VRowAlign
        %
        function set.VRowAlign(this, value)
            value = lower(value);
            if strcmp(value, this.VRowAlign); return; end
            
            assert(any(strcmp({'top' 'bottom' 'center'}, value)),...
                'Specified VRowAlign value "%s" is invalid. Must be either top, bottom or center', value);

%             assert(~strcmp('center', value),'VRowAlign center doesn''t work well at the moment');

            this.VRowAlign = value;
            this.Dirty = true;
        end
    end
    
    methods (Access=protected, Abstract)
        %
        % findBoxesPositions is the heavy duty method for a derived class.
        % In this method the derived class must find the position for each
        % of it's children and calculate it's own final size
        % position vector must be a row vector of the following format:
        % [x, y, rowIndex, rowWidth, rowHeight]
        % All position vector values must be specified in pixels
        %
        [positions, calculatedSize] = findBoxesPositions(this, boxes)
    end
    
    methods (Access=protected)
        function this = DynamicLayoutBox(varargin)
            % DynamicLayoutBox Ctor
            
            this.Align = 'left';
            this.VRowAlign = 'top';
            this.Direction = 'ltr';
            this.childResizedListeners = {};
            
            try
                uix.set(this, varargin{:});
            catch ex
                delete(this);
                ex.throwAsCaller();
            end
        end
        
        function redraw(this)
            if this.StopRedraw
                return;
            end
            
            % Suppress redraw
            this.StopRedraw = true;
            
            % this is needed to test if resize event should be raised at
            % the end of the redraw cycle
            sizeBeforeRedraw = sui.getSize(this, 'pixels');
            
            try
                % return to the base size to allow box rearrangement
                if ~isempty(this.BasePosition)
                    sui.setPos(this, this.BasePosition, this.BasePosUnits);
                end

                % get children in sequential order
                boxes = flip(this.Children);
                
                % do redraw
                [positions, calculatedSize] = this.findBoxesPositions(boxes);
                
                % resize self
                finalSize = this.resizeToAccomodateChildren(calculatedSize);
                
                % set the calculated positions to all children
                this.setChildrentPositions(boxes, positions, finalSize);
            catch e
                this.StopRedraw = false;
                e.throwAsCaller();
            end
            
            % this is needed to test if resize event should be raised at
            % the end of the redraw cycle
            sizeAfterRedraw = sui.getSize(this, 'pixels');
            if ~isequal(sizeBeforeRedraw, sizeAfterRedraw)
                notify(this, 'resized');
            end
            
            % Reactivate redraw
            this.StopRedraw = false;
            
            notify(this, 'redrawn');
        end
        
        function finalSize = resizeToAccomodateChildren(this, calculatedSize)
            % Resizes the DynamicLayoutBox to fit its children using the
            % size calculated by derived class in findBoxesPositions method
            
            originalSize = sui.getSize(this,'pixels');

            % stretch FlowBox vertically if necesary
            if any(calculatedSize > originalSize)
                finalSize = calculatedSize;
                pos = sui.getPos(this, 'pixels');
                
                % screen y coordinates are bottom to top and window layout 
                % flow is top to bottom.
                % move y coordinates down to account for the resized box
                %
                % x coordinates don't need to be adjusted because screen x
                % coordinates are left to right same as window layout flow
                sui.setPos(this, [pos(1), pos(2) - (calculatedSize(2) - originalSize(2)) calculatedSize], 'pixels');
            else
                finalSize = originalSize;
            end
        end
        
        function setChildrentPositions(this, boxes, positions, selfSize)
            % Positions all children according to the positions calculated
            % by derived class in findBoxesPositions method.
            % Final coordinates are calculated according to Align and
            % VAlign properties
            
            % position all ui elements after calculating final size of the box
            for i = 1:length(boxes)
                box = boxes(i);
                boxSize = sui.getSize(box, 'pixels');
                
                if strcmp(this.Direction, 'rtl')
                    finalPosX = this.calculatePositionXRTL(boxSize, positions(i, [1,2]), positions(i, [4,5]), selfSize);
                else
                    finalPosX = this.calculatePositionX(boxSize, positions(i, [1,2]), positions(i, [4,5]), selfSize);
                end
                finalPosY = this.calculatePositionY(boxSize, positions(i, [1,2]), positions(i, [4,5]), selfSize);
                
                sui.setPos(box, [finalPosX, finalPosY boxSize], 'pixels');
            end
        end
        
        function x = calculatePositionXRTL(this, boxSize, boxPos, rowSize, selfSize)
            switch this.Align
                case 'left'
                    x = selfSize(1) - boxPos(1) - boxSize(1) - (selfSize(1) - 2*this.Padding - rowSize(1));
                case 'right'
                    x = selfSize(1) - boxPos(1) - boxSize(1);
                case 'center'
                    x = selfSize(1) - boxPos(1) - boxSize(1) - (selfSize(1) - 2*this.Padding - rowSize(1))/2;
            end
        end
        
        function x = calculatePositionX(this, boxSize, boxPos, rowSize, selfSize)
            switch this.Align
                case 'left'
                    x = boxPos(1);
                case 'right'
                    x = boxPos(1) + selfSize(1) - 2*this.Padding - rowSize(1);
                case 'center'
                    x = boxPos(1) + (selfSize(1) - 2*this.Padding - rowSize(1))/2;
            end
        end
        
        function y = calculatePositionY(this, boxSize, boxPos, rowSize, selfSize)
            switch this.VRowAlign
                case 'top'
                    y = selfSize(2) - boxPos(2) - boxSize(2);
                case 'bottom'
                    y = selfSize(2) - boxPos(2) - rowSize(2);
                case 'center'
                    y = selfSize(2) - boxPos(2) - boxSize(2) - (rowSize(2)-boxSize(2))/2;
            end
        end
        
        function addChild(this, child)
            addChild@uix.Box(this, child);
            
            % Add listeners
            if isa( child, 'sui.INotifyRedrawn' )
                this.childResizedListeners{end+1} = ...
                    child.addlistener('resized', ...
                    @(src, args) this.onChildResized());
            else
                this.childResizedListeners{end+1} = [];
            end
        end
        
        function removeChild(this, child)
            % find child
            tf = this.Contents_ == child;
            
            % Remove listeners
            this.childResizedListeners(tf) = [];
            
            removeChild@uix.Box(this, child);
        end
        
        function onChildResized(this)
            this.Dirty = true;
        end
    end
end


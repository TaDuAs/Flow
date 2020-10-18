classdef (Abstract) DynamicLayoutBox < flow.Box  & ...
        matlab.ui.control.internal.model.mixin.HorizontallyAlignableComponent & ...
        matlab.ui.control.internal.model.mixin.VerticallyAlignableComponent & ...
        flow.mixin.DirectionallyAlignableComponent & ...
        flow.mixin.VRowAlignableComponent
        
    %DynamicLayoutBox  - A box expected to resize to fit it's contents. 
    %                 ** When using derived classes, Set BasePosition 
    %                 ** instead of Position property.
    %
    %  See also: flow.StackBox, flow.FlowBox
    % 
    %  Written by: TADA, Dec. 2018
    
    properties (Access=private)
        basePosition_;
        childResizedListeners;
    end
    
    properties (Access=protected)
        TempPosition;
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
            this.BasePosUnits = 'pixels'; %get(this, 'Units');
            set(this, 'Position', value);
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
        function this = DynamicLayoutBox()
            % DynamicLayoutBox Ctor
            this@flow.Box();
            this.childResizedListeners = {};
        end
        
        function setDirty(this)
            this.markDirty(true);
        end
        
        function doUpdate(this)
            % Call redraw on top of base class doUpdate functionality
            doUpdate@flow.Box(this);
            this.redraw();
        end
        
        function redraw(this)
            if this.StopRedraw
                return;
            end
            
            % Suppress redraw
            this.StopRedraw = true;
            
            % this is needed to test if resize event should be raised at
            % the end of the redraw cycle
            sizeBeforeRedraw = flow.getSize(this, 'pixels');
            
            try
                % return to the base size to allow box rearrangement
                if ~isempty(this.BasePosition)
                    this.TempPosition = this.convertPosUnits(this.BasePosition, this.BasePosUnits, 'pixels');
                else
                    this.TempPosition = flow.getPos(this, 'pixels');
                end

                % do redraw
                visibleBoxesMask = strcmp(get(this.Contents_, 'Visible'), 'on');
                [positions, calculatedSize] = this.findBoxesPositions(this.Contents_(visibleBoxesMask));
                
                % resize self
                finalSize = this.resizeToAccomodateChildren(calculatedSize);
                
                % set the calculated positions to all children
                this.setChildrentPositions(this.Contents_(visibleBoxesMask), positions, finalSize);
            catch e
                this.StopRedraw = false;
                e.throwAsCaller();
            end
            
            % this is needed to test if resize event should be raised at
            % the end of the redraw cycle
            sizeAfterRedraw = flow.getSize(this, 'pixels');
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
            
            baseSize = this.TempPosition(3:4);
            originalLocation = this.TempPosition(1:2);
            necessarySize = baseSize;
            originalSize = flow.getSize(this, 'pixels');
            
            % if calculated size is bigger than that, use calculated size
            if any(calculatedSize > necessarySize)
                necessarySize = calculatedSize;
            end
            
            % stretch FlowBox vertically if necesary
            if any(necessarySize ~= originalSize)
                finalSize = necessarySize;
                
                % screen y coordinates are bottom to top and window layout 
                % flow is top to bottom.
                % move y coordinates down to account for the resized box
                %
                % x coordinates don't need to be adjusted because screen x
                % coordinates are left to right same as window layout flow
                flow.setPos(this, [originalLocation(1), originalLocation(2) - (necessarySize(2) - baseSize(2)), necessarySize], 'pixels');
            else
                finalSize = necessarySize;
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
                boxSize = flow.getSize(box, 'pixels');
                
                if strcmp(this.DirectionAlignment, 'rtl')
                    finalPosX = this.calculatePositionXRTL(boxSize, positions(i, [1,2]), positions(i, [4,5]), selfSize);
                else
                    finalPosX = this.calculatePositionX(boxSize, positions(i, [1,2]), positions(i, [4,5]), selfSize);
                end
                finalPosY = this.calculatePositionY(boxSize, positions(i, [1,2]), positions(i, [4,5]), selfSize);
                
                flow.setPos(box, [finalPosX, finalPosY, boxSize], 'pixels');
            end
        end
        
        function x = calculatePositionXRTL(this, boxSize, boxPos, rowSize, selfSize)
            switch this.HorizontalAlignment
                case 'left'
                    x = selfSize(1) - boxPos(1) - boxSize(1) - (selfSize(1) - 2*this.Padding - rowSize(1));
                case 'right'
                    x = selfSize(1) - boxPos(1) - boxSize(1);
                case 'center'
                    x = selfSize(1) - boxPos(1) - boxSize(1) - (selfSize(1) - 2*this.Padding - rowSize(1))/2;
            end
        end
        
        function x = calculatePositionX(this, boxSize, boxPos, rowSize, selfSize)
            switch this.HorizontalAlignment
                case 'left'
                    x = boxPos(1);
                case 'right'
                    x = boxPos(1) + selfSize(1) - 2*this.Padding - rowSize(1);
                case 'center'
                    x = boxPos(1) + (selfSize(1) - 2*this.Padding - rowSize(1))/2;
            end
        end
        
        function y = calculatePositionY(this, boxSize, boxPos, rowSize, selfSize)
            switch this.VRowAlignment
                case 'top'
                    y = selfSize(2) - boxPos(2) - boxSize(2);
                case 'bottom'
                    y = selfSize(2) - boxPos(2) - rowSize(2);
                case 'center'
                    y = selfSize(2) - boxPos(2) - boxSize(2) - (rowSize(2)-boxSize(2))/2;
            end
        end
        
        function addChild(this, child)
            addChild@flow.Box(this, child);
            
            % Add listeners
            if isa( child, 'flow.INotifyRedrawn' )
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
            cellfun(@delete, this.childResizedListeners(tf));
            this.childResizedListeners(tf) = [];
            
            removeChild@flow.Box(this, child);
        end
        
        function onChildResized(this)
            this.markDirty(true);
        end
        
        function newPos = convertPosUnits(this, pos, u1, u2)
            % get this box size in u1 units and u2 units
            v1 = flow.getPos(this, u1);
            v2 = flow.getPos(this, u2);
            
            % calculate the conversion factor between u1 and u2 units
            cf = v2./v1;
            cf(v1 == 0) = 0;
            
            % convert pos vector using the conversion factor
            newPos = pos.*cf;
        end
    end
    
    
    
end


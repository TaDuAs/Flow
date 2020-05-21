classdef FloatBox < uix.Box
    %FLOWLAYOUTCONTAINER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function this = FloatBox(varargin)
            Simple.obsoleteWarning('Simple.UI');
            try
                uix.set(this, varargin{:});
            catch ex
                delete (this);
                ex.throwAsCaller();
            end
        end
    end
    methods (Access=protected)
        function redraw(this)
            this.positionBoxes(this.Children);
        end
    end
    
    methods (Access=private)
        function positionBoxes(this, boxes)
            % Prepare inner drawable area matrix in points
            originalSize = fliplr(floor(Simple.UI.getSize(this, 'pixels')));
            padding = get(this, 'Padding');
            A = false(originalSize - 2*padding);
            
            for boxi = 1:length(boxes)
                box = boxes(boxi);
                boxSize = fliplr(ceil(Simple.UI.getSize(box, 'pixels')));

                % find position for this box
                [A,posx,posy] = this.positionSingleBox(A, boxSize);
                
                % set box position
                finalBoxPostion = [posx,posy] + padding;
                Simple.UI.setPos(box, [finalBoxPostion fliplr(boxSize)], 'pixels');
            end

            newSize = [max(size(A, 1), originalSize(1)), max(size(A, 2), originalSize(2))];
            if any(newSize ~= originalSize)
                Simple.UI.setSize(this, fliplr(newSize), 'pixels');
            end
                
        end

        function [A,posx,posy] = positionSingleBox(this, A, boxSize)
            % validate box size
            if boxSize(2) > size(A, 2)
                % stretch this size to the FlowBox to accomodate the width
                % of the current box
                A = [A false(size(A,1), boxSize(2)-size(A,2))];
            end
            
            % find the first empty box at the desired size
            [posx, posy, didFind] = this.findEmptyBox(A, boxSize);
            
            % position current box at empty location
            if didFind
                pad = this.Spacing;
                
                % Accomodate box size (+ spacing to the bottom and right)
                % at the found location
                A(posy:(posy+boxSize(1)+pad-1),posx:min((posx+boxSize(2)+pad-1),size(A,2))) = true;
                
                % Block next children from accomodating unused spaces
                % located before this box, to maintain the correct GUI flow
                A(1:(posy-1),:) = true;
                A(posy:(posy+boxSize(1)-1),1:posx-1) = true;
            else
                % if there's no room for the current box, stretch the
                % FlowBox to accomodate it.
                A = [A; false(boxSize(1) + this.Spacing, size(A,2))];
                [A,posx,posy] = this.positionSingleBox(A, boxSize);
            end
        end

        function [posx, posy, didFind] = findEmptyBox(this, A, boxSize)
            % Find the first empty box which fits the desired box size.
            % Searching from the top-left corner, first to the right then
            % down.
            
            % locate all unaccomodated positions
            i0 = find(A == false);
            [is,js] = ind2sub(size(A), i0);
            
            % sort positions to find go through them in the correct order
            % (left->right first, top->bottom second)
            idx = sortrows([is js]);

            % iterate through all nonaccomodated positions
            for i = 1:size(idx,1)
                % If reached the boundaries, go on to the next position
                if ((idx(i,1)+boxSize(1)-1) > size(A,1)) || ((idx(i,2)+boxSize(2)-1) > size(A,2))
                    continue;
                end

                % get the entire box at the current position and check
                % for accomodated spaces, if there are any, go on to
                % the next position
                candidate = A(idx(i,1):(idx(i,1)+boxSize(1)-1),idx(i,2):(idx(i,2)+boxSize(2)-1));
                if any(candidate(:) ~= 0)
                    continue;
                end

                % if reached this line, the box is not accomodated,
                % return current position
                didFind = true;
                posx = idx(i,2);
                posy =  idx(i,1);
                return;
            end

            % if reached here, no empty space is large enough to accomodate
            % the desired box.
            didFind = false;
            posx = -1;
            posy = -1;
        end
    end
end


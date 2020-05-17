classdef Img < uix.Box & sui.INotifyRedrawn
    % Wraps the displaying of images for GUI styling purposes.
    % Also enables the use of resource manager to cache images instead of
    % reloading them from file each time.
    
    properties (Access=private)
        ax;
        image_;
        path_;
        isCached_;
        resourceMgr_;
        dirty_;
        maxSize_;
    end
    
    properties (Dependent)
        IsCached;
        ResourceMgr sui.IResourceManager = sui.ResourceManager.empty();
        Path;
        MaxSize;
    end
    
    methods
        function path = get.Path(this)
            path = this.path_;
        end
        function set.Path(this, path)
            if ~strcmp(path, this.path_)
                this.path_ = path;
                
                % 2-step dirty marking is necessary here because we want to
                % fire redraw but in the same time, we don't want every 
                % call to redraw to  reload the image from file, and when
                % setting this.Dirty = true it invokes redraw instead of
                % marking the dirty flag to true (for Drawable objects)
                this.dirty_ = true;
                this.Dirty = true;
            end
        end
        
        function mgr = get.ResourceMgr(this)
            mgr = this.resourceMgr_;
        end
        function set.ResourceMgr(this, mgr)
            this.resourceMgr_ = mgr;
        end
        
        function siz = get.MaxSize(this)
            siz = this.maxSize_;
        end
        function set.MaxSize(this, siz)
            if isequal(siz, this.maxSize_)
                return;
            end
            
            sui.setSize(this, siz, get(this, 'Units'));
            this.maxSize_ = sui.getSize(this, 'pixels');
            this.dirty_ = true;
            this.Dirty = true;
        end
        
        function isCached = get.IsCached(this)
            isCached = this.isCached_;
        end
        function set.IsCached(this, isCached)
            if this.isCached_ ~= isCached
                this.isCached_ = isCached;
            end
        end
    end
    
    methods
        function this = Img(varargin)
            try
                uix.set( this, varargin{:} );
            catch e
                delete( this );
                e.throwAsCaller();
            end
        end
        
        function drawImage(this)
            % find out if there are active axes
            if ~isempty(get(gcf,'CurrentAxes'))
                prevAx = gca;
            else
                prevAx = [];
            end

            if isempty(this.ax)
%                 parentBgColor = get(get(this, 'Parent'), 'BackgroundColor');
                % prepare axes
                this.ax = axes('Parent', this, 'Units', 'norm', 'Position', [0 0 1 1]);%, 'color', parentBgColor);
            else
                cla(this.ax);
            end
            
            % get image data
            imgData = this.getImgData();
            
            % shrink Img to fit the size of the image
            if ~isempty(this.MaxSize)
                this.resize(imgData);
            end

            % display image
            this.image_ = image(this.ax, imgData);

            % get rid of borders and axes tick marks
            set(this.ax, 'Visible', 'off');

            % focus previously focused axes
            if ~isempty(prevAx)
                axes(prevAx);
            end
            
            % raise redraw notification
            notify(this, 'redrawn');
        end
        
        function resize(this, imgData)
            % get the size of the image. the image is a [x,y,3] rgb 
            % matrix. remember this is the size of the matrix and not 
            % screen coordinates. y dimention preceds x dimention here
            imgSize = size(imgData);
            imgSize = imgSize([2,1]);
            prevSize = sui.getSize(this, 'pixels');
            maxSize = this.MaxSize;

            if all(imgSize([1,2]) <= maxSize)
                % all image dimentions are smaller than or equal to Img 
                % maximum size. Set the image size
                newSize = imgSize;
            else
                % some of the image dimentions or all of them are
                % bigger than the maximal size, resize this Img to
                % maintain the correct image ratio

                % calculate X/Y ratio
                xyr = imgSize(1)/imgSize(2);
                max_xyr = maxSize(1)/maxSize(2);
                
                % adjust size to fit x/y ratio of the image
                if xyr == max_xyr
                    newSize = maxSize;
                elseif xyr*maxSize(2) <= maxSize(1)
                    newSize = [xyr*maxSize(2), maxSize(2)];
                elseif maxSize(1)/xyr <= maxSize(2)
                    newSize = [maxSize(1), maxSize(1)/xyr];
                else
                    warning('sui:Img:resize:ImageRatioError',...
                            'image size evaluation failed. MaxSize=[%d], ImageSize=[%d]', maxSize, imgSize);
                    newSize = maxSize;
                end
            end
                
            % resize and raise event
            if ~isequal(prevSize, newSize)
                sui.setSize(this, newSize, 'pixels');
                notify(this, 'resized');
            end
        end
        
        function imgData = getImgData(this)
            if isempty(this.path_)
                imgData = [];
            % get image data
            elseif this.IsCached
                % get resource manager
                if isempty(this.ResourceMgr)
                    this.ResourceMgr = sui.ResourceManager.instance();
                end

                imgData = this.ResourceMgr.getImage(this.path_);
            else
                imgData = imread(this.path_);
            end
        end
    end
    
    methods (Access=protected)
        function redraw(this)
            % There is no base method, it was an
            % abstract method I had to implement....
            %redraw@uix.Box(this);
            
            if this.dirty_
                this.dirty_ = false;
                this.drawImage();
            end
        end
    end
end


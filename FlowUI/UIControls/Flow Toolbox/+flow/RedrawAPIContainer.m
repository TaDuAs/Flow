classdef (Abstract) RedrawAPIContainer < flow.ContainerBase &...
        flow.INotifyRedrawn & ...
        flow.IRedrawSuppressable
    % flow.RedrawAPIContainer is a baseclass for all container classes that
    % rely on the redraw mechanism devised for GUI Layout Toolbox.
    % 
    % Inheriting this base container class ensures that redraw is called
    % whenever a change is made to the view such that the container size is
    % changed, or when the children collection is changed or any of them
    % resize.
    % 
    % * Some of the code was taken from GUI Layout Toolbox by Mathworks.
    % Author - TADA, 2020
    
    properties( Dependent, Access = public )
        Contents % contents in layout order
    end
    
    properties( Access = protected )
        Contents_ = gobjects( [0 1] ) % backing for Contents
    end
    
    properties( Dependent, Access = protected )
        Dirty % needs redraw
    end
    
    properties( Access = private )
        Dirty_ = false % backing for Dirty
    end
    
    methods
    % accessors
    
        function value = get.Contents( obj )
            
            value = obj.Contents_;
            
        end % get.Contents
        
        function set.Contents( obj, value )
            
            % For those who can't tell a column from a row...
            if isrow( value )
                value = transpose( value );
            end
            
            % Check
            [tf, indices] = ismember( value, obj.Contents_ );
            assert( isequal( size( obj.Contents_ ), size( value ) ) && ...
                numel( value ) == numel( unique( value ) ) && all( tf ), ...
                'uix:InvalidOperation', ...
                'Property ''Contents'' may only be set to a permutation of itself.' )
            
            % Call reorder
            obj.reorder( indices )
            
        end % set.Contents
        
        function value = get.Dirty( obj )
            
            value = obj.Dirty_;
            
        end % get.Dirty
        
        function set.Dirty( obj, value )
            
            if value
                if obj.isDrawable() % drawable
                    try
                    obj.redraw() % redraw now
                    catch e
                        getReport(e);
                        rethrow(e);
                    end
                else % not drawable
                    obj.Dirty_ = true; % flag for future redraw
                end
            end
            
        end % set.Dirty
        
    end % accessors
    
    methods (Access=protected)
    % Redraw API dirty management
    
        function setDirty(this)
            this.Dirty = true;
        end
    end % Redraw API dirty management 
    
    methods (Access = {...
            ?appdesservices.internal.interfaces.model.AbstractModel, ...
            ?appdesservices.internal.interfaces.model.AbstractModelMixin})
        function markPropertiesDirty(this, props)
            markPropertiesDirty@flow.ContainerBase(this, props);
            this.setDirty();
        end
        
    end
    
    methods (Access=protected)
        function handleChildAdded(this, childAdded)
            this.setDirty();
        end
        
        function handleChildRemoved(this, childRemoved)
            this.setDirty();
        end
    end
    
    methods (Abstract, Access=protected)
        redraw(this);
    end
end


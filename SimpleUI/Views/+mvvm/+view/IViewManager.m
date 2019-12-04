classdef (Abstract) IViewManager < handle
    %IVIEWMANAGER Summary of this class goes here
    %   Detailed explanation goes here
        
    methods (Abstract)
        view = start(viewMgr, id);
        close(viewMgr, id);
        show(viewMgr, id);
%         getOwnerView(viewMgr, view);
    end
end


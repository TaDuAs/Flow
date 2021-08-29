function varargout = rmappdata(h, name)
%rmappdata Calls the builtin function then raises the data changed event
    [varargout{1:nargout}] = builtin('rmappdata', h, name);
    appDataListener = AppDataListener.instance();
    appDataListener.raiseDataChanged(h, name);
end


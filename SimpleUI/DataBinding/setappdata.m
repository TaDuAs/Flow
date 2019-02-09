function varargout = setappdata(h, name, value)
%SETAPPDATA Calls the builtin function then raises the data changed event
    [varargout{1:nargout}] = builtin('setappdata', h, name, value);
    appDataListener = AppDataListener.instance();
    appDataListener.raiseDataChanged(h, name);
end


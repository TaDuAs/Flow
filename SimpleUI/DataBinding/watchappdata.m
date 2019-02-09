function listener = watchappdata(functionHandle)
%APPDATACHANGEDHANDLER Summary of this function goes here
%   Detailed explanation goes here
    listener = addlistener(AppDataListener.instance(), 'dirty', functionHandle);
end


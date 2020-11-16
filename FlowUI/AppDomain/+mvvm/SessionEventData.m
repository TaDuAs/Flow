classdef SessionEventData < event.EventData
    properties (GetAccess=public, SetAccess=private)
        Session mvvm.AppSession;
        Key;
    end
    
    methods
        function this = SessionEventData(key, session)
            this.Key = key;
            this.Session = session;
        end
    end
end


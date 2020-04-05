classdef MessagingMediator < handle
    % MessagingMediator encapsulates the communication between objects.
    % Usecase #1: objects from deeper layers of the system can raise events
    % without breaking the layered architecture.
    %   Example: A model is saved, which raises a series of validations in
    %            by different components, such as integrity validation, 
    %            some external data server, and mailing server. Each
    %            validation can raise an error which needs to be caught by
    %            the UI (maybe even several views simultaneously). Instead
    %            of having to manage many event handlers, from all of them,
    %            or alternatively accummulating the errors to a list and 
    %            deciding in the view which errors are relevant, each view 
    %            registers to the messages of interest and handles those.
    % Usecase #2: passing messages between views. views need to communicate
    % instead of strong coupling them, have them raise messages.
    %   Example: Closing the main window when some components are dirty.
    %            The main window raises a AppClosingMessage.
    %            AppClosingMessage is caught by a form that has unsaved
    %            changes and a search tool. the search tool stops the
    %            current search. The form notifies the user that the
    %            application is closing and they have unsaved changes, and
    %            maybe even if the user presses cancel, the form will
    %            change the state of the AppClosingMessage to canceled
    % (see mediator pattern https://en.wikipedia.org/wiki/Mediator_pattern)
    
    properties (Access=protected)
        App mvvm.IApp = mvvm.App.empty();
        Listeners containers.Map;
    end
    
    methods
        function this = MessagingMediator(app)
            this.App = app;
            this.Listeners = containers.Map();
        end
        
        function register(this, messageId, messageHandler)
            if this.Listeners.isKey(messageId)
                this.Listeners(messageId) = [this.Listeners(messageId), {messageHandler}];
            else
                this.Listeners(messageId) = {messageHandler};
            end
        end
        
        function unregister(this, messageId, messageHandler)
            if ~this.Listeners.isKey(messageId)
                return;
            end
            handlers = this.Listeners(messageId);
            
            % find current message handler function in the listeners array
            mask = cellfun(@(fh) ~isequal(fh,messageHandler), handlers);
            
            % remove it from the listeners array
            this.Listeners(messageId) = handlers(mask);
        end
        
        function send(this, message)
            if ischar(message) || isStringScalar(message)
                message = mvvm.RelayMessage(message);
            end
            msgId = message.Id;
            if this.Listeners.isKey(msgId)
                msgListenesrs = this.Listeners(msgId);
                cellfun(@(mh) mh(message),msgListenesrs);
            end
        end
    end
end


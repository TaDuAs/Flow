classdef MessagingMediator < handle & mvvm.IMessagingMediator
    % MessagingMediator encapsulates the communication between objects.
    %
    % The MessagingMediator is loosely based on the MVVM Light Messenger
    % object.
    %
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
    %
    % Usecase #2: passing messages between views. views need to communicate
    % instead of strong coupling them, have them raise messages.
    %   Example: Closing the main window when some components are dirty.
    %            The main window raises a AppClosingMessage.
    %            AppClosingMessage is caught by a search tool and another 
    %            form that has unsaved changes. the search tool stops the
    %            current search. The form notifies the user that the
    %            application is closing and they have unsaved changes, and
    %            maybe even if the user presses cancel, the form will
    %            change the state of the AppClosingMessage to canceled
    %
    % see mediator pattern https://en.wikipedia.org/wiki/Mediator_pattern
    % see Publish–subscribe pattern https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern
    
    properties (Access=protected)
        App mvvm.IApp = mvvm.App.empty();
        Listeners containers.Map;
    end
    
    methods
        function this = MessagingMediator(app)
            this.App = app;
            this.Listeners = containers.Map();
        end
        
        function listener = register(this, messageId, messageHandler)
            listener = mvvm.MessageListener(this, messageId, messageHandler);
            
            if this.Listeners.isKey(messageId)
                this.Listeners(messageId) = [this.Listeners(messageId), {listener}];
            else
                this.Listeners(messageId) = {listener};
            end
        end
        
        function unregister(this, messageId, listener)
            if ~this.Listeners.isKey(messageId)
                return;
            end
            handlers = this.Listeners(messageId);
            
            % find current message handler function in the listeners array
            mask = cellfun(@(ml) ~isequal(ml, listener), handlers);
            
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
                cellfun(@(listener) listener.fire(message), msgListenesrs);
            end
        end
        
        function delete(this)
            this.clear();
            this.Listeners = containers.Map.empty();
        end
        
        function clear(this)
            allMessageIds = this.Listeners.keys();
            for i = 1:numel(allMessageIds)
                messageId = allMessageIds{i};
                handlers = this.Listeners(messageId);
                
                cellfun(@delete, handlers);
            end
            
            this.Listeners.remove(allMessageIds);
        end
        
    end
end

